#!/bin/bash

# <UDF name="SERVER_PORT" Label="Shadowsocks Server Port" default="25" />
# <UDF name="LOCAL_ADDRESS" Label="Local Address" default="127.0.0.1" />
# <UDF name="LOCAL_PORT" Label="Local Port" default="1080" />
# <UDF name="PASSWORD" Label="Password" />
# <UDF name="METHOD" Label="Method" default="aes-256-cfb" />
# <UDF name="TIMEOUT" Label="Timeout" default="300" />

# Install shadowsocks
sudo apt-get update
apt install shadowsocks-libev  -y
systemctl enable shadowsocks-libev


# Configure shadowsocks
cat >/etc/shadowsocks-libev/config.json<<EOF
{
  "server":"0.0.0.0",
  "server_port":$SERVER_PORT,
  "password":"$PASSWORD",
  "local_port":$LOCAL_PORT,
  "method":"$METHOD",
  "timeout":$TIMEOUT
}
EOF

#Start shadowsocks 
systemctl stop shadowsocks-libev
systemctl start shadowsocks-libev

