#!/usr/bin/env bash

#Run in provsion folder as root.
#Provision folder should contain ssh_config.txt, motd.txt, pubkeys folder, and this script.

#Shuffle entropy in case machine is in known/snapshot state. 
#Probably unnecessary step considering urandom's methodology.
rando_num=$(shuf -i1-500 -n1)
head -c $rando_num'M' </dev/urandom > /dev/null

#Real work begins.
workdir=$(pwd)

#SSH provision
/bin/cp -rf motd.txt /etc/motd
/bin/cp -rf sshd_config.txt /etc/ssh/sshd_config
sed -i -e '/pam_motd.so/s/^/#/' /etc/pam.d/sshd
cd /etc/ssh
/bin/rm ssh_host_*
ssh-keygen -G /tmp/moduli -b 4096
ssh-keygen -T /etc/ssh/moduli -f /tmp/moduli 
ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N ""
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N ""
update-rc.d -f ssh remove
update-rc.d -f ssh defaults
#This part is redundant, but Kali SSH acts weird sometimes.
update-rc.d -f ssh enable 2 3 4 5
service ssh restart
cd "$workdir"

#User provision
for x in $(ls pubkeys/ | sed s/\.pub//)
do 
 adduser --shell /bin/bash --disabled-password --gecos "" $x
 usermod -G sudo,wireshark,kismet,tcpdump $x
 mkdir -p /home/$x/.ssh/
 cat pubkeys/$x.pub > /home/$x/.ssh/authorized_keys
 chmod 700 /home/$x/.ssh/
 chmod 600 /home/$x/.ssh/authorized_keys
 chown -R $x:$x /home/$x/.ssh
 rando=$(< /dev/urandom tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | head -c20)
 echo -e "This is your password: $rando \nChange it by running command 'passwd'." > /home/$x/password.txt
 chown $x:$x /home/$x/password.txt
 chmod 400 /home/$x/password.txt
 echo $x:$rando | chpasswd
done
 
#Random root/user password
#No one should need to login directly as either of these accounts. Password not saved.
for x in user root
do
 rando=$(< /dev/urandom tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | head -c20)
 echo $x:$rando | chpasswd
done
