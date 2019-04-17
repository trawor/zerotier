# zerotier
Join zerotier network auto with Docker, I like ZT so much!

This is a very tiny(3~ MB) docker image to join zerotier without auth on web.
So, with this, you can scale up your docker and even any machine cluster programmly.

## Process
1. Alpine install zerotier
2. run ZT service
3. if `NW_ID` env is set, join it
4. if `NW_TOKEN` env is set, auth this peer with ZT api
5. if `IFTTT` env is set, send it a message with peer id and assigned IP

## Usage, simple

- Run as a ZT client only
`docker run -d --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN 
  -v /var/lib/zerotier-one:/var/lib/zerotier-one trawor/zerotier`

ps: if you don't like to buzz the docker host, remove `--net=host`
pps: mount `/var/lib/zerotier-one` to keep the data or you will have always a new join

- Run with ENV (with -e param)

  1. `NW_ID` : the network id you created, listed https://my.zerotier.com/network
  2. `NW_TOKEN` : 'API Access Tokens' in https://my.zerotier.com
  3. `IFTTT` : IFTTT trigger URL, looks like: `https://maker.ifttt.com/trigger/xxxxxxxxxx/with/key/ST-xxxxxxxxxxxxx`

