FROM alpine:3.8
LABEL maintainer="tw@travis.wang"

RUN apk add --no-cache zerotier-one --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN echo $'#!/bin/sh\n\
  mkdir -p /var/lib/zerotier-one \n\
  zerotier-one -d\n\
  if [ -n "$NW_ID" ]; then \n\
  sleep 1; zerotier-cli join "${NW_ID}";\n\
  MYID=$(zerotier-cli info | cut -d " " -f 3);\n\
  echo "Join to ${NW_ID}, my ID: ${MYID}"\n\
  while [ -z "$(zerotier-cli listnetworks | grep $NW_ID | grep ACCESS_DENIED)" ]; do echo "wait for connect"; sleep 1 ; done\n\
  if [ -n "$NW_TOKEN" ]; then\n\
  echo "Found ENV: NW_TOKEN, will auto auth myself ..."\n\
  MYURL=https://my.zerotier.com/api/network/${NW_ID}/member/$MYID\n\
  wget --header "Authorization: Bearer ${NW_TOKEN}" "${MYURL}" -q -O /tmp/ztinfo.txt\n\
  sed \'s/"authorized":false/"authorized":true/\' /tmp/ztinfo.txt > /tmp/ztright.txt\n\
  wget --header "Authorization: Bearer ${NW_TOKEN}" --post-data="$(cat /tmp/ztright.txt)" -q -O- "${MYURL}"\n\
  rm /tmp/ztinfo.txt && rm /tmp/ztright.txt\n\
  while [ -z "$(zerotier-cli listnetworks | grep $NW_ID | grep OK)" ]; do echo "wait for auth";sleep 1 ; done\n\
  MYIP=$(zerotier-cli listnetworks | grep $NW_ID |grep -o \'[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\' ) \n\
  echo "Success! IP: ${MYIP}" \n\
  if [ -n "$IFTTT" ]; then wget --header "Content-Type: application/json" --post-data="{\\"value1\\":\\"${MYID}\\",\\"value2\\":\\"${MYIP}\\"}" -q -O- "${IFTTT}";fi \n\
  fi\n\
  fi\n\
  exec "$@"' > /bin/entrypoint.sh && chmod +x /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]
CMD tail -f /dev/null
