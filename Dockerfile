FROM alpine:3.12
RUN apk add --no-cache curl jq bash bind-tools
COPY cloudflare-ddns-update.sh /cloudflare-ddns-update.sh
CMD ["/cloudflare-ddns-update.sh"]

