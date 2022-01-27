#!/bin/sh

# Source : https://github.com/Paul-Reed/cloudflare-ufw
# Script to add IPs of remote monitors (BetterUptime, UptimeRobot, OVH system health) to ufw

# Retrieve Cloudflare IPs
curl -s https://www.cloudflare.com/ips-v4 -o /tmp/monitoring_ips/ips_cloudflare
echo "" >> /tmp/monitoring_ips/ips_cloudflare
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/monitoring_ips/ips_cloudflare

# Allow all traffic from Cloudflare IPs (no ports restriction)
for cfip in `cat /tmp/monitoring_ips/ips_cloudflare`; do ufw allow proto tcp from $cfip comment 'Cloudflare IP'; done


# UptimeRobot IPs
curl -s https://uptimerobot.com/inc/files/ips/IPv4.txt -o /tmp/monitoring_ips/ips_uptimerobot
echo "" >> /tmp/monitoring_ips/ips_uptimerobot
curl -s https://uptimerobot.com/inc/files/ips/IPv6.txt >> /tmp/monitoring_ips/ips_uptimerobot
# Removing carriage return as file was compiled on Windows
sed -i 's/\r//' /tmp/monitoring_ips/ips_uptimerobot

for cfip in `cat /tmp/monitoring_ips/ips_uptimerobot`; do ufw allow proto tcp from $cfip comment 'UptimeRobot IP'; done

# BetterUptime IPs
curl -s https://betteruptime.com/ips.txt -o /tmp/monitoring_ips/ips_betteruptime
for cfip in `cat /tmp/monitoring_ips/ips_betteruptime`; do ufw allow proto tcp from $cfip comment 'BetterUptime IP'; done

# OVH IPs IPs, no txt file as of 220126 but https://docs.ovh.com/fr/dedicated/monitoring-ip-ovh/
echo "37.187.231.251
216.144.250.150
151.80.231.247
213.186.33.13
213.186.50.98
92.222.184.0/24
92.222.185.0/24
92.222.186.0/24
167.114.37.0/24
149.202.34.1/32
vps.first.3bytes.250
vps.first.3bytes.251" >> /tmp/monitoring_ips/ips_ovh
for cfip in `cat /tmp/monitoring_ips/ips_ovh`; do ufw allow proto tcp from $cfip comment 'OVH IP'; done


ufw reload > /dev/null


# OTHER EXAMPLE RULES
# Retrict to port 80
#for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 80 comment 'Cloudflare IP'; done

# Restrict to port 443
#for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 443 comment 'Cloudflare IP'; done

# Restrict to ports 80 & 443
#for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 80,443 comment 'Cloudflare IP'; done
