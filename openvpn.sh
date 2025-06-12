docker run -d \
  --name=openvpn-as --device /dev/net/tun \
  --cap-add=MKNOD --cap-add=NET_ADMIN \
  -p 944:943 -p 4344:443 -p 1195:1194/udp \
  -v /opt/openvpn/data:/openvpn \
  --restart=unless-stopped \
  --hostname=openvpn-system01.local \
  openvpn/openvpn-as

podman rm -f openvpn-as 

pomdan exec openvpn 'sacli --user "openvpn" --new_pass "R00tu53r" SetLocalPassword'


