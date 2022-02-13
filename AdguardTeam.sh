#!/bin/bash
# https://github.com/AdguardTeam/cname-trackers

# This script will install jq (https://stedolan.github.io/jq/) on your system!
# Don't run the the script if you do NOT want this!
which jq | grep -q 'jq'
if [ $? -eq 1 ]; then
	sudo apt-get -y install jq
fi

file=/home/pi/cloaked-trackers.json
sudo wget https://raw.githubusercontent.com/AdguardTeam/cname-trackers/master/script/src/cloaked-trackers.json -O $file

IFS=[,]
while read line; do
	domains=( ${line} )
	for domain in "${domains[@]}"; do 
		if [ ! -z "$domain" ]; then
			regex=(\\.\|^)${domain%.*}\\.${domain##*.}$
			sudo pihole-FTL sqlite3 "/etc/pihole/gravity.db" "insert or ignore into domainlist (type, domain, enabled, comment) values (3, '$regex', 1, 'AdguardTeam CNAME list');"
		fi
	done
done < <(jq --raw-output "map(\"\(.domains)\")|.[]" < /home/pi/cloaked-trackers.json < ${file} | tr -d '[]"')

/usr/local/bin/pihole restartdns reload-lists
