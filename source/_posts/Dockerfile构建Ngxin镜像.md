title: Dockerfile构建Ngxin镜像
author: Semaik.
tags:
  - Docker
categories: []
date: 2020-09-27 14:31:00
---
##### Dockerfile构建nginx镜像
>要求：dockerfile做nginx源码镜像。并且启动后容器后可以直接启动。

首先拖入nginx的tar包到物理机路径，与Dockerfile文件放在同一目录

编写Dockerfile
```java
[root@localhost ~]# vim Dockerfile 
FROM centos  # 调用docker中已下载的centos镜像
MAINTAINER FeiYi  # 作者名为FeiYi
 安装环境所需包
RUN yum -y install net-tools iproute pcre-devel openssl-devel gcc gcc-c++ make zlib-devel elinks
ADD nginx-1.11.1.tar.gz /usr/src  # 解压本地host中的nginx包到容器中的/usr/src目录
ENV NGINX_DIR /usr/src/nginx-1.11.1 # 定义环境变量
WORKDIR $NGINX_DIR  # 进入容器中的解压目录
 编译安装
RUN ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx && make && make install
 回到根目录
WORKDIR /
 创建程序用户
RUN useradd nginx
 优化命令环境
RUN ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
 监听端口80
EXPOSE 80
 后台启动nginx服务
CMD ["nginx", "-g", "daemon off;"]
```
使用Dockerfile构建镜像
```java
[root@localhost ~]# docker build -t chai/centos-nginx-start /root/
Successfully built c7efa3d71211
Successfully tagged chai/centos-nginx-start:latest
```
使用构建完成的镜像实例化一个容器，验证80端口是否启用

因为我们最后使用CMD去启动nginx，所以docker run后直接加/bin/bash会替代nginx启动的执行。所以使用以下方法进入容器
```java
[root@localhost ~]# docker run -itd --name nginxtest chai/centos-nginx-start
da7fe6d1541751dd86078848bf46c532cca9efb40832271bbf02c0eb7a25a1f8
[root@localhost ~]# docker exec -it nginxtest /bin/bash
[root@da7fe6d15417 /]# netstat -anpt | grep 80
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1/nginx: master pro
```
查看ip并访问页面
```java
# ip为172.17.0.3
[root@localhost ~]# curl -I 172.17.0.3
HTTP/1.1 200 OK
Server: nginx/1.11.1
Date: Fri, 27 Mar 2020 07:08:49 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Fri, 27 Mar 2020 06:58:35 GMT
Connection: keep-alive
ETag: "5e7da41b-264"
Accept-Ranges: bytes
```