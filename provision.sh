#!/usr/bin/env bash

#Run in provsion folder as root.
#Provision folder should contain ssh_config.txt, motd.txt, pubkeys folder, and this script.

#Packages
apt-get update
apt-get install git
#Comment out the packages you want
#All(wifi, radio, and gpu packages included)
#apt-get install kali-linux-all
#Base (no GPU, radio, or wifi)
#apt-get install kali-linux-full kali-linux-top10 kali-linux-voip kali-linux-web kali-linux-forensic kali-linux-pwtools
#GPU
#apt-get install kali-linux-gpu
#Wifi/Radio
#apt-get install kali-linux-sdr kali-linux-rfid kali-linux-wireless
git clone https://github.com/Veil-Framework/Veil /opt
git clone https://github.com/PowerShellMafia/PowerSploit /opt
git clone https://github.com/PowerShellEmpire/Empire /opt
git clone https://github.com/leebaird/discover /opt
git clone https://github.com/danielmiessler/SecLists /opt
git clone https://github.com/pentestgeek/smbexec /opt
git clone https://github.com/pentestmonkey/gateway-finder /opt
git clone https://github.com/pentestmonkey/pysecdump /opt
git clone https://github.com/pentestmonkey/timing-attack-checker /opt
git clone https://github.com/pentestmonkey/unix-privesc-check /opt
git clone https://github.com/pentestmonkey/windows-privesc-check /opt
git clone https://github.com/portcullislabs/rdp-sec-check /opt
git clone https://github.com/stribika/sshlabs /opt
git clone https://github.com/stufus/egresscheck-framework /opt
#king-phisher installed in kali2 default
git clone https://github.com/securestate/king-phisher-templates /opt
#alt phishing tool (could one day have all features of king, with better interface)
#git clone https://github.com/gophish/gophish /opt
/opt/Empire/setup/install.sh
#Manual interaction required for veil/smbexec
/opt/Veil/Install.sh
/opt/smbexec/install.sh
apt-get dist-upgrade -y
apt-get autoremove; apt-get autoclean

#Randomly mixes seed values in case machine is in known/snapshot state. 
#Probably unnecessary step considering urandom's process.
rando_num=$(shuf -i1-500 -n1)
head -c $rando_num'M' </dev/urandom > /dev/null

#Kill TFTP
sed -i 's/^tftp/#&/' /etc/inetd.conf && service inetd restart

#SSH work begins.
workdir=$(pwd)

#SSH provision
\cp -rf motd.txt /etc/motd
\cp -rf sshd_config.txt /etc/ssh/sshd_config
#Removes dual motd posting on login.
sed -i -e '/pam_motd.so/s/^/#/' /etc/pam.d/sshd
cd /etc/ssh
\rm ssh_host_*
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
 #Since the purpose of this box is to conduct pentest, all users need full sudo access.
 #Edit additional groups per your builds.
 usermod -G sudo,wireshark,kismet,tcpdump $x
 mkdir -p /home/$x/.ssh/
 cat pubkeys/$x.pub > /home/$x/.ssh/authorized_keys
 chmod 700 /home/$x/.ssh/
 chmod 600 /home/$x/.ssh/authorized_keys
 chown -R $x:$x /home/$x/.ssh
 rando=$(< /dev/urandom tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | head -c20)
 #This password file can only be accessed by the user and those with root access. 
 #Since only a small number of people (pentest team) should have access to this box, this is viewed
 #as an acceptable temporary risk. SSH login can only be done via keyfile login and all team members 
 #have applied passwords to their keys.
 echo -e "This is your password: $rando \nChange it by running command 'passwd'." > /home/$x/password.txt
 chown $x:$x /home/$x/password.txt
 chmod 400 /home/$x/password.txt
 echo $x:$rando | chpasswd
done
 
#Random root/user password
#No one can remotely login directly as either of these accounts. Password not saved.
for x in user root
do
 rando=$(< /dev/urandom tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | head -c20)
 echo $x:$rando | chpasswd
done
