#!/bin/sh

divider() {
    echo "----------------------------------------------"
}

if [ "$APP_SERVER_RANDOM_PASSWORD" = true ]; then
    APP_SERVER_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 16)
fi

if [ "$APP_SERVER_RANDOM_RCON_PASSWORD" = true ]; then
    APP_SERVER_RCON_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 16)
fi

APP_SERVER_NAME=${APP_SERVER_NAME:-"EdgeGamers Dev #$(tr -dc '0-9' </dev/urandom | head -c 3) | Development"}
APP_SERVER_IP=${APP_SERVER_IP:-0.0.0.0}
APP_SERVER_PORT=${APP_SERVER_PORT:-27015}
APP_SERVER_CLIENT_PORT=${APP_SERVER_CLIENT_PORT:-27005}
APP_SERVER_PASSWORD=${APP_SERVER_PASSWORD}
APP_SERVER_RCON_PASSWORD=${APP_SERVER_RCON_PASSWORD}
APP_SERVER_TICKRATE=${APP_SERVER_TICKRATE:-64}
APP_SERVER_RATE=${APP_SERVER_RATE:-128000}
APP_SERVER_MAXPLAYERS=${APP_SERVER_MAXPLAYERS:-24}
APP_SERVER_STEAMTOKEN=${APP_SERVER_STEAMTOKEN}
APP_SERVER_START_MAP=${APP_SERVER_START_MAP:-"$(shuf -n 1 /setup/startmaplist.txt)"}

divider
echo "Environment Variables"
divider
env
divider

set -ex

if [ ! -f "/app/csgo/steam.inf" ]; then
    cp -afs /cache/* /app

    cd /cache

    find . -type f \( -name '*.cfg' -o -name '*.so' -o -name '*.txt' \) -exec cp -af --parents --remove-destination \{\} /app \;

    cd "${OLDPWD}"
fi

# install / update app
steamcmd \
    +@sSteamCmdForcePlatformType linux \
    +login anonymous \
    +force_install_dir /app \
    +app_update 740 \
    +quit

if [ "$APP_SERVER_DEVELOPMENT" = true ]; then
    sed -i 's/ck_map_end "1"/ck_map_end "0"/g' /app/csgo/cfg/sourcemod/surftimer.cfg
    sed -i 's/ck_zoner_flag "m"/ck_zoner_flag "g"/g' /app/csgo/cfg/sourcemod/surftimer.cfg
fi

cp /setup/server.cfg csgo/cfg/server.cfg

cp /setup/databases.cfg csgo/addons/sourcemod/configs/

mkdir -p csgo/addons/sourcemod/configs/maul

cp /setup/maul/*.cfg csgo/addons/sourcemod/configs/maul/

cp /setup/umc_mapcycle.txt csgo/umc_mapcycle.txt

echo "" >csgo/maplist.txt
echo "https://edgm.rs/rules" >csgo/motd.txt

sed -i 's/#!\/bin\/sh/#!\/bin\/bash/g' ./srcds_run
sed -i 's/^\s*Rank/\t\/\/Rank/g' csgo/botprofile.db >/dev/null 2>&1

sed -i "s/{APP_SERVER_NAME}/${APP_SERVER_NAME}/g" csgo/cfg/server.cfg
sed -i "s/{APP_SERVER_RCON_PASSWORD}/${APP_SERVER_RCON_PASSWORD}/g" csgo/cfg/server.cfg
sed -i "s/{APP_SERVER_PASSWORD}/${APP_SERVER_PASSWORD}/g" csgo/cfg/server.cfg
sed -i "s/{APP_SERVER_TICKRATE}/${APP_SERVER_TICKRATE}/g" csgo/cfg/server.cfg
sed -i "s/{APP_SERVER_RATE}/${APP_SERVER_RATE}/g" csgo/cfg/server.cfg
sed -i "s/{APP_SERVER_STEAMTOKEN}/${APP_SERVER_STEAMTOKEN}/g" csgo/cfg/server.cfg

sed -i "s/{APP_SERVER_SURFTIMER_DB_HOST}/${APP_SERVER_SURFTIMER_DB_HOST}/g" csgo/addons/sourcemod/configs/databases.cfg
sed -i "s/{APP_SERVER_SURFTIMER_DB_PORT}/${APP_SERVER_SURFTIMER_DB_PORT}/g" csgo/addons/sourcemod/configs/databases.cfg
sed -i "s/{APP_SERVER_SURFTIMER_DB_NAME}/${APP_SERVER_SURFTIMER_DB_NAME}/g" csgo/addons/sourcemod/configs/databases.cfg

sed -i "s/{APP_MAUL_URL}/${APP_MAUL_URL}/g" csgo/addons/sourcemod/configs/maul/api.cfg
sed -i "s/{APP_MAUL_APIKEY}/${APP_MAUL_APIKEY}/g" csgo/addons/sourcemod/configs/maul/api.cfg
sed -i "s/{APP_MAUL_DEBUG}/${APP_MAUL_DEBUG}/g" csgo/addons/sourcemod/configs/maul/api.cfg
sed -i "s/{APP_MAUL_DIVISION}/${APP_MAUL_DIVISION}/g" csgo/addons/sourcemod/configs/maul/authentication.cfg

rm -f \
    csgo/subscribed_collection_ids.txt \
    csgo/subscribed_file_ids.txt \
    csgo/ugc_collection_cache.txt || true

mc mirror --quiet --overwrite S3/csgo/surf/ /app/csgo/

for file in csgo/maps/*.bsp; do
    x=$(basename "$file".bsp)

    if [ ! -f "csgo/maps/$x.nav" ]; then
        echo "Creating $x.nav ..."

        cp csgo/maps/autonav.nav csgo/maps/"$x".nav
    fi
done

exec ./srcds_run \
    -game csgo \
    -authkey "${APP_SERVER_STEAMAPIKEY}" \
    -autoupdate \
    -console \
    -ip "${APP_SERVER_IP}" \
    -maxplayers_override "${APP_SERVER_MAXPLAYERS}" \
    -net_port_try 1 \
    -nobreakpad \
    -nocrashdialog \
    -nohltv \
    -norestart \
    -port "${APP_SERVER_PORT}" \
    -tickrate "${APP_SERVER_TICKRATE}" \
    -usercon \
    +clientport "${APP_SERVER_CLIENT_PORT}" \
    +game_mode 0 \
    +game_type 0 \
    +host_timer_spin_ms 0 \
    +map "${APP_SERVER_START_MAP}" \
    +sv_setsteamaccount "${APP_SERVER_STEAMTOKEN}"
