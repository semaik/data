title: Docker私有仓库
author: Semaik.
tags:
  - Docker
categories:
  - Docker
date: 2020-09-10 17:30:00
---
##### [Docker的公共仓库](https://hub.docker.com/)

由Docker公司维护的Registry，用户也可以将自己的镜像保存到DockerHub上中免费的response中，因为在国内访问由很多的限制
登录方法
```
docker login -u 用户名 密码 https://
```
登录后下载方法
```
docker pull 用户名/images名:tag
```
##### [Quay](https://quay.io/)

被红帽收购后速度相当慢，红帽对国内还不是完全开放，是一个私人注册托管中心，它上面更多的是很多用户自己上传制作的镜像，没有很多的官方镜像，使用面也不是很广

##### 阿里云镜像仓库

是国内提供docker镜像的仓库，需要用户登录后在控制中心，找到容器镜像服务，可以镜像镜像搜索、新建自己的仓库、也包括官方镜像和其他用户开放的镜像，官方镜像是直接拿取的DockerHub的镜像，属于国内的一个缓存。

这些公有镜像不适合工作中去使用，接下来就看私有仓库

##### 使用registry私有仓库镜像
Harbor仓库在微服务架构的文章中已经写到怎么使用了，这里就不多说了

环境要：Docker服务器必须开启路由转发

使用两台主机来完成接下来验证私有仓库的使用

|主机			  |   	服务       |	备注 |
|:---------------:|:--------------------:|:--------:|
|192.168.1.11	|已安装启动docker	|私有仓库|
|192.168.1.12	|已安装启动docker	| 		 |

###### 步骤
两台主机都做路由转发
```
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```
###### 下载私库镜像

`192.168.1.11`

下载2版本的私有仓库镜像，2版本是go语言写的，速度和安全性都比1要好，1是python写的
```
[root@localhost ~]# docker pull registry:2
```
创建私库在本地物理机的存放路径
```
[root@localhost ~]# mkdir -p /opt/data/registry
```
运行私库

使用镜像实例化，并进行相应的指定，后台运行仓库
```
docker run -itd -p 5000:5000 --restart always \
--volume /opt/data/registry/:/var/lib/registry registry:2
# 解释参数
-p：指定端口，5000:5000表示在物理机开一个端口，在容器内开一个端口
--restart always：无论容器遇到什么错误就会重启容器
-v/--volume：本地目录映射到容器内的目录
5000：是registry的端口号
/var/lib/registry：是registry仓库中存放镜像的目录
```
运行起来后，在本地是可以监听到5000端口的
```
[root@localhost ~]# netstat -anput | grep 5000
tcp6     0      0 :::5000      :::*         LISTEN      80040/docker-proxy
```
查看仓库中的镜像
```
[root@localhost ~]# curl 192.168.1.11:5000/v2/_catalog
{"repositories":[]}  # 表示没有任何镜像
```
###### 指定私库地址

需要修改docker的服务文件，让docker知道私有仓库地址
```
[root@localhost ~]# vim /usr/lib/systemd/system/docker.service 
# 14行的末尾添加--insecure-registry 192.168.1.11:5000
# 14行也就是以ExecStart开头的一行
```
重新加载配置文件，并重启服务生效
```
[root@localhost ~]# systemctl daemon-reload 
[root@localhost ~]# systemctl restart docker
```
查看服务状态，可以看到是否识别到了私有仓库
```
[root@localhost ~]# systemctl status docker -l
# 找到以下关键信息，则代表识别私库地址成功
   CGroup: /system.slice/docker.service
           ├─80357 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --insecure-registry 192.168.1.11:5000
           └─80477 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 5000 -container-ip 172.17.0.2 -container-port 5000
 ```
`192.168.1.12`
进行修改docker的文件去指向docker的私有仓库地址
```
[root@localhost ~]# vim /usr/lib/systemd/system/docker.service 
# 14行的末尾添加--insecure-registry 192.168.1.11:5000
# 14行也就是以ExecStart开头的一行
[root@localhost ~]# systemctl daemon-reload 
[root@localhost ~]# systemctl restart docker
```
###### 验证

`192.168.1.11`
使用tag为镜像改个名字
注意：改名字要按照格式来私库ip:5000/镜像名，否则会上传失败
此时镜像名的作用：push到私库中（私库ip:5000），镜像名为httpd
```
[root@localhost ~]# docker tag httpd:latest 192.168.1.11:5000/httpd
[root@localhost ~]# docker tag centos:latest 192.168.1.11:5000/centos
[root@localhost ~]# docker tag busybox:latest 192.168.1.11:5000/busybox
```
将改名后的镜像上传到私有仓库中
```
[root@localhost ~]# docker push 192.168.1.11:5000/httpd
The push refers to repository [192.168.1.11:5000/httpd]
25a92d79dbfe: Pushed 
b5432b464616: Pushed 
e6699b4fc2e3: Pushed 
762ba19e7ef1: Pushed 
f2cb0ecef392: Pushed 
[root@localhost ~]# docker push 192.168.1.11:5000/centos
The push refers to repository [192.168.1.11:5000/centos]
77b174a6a187: Pushed 
[root@localhost ~]# docker push 192.168.1.11:5000/busybox
The push refers to repository [192.168.1.11:5000/busybox]
a6d503001157: Pushed
```
查看上传后的私库中的镜像
`192.168.1.12`
查看到的镜像名和前面讲的是一样的
```
[root@localhost ~]# curl 192.168.1.11:5000/v2/_catalog
{"repositories":["busybox","centos","httpd"]}
```
下载镜像，速度相当快
```
[root@localhost ~]# docker pull 192.168.1.11:5000/httpd
# 最后会输出下载地址
Status: Downloaded newer image for 192.168.1.11:5000/httpd:latest
192.168.1.11:5000/httpd:latest
```
`192.168.1.11`
查看镜像映射到本地的存储目录
```
[root@localhost ~]# ls /opt/data/registry/docker/registry/v2/repositories
busybox  centos  httpd
```
###### 查看仓库中镜像的信息
查看httpd镜像的tags
```
[root@localhost ~]# curl 192.168.1.11:5000/v2/httpd/tags/list
{"name":"httpd","tags":["latest"]}
```
查看镜像的hash值
```
curl 192.168.1.11:5000/v2/httpd/manifests/latest \
--header "Accept: application/vnd.docker.distribution.manifest.v2+json"
# 找到第一个"digest":的值就是该镜像的hash值，以下的"digest":都是镜像层的hash值
```
删除私库镜像
```
# 直接进入目录删除其中一个镜像的目录即可
[root@localhost ~]# rm -rf /opt/data/registry/docker/registry/v2/repositories/httpd
[root@localhost ~]# curl 192.168.1.11:5000/v2/_catalog
{"repositories":["busybox","centos"]}
 ```
 
