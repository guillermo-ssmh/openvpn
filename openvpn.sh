docker run -d \
  --name=openvpn-as --device /dev/net/tun \
  --cap-add=MKNOD --cap-add=NET_ADMIN \
  -p 944:943 -p 4344:443 -p 1195:1194/udp \
  -v /opt/openvpn/data:/openvpn \
  --restart=unless-stopped \
  --hostname=gssmh.ddns.net \
  openvpn/openvpn-as

podman rm -f openvpn-as 

pomdan exec openvpn 'sacli --user "openvpn" --new_pass "R00tu53r" SetLocalPassword'


pomdan exec openvpn 'sacli --key "admin_ui.https.port" --value "944" ConfigPut' 
pomdan exec openvpn 'sacli --key "cs.https.port" --value "944" ConfigPut' 
pomdan exec openvpn 'sacli --key "vpn.daemon.0.listen.port" --value "4344" ConfigPut' 
pomdan exec openvpn 'sacli --key "vpn.server.daemon.tcp.port" --value "4344" ConfigPut' 
pomdan exec openvpn 'sacli start' 
