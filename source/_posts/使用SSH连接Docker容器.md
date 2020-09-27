title: 使用SSH连接Docker容器
author: Semaik.
tags:
  - Docker
categories: []
date: 2020-09-27 14:54:00
---
**实验：使用ssh管理docker的容器**
 
**实验要求：**
 
>1、ssh可以登录容器
>2、在容器内yum 安装httpd并且启动
 
**实验步骤**
 
将docker的centos镜像实例化名为sshd的容器
 ```java
[root@localhost ~]# docker run -itd --name sshd centos /bin/bash
cd3c512d6cd959263b1c94e19781d7213831aad714a2e962ade7c0adc28c510e
```
进入容器，并进行安装sshd和启动sshd的相应操作
 ```java
[root@localhost ~]# docker exec -it sshd /bin/bash
[root@cd3c512d6cd9 /]# yum -y install openssh-server openssh-clients password iproute net-tools
[root@cd3c512d6cd9 /]# passwd root   # 设置root密码
[root@cd3c512d6cd9 /]# cat /usr/lib/systemd/system/sshd.service
 找到以下
ExecStart=/usr/sbin/sshd -D $OPTIONS
 /usr/sbin/sshd -D这个用来启动yum安装的服务，几乎所有yum安装的都有这个
[root@5c46b791e8d2 /]# /usr/sbin/sshd -D
 执行之后发现报错，找不到3个密钥文件
Could not load host key: /etc/ssh/ssh_host_rsa_key
Could not load host key: /etc/ssh/ssh_host_ecdsa_key
Could not load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.
 生成密钥，分别存放到它要找到三个路径中
[root@cd3c512d6cd9 /]# ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
[root@cd3c512d6cd9 /]# ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
[root@cd3c512d6cd9 /]# ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''
 
keygen参数：
    -q：不在终端显示密钥
    -b：字节长度
    -f：指定密钥文件路径
 
 可以通过cat去查看这三个密钥
[root@cd3c512d6cd9 /]# vi /etc/ssh/sshd_config 
 修此文件是得ssh以进程方式运行
 这是pam模块使用sshd，容器中没有这个模块，所以需要注释
UsePAM no  
 解开以下注释并修改值为no
UsePrivilegeSeparation sandbox  //将sandbox改为no
 以下解开注释，允许超级用户登录
PermitRootLogin yes
```
启动sshd服务
```java
[root@5c46b791e8d2 /]# /usr/sbin/sshd -D &
[root@5c46b791e8d2 /]# exit
exit
```
然后就可以通过ssh来使用物理机连接docker容器sshd
 ```java
[root@192 ~]# ssh root@172.17.0.2
The authenticity of host '172.17.0.2 (172.17.0.2)' can't be established.
ECDSA key fingerprint is SHA256:8M08usrRzTfDZjM9cfZhM+DAMn8d4O6/xW3ULlpM17o.
ECDSA key fingerprint is MD5:8b:72:3b:0f:15:ac:f4:8f:24:f0:ed:fa:40:12:c3:ae.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.17.0.2' (ECDSA) to the list of known hosts.
root@172.17.0.2's password:
```
安装httpd并启动
```java
[root@5c46b791e8d2 ~]# yum -y install httpd
[root@5c46b791e8d2 ~]# find / -name httpd.service
/usr/lib/systemd/system/httpd.service
[root@5c46b791e8d2 ~]# cat /usr/lib/systemd/system/httpd.service
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
[root@5c46b791e8d2 ~]# /usr/sbin/httpd  &
AH00558: httpd: Could not reliably determine the server's fully qualified
domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
[root@5c46b791e8d2 ~]# netstat -anpt | grep 80
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      191/httpd 
[root@5c46b791e8d2 ~]# curl 172.17.0.2
```
