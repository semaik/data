title: Centos7部署轻量级自动化运维工具pssh
author: Semaik.
tags:
  - Linux
categories:
  - Linux
date: 2020-10-13 15:31:00
---
> pssh是由python编写，可以在多台服务器执行命令的工具。在服务器越来越多的企业这种自动化运维工具越来越火。

##### 下载pssh安装包
```java
[root@localhost ~]# wget https://files.pythonhosted.org/packages/60/9a/8035af3a7d3d1617ae2c7c174efa4f154e5bf9c24b36b623413b38be8e4a/pssh-2.3.1.tar.gz
```
##### 配置免密登录
```java
[root@localhost ~]# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:3antaxjGw+hdgfSlrXLYhUe5vgHe9b0ehh/gUY9E8Eg root@localhost.localdomain
The key's randomart image is:
+---[RSA 2048]----+
|            E... |
|          .. ++  |
|         . o.*oo |
|         ...*o*.o|
|        S+.+o@..+|
|        . OoB B o|
|       . o.B.o *.|
|        . o.. +.o|
|           .o..o |
+----[SHA256]-----+
[root@localhost ~]# cd /root/.ssh/
[root@localhost .ssh]# ls
id_rsa  id_rsa.pub
[root@localhost .ssh]# ssh-copy-id 172.16.1.112
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host '172.16.1.112 (172.16.1.112)' can't be established.
ECDSA key fingerprint is SHA256:yFvaxR1x5YDhhe+6xR/Ou6Sm+YPYvPAoiLVKt9mAnXA.
ECDSA key fingerprint is MD5:0d:c4:79:bc:36:7a:a4:82:95:4f:d5:d0:a3:c8:7d:2e.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@172.16.1.112's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '172.16.1.112'"
and check to make sure that only the key(s) you wanted were added.
[root@localhost .ssh]# ssh-copy-id 172.16.1.16
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host '172.16.1.16 (172.16.1.16)' can't be established.
ECDSA key fingerprint is SHA256:ANzlXzrGA87YLI2vzkPJ/iNPiSQ5JStJc95948jE8aw.
ECDSA key fingerprint is MD5:f9:f1:1b:5a:99:64:d8:d8:e9:9b:e6:bb:c3:d5:bd:e7.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@172.16.1.16's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '172.16.1.16'"
and check to make sure that only the key(s) you wanted were added.
```
##### 测试免密登录
```java
[root@localhost ~]# ssh 172.16.1.112
Last login: Tue Jun  2 09:44:24 2020 from 172.16.1.16
[root@localhost ~]# ssh 172.16.1.16
Last login: Tue Jun  2 09:30:47 2020 from 172.16.1.100
```

##### 测试pssh
```java
# 将IP写入到文件中
[root@localhost ~]# echo "172.16.1.112" >> aaa
[root@localhost ~]# echo "172.16.1.16" >> aaa
[root@localhost ~]# cat aaa
172.16.1.112
172.16.1.16
# 批量执行date命令
[root@localhost ~]# pssh -h aaa -l root -P "date"
172.16.1.16: 2020年 06月 02日 星期二 09:59:48 CST
[1] 09:59:48 [SUCCESS] 172.16.1.16
172.16.1.112: 2020年 06月 02日 星期二 09:59:48 CST
[2] 09:59:48 [SUCCESS] 172.16.1.112
# 查看磁盘
[root@localhost ~]# pssh -h aaa -l root -P "lsblk"
172.16.1.16: NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sr0              11:0    1  4.2G  0 rom  
[1] 10:13:02 [SUCCESS] 172.16.1.16
172.16.1.112: NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sr0              11:0    1  4.2G  0 rom  
[2] 10:13:03 [SUCCESS] 172.16.1.112

```