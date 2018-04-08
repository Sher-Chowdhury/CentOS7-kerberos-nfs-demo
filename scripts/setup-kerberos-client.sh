#!/usr/bin/env bash
# exit 0
set -ex

echo '##########################################################################'
echo '##### About to run setup-kerberos-client.sh script #############'
echo '##########################################################################'


yum install -y krb5-workstation pam_krb5

cp /etc/krb5.conf /etc/krb5.conf-orig
# the following replaces a whole line based on a partial match
# https://stackoverflow.com/questions/11245144/replace-whole-line-containing-a-string-using-sed
sed -i '/default_realm/c\ default_realm = CB.NET' /etc/krb5.conf


sed -i 's/# EXAMPLE.COM/  CB.NET/g' /etc/krb5.conf

sed -i 's/#  kdc = kerberos.example.com/   kdc = kdc.cb.net/g' /etc/krb5.conf
sed -i 's/#  admin_server = kerberos.example.com/   admin_server = kdc.cb.net/g' /etc/krb5.conf
sed -i 's/# }/}/g' /etc/krb5.conf     # this should edit the line that's right after the admin_server line. 

sed -i 's/# .example.com = EXAMPLE.COM/ .cb.net = CB.NET/g' /etc/krb5.conf
sed -i 's/# example.com = EXAMPLE.COM/ cb.net = CB.NET/g' /etc/krb5.conf

clienthostname=$(hostname -f)
kadmin <<EOF
rootpassword
addprinc -randkey host/$clienthostname
ktadd host/$clienthostname
quit
EOF

exit 0