#!/bin/bash

podman ps -a

podman stop openvpn-as

podman rm openvpn-as

podman run -d \
  --name=openvpn-as --device /dev/net/tun \
  --cap-add=MKNOD --cap-add=NET_ADMIN \
  -p 944:944 -p 4344:4344 -p 1195:1195/udp \
  -v /opt/openvpn/data:/openvpn \
  --restart=unless-stopped \
  --hostname=gssmh.ddns.net \
  openvpn/openvpn-as

sleep 3

podman exec openvpn-as /usr/sbin/sacli --user "openvpn" --new_pass "R00tu53r"   SetLocalPassword
podman exec openvpn-as /usr/sbin/sacli --key "admin_ui.https.port"        --value "944"  ConfigPut
podman exec openvpn-as /usr/sbin/sacli --key "cs.https.port"              --value "944"  ConfigPut
podman exec openvpn-as /usr/sbin/sacli --key "vpn.server.daemon.tcp.port" --value "4334" ConfigPut 
podman exec openvpn-as /usr/sbin/sacli --key "vpn.server.daemon.udp.port" --value "1195" ConfigPut 
podman exec openvpn-as /usr/sbin/sacli --key "vpn.daemon.0.listen.port"   --value "1195" ConfigPut 
podman exec openvpn-as /usr/sbin/sacli --key "vpn.daemon.0.proto"         --value "udp"  ConfigPut 
podman exec openvpn-as /usr/sbin/sacli --key "vpn.daemon.1.listen.port"   --value "4344" ConfigPut 
podman exec openvpn-as /usr/sbin/sacli --key "vpn.daemon.1.proto"         --value "tcp"  ConfigPut
podman exec openvpn-as /usr/sbin/sacli start

podman ps -l

sudo firewall-cmd --permanent --add-port=944/tcp
sudo firewall-cmd --permanent --add-port=4334/tcp
sudo firewall-cmd --permanent --add-port=1195/udp

sudo firewall-cmd --reload
sudo firewall-cmd --list-all

exit 0
