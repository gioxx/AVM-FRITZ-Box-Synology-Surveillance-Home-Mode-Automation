#!/bin/bash
# Credits: https://shkspr.mobi/blog/2019/02/tado-api-guide-updated-for-2019/
#          https://cameronnokes.com/blog/working-with-json-in-bash-using-jq/

######## Telegram configuration
TELEGRAM=0; #0 = disabled | 1 = enabled (if enabled, You have to fill all parameters below)
BOT_TOKEN="111111111:AAZZAAZ1zaaz1A0_XXXXXXXXXXXXXXXXXXX";
CHAT_ID="-111111111";

######## Tado° configuration
TADOUSER=mario.rossi@contoso.com
TADOPWD=MY-SUPER-SECRET-PASSWORD
MSG_TADO_HOME="Tado switched to Home Mode. Welcome back!";
MSG_TADO_AWAY="Tado switched to Away Mode. See you soon!";

######## State file configuration (don't touch anything if not necessary)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TADOSTATE=${DIR}'/tado.state';
TADORETRY=${DIR}'/tado.retry';

###### Functions
function Debug_getTadoToken () {
	curl -s -o tado.env https://my.tado.com/webapp/env.js > /dev/null
	env=$(more tado.env | grep "clientSecret")
	clientSecret=$(sed -n "s/^.*'\(.*\)'.*$/\1/p" <<< $env)
	rm tado.env
	tadoToken=$(curl -s --request POST 'https://auth.tado.com/oauth/token' -d 'client_id=tado-web-app' -d 'grant_type=password' -d 'scope=home.user' -d 'username='${TADOUSER}'' -d 'password='${TADOPWD}'' -d 'client_secret='${clientSecret}'' | jq '.access_token' | xargs);
	echo $tadoToken;
}

function _getTadoPresence () {
	curl -s -o tado.env https://my.tado.com/webapp/env.js > /dev/null
	env=$(more tado.env | grep "clientSecret")
	clientSecret=$(sed -n "s/^.*'\(.*\)'.*$/\1/p" <<< $env)
	rm tado.env
	tadoToken=$(curl -s --request POST 'https://auth.tado.com/oauth/token' -d 'client_id=tado-web-app' -d 'grant_type=password' -d 'scope=home.user' -d 'username='${TADOUSER}'' -d 'password='${TADOPWD}'' -d 'client_secret='${clientSecret}'' | jq '.access_token' | xargs);
	tadoHomeID=$(curl -s 'https://my.tado.com/api/v1/me' -H 'Authorization: Bearer '${tadoToken}'' | jq '.homeId' | xargs);
	tadoPresence=$(curl -s 'https://my.tado.com/api/v2/homes/'${tadoHomeID}'/state' -H 'Authorization: Bearer '${tadoToken}'' | jq '.presence' | xargs);
	echo $tadoPresence;
}

if [ -f $TADOSTATE ]; then
	result=$(_getTadoPresence);
	if [ $result == "HOME" ] && grep -q AWAY $TADOSTATE; then
		rm $TADOSTATE;
		echo HOME > $TADOSTATE;
		if [ $TELEGRAM -eq 1 ]; then
				echo ""; echo "tado° Home | Send updated status to Telegram ...";
				TGRAM_COMMAND="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG_TADO_HOME}";
				curl -L "$TGRAM_COMMAND";
		fi
	elif [ -f $TADORETRY ]; then
		if [ $result == "AWAY" ] && grep -q HOME $TADOSTATE; then
			rm $TADOSTATE;
			echo AWAY > $TADOSTATE;
			if [ $TELEGRAM -eq 1 ]; then
					echo ""; echo "tado° Away | Send updated status to Telegram ...";
					TGRAM_COMMAND="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG_TADO_AWAY}";
					curl -L "$TGRAM_COMMAND";
			fi
			rm $TADORETRY;
		else
			rm $TADORETRY;
		fi
        elif [ $result == "AWAY" ] && grep -q HOME $TADOSTATE; then
                echo retry > $TADORETRY;
	fi
else
	echo AWAY > $TADOSTATE;
fi
exit 0;
