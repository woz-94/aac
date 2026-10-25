#!/usr/bin/env bash
set -euo pipefail

: "${AAC_DB_HOST:=db}"
: "${AAC_DB_PORT:=3306}"
: "${AAC_DB_NAME:=aac}"
: "${AAC_DB_USER:=otserver}"
: "${AAC_DB_PASSWORD:=otserver}"
: "${AAC_SERVER_NAME:=OT Server}"
: "${AAC_SERVER_IP:=127.0.0.1}"
: "${AAC_SERVER_LOCATION:=BRA}"
: "${AAC_LOGIN_PORT:=7171}"
: "${AAC_GAME_PORT:=7172}"
: "${AAC_STATUS_PORT:=7173}"
: "${AAC_STATUS_TIMEOUT:=5000}"
: "${AAC_DATA_PACK:=data}"

SERVER_PATH="${MYAAC_SERVER_PATH:-/srv/}"
SERVER_PATH="${SERVER_PATH%/}/"

escape_lua() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

require_uint() {
	local name="$1"
	local value="$2"
	if [[ ! "$value" =~ ^[0-9]+$ ]]; then
		echo "Invalid ${name}: '${value}'. Use only unsigned integer values." >&2
		exit 1
	fi
}

require_uint "AAC_DB_PORT" "$AAC_DB_PORT"
require_uint "AAC_LOGIN_PORT" "$AAC_LOGIN_PORT"
require_uint "AAC_GAME_PORT" "$AAC_GAME_PORT"
require_uint "AAC_STATUS_PORT" "$AAC_STATUS_PORT"
require_uint "AAC_STATUS_TIMEOUT" "$AAC_STATUS_TIMEOUT"

# Minimal server config for MyAAC's status widget and downloads page. Written
# into the datapack copy mounted at SERVER_PATH; only read by MyAAC.
mkdir -p "${SERVER_PATH}${AAC_DATA_PACK}/XML"
cat > "${SERVER_PATH}config.lua" <<EOF
serverName = "$(escape_lua "$AAC_SERVER_NAME")"
ip = "$(escape_lua "$AAC_SERVER_IP")"
loginProtocolPort = ${AAC_LOGIN_PORT}
gameProtocolPort = ${AAC_GAME_PORT}
statusProtocolPort = ${AAC_STATUS_PORT}
statusTimeout = ${AAC_STATUS_TIMEOUT}
worldType = "pvp"
dataPackDirectory = "$(escape_lua "$AAC_DATA_PACK")"
mysqlHost = "$(escape_lua "$AAC_DB_HOST")"
mysqlPort = ${AAC_DB_PORT}
mysqlUser = "$(escape_lua "$AAC_DB_USER")"
mysqlPass = "$(escape_lua "$AAC_DB_PASSWORD")"
mysqlDatabase = "$(escape_lua "$AAC_DB_NAME")"
passwordType = "sha1"
EOF

# Default vocations/groups written only when the datapack does not ship them.
VOCATIONS_PATH="${SERVER_PATH}${AAC_DATA_PACK}/XML/vocations.xml"
if [ ! -s "$VOCATIONS_PATH" ]; then
	cat > "$VOCATIONS_PATH" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<vocations>
	<vocation id="0" name="None" fromvoc="0" />
	<vocation id="1" name="Sorcerer" fromvoc="1" />
	<vocation id="2" name="Druid" fromvoc="2" />
	<vocation id="3" name="Paladin" fromvoc="3" />
	<vocation id="4" name="Knight" fromvoc="4" />
	<vocation id="5" name="Master Sorcerer" fromvoc="1" />
	<vocation id="6" name="Elder Druid" fromvoc="2" />
	<vocation id="7" name="Royal Paladin" fromvoc="3" />
	<vocation id="8" name="Elite Knight" fromvoc="4" />
</vocations>
EOF
fi

GROUPS_PATH="${SERVER_PATH}${AAC_DATA_PACK}/XML/groups.xml"
if [ ! -s "$GROUPS_PATH" ]; then
	cat > "$GROUPS_PATH" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<groups>
	<group id="1" name="player" access="0" maxdepotitems="0" maxvipentries="0" />
	<group id="6" name="god" access="1" maxdepotitems="0" maxvipentries="200" />
</groups>
EOF
fi

php /usr/local/bin/aac-bootstrap.php
chown -R www-data:www-data /var/www/html/config.local.php /var/www/html/system/cache /var/www/html/system/logs /var/www/html/system/php_sessions

exec "$@"
