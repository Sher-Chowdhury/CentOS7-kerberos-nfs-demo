#!/usr/bin/env bash

set -ex

echo '##########################################################################'
echo '##### About to run setup-kerberos-client.sh script #############'
echo '##########################################################################'


yum install -y krb5-workstation pam_krb5

cp /etc/krb5.conf /etc/krb5.conf-orig
# the following replaces a whole line based on a partial match
# https://stackoverflow.com/questions/11245144/replace-whole-line-containing-a-string-using-sed
sed -i '/default_realm/c\ default_realm = CODINGBEE.NET' /etc/krb5.conf


sed -i 's/# EXAMPLE.COM/  CODINGBEE.NET/g' /etc/krb5.conf

sed -i 's/#  kdc = kerberos.example.com/   kdc = kdc.codingbee.net/g' /etc/krb5.conf
sed -i 's/#  admin_server = kerberos.example.com/   admin_server = kdc.codingbee.net/g' /etc/krb5.conf
sed -i 's/# }/}/g' /etc/krb5.conf     # this should edit the line that's right after the admin_server line. 

sed -i 's/# .example.com = EXAMPLE.COM/ .codingbee.net = CODINGBEE.NET/g' /etc/krb5.conf
sed -i 's/# example.com = EXAMPLE.COM/ codingbee.net = CODINGBEE.NET/g' /etc/krb5.conf

clienthostname=$(hostname -f)
kadmin <<EOF
MySecretRootPassword
addprinc -randkey host/$clienthostname
ktadd host/$clienthostname
quit
EOF


cp /etc/ssh/ssh_config /etc/ssh/ssh_config-orig

sed -i 's/#   GSSAPIAuthentication no/    GSSAPIAuthentication yes/g' /etc/ssh/ssh_config
sed -i 's/#   GSSAPIDelegateCredentials no/    GSSAPIDelegateCredentials yes/g' /etc/ssh/ssh_config

sed -i 's/GSSAPIAuthentication no/GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

authconfig --enablekrb5  --update

useradd krbtest


# su - krbtest
# the following should fail, becuase it gives a password prompt:
# $ e
# the following should give a 'not found' error message:
# $ klist
# kinit    will get a password prompt, enter: TestAccountPassword 
# klist  # this is to check you have an active token
# then do:
# $ ssh kdc.codingbee.net
# you should be able to log in without a password prompt, or the need to first setup private+public ssh keys. 