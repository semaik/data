title: Docker基础操作逻辑命令
author: Semaik.
tags:
  - Docker
categories:
  - Docker
date: 2020-09-10 17:08:00
---
![upload successful](/images/pasted-15.png)

镜像小的原因：
Linux操作系统两个部分构成内核空间（kernel）、用户空间（rootfs）

查看docker的基础信息

`docker info`


查看docker中已经存在的镜像
```
docker images
参数：
	-a：列出本地所有的镜像（含中间映像层）
	-q：只显示镜像id
	--digests：显示镜像的摘要信息
	--no-trunc：显示完整的镜像信息
    ```



在docker hub中查看关于该镜像的所有镜像

```
docker search
例：
docker search ubuntu # 全网搜索ubuntu镜像
```

下载镜像
```
docker pull 镜像名   //默认下载tomcat:latest，意思是最新版，或者tomcat:3.2  下载3.2版本
```

删除镜像
```
docker rmi 镜像名： 删除镜像，默认删除 镜像名:latest，这个镜像不能在运行中
docker rmi -f 镜像名：强制删除
docker rmi -f $（docker images -qa）：删除全部镜像
```
导出镜像
```
docker save -o 压缩包名称 镜像名称
例：将镜像导出当前目录下
docker save -o centos.tar centos:latest
将镜像centos:latest另存到虚拟机当前目录下，命名为centos.tar
```
 
导入镜像
```
docker load < centos.tar
```
重命名镜像名称
```
docker tag 旧镜像名称 新镜像名称
例：
docker tag 500b941e6f79 tomcat7:jre7
```
创建不运行容器
```
docker create --name web httpd
```
创建并运行容器
```
docker run -itd -p 88:80--name test --restart always centos:7 /bin/bash
可用docker ps -a，查看容器运行状态
参数：
    -i  以交互方式登录
    -t  允许以交互方式打开终端
    -d  在后台运行
    -p  映射端口，将容器中的80端口映射成物理机中的88端口
    --name  添加容器名
    --restart always  跟随docker启动而启动，就是当服务重启时、启动时，该容器也会运行
    --rm  容器一旦停止就会被自动删除，不添加的话容器会永久保存在计算机中
    --privileged  添加特权，不添加此参数 运行一些系统命令时错
```
查看所有容器
```
docker ps -a
```
立马强制性退出容器
```
docker kill 容器id
```
停止容器
```
docker stop 容器id
```
启动容器
```
docker start 容器id
```
进入容器
```
docker exec -it 容器id /bin/bash
```
挂起容器
```
docker pause 容器id
```
取消挂起正常运行容器
```
docker unpause 容器id
```
删除容器：（删除容器前需要停止容器）
```
docker rm 容器id
如：容器正在运行中需要删除容器，就需要添加参数-f
docker rm -f 容器id
```
查看容器信息
```
docker inspect 容器id
```
编写进入容器脚本
```
vim /usr/bin/docker-enter
!/bin/sh
if [ -e $(dirname "$0")/nsenter ]; then
 with boot2docker, nsenter is not in the PATH but it is in the same folder
  NSENTER=$(dirname "$0")/nsenter
else
  NSENTER=nsenter
fi
if [ -z "$1" ]; then
  echo "Usage: `basename "$0"` CONTAINER [COMMAND [ARG]...]"
  echo ""
  echo "Enters the Docker CONTAINER and executes the specified COMMAND."
  echo "If COMMAND is not specified, runs an interactive shell in CONTAINER."
else
  PID=$(docker inspect --format "{{.State.Pid}}" "$1")
  if [ -z "$PID" ]; then
    exit 1
  fi
  shift
  OPTS="--target $PID --mount --uts --ipc --net --pid --"
  if [ -z "$1" ]; then
    # No command given.
    # Use su to clear all host environment variables except for TERM,
    # initialize the environment variables HOME, SHELL, USER, LOGNAME, PATH,
    # and start a login shell.
    "$NSENTER" $OPTS su - root
 else
    # Use env to clear all host environment variables.
    "$NSENTER" $OPTS env --ignore-environment -- "$@"
  fi
fi
```
给予权限
```
chmod +x /usr/bin/docker-enter
```
可以使用该脚本，加容器name或者容器id来启动容器
```
docker-enter 容器id
```








##### 补充：
虚拟机版本低于7.7，进如容器后无法使用网络，因为默认是关闭路由转发的，需要手动开启。
退出容器在宿主机执行以下操作：
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

##### 提示：
进入任何一个容器中，所有命令不可以使用，环境比脸都干净，需要自己手动安装命令。
如果想使用某一条命令就执行 yum provides 命令  该命令搜查出命令对应的安装包，安装成功后命令即可使用。

如：
我想使用ifcofnig这条命令查看IP地址
安装前执行命令（报错：没有该命令）

![upload successful](/images/pasted-16.png)

搜查命令对应的软件包

![upload successful](/images/pasted-17.png)
安装软件包

![upload successful](/images/pasted-18.png)
测试


![upload successful](/images/pasted-19.png)