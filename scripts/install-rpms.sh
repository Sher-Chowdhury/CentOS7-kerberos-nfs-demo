#!/usr/bin/env bash

set -ex


echo '##########################################################################'
echo '##### About to run install-rpms.sh script ##################'
echo '##########################################################################'

yum install -y epel-release || exit 1
yum install -y vim || exit 1
yum install -y bash-completion || exit 1
yum install -y man-pages
yum install -y bash-completion-extras || exit 1
yum install -y mtr || exit 1



# Do a few more stuff. 
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
setenforce enforcing

systemctl enable firewalld
systemctl start firewalld