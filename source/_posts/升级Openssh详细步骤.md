title: 升级Openssh详细步骤
author: Semaik.
tags:
  - Linux
categories:
  - Linux
date: 2020-09-11 15:34:00
---
#### 1、准备工作

1.1、下载相关软件包

> OpenSSH需要依赖ZLIB和OpenSSL，因此需要从官网下载三者的源码包。需要注意的是：OpenSSH最新版8.1p1依赖的OpenSSL版本为1.0.2k，而不是其最新版1.1.0e（使用此版会升级失败）,ZLIB可以使用最新 版1.2.11。 

三者源码下载地址：

     http://www.zlib.net/
     http://www.openssl.org/
     http://www.openssh.org/

1.2、查看系统当前软件版本

    # rpm -q zlib
    # openssl version
    # ssh -V

1.3、配置在线yum源
```
# cd /etc/yum.repos.d
# rm -rf *             #删除当前所有yum源文件

# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo   #连接阿里云在线源
```

1.4、安装telnet服务并启用

   > 因升级OpenSSH过程中需要卸载现有OpenSSH, 因此为了保持服务器的远程连接可用，需要启用telnet服务作为替代，如升级出现问题，也可通过telnet登录服务器进行回退。

   A、安装telnet服务
```
   # yum -y install telnet-server*
```
   B、启用telnet

   先关闭防火墙，否则telnet可能无法连接
```
# service iptables stop
# chkconfig iptables off
# vi /etc/xinetd.d/telnet
将其中disable字段的yes改为no以启用telnet服务
# mv /etc/securetty /etc/securetty.old          #允许root用户通过telnet登录
# /etc/init.d/xinetd start       #启动telnet服务
# chkconfig xinetd on              #使telnet服务开机启动，避免升级过程中服务器意外重启后无法远程登录系统
# telnet [ip]                 #新开启一个远程终端以telnet登录验证是否成功启用
```
1.5、安装编译所需工具包
```
# yum -y install gcc pam-devel zlib-devel
```

#### 2、正式升级

2.1、升级ZLIB

A、解压zlib_1.2.11源码并编译
```
# tar -zxvf zlib-1.2.11.tar.gz
# cd zlib-1.2.11
# ./configure --prefix=/usr
# make
```
B、卸载当前zlib

> 注意：此步骤必须在步骤A执行完毕后再执行，否则先卸载zlib后，/lib64/目录下的zlib相关库文件会被删除，步骤A编译zlib会失败。
```
# rpm -e --nodeps zlib 
```

C、安装之前编译好的zlib 
```
# make install 
```
在zlib编译目录执行如下命令

D、共享库注册

> zlib安装完成后，会在/usr/lib目录中生产zlib相关库文件，需要将这些共享库文件注册到系统中。
```
# echo '/usr/lib' >> /etc/ld.so.conf
# ldconfig #更新共享库cache
```

2.2、升级OpenSSL

A、备份当前openssl
```
# find / -name openssl
  /usr/lib64/openssl
  /usr/bin/openssl
  /etc/pki/ca-trust/extracted/openssl

# mv /usr/lib64/openssl /usr/lib64/openssl.old
# mv /usr/bin/openssl /usr/bin/openssl.old
# mv /etc/pki/ca-trust/extracted/openssl /etc/pki/ca-trust/extracted/openssl.old

如下两个库文件必须先备份，因系统内部分工具（如yum、wget等）依赖此库，而新版OpenSSL不包含这两个库
# cp /usr/lib64/libcrypto.so.10 /usr/lib64/libcrypto.so.10.old
# cp /usr/lib64/libssl.so.10 /usr/lib64/libssl.so.10.old

```
B、卸载当前openssl
```
# rpm -qa | grep openssl
   openssl-1.0.1e-42.el6.x86_64

# rpm -e --nodeps openssl-1.0.1e-42.el6.x86_64
# rpm -qa | grep openssl
```

C、解压openssl_1.0.2k源码并编译安装
```
# tar -zxvf openssl-1.0.2k.tar.gz
# cd openssl-1.0.2k
# ./config --prefix=/usr --openssldir=/etc/ssl --shared zlib                                #必须加上--shared，否则编译时会找不到新安装的openssl的库而报错
# make
# make test                             #必须执行这一步结果为pass才能继续，否则即使安装完成，ssh也无法使用
# make install
# openssl version -a                           #查看是否升级成功
```

D、恢复共享库

> 由于OpenSSL_1.0.2k不提供libcrypto.so.10和libssl.so.10这两个库，而yum、wget等工具又依赖此库，因此需要将先前备份的这两个库进行恢复，其他的可视情况考虑是否恢复。
```
# mv /usr/lib64/libcrypto.so.10.old  /usr/lib64/libcrypto.so.10
# mv /usr/lib64/libssl.so.10.old   /usr/lib64/libssl.so.
```

2.3、升级OpenSSH

A、备份当前openssh
```
# mv /etc/ssh  /etc/ssh.old
```

B、卸载当前openssh
```
# rpm -qa | grep openssh
openssh-clients-5.3p1-111.el6.x86_64
openssh-server-5.3p1-111.el6.x86_64
openssh-5.3p1-111.el6.x86_64
openssh-askpass-5.3p1-111.el6.x86_64

# rpm -e --nodeps openssh-5.3p1-111.el6.x86_64
# rpm -e --nodeps openssh-server-5.3p1-111.el6.x86_64
# rpm -e --nodeps openssh-clients-5.3p1-111.el6.x86_64
# rpm -e --nodeps openssh-askpass-5.3p1-111.el6.x86_64
# rpm -qa | grep openssh                # 查看是否卸载成功
```

C、openssh安装前环境配置
```
# install -v -m700 -d /var/lib/sshd
# chown -v root:sys /var/lib/sshd
# groupadd -g 50 sshd
# useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd
```

D、解压openssh_7.4p1源码并编译安装
```
# tar -zxvf openssh-8.1p1.tar.gz
# cd openssh-8.1p1
# ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-pam --with-zlib --with-openssl-includes=/usr --with-privsep-path=/var/lib/sshd
# make
# make install
```

E、openssh安装后环境配置
```
# 在openssh编译目录执行如下命令
# install -v -m755 contrib/ssh-copy-id /usr/bin
# install -v -m644 contrib/ssh-copy-id.1 /usr/share/man/man1
# install -v -m755 -d /usr/share/doc/openssh-8.1p1
# install -v -m644 INSTALL LICENCE OVERVIEW README* /usr/share/doc/openssh-8.1p1
# ssh -V #验证是否升级成功
```

F、启用OpenSSH服务
```
# 在openssh编译目录执行如下目录
# echo 'X11Forwarding yes' >> /etc/ssh/sshd_config
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config #允许root用户通过ssh登录
# cp -p contrib/redhat/sshd.init /etc/init.d/sshd
# chmod +x /etc/init.d/sshd
# chkconfig --add sshd
# chkconfig sshd on
# chkconfig --list sshd
# /etc/init.d/sshd restart
```
> 注意：如果升级操作一直是在ssh远程会话中进行的，上述sshd服务重启命令可能导致会话断开并无法使用ssh再行登入（即ssh未能成功重启），此时需要通过telnet登入再执行sshd服务重启命令。

 

#### 3、善后工作

 > 新开启远程终端以ssh [ip]登录系统，确认一切正常升级成功后，只需关闭telnet服务以保证系统安全性即可。
```
# mv /etc/securetty.old  /etc/securetty
# chkconfig xinetd off
# /etc/init.d/xinetd stop
```