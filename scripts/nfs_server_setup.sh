#!/usr/bin/env bash

set -ex

echo '##########################################################################'
echo '##### About to run nfs_server_setup.sh script ##################'
echo '##########################################################################'


sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
setenforce enforcing

setsebool -P nfs_export_all_rw 1
setsebool -P nfs_export_all_ro 1
# Here we made (P)ersistant changes, you can check with 
# getsebool -a | grep nfs_export



# allow nfs traffic through the firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
systemctl restart firewalld


# install nfs server software
yum install -y nfs-utils


# here are the 2 folders to be shared
mkdir -p /nfs/export_ro
mkdir -p /nfs/export_rw


semanage fcontext -a -t public_content_rw_t  "/nfs/export_ro(/.*)?"
restorecon -R /nfs/export_ro

semanage fcontext -a -t public_content_rw_t  "/nfs/export_rw(/.*)?"
restorecon -R /nfs/export_rw

# Next we need to add entries to /etc/exports, which is an empty file by default:
# do 'man exports' to see exmaple confis 
echo '/nfs/export_ro  *(sync)' > /etc/exports
echo '/nfs/export_rw  *(rw,no_root_squash)' >> /etc/exports

# here we start the export process, we are exporting (a)ll (v)erbosely 
# exportfs -avr




systemctl start nfs-server
systemctl enable nfs-server


# You can confirm this has worked by running:
# showmount -e localhost
# and also:
# cat /var/lib/nfs/etab




exit 0