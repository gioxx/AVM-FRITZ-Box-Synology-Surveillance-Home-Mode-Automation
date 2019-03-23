#!/bin/bash

# Synology PHP Module Enabler for PHP7
# GSolone (2019) - https://gioxx.org

# Check if PHP7 exist
# Credits: https://stackoverflow.com/questions/24398242/check-if-service-exists-in-bash-centos-and-ubuntu
if synoservicecfg --list | grep -Fq PHP7; then
	# Copy modules if they not exist
	if [ ! -f "/usr/local/lib/php70/modules/openssl.so" ]; then
		echo "openssl.so not found, copy from /volume1/@appstore/PHP7.0/usr/local/lib/php70/modules"
		cp /volume1/@appstore/PHP7.0/usr/local/lib/php70/modules/openssl.so /usr/local/lib/php70/modules/
	else
		echo "/usr/local/lib/php70/modules/openssl.so found, skip."
	fi
	if [ ! -f "/usr/local/lib/php70/modules/curl.so" ]; then
		echo "curl.so not found, copy from /volume1/@appstore/PHP7.0/usr/local/lib/php70/modules"
		cp /volume1/@appstore/PHP7.0/usr/local/lib/php70/modules/curl.so /usr/local/lib/php70/modules/
	else
		echo "/usr/local/lib/php70/modules/curl.so found, skip."
	fi
	if [ ! -f "/usr/local/lib/php70/modules/soap.so" ]; then
		echo "soap.so not found, copy from /volume1/@appstore/PHP7.0/usr/local/lib/php70/modules"
		cp /volume1/@appstore/PHP7.0/usr/local/lib/php70/modules/soap.so /usr/local/lib/php70/modules/
	else
		echo "/usr/local/lib/php70/modules/soap.so found, skip."
	fi

	# Check if PHP.ini already load modules (if KO, inject extension=$MODULE)
	# Credits: https://stackoverflow.com/questions/4749330/how-to-test-if-string-exists-in-file-with-bash
	if grep -Fxq "extension=openssl.so" /usr/local/etc/php70/php.ini
	then
		# Modules found
		echo "Modules already exist in PHP.ini, abort."
		exit 1;
	else
		# Modules not found
		# Credits: https://stackoverflow.com/questions/15559359/insert-line-after-first-match-using-sed
		echo "Modules not found in PHP.ini, I modify the file."
		sed -i '/extension_dir = "\/usr\/local\/lib\/php70\/modules"/a extension=openssl.so' /usr/local/etc/php70/php.ini
		sed -i '/extension_dir = "\/usr\/local\/lib\/php70\/modules"/a extension=curl.so' /usr/local/etc/php70/php.ini
		sed -i '/extension_dir = "\/usr\/local\/lib\/php70\/modules"/a extension=soap.so' /usr/local/etc/php70/php.ini
		echo "Done. Now I reboot PHP7"
		# Restart PHP7
		# Credits: https://diktiosolutions.eu/en/synology/synology-dsm-6-terminal-service-control-en/
		synoservicecfg -restart pkgctl-PHP7.0
		echo "Done. Please verify."
	fi

	exit 0;
else
	echo "PHP7 not found, abort."
fi
