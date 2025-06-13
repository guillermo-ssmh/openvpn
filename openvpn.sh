#!/bin/bash

podman rm -f openvpn-as 

podman run -d \
  --name=openvpn-as --device /dev/net/tun \
  --cap-add=MKNOD --cap-add=NET_ADMIN \
  -p 944:944 -p 4344:4344 -p 1195:1195/udp \
  -v /opt/openvpn/data:/openvpn \
  --restart=unless-stopped \
  --hostname=gssmh.ddns.net \
  openvpn/openvpn-as
  
podman exec openvpn 'sacli --user "openvpn" --new_pass "R00tu53r" SetLocalPassword'
podman exec openvpn 'sacli --key "admin_ui.https.port" --value "944" ConfigPut' 
podman exec openvpn 'sacli --key "cs.https.port" --value "944" ConfigPut' 
podman exec openvpn 'sacli --key "vpn.daemon.0.listen.port" --value "1195 ConfigPut' 
podman exec openvpn 'sacli --key "vpn.daemon.0.proto"       --value "udp" ConfigPut' 
podman exec openvpn 'sacli --key "vpn.daemon.1.listen.port" --value "4344 ConfigPut' 
podman exec openvpn 'sacli --key "vpn.daemon.1.proto"       --value "tcp" ConfigPut' 
podman exec openvpn 'sacli start' 
