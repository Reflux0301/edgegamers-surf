# syntax=docker/dockerfile:1.3
FROM registry.edgegamers.io/valve/tools/base:master as base

ARG CI_DEPLOY_USER
ARG CI_DEPLOY_PASSWORD
ARG CI_SERVER_HOST
ARG CI_COMMIT_REF_NAME

SHELL ["/bin/bash", "-c"]

COPY addons/sourcemod/scripting /tmp/scripting

RUN set -e ; \
    git config --global url."https://${CI_DEPLOY_USER}:${CI_DEPLOY_PASSWORD}@${CI_SERVER_HOST}/".insteadOf "git@gitlab.edgegamers.io:" ; \
    echo -e '#!/bin/bash\n$COMPILER_PATH/spcomp "$@" -v2 -O2' > /usr/bin/spcompo ; \
    chmod +x /usr/bin/spcompo

# SteamWorks
RUN set -ex; \
    mkdir plugins/steamworks \
    && cd plugins/steamworks \
    && curl -sL "https://github.com/hexa-core-eu/SteamWorks/releases/download/v1.2.3/package-linux.zip" -o ./plugin.zip \
    && unzip plugin.zip \
    && cd build/package/addons/sourcemod \
    && mv extensions/SteamWorks.ext.so $SOURCEMOD_PATH/extensions/ \
    && rm -rf /tmp/plugins/*

# SteamWorks
RUN set -ex; \
    mkdir plugins/steamworks-inc \
    && cd plugins/steamworks-inc \
    && git clone "https://github.com/KyleSanderson/SteamWorks" . \
    && cd Pawn/includes \
    && mv SteamWorks.inc $COMPILER_PATH/include/ \
    && rm -rf /tmp/plugins/*

# Autoexecconfigs
# https://github.com/Impact123/AutoExecConfig
RUN mkdir plugins/AutoExecConfig \
    && cd plugins/AutoExecConfig \
    && curl -L "https://github.com/Impact123/AutoExecConfig/raw/development/autoexecconfig.inc" -o ./autoexecconfig.inc \
    && mv autoexecconfig.inc $COMPILER_PATH/include/ \
    && rm -rf /tmp/plugins/*

# DHooks w/ detour support
# https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589
RUN set -ex; \
    mkdir plugins/dhooks \
    && cd plugins/dhooks \
    && curl -L "https://forums.alliedmods.net/attachment.php?attachmentid=190123&d=1625050030" -o ./dhooks.zip \
    && unzip dhooks.zip \
    && rm -rf dhooks.zip \
    && rsync -av . $APP_PATH/ \
    && touch $SOURCEMOD_PATH/extensions/dhooks.autoload \
    && rm -rf /tmp/plugins/*

# ShowPlayerClips
# https://github.com/GAMMACASE/ShowPlayerClips
RUN set -ex; \
    mkdir plugins/show-player-clips \
    && cd plugins/show-player-clips \
    && git clone "https://github.com/GAMMACASE/ShowPlayerClips.git" . \
    && rm -rf .git *.md LICENSE .github \
    && rsync -av . $APP_PATH/ \
    && cd $COMPILER_PATH \
    && $COMPILER_PATH/spcomp -O2 -v2 showplayerclips.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# SMJansson
# https://github.com/thraaawn/SMJansson
RUN set -ex; \
    mkdir plugins/smjansson \
    && cd plugins/smjansson \
    && git clone "https://github.com/thraaawn/SMJansson.git" . \
    && mv bin/smjansson.ext.so $SOURCEMOD_PATH/extensions/ \
    && cd pawn \
    && rsync -av . $SOURCEMOD_PATH/ \
    && rm -rf /tmp/plugins/*

# sourcemod-discord
# https://github.com/Deathknife/sourcemod-discord
RUN set -ex; \
    mkdir plugins/sourcemod-discord \
    && cd plugins/sourcemod-discord \
    && git clone "https://github.com/Deathknife/sourcemod-discord.git" . \
    && rm -rf .git .gitignore *.md examples \
    && rsync -av . $COMPILER_PATH/ \
    && $COMPILER_PATH/spcomp -O2 -v2 discord_api.sp \
    && mv discord_api.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# ColorVariables
# https://github.com/PremyslTalich/ColorVariables
RUN set -ex; \
    mkdir plugins/colorvariables \
    && cd plugins/colorvariables \
    && git clone "https://github.com/PremyslTalich/ColorVariables.git" . \
    && cd addons/sourcemod/scripting/includes \
    && mv colorvariables.inc $COMPILER_PATH/include/ \
    && rm -rf /tmp/plugins/*

# smlib
# https://github.com/bcserv/smlib
RUN set -ex; \
    mkdir plugins/smlib \
    && cd plugins/smlib \
    && git clone -b transitional_syntax "https://github.com/bcserv/smlib.git" . \
    && rm -rf .git .gitignore .travis.yml *.md \
    && rsync -av . $SOURCEMOD_PATH/ \
    && rm -rf /tmp/plugins/*

# sourcecomms
# https://github.com/sbpp/sourcebans-pp
RUN set -ex; \
    mkdir plugins/sourcecomms \
    && cd plugins/sourcecomms \
    && curl -L "https://raw.githubusercontent.com/sbpp/sourcebans-pp/v1.x/game/addons/sourcemod/scripting/include/sourcecomms.inc" -o ./sourcecomms.inc \
    && mv sourcecomms.inc $COMPILER_PATH/include/ \
    && rm -rf /tmp/plugins/*

# cleaner
# https://github.com/Accelerator74/Cleaner
RUN set -ex; \
    mkdir plugins/cleaner \
    && cd plugins/cleaner \
    && curl -L "https://github.com/Accelerator74/Cleaner/releases/download/build/cleaner-sm1.10-linux-f5a6229.zip" -o ./cleaner.zip \
    && unzip cleaner.zip \
    && cd addons/sourcemod/extensions/ \
    && mv cleaner.ext.2.csgo.so $SOURCEMOD_PATH/extensions/ \
    && mv cleaner.autoload $SOURCEMOD_PATH/extensions/ \
    && rm -rf /tmp/plugins/*

# RNGFix
# https://forums.alliedmods.net/showthread.php?t=310825
RUN set -ex; \
    mkdir plugins/rngfix \
    && cd plugins/rngfix \
    && git clone "https://github.com/jason-e/rngfix.git" . \
    && cd plugin \
    && rsync -av . $SOURCEMOD_PATH/ \
    && cd $COMPILER_PATH \
    && $COMPILER_PATH/spcomp -O2 -v2 rngfix.sp \
    && mv rngfix.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Movement Unlocker
# https://forums.alliedmods.net/showthread.php?t=255298
RUN set -ex; \
    mkdir plugins/movement-unlocker \
    && cd plugins/movement-unlocker \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=141520&d=1421117043" -o ./plugin.sp \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=141521&d=1495261818" -o ./csgo_movement_unlocker.games.txt \
    && $COMPILER_PATH/spcomp -O2 -v2 plugin.sp \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/csgo_movement_unlocker.smx \
    && mv csgo_movement_unlocker.games.txt $SOURCEMOD_PATH/gamedata/ \
    && rm -rf /tmp/plugins/*

# Normalized-Run-Speed
# https://github.com/sneak-it/Normalized-Run-Speed
RUN set -ex; \
    mkdir plugins/runspeed \
    && cd plugins/runspeed \
    && git clone "https://github.com/sneak-it/Normalized-Run-Speed.git" . \
    && rsync -av gamedata/ $SOURCEMOD_PATH/gamedata/ \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 runspeed.sp \
    && mv runspeed.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Show Triggers Redux
# https://github.com/JoinedSenses/SM-ShowTriggers-Redux
RUN set -ex ; \
    mkdir plugins/show-triggers ; \
    cd plugins/show-triggers ; \
    git clone https://github.com/JoinedSenses/SM-ShowTriggers-Redux.git . ; \
    cd scripting ; \
    sed -i '26,31d;33,34d;38d;42,47d;49,50d;54d;226,231d;233,234d;238d;296,337d;345,358d;380,385d' showtriggers.sp ; \
    sed -i 's/ 6/ 0/g' showtriggers.sp ; \
    sed -i 's/ 9/ 1/g' showtriggers.sp ; \
    sed -i 's/ 10/ 2/g' showtriggers.sp ; \
    sed -i 's/ 11/ 3/g' showtriggers.sp ; \
    sed -i 's/13/4/g' showtriggers.sp ; \
    $COMPILER_PATH/spcomp -O2 -v2 showtriggers.sp ; \
    mv showtriggers.smx $SOURCEMOD_PATH/plugins/showtriggers.smx ; \
    rm -rf /tmp/plugins/*

# Session Flags
# https://forums.alliedmods.net/showthread.php?p=2191575
RUN set -ex; \
    mkdir plugins/session-flags \
    && cd plugins/session-flags \
    && curl "http://ddhoward.com/sourcemod/updater/plugins/sessionflags.smx" -o ./plugin.smx \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/sessionflags.smx \
    && rm -rf /tmp/plugins/*

# EdgeGamers Utility Plugins
# Currently in use: Statushist, getip, chatads, psay fix, vote kick/ban
RUN set -ex; \
    BRANCH_NAME=${CI_COMMIT_REF_NAME:-""} \
    && if [ "$BRANCH_NAME" != "master" ]; then BRANCH_NAME="dev" ; else BRANCH_NAME="edgmrs";  fi \
    && mkdir plugins/ego \
    && cd plugins/ego \
    && git clone -b $BRANCH_NAME "git@${CI_SERVER_HOST}:plugins/sourcemod/utilities.git" . \
    && cd scripting \
    && cp includes/*.inc $COMPILER_PATH/include \
    && $COMPILER_PATH/spcomp -O2 -v2 psay_fix.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 statushist.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 BlockWeaponEntitySounds.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 blocksounds.sp \
    && mv -- *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# SurfTimer
# https://github.com/surftimer/Surftimer-Official
RUN set -ex; \
    BRANCH_NAME=${CI_COMMIT_REF_NAME:-""} \
    && if [ "$BRANCH_NAME" != "master" ]; then BRANCH_NAME="dev" ; else BRANCH_NAME="edgmrs";  fi \
    && mkdir plugins/surftimer \
    && cd plugins/surftimer \
    && git clone -b $BRANCH_NAME "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/surftimer.git" . \
    && mv sound maps $APP_PATH/ \
    && rsync -av addons/sourcemod/translations/ $SOURCEMOD_PATH/translations/ \
    && cd addons/sourcemod/scripting \
    && cp include/surftimer.inc $COMPILER_PATH/include \
    && $COMPILER_PATH/spcomp -O2 -v2 SurfTimer.sp \
    && mv SurfTimer.smx $SOURCEMOD_PATH/plugins/ \
    && mkdir -p $SOURCEMOD_PATH/data/replays \
    && rm -rf /tmp/plugins/*

# Advanced Admin
# https://forums.alliedmods.net/showthread.php?p=2438705
RUN set -ex; \
    mkdir plugins/advancedadmin \
    && cd plugins/advancedadmin \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=170987&d=1534436141" -o ./plugin.zip \
    && unzip plugin.zip \
    && rm -rf plugins plugin.zip \
    && cd scripting \
    && sed -i "s/ADMFLAG_KICK,/ADMFLAG_RCON,/g" advadmin.sp \
    && sed -i "s/ADMFLAG_BAN,/ADMFLAG_RCON,/g" advadmin.sp \
    && sed -i "s/ADMFLAG_GENERIC,/ADMFLAG_RCON,/g" advadmin.sp \
    && sed -i "s/ADMFLAG_CHANGEMAP,/ADMFLAG_RCON,/g" advadmin.sp \
    # && sed -i "s/CMD_Spec,			ADMFLAG_RCON/CMD_Spec,			ADMFLAG_KICK/g" advadmin.sp \
    && sed -i "78d" advadmin.sp \
    && sed -i "s/CMD_PlaySound,		ADMFLAG_RCON/CMD_PlaySound,		ADMFLAG_ROOT/g" advadmin.sp \
    && sed -i 's/\"sm_advadmin_announce\",		\"2\"/\"sm_advadmin_announce\",		\"0\"/g' advadmin.sp \
    && spcompo advadmin.sp \
    && mv advadmin.smx $SOURCEMOD_PATH/plugins/ \
    && cd .. \
    && rsync -av . $SOURCEMOD_PATH/ \
    && rm -rf /tmp/plugins/*

# AFK Manager
RUN set -ex; \
    mkdir plugins/afk-manager \
    && cd plugins/afk-manager \
    && curl -s "https://forums.alliedmods.net/attachment.php?attachmentid=170330&d=1530622367" -o ./plugin.sp \
    && curl -s "https://forums.alliedmods.net/attachment.php?attachmentid=168028&d=1516358726" -o ./afk_manager.inc \
    && curl -s "https://forums.alliedmods.net/attachment.php?attachmentid=166646&d=1510967008" -o ./afk_manager.phrases.txt \
    && mv *.inc $COMPILER_PATH/include/ \
    && sed -i "s/g_sPrefix/g_ssPrefix/g" plugin.sp \
    && sed -i "s/ADMFLAG_KICK,/ADMFLAG_RCON,/g" plugin.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 plugin.sp \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/afk_manager4.smx \
    && mv afk_manager.phrases.txt $SOURCEMOD_PATH/translations/ \
    && rm -rf /tmp/plugins/*

# Extra Spawn Points
RUN set -ex; \
    mkdir plugins/esp \
    && cd plugins/esp \
    && git clone "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/extra-spawn-points.git" . \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 ExtraSpawnPoints.sp \
    && mv ExtraSpawnPoints.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Force All Talk
RUN set -ex; \
    mkdir plugins/alltalk \
    && cd plugins/alltalk \
    && curl -s "https://forums.alliedmods.net/attachment.php?attachmentid=165981&d=1507823819" -o ./plugin.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 plugin.sp \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/force_alltalk.smx \
    && rm -rf /tmp/plugins/*

# Ultimate Map Chooser
# https://github.com/Silenci0/UMC
RUN set -ex; \
    mkdir plugins/ultimate-map-chooser \
    && cd plugins/ultimate-map-chooser \
    && git clone -b edgmrs-surftimer "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/ultimate-map-chooser.git" . \
    && rsync -av addons/sourcemod/scripting/include/ $COMPILER_PATH/include/ \
    && rsync -av addons/sourcemod/translations $SOURCEMOD_PATH/ \
    && cd addons/sourcemod/scripting \
    && for file in ./*.sp; do echo "\nCompiling $file..."; $COMPILER_PATH/spcomp -O2 -v2 $file; done \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && cd $SOURCEMOD_PATH/plugins \
    && mv nativevotes.smx disabled/ \
    && bash -c "mv umc-{endvote-warnings,mapcommands,maprate-reweight}.smx disabled/" \
    && bash -c "mv umc-{nativevotes,prefixexclude,timelimits,weight}.smx disabled/" \
    && rm -rf /tmp/plugins/*

# MomSurfFix
# https://github.com/GAMMACASE/MomSurfFix
RUN set -ex; \
    mkdir plugins/momsurffix \
    && cd plugins/momsurffix \
    && git clone "https://github.com/GAMMACASE/MomSurfFix.git" . \
    && cd addons/sourcemod \
    && rsync -av gamedata/ $SOURCEMOD_PATH/gamedata/ \
    && rsync -av scripting/include/ $COMPILER_PATH/include/ \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 momsurffix2.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# PTaH
# https://github.com/komashchenko/PTaH
RUN set -ex; \
    mkdir plugins/ptah \
    && cd plugins/ptah \
    && curl -L "https://ptah.zizt.ru/files/PTaH-V1.1.2-build18-linux.zip" -o ./ptah.zip \
    && unzip ptah.zip \
    && rm -rf ptah.zip \
    && rsync -av . $APP_PATH/ \
    && rm -rf /tmp/plugins/*

# Weapons
# https://github.com/kgns/weapons
RUN set -ex; \
    mkdir plugins/weapons \
    && cd plugins/weapons \
    && git clone "https://github.com/kgns/weapons.git" . \
    && rsync -av addons/sourcemod/configs/weapons/weapons_english.cfg $SOURCEMOD_PATH/configs/weapons/ \
    && rm -rf .git *.md LICENSE cfg addons/sourcemod/configs/weapons addons/sourcemod/translations \
    && rsync -av . $APP_PATH/ \
    && cd $COMPILER_PATH \
    && $COMPILER_PATH/spcomp -O2 -v2 weapons.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Hats Plugin
# https://github.com/Franc1sco/Franug-hats
RUN set -ex; \
    mkdir plugins/franug-hats \
    && cd plugins/franug-hats \
    && curl -L "https://github.com/Franc1sco/Franug-hats/raw/master/plugins/franug_hats.smx" -o ./plugin.smx \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/franug_hats.smx \
    && rm -rf /tmp/plugins/*

# Disable Killfeed
# https://github.com/hlstriker/SMPlugins/raw/master/Plugins/DisableKillFeed
RUN set -ex; \
    mkdir plugins/disable-killfeed \
    && cd plugins/disable-killfeed \
    && curl -L "https://github.com/hlstriker/SMPlugins/raw/master/Plugins/DisableKillFeed/DisableKillFeed.sp" -o ./plugin.sp \
    && $COMPILER_PATH/spcomp plugin.sp \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/DisableKillFeed.smx \
    && rm -rf /tmp/plugins/*

# Block Chat Wheel
RUN mkdir plugins/block-wheel \
    && cd plugins/block-wheel \
    && curl -s "https://forums.alliedmods.net/attachment.php?attachmentid=185363&d=1607045800" -o ./plugin.sp \
    && $COMPILER_PATH/spcomp plugin.sp \
    && mv plugin.smx $SOURCEMOD_PATH/plugins/pingblocker.smx \
    && rm -rf /tmp/plugins/*

# Command-Aliases
# https://github.com/kidfearless/Command-Aliases
RUN set -ex; \
    mkdir plugins/command-aliases \
    && cd plugins/command-aliases \
    && git clone "https://github.com/kidfearless/Command-Aliases.git" . \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 command_alias.sp \
    && mv command_alias.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Chat Commands
RUN set -ex; \
    mkdir plugins/chat-commands \
    && cd plugins/chat-commands \
    && git clone "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/chat-commands.git" . \
    && cd addons/sourcemod/scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 chat-commands-global.sp \
    && mv chat-commands-global.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Welcome Messages
RUN set -ex; \
    mkdir plugins/welcome-messages \
    && cd plugins/welcome-messages \
    && git clone "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/welcome-messages.git" . \
    && cd addons/sourcemod/scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 welcome-messages-global.sp \
    && mv welcome-messages-global.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# sm-ext-socket
# https://github.com/JoinedSenses/sm-ext-socket/tree/v0.2
RUN mkdir plugins/socket \
    && cd plugins/socket \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=83286&d=1299423920" -o ./plugin.zip \
    && curl "https://raw.githubusercontent.com/JoinedSenses/sm-ext-socket/master/scripting/include/socket.inc" -o ./socket.inc \
    && mv socket.inc $COMPILER_PATH/include/ \
    && unzip plugin.zip \
    && rsync -av addons/sourcemod/extensions/socket.ext.so $SOURCEMOD_PATH/extensions/ \
    && rm -rf /tmp/plugins/*

# ServerRedirect
RUN set -ex; \
    mkdir plugins/server-redirect \
    && cd plugins/server-redirect \
    && git clone -b edgmrs "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/server-redirect.git" . \
    && rm -rf LICENSE .git *.md \
    && rsync -av . $APP_PATH/ \
    && cd addons/sourcemod/scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 server_redirect.sp \
    && mv server_redirect.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Bash Anticheat
RUN set -ex; \
    mkdir plugins/bash \
    && cd plugins/bash \
    && git clone -b edgmrs "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/bash2.git" . \
    && rm -rf LICENSE .git *.md \
    && rsync -av include/ $COMPILER_PATH/include/ \
    && sed -i "s/\[JB\]/\[Surf\]/g" bash.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 bash.sp \
    && mv bash.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# BlockSMPlugins
# https://github.com/Bara/BlockSMPlugins
RUN set -ex; \
    mkdir plugins/block-sm-plugins \
    && cd plugins/block-sm-plugins \
    && git clone "https://github.com/Bara/BlockSMPlugins" . \
    && rm -rf README.md .github DHooks .git .gitignore LICENSE \
    && cd PTaH \
    && rm -rf plugins \
    && rsync -av --ignore-existing scripting/include/ $COMPILER_PATH/include/ \
    && rsync -av --ignore-existing translations/ $SOURCEMOD_PATH/translations/ \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 sbp.sp \
    && mv sbp.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# csgo-fix-mapchange-crash-sm
# https://github.com/Ilusion9/csgo-fix-mapchange-crash-sm
RUN mkdir plugins/fix-mapchange-crash \
    && cd plugins/fix-mapchange-crash \
    && git clone "https://github.com/Ilusion9/csgo-fix-mapchange-crash-sm.git" . \
    && rm -rf .git .github *.md \
    && cd scripting \
    && $COMPILER_PATH/spcomp fixcrash_mapchange.sp \
    && mv fixcrash_mapchange.smx $SOURCEMOD_PATH/plugins/disabled/ \
    && rm -rf /tmp/plugins/*

# Block Radio
# https://forums.alliedmods.net/showthread.php?p=1728742
RUN set -ex; \
    mkdir plugins/blockradio \
    && cd plugins/blockradio \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=147627&d=1440199013" -o ./blockradio.sp \
    && sed -i "s/\"cheer\"/\"cheer\", \"go_a\", \"go_b\", \"sorry\", \"needrop\", \"deathcry\", \"playerradio\", \"playerchatwheel\", \"radio\", \"radio1\", \"radio2\", \"radio3\"/g" blockradio.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 blockradio.sp \
    && mv blockradio.smx $SOURCEMOD_PATH/plugins/ \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=126759&d=1381690218" -o ./blockradio.phrases.txt \
    && mv blockradio.phrases.txt $SOURCEMOD_PATH/translations/ \
    && rm -rf /tmp/plugins/*

# Exploit Fixes by Backwards
RUN mkdir plugins/exploit-fixes \
    && cd plugins/exploit-fixes \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=189451&d=1622239750" -o ./ExploitFix_5_28_2021.zip \
    && unzip ExploitFix_5_28_2021.zip \
    && cd ExploitFix_5_28_2021/ \
    && rsync -av gamedata/ $SOURCEMOD_PATH/gamedata/ \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 *.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && cd ../.. \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=186010&d=1609577056" -o ./rcon_exploit_fix.zip \
    && unzip rcon_exploit_fix.zip \
    && cd rcon_exploit_fix/ \
    && rsync -av gamedata/ $SOURCEMOD_PATH/gamedata/ \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 *.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/disabled/ \
    && cd ../.. \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=186009&d=1609576886" -o ./'SendFileFix 3.1.zip' \
    && unzip 'SendFileFix 3.1.zip' \
    && cd 'SendFileFix 3.1'/ \
    && rsync -av gamedata/ $SOURCEMOD_PATH/gamedata/ \
    && cd scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 *.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && cd ../.. \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=180045&d=1583628924" -o ./ServerLagExploitFix_3_7_2020.sp \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=180046&d=1583628924" -o ./LagExploitFix_3_7_2020.txt \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=177142&d=1567397102" -o ./AntiServerCrash_9_1_2019.sp \
    && for file in ./*.sp; do echo "\nCompiling $file..."; $COMPILER_PATH/spcomp -O2 -v2 $file; done \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rsync -av *.txt $SOURCEMOD_PATH/gamedata/ \
    && rm -rf /tmp/plugins/*

# Reputation System
# https://gitlab.edgegamers.io/plugins/sourcemod/counter-strike/edgmrs-review-system
RUN set -ex; \
    mkdir plugins/edgmrs-review-system \
    && cd plugins/edgmrs-review-system \
    && git clone "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/edgmrs-review-system.git" . \
    && cd addons/sourcemod/scripting \
    && $COMPILER_PATH/spcomp -O2 -v2 reputation.sp \
    && mv reputation.smx $SOURCEMOD_PATH/plugins/disabled/ \
    && rm -rf /tmp/plugins/*

# Macro Detection
RUN set -ex; \
    mkdir plugins/macro-detection \
    && cd plugins/macro-detection \
    && git clone "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/macro-detection.git" . \
    && rm -rf .git *.md \
    && cd scripting/ \
    && $COMPILER_PATH/spcomp -O2 -v2 macrodetection.sp \
    && mv macrodetection.smx $SOURCEMOD_PATH/plugins/disabled/ \
    && rm -rf /tmp/plugins/*

# player-paint
RUN set -ex; \
    mkdir plugins/player-paint \
    && cd plugins/player-paint \
    && git clone -b edgmrs "git@${CI_SERVER_HOST}:plugins/sourcemod/counter-strike/player-paint.git" . \
    && rsync -av addons/sourcemod/translations/ $SOURCEMOD_PATH/translations/ \
    && cd addons/sourcemod/scripting/ \
    && $COMPILER_PATH/spcomp -O2 -v2 player-paint.sp \
    && mv player-paint.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Call Admin Discord
#RUN set -ex; \
#    mkdir plugins/calladmin \
#    && cd plugins/calladmin \
#    && mv /tmp/scripting/discord-calladmin.sp . \
#    && $COMPILER_PATH/spcomp -O2 -v2 discord-calladmin.sp \
#    && mv discord-calladmin.smx $SOURCEMOD_PATH/plugins/ \
#    && rm -rf /tmp/plugins/*

# No Blood
# https://forums.alliedmods.net/attachment.php?attachmentid=154825&d=1463842189
RUN set -ex; \
    mkdir plugins/noblood \
    && cd plugins/noblood \
    && curl "https://forums.alliedmods.net/attachment.php?attachmentid=154825&d=1463842189" -o ./noblood.sp \
    && $COMPILER_PATH/spcomp -O2 -v2 noblood.sp \
    && mv noblood.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

# Server Specialist Elevated Perms
# Non-master (dev server) only
RUN set -ex; \
    BRANCH_NAME=${CI_COMMIT_REF_NAME:-""} \
    && if [ "$BRANCH_NAME" != "master" ]; then \
    mkdir plugins/dev_giveperms \
    && cd plugins/dev_giveperms \
    && mv /tmp/scripting/dev_giveperms.sp . \
    && spcompo *.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/* \
    ; fi

# Set/GetPos Command
# Non-master (dev server) only
RUN set -ex; \
    BRANCH_NAME=${CI_COMMIT_REF_NAME:-""} \
    && if [ "$BRANCH_NAME" != "master" ]; then \
    mkdir plugins/setpos \
    && cd plugins/setpos \
    && mv /tmp/scripting/setpos.sp . \
    && mv /tmp/scripting/getpos.sp . \
    && spcompo getpos.sp \
    && spcompo setpos.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/* \
    ; fi

# Night vision
RUN set -ex; \
    mkdir plugins/nightvision \
    && cd plugins/nightvision \
    && curl -L "https://github.com/GAMMACASE/NightVision/releases/download/1.0.1/nightvision_1.0.1.zip" -o ./nightvision_1.0.1.zip \
    && unzip nightvision_1.0.1.zip \
    && rsync -av . $APP_PATH/ \
    && cd addons/sourcemod/scripting \
    && $COMPILER_PATH/spcomp *.sp \
    && mv *.smx $SOURCEMOD_PATH/plugins/ \
    && rm -rf /tmp/plugins/*

FROM registry.edgegamers.io/valve/tools/steamcmd:alpine

COPY --chown=steam:steam --from=base /tmp/app /app/csgo

COPY --chown=steam:steam addons /app/csgo/addons
COPY --chown=steam:steam cfg /app/csgo/cfg
COPY --chown=steam:steam setup /setup

COPY --chmod=0555 docker-entrypoint.sh /docker-entrypoint.sh

RUN install -d -o steam -g steam /app/csgo/maps

USER steam

WORKDIR /app

VOLUME [ "/app" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
