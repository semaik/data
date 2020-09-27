title: Dockerfile文件语法
author: Semaik.
tags:
  - Docker
categories:
  - Docker
date: 2020-09-27 14:20:00
---
##### Dockerfile文件编写格式：
```java
FROM  # 指定base镜像
MAINTAINER # 指定镜像作者，后面根任意字符串
COPY # 把文件从host复制到镜像内
  COPY src dest
  COPY ["src","dest"]
  src:只能是文件
ADD # 用法和COPY一样，唯一不同时src可以是压缩包，表示解压缩到dest位置，src也可以是目录
ENV # 设置环境变量可以被接下来的镜像层引用，并且会加入到镜像中
  ENV MY_VERSION 1.3
  RUN yum -y install http-$MY_VERSION
  # 当进入该镜像的容器中echo $MY_VERSION会输出1.3
EXPOSE # 指定容器中的进程监听的端口（接口），会在docker ps -a中的ports中显示
  EXPOSE 80
VOLUME # 容器卷，后面会讲到，把host的路径mount到容器中
  VOLUME /root/htdocs /usr/local/apahce2/htdocs
WORKDIR # 为后续的镜像层设置工作路径
        # 如果不设置，Dockerfile文件中的每一条命令都会返回到初始状态
        # 设置一次后，会一直在该路经执行之后的分层，需要WORKDIR /回到根目录
CMD # 启动容器后默认运行的命令，使用构建完成的镜像实例化为容器时，进入后默认执行的命令
    # 这个命令会被docker run启动命令替代
    # 如：docker -it --rm centos echo "hello"
    # echo "hello"会替代CMD运行的命令
  CMD ["nginx", "-g", "daemon off"]  # 该镜像实例化后的容器，进入后运行nginx启动服务
ENTRYPOINT # 容器启动时运行的命令，不会被docker run的启动命令替代
```

![upload successful](/images/pasted-80.png)

**镜像的命名规则：**

image name = 镜像站地址+作者命名+服务名称:标签

##### Dockerfile文件排错方法
当个构建镜像时Dockerfile中报错，先来制作一个错误的Dockerfile
```java
[root@localhost ~]# vim Dockerfile
FROM busybox
RUN touch tmpfile
RUN /bin/bash -c echo "continue to build..."
COPY testfile /
```
使用这个Dockerfile去构建镜像
```java
[root@localhost ~]# docker build -t testerror /root
Sending build context to Docker daemon  4.336MB
Step 1/4 : FROM busybox
 ---> 83aa35aa1c79
Step 2/4 : RUN touch tmpfile
 ---> Running in 41a8dad29cd6
Removing intermediate container 41a8dad29cd6
 ---> 8cd5c9a720bb
Step 3/4 : RUN /bin/bash -c echo "continue to build..."
 ---> Running in bc1849fa8144
/bin/sh: /bin/bash: not found
The command '/bin/sh -c /bin/bash -c echo "continue to build..."' returned a non-zero code: 127
```
发现构建镜像过程中出现了报错`/bin/sh: /bin/bash: not found`

可以看到报错信息是从第三步才开始的，说明前两步是没有问题的，可以通过进入前两步最后结束的镜像id中去查看错误，进入前两层的镜像id是一个正常的容器环境，将第三步无法执行的命令，在容器中运行，将会看到真正的错误是没有`/bin/bash`这个环境
```java
[root@localhost ~]# docker run -it  8cd5c9a720bb
/ # /bin/bash -c echo "continue to build..."
sh: /bin/bash: not found
```
因为构建这个镜像使用的是busybox，它使用的环境是`/bin/sh`

修改后，重新构建成功
```java
[root@localhost ~]# docker build -t testerror /root
Successfully built ae5870fff063
Successfully tagged testerror:latest
```
运行容器后，可以看到创建的tmpfile和复制testfile
```java
[root@localhost ~]# docker run -it testerror 
/ # ls
bin       etc       proc      sys       tmp       usr
dev       home      root      testfile  tmpfile   var
```
##### 镜像构建过程
在构建命令执行时输出的一大堆信息中，是执行Dockerfile中的每一行，最关键的几行信息如下
```java
Step 1/5 : FROM centos  # 调用centos
 5e35e350aded   # centos镜像id
  
Step 2/5 : RUN yum install httpd -y
 Running in a16ddf07c140  # 运行一个临时容器来执行install httpd
Removing intermediate container a16ddf07c140  # 完成后删除临时的容器id
 b51207823459  # 生成一个镜像
  
Step 3/5 : RUN yum install net-tools -y
 Running in 459c8823018a # 运行一个临时容器执行install net-tools
Removing intermediate container 459c8823018a # 完成后删除临时容器id
 5b6c30a532d4  # 再生成一个镜像
 
Step 4/5 : RUN yum install elinks -y
 Running in a2cb490f9b2f  # 运行一个临时容器执行install elinks
Removing intermediate container a2cb490f9b2f # 完成后删除临时容器id
 24ba4735814b # 生成一个镜像
 
Step 5/5 : CMD ["/bin/bash"]
 Running in 792333c88ba8  # 运行临时容器，执行/bin/bash
Removing intermediate container 792333c88ba8  # 完成后删除临时容器id
 09266c896243  # 生成镜像
Successfully built 09266c896243  # 最终成功后的镜像id就是最后生成的镜像id
```
每一步生成一个镜像，都属于一个`docker commit`的执行结果

在这个过程中一共生成了三个镜像层，都会被存储在graph中，包括层与层之间的关系，查看docker images中生成的镜像id是否为最后生成的镜像id，`FROM`和`CMD`都不算做镜像层
```java
[root@localhost ~]# docker images
REPOSITORY             TAG       IMAGE ID       CREATED          SIZE
chai/centos-http-net   latest    09266c896243   10 seconds ago   581MB
```
通过`docker history`也可以看到简单的构建过程，这几个过程的size容量加起来也就是最终生成镜像的大小，也可将这里的镜像id和上面过程中的id进行对比，我们所看到的是三个yum就是形成的三个镜像层
```java
[root@localhost ~]# docker history chai/centos-http-net:latest 
IMAGE         CREATED          CREATED BY                                      SIZE    COMMENT
09266c896243  17 minutes ago   /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B                  
24ba4735814b  17 minutes ago   /bin/sh -c yum install elinks -y                121MB               
5b6c30a532d4  18 minutes ago   /bin/sh -c yum install net-tools -y             112MB               
b51207823459  18 minutes ago   /bin/sh -c yum install httpd -y                 145MB               
5e35e350aded  4 months ago     /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B                  
<missing>     4 months ago     /bin/sh -c #(nop)  LABEL org.label-schema.sc…   0B                  
<missing>     4 months ago     /bin/sh -c #(nop) ADD file:45a381049c52b5664…   203MB
```
![upload successful](/images/pasted-81.png)

![upload successful](/images/pasted-82.png)

![upload successful](/images/pasted-83.png)

![upload successful](/images/pasted-84.png)