title: 对容器进行cpu的使用控制
author: Semaik.
tags:
  - Docker
categories:
  - Docker
date: 2020-09-27 14:50:00
---
##### 控制容器中cpu使用的优先级
默认情况下所有的容器都平等的使用cpu，并没有限制，Docker可以通过内容进行限制

**关键词**
```java
-c/--cpu-shares:控制cpu优先级
--cpuset-cpus:指定使用哪块cpu
```
**实验环境**

将计算机调整为单核cpu，内存4G

**实验目的**

启动多个容器，指定容器使用cpu的优先级

**实验步骤**
```java
[root@localhost ~]# systemctl start docker
```
启动一个名为aa的容器，并指定cpu优先级为1024
```java
[root@localhost ~]# docker run -itd --name aa --cpu-shares 1024 centos /bin/bash
196380b6bbb7a044e2aafec7059b37db573f9612f3705d93aa1d8975e94ffad7
```
在启动一个名为bb的容器，并指定cpu优先级为512
```java
[root@localhost ~]# docker run -itd --name bb --cpu-shares 512 centos /bin/bash
03dad75a9447768480e758e044857d6306bd73b89bccb2725594ead830d38e28
```
我们可以在物理机的cgroup目录中看到限制容器使用cpu的优先级，需要用到以上启动容器时返回的容器id

查看aa容器的CPU优先级
```java
[root@localhost ~]# cd /sys/fs/cgroup/cpu/docker/196...ad7
 可以看到该目录中存放了，docker程序中，aa容器的所有cpu资源的控制项
[root@localhost 196...ad7]# ls
cgroup.clone_children  cpuacct.usage         cpu.rt_period_us   notify_on_release
cgroup.event_control   cpuacct.usage_percpu  cpu.rt_runtime_us  tasks
cgroup.procs           cpu.cfs_period_us     cpu.shares
cpuacct.stat           cpu.cfs_quota_us      cpu.stat
[root@localhost 196...ad7]# cat tasks
3750  # 这个文件里面存放了这个容器在物理机运行的pid号
[root@localhost 196...ad7]# ps aux | grep 3750
root   3750  0.0  0.0  11828  1656 pts/0  Ss+  08:29  0:00 /bin/bash
root   4369  0.0  0.0 112712   956 pts/2  R+   08:37  0:00 grep --color=auto 3750
 查看该容器的cpu优先级

[root@localhost 196...ad7]# cat cpu.shares
1024
```
查看bb容器的cpu优先级
```java
同样是docker目录下的另一个容器
[root@localhost 196...ad7]# cd ../03d...e28/
[root@localhost 03d...e28]# cat cpu.shares
512
```
docker程序的cpu优先级
```java
[root@localhost 03d...e28]# cd ..
[root@localhost docker]# cat cpu.shares 
1024  # docker在主机内的cpu优先级
[root@localhost docker]# cat tasks
```
**注意目录结构**

下载一个docker用来测试的镜像
```java
[root@localhost ~]# docker pull progrium/stress
```
使用测试镜像启动容器，用来测试查看cpu优先级

`--cpu用来限制cpu工作线程的数量`
```java
[root@localhost ~]# docker run -itd --name cc -c 512 progrium/stress --cpu 1
6cff87f45ac88f0a27a250f099dc46d4a2dcdc191f2599a73b3e649a5ed91e80
[root@localhost ~]# docker run -itd --name dd -c 1024 progrium/stress --cpu 1
2a3f49cccb8addc69684bf96d3d95fc438768d98d942c60cd6a5df05b435068a
```
使用top查看两个测试线程（stress ）的cpu使用率，也就是谁优先使用多少
```java
[root@localhost ~]# top
 关键信息如下，一个66.8%，一个32.9%，两个加起来几乎等于100
   PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
  4842 root      20   0    7304    100      0 R 66.8  0.0   1:25.19 stress 
  4789 root      20   0    7304     96      0 R 32.9  0.0   0:58.09 stress
```
cpu的优先级只有在多个容器使用时才生效，说明他俩会抢占cpu资源，如果只有一个容器，即使设置了cpu优先级，它也会把cpu资源尽可能多的去使用

控制容器使用某块cpu
分配第一个和第二个cpu给容器（--cpuset只适用于多核cpu时使用）

第一个cpu从0起计算
```java
docker run -it --name cpu --cpuset-cpus="0,1" centos /bin/bash
[root@8cb4e22abd77 /]# cat /sys/fs/cgroup/cpuset/cpuset.cpus
0-1
```
