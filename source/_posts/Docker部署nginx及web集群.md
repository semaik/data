title: Docker部署nginx及web集群
author: Semaik.
tags:
  - Docker
categories:
  - Docker
date: 2020-09-10 17:42:00
---
在容器部署基于centos镜像的nginx：

首先将nginx软件包放入物理机（虚拟机）中

进去容器后，什么都没有，环境相当干净，所以各种命令需要自己安装

使用yum provides 查看命令的软件包，并且进行安装，即可使用
```
yum provides ip/ifconfig/scp
yum -y install iproute   //ip
yum -y install net-tools //ifconfig
yum -y install openssh-clients  //scp
```
准备nginx环境
```
yum -y install gcc gcc-c++ pcre-devel zlib-devel openssl-devel make
```
查看容器的IP地址

![upload successful](/images/pasted-20.png)

退出容器：exit
 
查看本地ip，docker网卡

![upload successful](/images/pasted-21.png)

方法一：在容器中，将物理机的软件包拷贝到容器中

![upload successful](/images/pasted-22.png)

方法二：在物理机中，3a9f...0c4为容器的id，也可以使用容器名（--name指定的名称）

![upload successful](/images/pasted-23.png)

 
###### 安装nginx
```
tar zxf nginx-1.12.0.tar.gz -C /usr/src
cd /usr/src/nginx-1.12.0/
./configure --prefix=/usr/local/nginx --user=nginx --group=ngixn --with-http_stub_status_module --with-pcre && make && make install
useradd nginx
ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx
/nginx
```
 
修改页面文件
```
echo "172.17.0.2" > /usr/local/nginx/html/index.html
```
 
启动nginx

![upload successful](/images/pasted-24.png)
 
测试

![upload successful](/images/pasted-25.png)
 
为了后面做web集群时方便使用，可以将上面安装好命令与nginx的容器做一个镜像，方便后期使用。

将配置好的容器制作成一个镜像

docker commit 容器id  镜像名称

![upload successful](/images/pasted-26.png)
 
将做好的镜像导出到本地（用于做备份）

![upload successful](/images/pasted-27.png)
 
模拟误删除镜像

![upload successful](/images/pasted-28.png)

将已导出的镜像tar包，再导入进来（这时发现删除的镜像又回来了）

![upload successful](/images/pasted-29.png)
 
WEB集群
使用zu镜像做一个web2容器

![upload successful](/images/pasted-30.png)

![upload successful](/images/pasted-31.png)

修改页面文件

![upload successful](/images/pasted-32.png)

启动nginx，并退出容器

![upload successful](/images/pasted-33.png)

使用zu镜像做一个web3容器

![upload successful](/images/pasted-34.png)

修改页面文件

![upload successful](/images/pasted-35.png)

启动nginx

![upload successful](/images/pasted-36.png)

![upload successful](/images/pasted-37.png)

 
###### 本地部署nginx
安装环境
```
yum -y install  pcre-devel zlib-devel openssl-devel
```
安装nginx
```
tar zxf nginx-1.12.0.tar.gz -C /usr/src/
cd /usr/src/nginx-1.12.0/
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module --with-pcre && make && make install
useradd nginx
ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx
```
修改配置文件
vim /usr/local/nginx/conf/nginx.conf

![upload successful](/images/pasted-38.png)
启动nginx

![upload successful](/images/pasted-39.png)
测试
 
![upload successful](/images/pasted-40.png)

