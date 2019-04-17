FROM alpine:3.8
LABEL maintainer="tw@travis.wang"

RUN apk add --no-cache zerotier-one --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing

ADD ./entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]
CMD tail -f /dev/null
