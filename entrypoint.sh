#!/bin/sh
mkdir -p /var/lib/zerotier-one
zerotier-one -d

if [ -n "$NW_ID" ]; then
    sleep 1; 
    MYID=$(zerotier-cli info | cut -d " " -f 3);

    if [ -z "$(zerotier-cli listnetworks | grep $NW_ID)" ]; then
        zerotier-cli join "${NW_ID}";
        echo "Join to ${NW_ID}, my ID: ${MYID}"
        while [ -z "$(zerotier-cli listnetworks | grep $NW_ID | grep ACCESS_DENIED)" ]; do echo "wait for connect"; sleep 1 ; done
    fi
    
    if [ -n "$NW_TOKEN" ]; then
      if [ -n "$(zerotier-cli listnetworks | grep $NW_ID | grep ACCESS_DENIED)" ]; then
        echo "Found ENV: NW_TOKEN, will auto auth myself ..."
        MYURL=https://my.zerotier.com/api/network/${NW_ID}/member/$MYID
        wget --header "Authorization: Bearer ${NW_TOKEN}" "${MYURL}" -q -O /tmp/ztinfo.txt
        sed 's/"authorized":false/"authorized":true/' /tmp/ztinfo.txt > /tmp/ztright.txt
        wget --header "Authorization: Bearer ${NW_TOKEN}" --post-data="$(cat /tmp/ztright.txt)" -q -O- "${MYURL}"
        rm /tmp/ztinfo.txt && rm /tmp/ztright.txt
      fi
    fi

    while [ -z "$(zerotier-cli listnetworks | grep $NW_ID | grep OK)" ]; do echo "wait for auth";sleep 1 ; done
    MYIP=$(zerotier-cli listnetworks | grep $NW_ID |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' )
    echo "Success! IP: ${MYIP}"

    if [ -n "$IFTTT" ]; then wget --header "Content-Type: application/json" --post-data="{\\"value1\\":\\"${MYID}\\",\\"value2\\":\\"${MYIP}\\"}" -q -O- "${IFTTT}";fi
fi
exec "$@"