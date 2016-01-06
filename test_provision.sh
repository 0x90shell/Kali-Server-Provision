#!/usr/bin/env bash

#Run in provsion folder.
#Provision folder should contain ssh_config.txt, motd.txt, pubkeys folder, and this script. 

workdir=$(pwd)

#SSH provision

cd /etc/ssh

cd "$workdir"

#User provision
#Run as root
for x in $(ls ./pubkeys/ | sed s/\.pub//)
do 
 echo $x
done
 
#Random root/user password
#No one should need to login directly as either of these accounts. Password not saved.
for x in user root
do
 rando=$(< /dev/urandom tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | head -c20)
 echo $x:$rando
done
