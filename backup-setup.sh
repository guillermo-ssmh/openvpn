#! /bin/bash


podman exec openvpn-as /usr/sbin/sacli ConfigQuery > openvpn-as.config-$(date +%F).json

tar czvf ./backup/openvpn_as_backup_$(date +%F).tar.gz ./data/etc/db/config.db ./data/etc/db/config_local.db ./data/etc/db/certs.db
