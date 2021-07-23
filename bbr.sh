#!/bin/bash

kernelBranch=$(uname -r | awk -F\. '{print $1}')
osVersion=$(uname -r | awk -F\. '{print $2}')
rebootv=0

if [[ kernelBranch -gt 4 ]]
then
  echo net.core.default_qdisc = fq >> /etc/sysctl.conf
  echo net.ipv4.tcp_congestion_control = bbr >> /etc/sysctl.conf
elif [[ kernelBranch -eq 4 ]]
then
  if [[ osVersion -gt 8 ]]
  then
    echo net.core.default_qdisc = fq >> /etc/sysctl.conf
    echo net.ipv4.tcp_congestion_control = bbr >> /etc/sysctl.conf
  elif [[ osVersion -lt 9 ]]
  then
    #update kernel
	grep -i UBUNTU /etc/os-release > /dev/null && osname=1
	if [[ osname -eq 1 ]]
	then
	  apt-get install --install-recommends linux-generic-hwe-16.04
	fi
	
	#enable BBR
    echo net.core.default_qdisc = fq >> /etc/sysctl.conf
    echo net.ipv4.tcp_congestion_control = bbr >> /etc/sysctl.conf
	
	rebootv=1
  fi
elif [[ kernelBranch -lt 4 ]]
then
  #update kernel
  grep -i fedora /etc/os-release > /dev/null && osname=2
  if [[ osname -eq 2 ]]
  then
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
	yum --enablerepo=elrepo-kernel install kernel-lt -y
	sed 's/^GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' -i /etc/default/grub
	grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
  
  #enable BBR
  echo net.core.default_qdisc = fq >> /etc/sysctl.conf
  echo net.ipv4.tcp_congestion_control = bbr >> /etc/sysctl.conf
  
  rebootv=1
fi

echo -e "\n\n\n\n\n"
sysctl -p

if [[ rebootv -eq 1 ]]
then
  systemctl reboot
fi
