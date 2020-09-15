#!/bin/bash

# Update Cloudflare DNS entries from domains using external IP of the machine
# Normaly used to provide DDNS
#
# CF_ZONE: DNS zone name for the domain, example.com
# CF_DNS_RECORDS: FULL DNS name, splitted by , if several domains
# CF_TOKEN: API Token with
#
#   Permissions:
#   * ZONE - DNS - Edit
#      
#   Zone Resources:
#   * Include - Specific zone - example.com
#

# ENVIRONMENT VARIABLES

# Cloudflare zone is the zone which holds the record
[ -z $CF_ZONE ] && echo "[error] CF_ZONE not defined." && exit 1
# Remove trailing  newline
CF_ZONE=${CF_ZONE%$'\n'}

# DNS record is the A record which will be updated
[ -z $CF_DNS_RECORDS ] && echo "[error] CF_DNS_RECORDS not defined." && exit 1
CF_CNDS_RECORDS=${DNS_RECORDS%$'\n'}

# Cloudflare authentication API Token
[ -z $CF_TOKEN ] && echo "[error] CF_TOKEN not defined." && exit 1
CF_TOKEN=${CF_TOKEN%$'\n'}

# FUNCTIONS

get_ip() {
  # Get external IP address
  curl -s -X GET https://checkip.amazonaws.com || { echo "[ERROR] could not get result from checkip.amazonaws.com" && exit -1; }
}

update_ip_dns() {
  ip=$1
  dnsrecord=$2

  echo "[DEBUG] Getting Zoneid for $CF_ZONE"
  zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$CF_ZONE&status=active" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

  echo "[DEBUG] Zoneid for $CF_ZONE is $zoneid"

  # Get the DNS record id
  dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

  echo "[DEBUG] DNS Record ID for $dnsrecord is $dnsrecordid"

  # Update the DNS A record
  curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq
}

domain_changed_ip() {
  myip=$1
  mydomain=$(echo $2 | sed 's/^*/anything/')
#  mydomain=$2

  myhostname=$(host -N 1 $mydomain lex.ns.cloudflare.com | grep "has address" )
  if echo $myhostname | grep "$myip"; then
    echo "[DEBUG] $2 already set to $myip; no changes needed"
  else
    echo "[DEBUG] Domain: $2: "
    echo "[DEBUG] Domain resolved: $myhostname"
    echo "[DEBUG] $2 currently not set to $myip; changes needed"
    update_ip_dns $myip $2
  fi
  
}

# MAIN

ip=$(get_ip)
[ -z $ip ] && echo "[ERROR] Got empty external IP address" && exit -1

echo "[INFO] Current IP: $ip"
echo -n "[INFO] DNS names detected: "
echo $CF_DNS_RECORDS |tr , ' '

for d in $(echo $CF_DNS_RECORDS | tr , ' '); do
  echo "[INFO] Check domain $d for IP $ip"
  domain_changed_ip $ip $d
done

