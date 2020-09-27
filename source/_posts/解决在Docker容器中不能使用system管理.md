title: 解决在Docker容器中不能使用system管理
author: Semaik.
tags:
  - Docker
categories: []
date: 2020-09-27 15:00:00
---
**例：httpd服务**

![upload successful](/images/pasted-85.png)
```java
[root@a4120181b4d3 /]# systemctl start httpd
报错：Failed to get D-Bus connection: Operation not permitted
```
 
**解决方法一：**

运行容器时提权
```java
docker run -tid --name centos_1 --privileged=true centos:latest /sbin/init
```
>-privileged：提权操作

**解决方法二：**
进入配置文件

vi /usr/lib/systemd/system/httpd.service

![upload successful](/images/pasted-86.png)
复制/usr/sbin/httpd

启动httpd服务

![upload successful](/images/pasted-87.png)

![upload successful](/images/pasted-88.png)