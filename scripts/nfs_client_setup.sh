#!/usr/bin/env bash

set -ex

echo '##########################################################################'
echo '############### About to run nfs_client_setup.sh script ##################'
echo '##########################################################################'


mkdir -p /mnt/backups


# showmount -e kerberos-nfs-storage.local
# mount -t nfs kerberos-nfs-storage.local:/nfs/export_rw /mnt/backups

echo 'kerberos-nfs-storage.local:/nfs/export_rw   /mnt/backups    nfs    soft,timeo=100,_netdev,rw   0   0' >> /etc/fstab
mount -a




