#!/bin/bash

#Set MOTD
cat templates/motd > /etc/motd
cat templates/motd > /etc/issue
cat templates/motd > etc/issue.net

#Update System
apt update
apt upgrade -y
apt dist-upgrade -y

#Setting a more restructive UMASK
cp templates/logins.defs /etc/login.defs

#Disabling Unused Filesystems

echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf

#Diabling uncommon network protocols

echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf

#Create Privileged User
useradd -m -s /bin/bash swupoh
usermod -aG sudo swupoh
mkdir -p /home/swupoh/.ssh
cp templates/swupoh_authorized_keys /home/swupoh/.ssh/authorized_keys
chown -R swupoh: /home/swupoh/.ssh
chmod 700 /home/swupoh/.ssh
chown -R swupoh: /home/swupoh/.ssh/authorized_keys
chmod 600 /home/swupoh/.ssh/authorized_keys

#Secure SSH
cp /templates/sshd_config /etc/ssh/sshd_config
service ssh restart

#Secure /tmp folder

dd if=/dev/zero of=/usr/tmpDISK bs=1024 count=2048000
mkdir /tmpbackup
cp -Rpf /tmp /tmpbackup
mount -t tmpfs -o loop,noexec,nosuid,rw /usr/tmpDISK /tmp
chmod 1777 /tmp
cp -Rpf /tmpbackup/* /tmp/
rm -rf /tmpbackup
echo "/usr/tmpDISK  /tmp    tmpfs   loop,nosuid,nodev,noexec,rw  0 0" >> /etc/fstab
sudo mount -o remount /tmp


#Setup UFW
ufw enable
ufw allow ssh
ufw allow 8080/tcp
ufw allow 9100/tcp
ufw allow 10000:11000/tcp 

#Install PSAD
#PSAD actively monitors firewall logs to determine if a scan or attack is taking place
apt-get install psad
iptables -A INPUT -j LOG
iptables -A FORWARD -j LOG
ip6tables -A INPUT -j LOG
ip6tables -A FORWARD -j LOG
ufw logging on
cp templates/psad.conf /etc/psad/psad.conf
psad --sig-update
service psad restart


#Install Fail2ban
apt install sendmail
apt install fail2ban

#Enable Process Accounting
apt install acct
touch /var/log/wtmp


#Setting File Permissions on critical system files
chmod -R g-wx,o-rwx /var/log/*

chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config

chown root:root /etc/passwd
chmod 644 /etc/passwd

chown root:shadow /etc/shadow
chmod o-rwx,g-wx /etc/shadow

chown root:root /etc/group
chmod 644 /etc/group

chown root:shadow /etc/gshadow
chmod o-rwx,g-rw /etc/gshadow

chown root:root /etc/passwd-
chmod 600 /etc/passwd-

chown root:root /etc/shadow-
chmod 600 /etc/shadow-

chown root:root /etc/group-
chmod 600 /etc/group-

chown root:root /etc/gshadow-
chmod 600 /etc/gshadow-


