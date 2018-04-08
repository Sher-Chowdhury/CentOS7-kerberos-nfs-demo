#!/usr/bin/env bash

set -ex

echo '##########################################################################'
echo '##### About to run setup-kdc-authentication-system.sh script #############'
echo '##########################################################################'


yum install -y krb5-server krb5-workstation pam_krb5


cp /var/kerberos/krb5kdc/kdc.conf /var/kerberos/krb5kdc/kdc.conf-orig




sed -i s/EXAMPLE.COM/CB.NET/g /var/kerberos/krb5kdc/kdc.conf


# make it only kerberos5 compatible and not backward compatible. 
sed -i s/#master_key_type/master_key_type/g /var/kerberos/krb5kdc/kdc.conf
sed -i '/master_key_type/a \ \ default_principle_flags = +preauth' /var/kerberos/krb5kdc/kdc.conf # this inserts a line after a match
                                                                                                  # https://stackoverflow.com/questions/15559359/insert-line-after-first-match-using-sed


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

cp /var/kerberos/krb5kdc/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl-orig

sed -i 's/EXAMPLE.COM/CB.NET/g' /var/kerberos/krb5kdc/kadm5.acl

# this is the create the kerberos database. It can take several minutes to finish. 
kdb5_util create -s -r CB.NET << EOF
MySecretPassword
MySecretPassword
EOF

systemctl enable krb5kdc
systemctl enable kadmin

systemctl start krb5kdc
systemctl start kadmin


kadmin.local <<EOF
addprinc root/admin
rootpassword
rootpassword
addprinc -randkey host/kdc.cb.net
ktadd host/kdc.cb.net
quit
EOF


# the above ktadd command ends up creating the following file:

#cp /etc/ssh/ssh_config /etc/ssh/ssh_config-orig

#sed -i 's/#   GSSAPIAuthentication no/    GSSAPIAuthentication yes/g' /etc/ssh/ssh_config


#sed -i 's/#   GSSAPIDelegateCredentials no/    GSSAPIDelegateCredentials yes/g' /etc/ssh/ssh_config

#sed -i 's/GSSAPIAuthentication no/GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
#systemctl restart sshd

#authconfig --enablekrb5  --update



firewall-cmd --add-service=kadmin --permanent
firewall-cmd --add-service=kerberos --permanent

systemctl restart firewalld



# next we do some testing:

# useradd krbtest


# su - krbtest
# the following should fail, becuase it gives a password prompt:
# $ ssh kdc.cb.net
# the following should give a 'not found' error message:
# $ klist
# kinit    will get a password prompt, enter:   TestAccountPassword 
# klist  # this is to check you have an active token
# then do:
# $ ssh kdc.cb.net
# you should be able to log in without a password prompt, or the need to first setup private+public ssh keys. 

echo 0