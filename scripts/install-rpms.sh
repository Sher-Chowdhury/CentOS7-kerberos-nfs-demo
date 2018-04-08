#!/usr/bin/env bash

set -ex


echo '##########################################################################'
echo '##### About to run install-rpms.sh script ##################'
echo '##########################################################################'

yum install -y epel-release 
yum install -y vim
yum install -y bash-completion
yum install -y man-pages
yum install -y bash-completion-extras
yum install -y mtr



# Do a few more stuff. 
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
setenforce enforcing

systemctl enable firewalld
systemctl start firewalld

mandb

exit 0