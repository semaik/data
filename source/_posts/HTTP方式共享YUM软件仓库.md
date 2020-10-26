title: HTTP方式共享YUM软件仓库
author: Semaik.
tags:
  - Linux
categories:
  - Linux
date: 2020-10-13 15:04:00
---
##### 两台机器
| IP 		| 备注 	 |
| -- 		| 	----	| 
| 1.1.1.5	|	YUM仓库|
| 1.1.1.3	|	测试机器|

**1.1.1.5通过apache镜像目录共享**
```java
[root@localhost ~]# yum install -y httpd
```
在/var/www/html下面创建centos目录

```java
[root@localhost ~]# mkdir /var/www/html/centos
```

挂载镜像到/var/www/html/aaa下
```java
[root@localhost ~]# mount CentOS-7-x86_64-DVD-1611.iso /var/www/html/centos/
[root@localhost ~]# ls /var/www/html/centos/
CentOS_BuildTag  EULA  images    LiveOS    repodata              RPM-GPG-KEY-CentOS-Testing-7
EFI              GPL   isolinux  Packages  RPM-GPG-KEY-CentOS-7  TRANS.TBL
```

测试浏览器访问

![upload successful](/images/pasted-99.png)

在1.1.1.3配置yum
```java
[root@localhost ~]# vi /etc/yum.repos.d/yum.repo
[yum]
name=yum
enabled=1
gpgcheck=0
baseurl=http://1.1.1.5/centos                       
```
测试安装软件
```java
[root@localhost ~]# yum install vsftpd -y
已加载插件：fastestmirror
Loading mirror speeds from cached hostfile
正在解决依赖关系
......

总下载量：169 k
安装大小：348 k
Downloading packages:
vsftpd-3.0.2-22.el7.x86_64.rpm | 169 kB 00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
正在安装 : vsftpd-3.0.2-22.el7.x86_64 1/1
验证中 : vsftpd-3.0.2-22.el7.x86_64 1/1

已安装:
vsftpd.x86_64 0:3.0.2-22.el7

完毕！
```


