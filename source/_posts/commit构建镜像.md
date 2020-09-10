title: commit构建镜像
author: Semaik.
tags:
  - Docker
categories:
  - Docker
date: 2020-09-10 17:40:00
---
###### 用docker commit构建映像
```
　　1.docker run -i -t centos /bin/bash　　//启动一个容器，启动后默认进入该窗口的bash进程
　　2.yum install -y epel-release.noarch　　//为启动的窗口安装软件源
　　3.yum install -y nginx　　//为启动的容器安装nginx
　　4.exit　　//退出该容器，回到宿主机环境
　　5.docker commit 容器ID zx/nginx　　//将上次创建的窗口ID当作映像提交到本地,zrs是repository名称,nginx是image名称
　　6.docker images　　//可以查看到上步提交的映像
  ```
###### 注意：
　　　　1.一定要区分开容器和映像的区别；
    
　　　　2.有了zx/nginx后，下次可以直接使用该映像来启动容器，而不用为这个容器安装nginx;
    
　　　　3.docker commit -m="this is a container contains nginx" --author="zx" 容器ID zx/nginx，类似git不作多余解释；