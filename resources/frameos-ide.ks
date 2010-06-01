install
cdrom
text
key --skip

lang en_US.UTF-8
langsupport --default=en_US.UTF-8 en_US.UTF-8
keyboard us
mouse none

#
# Configure the network
#
network --bootproto=query
#network --bootproto=static --ip=10.0.2.15 --netmask=255.255.255.0 --gateway=10.0.2.254 --nameserver=10.0.2.1 --hostname=frameos
#network --bootproto=dhcp 

zerombr yes
clearpart --all --drives=hda

part /boot --fstype ext2 --size=100
part pv.6 --size=7000 --grow --ondisk=hda
volgroup systemvg pv.6
logvol / --fstype=ext3 --name=rootlv --vgname=systemvg --size=3000 --grow
logvol /var --fstype=ext3 --name=varlv --vgname=systemvg --size=1024 
logvol /tmp --fstype=ext3 --name=tmplv --vgname=systemvg --size=1024
logvol swap --fstype=swap --name=swaplv --vgname=systemvg --size=1024
bootloader --location=mbr --driveorder=hda --append="rhgb quiet"

timezone Europe/Madrid
rootpw frameos
authconfig --enableshadow --enablemd5
selinux --disabled
firewall --disabled
skipx
reboot --eject


%packages --nobase
coreutils
yum
rpm
e2fsprogs
lvm2
grub
openssh-server
openssh-clients
-system-config-securitylevel-tui
-wireless-tools
-rhpl
-kudzu
