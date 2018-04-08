#!/usr/bin/env bash
# exit 0
set -ex

echo '##########################################################################'
echo '############### About to run nfs_client_setup.sh script ##################'
echo '##########################################################################'

yum install -y nfs-utils

mkdir -p /mnt/backups


systemctl enable nfs-client.target
systemctl restart nfs-client.target

# showmount -e nfs-storage.cb.net
# mount -t nfs nfs-storage.cb.net:/nfs/export_rw /mnt/backups

# non-kerberos-authentication entry:
echo 'nfs-storage.cb.net:/nfs/export_rw   /mnt/backups    nfs    soft,timeo=100,_netdev,rw,sec=krb5   0   0' >> /etc/fstab
mount -a




exit 0