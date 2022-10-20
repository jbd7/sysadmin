#!/bin/bash
## FORKED FROM from https://github.com/techarkit/CPU_Utilization_Script on 221019
## Collect Real Time CPU Usage DATE: 12th July 2017 Author: Ankam Ravi Kumar
## 2016 is the number of 5min blocks into 1 week, so as to truncate the file when on a cron with a 5min frequency

## Where to send alerts
EMAILADDRESS=<INSERT_EMAIL_ADDRESS_HERE>

## Threshold in percent above which the 15min average is declared a stress
STRESSLIMIT=150

## Threshold in percent above which the 1min average is declared a spike
SPIKELIMIT=1000

CPU_USAGE=$(cat /proc/loadavg | awk '{print $1 " " $2 " " $3}')
CPU_USAGE_15AVG=$(cat /proc/loadavg | awk '{print $3 * 100}')
CPU_USAGE_01AVG=$(cat /proc/loadavg | awk '{print $1 * 100}')
if [ $CPU_USAGE_15AVG -ge $STRESSLIMIT ]; then
 DATE=$(date "+%F %H:%M:%S")
 CPU_USAGE1="$DATE CPU: $CPU_USAGE"
 echo $(printf "$CPU_USAGE1 \t STRESS") >> /tmp/cpusage.out
 cat /tmp/cpusage.out |tail -5 > /tmp/cpusage.tmp
 echo "" >> /tmp/cpusage.tmp
 echo $(ps auxh --sort=-c | awk 'NR<=5 {printf "ps:  %5s %6d %s\r\n",$3,$2,$11}') >> /tmp/cpusage.tmp
 mail -s "CPU Utilization (Continous stess) of `hostname`" $EMAILADDRESS < /tmp/cpusage.tmp
elif [ $CPU_USAGE_01AVG -ge $SPIKELIMIT ]; then
 DATE=$(date "+%F %H:%M:%S")
 CPU_USAGE1="$DATE CPU: $CPU_USAGE"
 echo $(printf "$CPU_USAGE1 \t SPIKE") >> /tmp/cpusage.out
 cat /tmp/cpusage.out |tail -5 > /tmp/cpusage.tmp
 echo "" >> /tmp/cpusage.tmp
 echo $(ps auxh --sort=-c | awk 'NR<=5 {printf "ps:  %5s %6d %s\r\n",$3,$2,$11}') >> /tmp/cpusage.tmp
 mail -s "CPU Utilization (Spike) of `hostname`" $EMAILADDRESS < /tmp/cpusage.tmp
else
 DATE=$(date "+%F %H:%M:%S")
 CPU_USAGE1="$DATE CPU: $CPU_USAGE"
 echo $(printf "$CPU_USAGE1 \t OK") >> /tmp/cpusage.out
 cat /tmp/cpusage.out |tail -2016 > /tmp/cpusage.tmp
 mv /tmp/cpusage.tmp /tmp/cpusage.out
fi
