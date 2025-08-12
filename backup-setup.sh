#! /bin/bash


podman exec openvpn-as /usr/sbin/sacli ConfigQuery > ./backup/openvpn-as.config-$(date +%F).json

tar --absolute-names -czvf ./backup/openvpn_as_backup_$(date +%F).tar.gz /opt/openvpn/data/etc/db/config.db /opt/openvpn/data/etc/db/config_local.db /opt/openvpn/data/etc/db/certs.db

echo "New files..."
ls -las ./backup/*$(date +%F).*

