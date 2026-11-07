#!/bin/sh
# Print the DNS TXT record(s) required for acme.sh's persistent DNS
# validation mode (draft-ietf-acme-dns-persist-01).
#
# Usage:
#   acmesh-dnspersist.sh <server> <account_email> <wildcard> <ca_name> <days> <domain>...
#
# Empty values are passed as "-" by the LuCI view.

set -u

ACME=/usr/lib/acme/client/acme.sh
STATE_DIR=/etc/acme

server="${1:--}"
account_email="${2:--}"
wildcard="${3:-0}"
ca_name="${4:--}"
days="${5:--}"
shift 5 2>/dev/null || true

[ "$server" = "-" ] && server=""
[ "$account_email" = "-" ] && account_email=""
[ "$ca_name" = "-" ] && ca_name=""
[ "$days" = "-" ] && days=""

if [ -z "$server" ]; then
	server="letsencrypt"
fi

export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export NO_TIMESTAMP=1
export ACME_NO_COLOR=1

make_value() {
	_domain="$1"

	set -- --home "$STATE_DIR" --server "$server"
	[ -n "$account_email" ] && set -- "$@" --accountemail "$account_email"
	[ "$wildcard" = "1" ] && set -- "$@" --dns-persist-wildcard
	[ -n "$ca_name" ] && set -- "$@" --dns-persist-ca-name "$ca_name"
	[ -n "$days" ] && set -- "$@" --dns-persist-days "$days"
	set -- "$@" --make-dns-persist-value -d "$_domain"

	"$ACME" "$@"
}

rc=0
for domain in "$@"; do
	# A persist record is always published at the base domain, even for
	# wildcard certificates.
	case "$domain" in
		\*.*) domain="${domain#\*.}" ;;
	esac

	printf '=== %s ===\n' "$domain"
	if ! make_value "$domain" 2>&1; then
		rc=1
	fi
	printf '\n'
done

if [ "$rc" -ne 0 ]; then
	printf 'ERROR: failed to generate one or more TXT record values.\n'
fi

# cgi-io only reports the HTTP result, so always exit successfully and let
# the caller display the generated output or the error text above.
exit 0
