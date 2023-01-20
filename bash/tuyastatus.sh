#!/bin/sh

# tuyastatus.sh
# Description: Bash script to create a custom automation with Tuya IoT devices
# Inspired from https://github.com/jasonacox/tuyapower

# Use case: I wanted to access directly the values of my Tuya devices (Anccy smart plugs), that have the original firmware, that I could only see in the Tuya 'Smart Life' app, and play with them in a simple way, without relying on a third party library or HASS. 

# Step 1: Get credentials for a Tuya developer account on iot.tuya.com. Optionally, follow instructions from https://github.com/jasonacox/tuyapower
# Step 2: Add IoT devices to the tuya.com account, doable via scanning a QR code with the Smart Life app. Pay attention to which region your devices belong to, the classification by Tuya is not standard. Read device IDs on the dashboard of tuya.com
# Step 3: Edit credentials and device ID below, add/remove devices, replace the Logtail section with your log collector or other destination 
# Step 4: Schedule script 

# Created in 2023 by https://github.com/jbd7/


#####
##### Your own Tuya credentials and device ID (get them from iot.tuya.com), and Logtail source token
#####


ClientID="<TUYA CLIENTID HERE>"
ClientSecret="<TUYA SECRET HERE>"
URL12345="/v1.0/iot-03/devices/<DEVICE ID HERE>/status"
URL56789="/v1.0/iot-03/devices/<DEVICE ID HERE>/status"
LogtailSourceToken="<LOGTAIL SOURCE TOKEN HERE>"


#####
##### No need to edit anything below if you use Logtail.com. If you don't, replace the Logtail section 
#####


# Set to true or false to (de)activate debugging output
debug=false


# Declare constants
BaseUrl="https://openapi.tuyaeu.com"
URL="/v1.0/token?grant_type=1"
EmptyBodyEncoded="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
tuyatime=`(date +%s)`
tuyatime=$tuyatime"000"
if ($debug) then echo Tuyatime is now $tuyatime; fi;

#####
##### Get Tuya Access Token, following signature instructions from https://developer.tuya.com/en/docs/iot/new-singnature?id=Kbw0q34cs2e5g
#####

StringToSign="${ClientID}${tuyatime}GET\n${EmptyBodyEncoded}\n\n${URL}"
if ($debug) then echo StringToSign is now $StringToSign; fi;

AccessTokenSign=$(printf $StringToSign | openssl sha256 -hmac  "$ClientSecret" | tr '[:lower:]' '[:upper:]' |sed "s/.* //g")
if ($debug) then echo AccessTokenSign is now $AccessTokenSign; fi;

AccessTokenResponse=$(curl -sSLkX GET "$BaseUrl$URL" -H "sign_method: HMAC-SHA256" -H "client_id: $ClientID" -H "t: $tuyatime"  -H "mode: cors" -H "Content-Type: application/json" -H "sign: $AccessTokenSign")
if ($debug) then echo AccessTokenResponse is now $AccessTokenResponse; fi;

AccessToken=$(echo $AccessTokenResponse | sed "s/.*\"access_token\":\"//g"  |sed "s/\".*//g")
if ($debug) then echo Access token is now $AccessToken; fi;

#####
##### Get Tuya devices status 
#####

StringToSign12345="${ClientID}${AccessToken}${tuyatime}GET\n${EmptyBodyEncoded}\n\n${URL12345}"
StringToSign56789="${ClientID}${AccessToken}${tuyatime}GET\n${EmptyBodyEncoded}\n\n${URL56789}"
if ($debug) then echo StringToSign is now $StringToSign12345; fi;

RequestSign12345=$(printf $StringToSign12345 | openssl sha256 -hmac  "$ClientSecret" | tr '[:lower:]' '[:upper:]' |sed "s/.* //g")
RequestSign56789=$(printf $StringToSign56789 | openssl sha256 -hmac  "$ClientSecret" | tr '[:lower:]' '[:upper:]' |sed "s/.* //g")
if ($debug) then echo RequestSign is now $RequestSign12345; fi;

RequestResponse12345=$(curl -sSLkX GET "$BaseUrl$URL12345" -H "sign_method: HMAC-SHA256" -H "client_id: $ClientID" -H "t: $tuyatime"  -H "mode: cors" -H "Content-Type: application/json" -H "sign: $RequestSign12345" -H "access_token: $AccessToken")
RequestResponse56789=$(curl -sSLkX GET "$BaseUrl$URL56789" -H "sign_method: HMAC-SHA256" -H "client_id: $ClientID" -H "t: $tuyatime"  -H "mode: cors" -H "Content-Type: application/json" -H "sign: $RequestSign56789" -H "access_token: $AccessToken")
if ($debug) then echo RequestResponse is now $RequestResponse12345; fi;


#####
##### Submit payload to Logtail
#####

# Function to transform the Tuya response array into a cleaner JSON set of key:value pairs
transform_json() {
    input=$1
    echo $input | jq -c '{result: (.result | map({(.code): .value}) | add), success, t, tid}'
}

RequestResponse12345=$(transform_json "$RequestResponse12345")
RequestResponse56789=$(transform_json "$RequestResponse56789")
if ($debug) then echo Transformed json is now: $RequestResponse12345; fi;

curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $LogtailSourceToken" -d '{"dt":"'"$(date -u +'%Y-%m-%d %T UTC')"'","message":"Tuya device 1", "device_id":"Custom value, this is a device ID", "response":'$RequestResponse12345'}' -k https://in.logtail.com
curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $LogtailSourceToken" -d '{"dt":"'"$(date -u +'%Y-%m-%d %T UTC')"'","message":"Tuya device 2", "device_id":"Custom value, this is another device ID", "response":'$RequestResponse56789'}' -k https://in.logtail.com
