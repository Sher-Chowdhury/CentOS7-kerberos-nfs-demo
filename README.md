```
                   +----------------------------+
                   |                            |
                   |      Kerberos Serve        |
                   |      (IP: 10.0.9.11)       |
                   |                            |
                   |                            |
                   |                            |
                   |                            |
                   +----------------------------+
                       ^                     ^
                       |                     |
                       |                     |
                       |                     |
                       v                     v
+--------------------------+               +--------------------------+
|                          |               |                          |
|       nfs-storage        |               |        nfs-client        |
|     (IP: 10.0.9.12)      |               |       (IP: 10.0.9.13)    |
|                          |               |                          |
|                          |               |                          |
|                          |               |                          |
|   +-----------------+    |   kerberos    |     +---------------+    |
|   | /nfs/export_rw  |<-------------------|---->| /mnt/backups  |    |
|   +-----------------+    | authenticated |     +---------------+    |
|                          |               |                          |
|                          |               |                          |
+--------------------------+               +--------------------------+
```

For more info see:

https://codingbee.net/tutorials/rhce/nfs-use-kerberos-to-control-nfs-access-on-centos-7

Test yourself:

first uncomment all lines inside the scripts folder, that has '# exit 0' near the top. Then do 'vagrant up' Then do the following:

1. install setup nfs on nfs server and nfs client, without any kerberos encryption
2. setup kerberos server and both kerberos clients
3. configure kerberos+nfs encryption
4. (bonus) setup krbtest user across all boxes so that authentication is done via ssh. 
5. (bonus) make export a private group folder where krbtest is a group member. 

