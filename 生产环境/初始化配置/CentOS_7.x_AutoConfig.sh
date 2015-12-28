#!/bin/bash

#/*==============================================================*/
#/* Created on:     2015-12-22 16:00:00                          */
#/* Author:         xujr                                         */
#/* E-mail:         xujr@nbpt.cn                                 */
#/* Description:    CentOS 7.x minimal安装系统配置脚本           */
#/*==============================================================*/

echo "CentOS 7.x minimal安装系统配置"
echo "----------------------------------------"
# 1.安装常用软件
# 待完善 判断是否已安装过 是否配置成功
yum -y update
yum -y install net-tools firewalld vim ftp ntpdate zip unzip telnet wget gcc gcc-c++ ncurses-devel cmake make perl dmidecode ld-linux.so.2 libstdc++.so.6 libusb-0.1.so.4 libicudata.so.50.1.2 libicu libicui18n.so.50.1.2 libicuuc.so.50.1.2
ln -s /usr/lib64/libicudata.so.50.1.2 /usr/lib/libicudata.so.38
ln -s /usr/lib64/libicui18n.so.50.1.2 /usr/lib/libicui18n.so.38
ln -s /usr/lib64/libicuuc.so.50.1.2 /usr/lib/libicuuc.so.38

# 2.添加hosts
# 待完善 判断是否已修改过 是否配置成功
local_hostname="`hostname --fqdn`"
local_ip="`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`"
sed -i "1,2s/$/ ${local_hostname}/g" /etc/hosts
echo "${local_ip} ${local_hostname}" >> /etc/hosts

# 3.关闭selinux
# 待完善 判断是否已修改过 是否配置成功
sed -i "s/SELINUX=enforcing/#SELINUX=enforcing/g; s/SELINUXTYPE=targeted/#SELINUXTYPE=targeted/g" /etc/selinux/config
echo "SELINUX=disabled" >> /etc/selinux/config
setenforce 0

# 4.SSH服务配置
# 待完善 检验是否配置成功
sed -i "s/#Port 22/Port 5631/g; s/#PermitRootLogin yes/PermitRootLogin no/g; s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
cp /usr/lib/firewalld/services/ssh.xml /etc/firewalld/services/ssh.xml
sed -i "s/22/5631/g" /etc/firewalld/services/ssh.xml
systemctl restart sshd.service
#firewall-cmd --reload

# 5.vsftpd服务及nbpt目录 (默认不开启vsftpd服务)
# 待完善 检验是否配置成功
mkdir -p /usr/local/nbpt
chmod 777 /usr/local/nbpt
#sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g; s/#chroot_local_user=YES/chroot_local_user=YES/g" /etc/vsftpd/vsftpd.conf
#echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
#echo "pasv_enable=Yes" >> /etc/vsftpd/vsftpd.conf
#echo "pasv_min_port=50100" >> /etc/vsftpd/vsftpd.conf
#echo "pasv_max_port=50200" >> /etc/vsftpd/vsftpd.conf
#echo "local_root=/usr/local/nbpt/" >> /etc/vsftpd/vsftpd.conf
#systemctl enable vsftpd.service
#service vsftpd restart

# 6.java环境配置
# 待完善 检验是否配置成功
cp /root/jdk-6u45-linux-x64.bin /usr/local/nbpt/
chmod 777 /usr/local/nbpt/jdk-6u45-linux-x64.bin
cd /usr/local/nbpt
./jdk-6u45-linux-x64.bin
mv /usr/local/nbpt/jdk1.6.0_45/ /usr/local/jdk
echo "#java" >> /etc/profile
echo "export JAVA_HOME=/usr/local/jdk" >> /etc/profile
echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar" >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
source /etc/profile
java -version

# 7.增加nbpt用户
# 待完善 检验是否输入成功 是否配置成功
useradd nbpt
echo "请设置nbpt用户的密码："
passwd nbpt
usermod -G root,bin,adm,floppy,audio,dip,daemon,sys,disk,wheel nbpt
chown -Rf nbpt:nbpt /usr/local/nbpt
sed -i "/root	ALL=(ALL) 	ALL/a\nbpt	ALL=(ALL) 	ALL" /etc/sudoers

# 8.重启系统
echo "系统配置完成！请重启系统，重启后通过ssh 5631端口连接，使用nbpt用户登陆。"
sleep 20
reboot

