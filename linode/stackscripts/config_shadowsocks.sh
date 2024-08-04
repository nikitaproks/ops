#!/bin/bash

# <UDF name="SERVER_PORT" Label="Shadowsocks Server Port" default="25" />
# <UDF name="LOCAL_ADDRESS" Label="Local Address" default="127.0.0.1" />
# <UDF name="LOCAL_PORT" Label="Local Port" default="1080" />
# <UDF name="PASSWORD" Label="Password" />
# <UDF name="METHOD" Label="Method" default="aes-128-gcm" />
# <UDF name="TIMEOUT" Label="Timeout" default="300" />

# Install shadowsocks
sudo apt update
sudo apt install -y curl

curl -L -o /tmp/shadowsocks-rust.tar.xz https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.20.3/shadowsocks-v1.20.3.x86_64-unknown-linux-gnu.tar.xz
sudo tar -xvf /tmp/shadowsocks-rust.tar.xz -C /usr/local/bin

cat >/etc/systemd/system/shadowsocks-rust.service<<EOF
[Unit]
Description=Shadowsocks-Rust Server Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks-rust/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/shadowsocks-rust
touch /etc/shadowsocks-rust/config.json
# Configure shadowsocks
cat >/etc/shadowsocks-rust/config.json<<EOF
{
  "server":"0.0.0.0",
  "server_port":$SERVER_PORT,
  "password":"$PASSWORD",
  "local_port":$LOCAL_PORT,
  "method":"$METHOD",
  "timeout":$TIMEOUT,
  "fast_open": true,
  "reuse_port": true,
  "no_delay": true
}
EOF

cat >/etc/sysctl.conf<<EOF
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=16777216
net.core.wmem_default=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_moderate_rcvbuf=1
}
EOF

# Apply the changes
sudo sysctl -p

# Optimize network settings for performance
sudo ethtool -K eth0 tso off gso off
sudo ethtool -C eth0 rx-usecs 10

#Start shadowsocks 
sudo systemctl enable shadowsocks-rust
sudo systemctl start shadowsocks-rust



