#!/usr/bin/env bash

set -ex

exit 0

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

authconfig --enablekrb5  --update

sed -i 's/)/,sec=krb5)/g' /etc/exports



systemctl restart nfs-server
# note, restarting the daemon isn't enough, for some reason have to reboot the whole machine. 










