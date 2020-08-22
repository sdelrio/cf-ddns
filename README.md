
# Description

Update Cloudflare DNS entries from domains using external IP of the machine

Normaly used to provide DDNS

# Requirements

## Cloudflare DNS entry

You have to create a DNS entry on Cloudflare before this script can update

# Usage

## Environment vars

* `CF_ZONE`: DNS zone name for the domain
* `CF_DNS_RECORDS`: FULL DNS name, splitted by , if several domains
* `CF_TOKEN`: Cloudflare API Token (see below for more info)

## Docker

```
docker run --rm -e CF_ZONE=mydomain.com -e CF_DNS_RECORDS="name1.mydomain.com,name2.mydomain.com" -e CF_TOKEN=1234567890abcdefghijklmnoprstuvwxyz -ti sdelrio/cf-ddns
```

## CLI

```
CF_ZONE=mydomain.com CF_DNS_RECORDS=name1.mydomain.com,name2.mydomain.com CF_TOKEN=1234567890abcdefghijklmnoprstuvwxyz ./cloudflare-ddns-update.sh         
```

# Cloudflare token

Go to <https://dash.cloudflare.com/profile/api-tokens> and create a token with:

* Permissions:
  * ZONE - DNS - Edit

* Zone Resources:
  * Include - Specific zone - example.com

Some free domains like .tk or .gr are not allowed to use this record update on Cloudflare

