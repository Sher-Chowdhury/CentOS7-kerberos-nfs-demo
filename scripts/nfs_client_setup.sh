#!/usr/bin/env bash
# exit 0
set -ex

echo '##########################################################################'
echo '############### About to run nfs_client_setup.sh script ##################'
echo '##########################################################################'

yum install -y nfs-utils

mkdir -p /mnt/backups

clienthostname=$(hostname -f)
kadmin <<EOF
rootpassword
addprinc -randkey nfs/$clienthostname
ktadd nfs/$clienthostname
quit
EOF
### at this point I think if you run kadmin again, you get the following error message: 
# [root@nfs-client rw]# kadmin
# Authenticating as principal host/admin@CB.NET with password.
# kadmin: Client 'host/admin@CB.NET' not found in Kerberos database while initializing kadmin interface
### not sure why this happens. but you can override this by running the following instead. 
# [root@nfs-client rw]# kadmin -p root/admin

systemctl enable nfs-client.target
systemctl stop nfs-client.target
systemctl start nfs-client.target

# showmount -e nfs-storage.cb.net
# mount -t nfs nfs-storage.cb.net:/nfs/export_rw /mnt/backups

# kerberos-authentication entry:
echo 'nfs-storage.cb.net:/nfs/export_rw   /mnt/backups    nfs    soft,timeo=100,_netdev,rw,sec=krb5   0   0' >> /etc/fstab
mount -a




exit 0