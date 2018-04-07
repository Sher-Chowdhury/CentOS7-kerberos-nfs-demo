#!/usr/bin/env bash

set -ex

echo '##########################################################################'
echo '##### About to run nfs_server_kerberos_integration.sh script #############'
echo '##########################################################################'

clienthostname=$(hostname -f)
kadmin <<EOF
MySecretRootPassword
addprinc -randkey nfs/$clienthostname
ktadd nfs/$clienthostname
quit
EOF

systemctl enable nfs-client.target
systemctl restart nfs-client.target

# mount -t nfs -o sec=krb5,rw kerberos-nfs-storage.local:/nfs/export_rw /mnt/backups 

echo 'kerberos-nfs-storage.local:/nfs/export_rw   /mnt/backups    nfs    soft,timeo=100,_netdev,rw,sec=krb5   0   0' >> /etc/fstab
mount -a




