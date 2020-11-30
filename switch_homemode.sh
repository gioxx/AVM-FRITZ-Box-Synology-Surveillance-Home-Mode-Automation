#!/bin/bash

######## Personal configuration
SYNO_SS_USER="api_user";
SYNO_SS_PASS="pass";
SYNO_URL="192.168.1.1:5000";
FRITZ_URL='192.168.1.2';

######## Telegram configuration
TELEGRAM=0; #0 = disabled | 1 = enabled (if enabled, You have to fill BOT_TOKEN, CHAT_ID, MSG_SS_ACTIVE and MSG_SS_INACTIVE)
BOT_TOKEN="111111111:AAZZAAZ1zaaz1A0_XXXXXXXXXXXXXXXXXXX";
CHAT_ID="-111111111";
MSG_SS_ACTIVE="Synology Surveillance Activated. I'm recording.";
MSG_SS_INACTIVE="Synology Surveillance Deactivated. I'm not recording anymore.";

######## Arlo configuration
ARLO=0; #0 = disabled | 1 = enabled (if enabled, You have to fill all parameters below)
ARLO_TOKEN="1_2aZ-b34Kfb5QWER-6ScN-XXx0X1xX23XxX_x4x56xxxx7x_X8X9xxxxxxXxxxXx0xX2XXxxXXXXxXXXxxxxx3Xx4xXXxxXX5xxXxxx_XxXxX6xXxX-xXXX67xxx8xx90x1xx23X4-XXxx5XxxXXxXXX6XxXXX7XXXxxx8XXX90Xx"
ARLO_USERID="ABC123-456-78901234"
BASESTATION_deviceId="0AB12C3DE45F6"
BASESTATION_xcloudId="ABCDE-0123-456-789012345"
MSG_ARLO_ACTIVE="Arlo ARMED. Detect movements in the house.";
MSG_ARLO_INACTIVE="Arlo DISARMED. Stop detecting movements in the house.";

######## State file configuration (don't touch anything if not necessary)
STATEFILE='/var/services/homes/api_user/synohomemode.state';
RETRYFILE='/var/services/homes/api_user/synohomemode.retry';
CHECKFRITZ='/usr/local/bin/php70 /var/services/homes/api_user/fritz_activemac.php';

######### Internal variables ############
MACS=$@;
ID="$RANDOM";
COOKIESFILE="$0-cookies-$ID";

###### Functions
function _switchHomemode ()
{
	wget -q --keep-session-cookies --save-cookies $COOKIESFILE -O- "http://${SYNO_URL}//webapi/auth.cgi?api=SYNO.API.Auth&method=Login&version=3&account=${SYNO_SS_USER}&passwd=${SYNO_SS_PASS}&session=SurveillanceStation";
	wget -q --load-cookies $COOKIESFILE -O- "http://${SYNO_URL}//webapi/entry.cgi?api=SYNO.SurveillanceStation.HomeMode&version=1&method=Switch&on=${1}";
	wget -q --load-cookies $COOKIESFILE -O- "http://${SYNO_URL}/webapi/auth.cgi?api=SYNO.API.Auth&method=Logout&version=1";
	rm $COOKIESFILE;
	rm $STATEFILE;
	echo $1 > $STATEFILE;
}

if [ $# -eq 0 ]; then
	echo "MAC address or addresses missing"
	exit 1;
fi

if [ -f $STATEFILE ]; then
	result=$($CHECKFRITZ $FRITZ_URL $MACS);
	if [ $result -eq 1 ] && grep -q false $STATEFILE; then
		_switchHomemode "true";
		if [ $TELEGRAM -eq 1 ]; then
			echo ""; echo "Syno SS Status: INACTIVE | Send updated status to Telegram ...";
			TGRAM_COMMAND="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG_SS_INACTIVE}";
			curl -L "$TGRAM_COMMAND";
			echo "";
		fi
		if [ $ARLO -eq 1 ]; then
			if [ $TELEGRAM -eq 1 ]; then
				echo ""; echo "Disarm Arlo | Send updated status to Telegram ...";
				TGRAM_COMMAND="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG_ARLO_INACTIVE}";
				curl -L "$TGRAM_COMMAND";
			fi
			curl --request POST 'https://my.arlo.com/hmsweb/users/devices/notify/'${BASESTATION_deviceId}'' \
			-H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_2 like Mac OS X) AppleWebKit/604.3.5 (KHTML, like Gecko) Mobile/15B202 NETGEAR/v1 (iOS Vuezone)' \
			-H 'Content-Type: application/json;charset=UTF-8' \
			-H 'DNT: 1' \
			-H 'schemaVersion: 1' \
			-H 'Referer: https://my.arlo.com/' \
			-H 'Authorization: '${ARLO_TOKEN}'' \
			-H 'xcloudId: '${BASESTATION_xcloudId}'' \
			-d '{"from": "'${ARLO_USERID}'_web","to": "'${BASESTATION_deviceId}'","action": "set","resource": "modes","transId": "web!3975ac7b.ebb3a8!1504266382584","publishResponse": true,"properties": {"active": "mode0"}}'
		fi
	elif [ -f $RETRYFILE ]; then
		if [ $result -eq 0 ] && grep -q true $STATEFILE; then
			_switchHomemode "false";
			if [ $TELEGRAM -eq 1 ]; then
				echo ""; echo "Syno SS Status: ACTIVE | Send updated status to Telegram ...";
				TGRAM_COMMAND="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG_SS_ACTIVE}";
				curl -L "$TGRAM_COMMAND";
				echo "";
			fi
			if [ $ARLO -eq 1 ]; then
				if [ $TELEGRAM -eq 1 ]; then
					echo ""; echo "Arm Arlo | Send updated status to Telegram ...";
					TGRAM_COMMAND="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG_ARLO_ACTIVE}";
					curl -L "$TGRAM_COMMAND";
				fi
				curl --request POST 'https://my.arlo.com/hmsweb/users/devices/notify/'${BASESTATION_deviceId}'' \
				-H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_2 like Mac OS X) AppleWebKit/604.3.5 (KHTML, like Gecko) Mobile/15B202 NETGEAR/v1 (iOS Vuezone)' \
				-H 'Content-Type: application/json;charset=UTF-8' \
				-H 'DNT: 1' \
				-H 'schemaVersion: 1' \
				-H 'Referer: https://my.arlo.com/' \
				-H 'Authorization: '${ARLO_TOKEN}'' \
				-H 'xcloudId: '${BASESTATION_xcloudId}'' \
				-d '{"from": "'${ARLO_USERID}'_web","to": "'${BASESTATION_deviceId}'","action": "set","resource": "modes","transId": "web!3975ac7b.ebb3a8!1504266382584","publishResponse": true,"properties": {"active": "mode1"}}'
			fi
			rm $RETRYFILE;
		else
			rm $RETRYFILE;
		fi
        elif [ $result -eq 0 ] && grep -q true $STATEFILE; then
                echo retry > $RETRYFILE;
	fi
else
	echo false > $STATEFILE;
fi
exit 0;
