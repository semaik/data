title: Keepalived
author: Semaik.
tags:
  - Linux
categories: []
date: 2020-11-03 15:49:00
---
Keepalived：最初给LVS负载均衡集群中的服务节点提供健康检查功能，后来因为集成了VRRP协议，可以实现解决服务节点的单点故障，提高服务的可靠性，支持高可用集群的部署

VRRP协议

VRRP（虚拟路由冗余协议）：由多台物理路由器组成一台高性能的虚拟路由器，多个物理路由器之间通过优先级举出主节点，其它节点为从节点，从节点不工作只接收主节点发来的VRRP通告，主节点管理虚拟IP并对外提供服务，主节点定时给从节点发送VRRP通告，通告中包含着主节点的优先级，当从节点在计时器的时间到了之后接收不到主机点发送的VRRP通告时，就认为主节点不可用，此时，从节点就会根据优先级选举出新的主节点并接管虚拟IP对外提供服务，这个切换过程对于客户端来说是透明的，这样解决了单点故障，保证了服务的可用性


无故ARP（免费ARP）：特点是arp广播包中源IP目的IP源MAC目的MAC都是发送方的，也就是都是虚拟IP和虚拟MAC，

作用：

1.可以检测是否有地址冲突

2.可以更新终端设备的ARP缓存表

##### 实验环境：


| 系统 | IP | 服务 |
| :-----:| :----: | :----: |
| Centos7.4 | 1.1.1.1 | keepalived主 |
| Centos7.4 | 1.1.1.2 | keepalived备 |
| Centos7.4 | 1.1.1.3 | Nginx |
| Centos7.4 | 1.1.1.4 | Nginx |
| * | 1.1.1.111 | VIP|
| Centos7.4	|	1.1.1.10	|	Client	|

##### 配置keepalived主
###### 使用yum安装keepalived服务
```java
# yum -y install keepalived
```
###### 修改配置文件
```java
vim /etc/keepalived/keepalived.conf
global_defs {			//默认全局配置
   notification_email {		//指定该keepalived节点故障时接收邮件的收信人
     acassen@firewall.loc	
     failover@firewall.loc	
     sysadmin@firewall.loc	
   }
   notification_email_from Alexandre.Cassen@firewall.loc		//keepalived故障时发送邮件的发信人
   smtp_server 192.168.200.1		//指定邮件服务器的IP，stmp简单邮件传输协议，使用端口25
   smtp_connect_timeout 30		//与邮件服务器的连接超时时间，单位s，可以自定义
   router_id master		//该节点的唯一表示，用于发邮件时表示该节点，可以是主机名，也可以是自己指定的名字
}

vrrp_instance VI_1 {		//定义一个VRRP实例，处于同一个组中的节点使用的实例名字应该一致，默认使用名字VI_1
    state MASTER		//该节点的状态，MASTER为主，BACKUP为备，必须大写，但是只是用来标识节点状态，节点主备是由优先级决定的
    interface ens33		//指定主节点从那块网卡发送VRRP通告
    virtual_router_id 51		//指定该实例所属的虚拟路由组的id，属于同一个组的节点使用的id应该相同，id取值范围为0-255
    priority 100		//指定该节点的优先级，属于同一个组的节点优先级最高为主节点，取值范围为1-255，配置超过取值范围的值都默认视为100
添加：nopreempt		//将该节点设置为非抢占模式
    advert_int 1		//主节点每隔1s发送一次VRRP通告，时间可以自定义
    authentication {		//配置主备节点之间的认证方式以及密码
        auth_type PASS		//认证类型，主备必须一致，有PASS和HA两种，PASS密码是明文的，HA是密文的
        auth_pass 1111		//认证密钥，主备必须一致，只识别前八位
    }
    virtual_ipaddress {		//配置虚拟IP，只有主节点才会拥有该地址，只能通过ip add查看，ifconfig是查看不到的
        1.1.1.111/8		//与物理机IP同网段
    }
}

virtual_server 1.1.1.111 80 {		//指定LVS集群使用的虚拟IP以及端口
    delay_loop 6		//指定对服务节点进行健康检查的间隔时间
    lb_algo rr 		//该集群的使用的调度算法
    lb_kind DR		//该集群的调度模式
    persistence_timeout 0		//服务节点的连接时间，0表示为短链接
    protocol TCP		//集群中节点之间通过TCP协议通信
    netmask 255.0.0.0	//VIP掩码

	real_server 1.1.1.3 80 {		//向集群中添加服务节点
   	weight 1		//设置节点的权重，默认为1，如果权重为0则表示该节点不可用
	   TCP_CHECK {	//启用TCP健康检查
            connect_timeout 1		//对服务节点做健康检查的连接超时时间，1s可以自定义
            nb_get_retry 3		//所健康检查的重试次数，可自定义
            delay_before_retry 1		//每次健康检查之间间隔时间，可自定义
            connect_port 80		//针对哪个端口进行TCP检查
            }
	 }
	real_server 1.1.1.4 80 {		
   	weight 1
	   TCP_CHECK {
            connect_timeout 3	
            nb_get_retry 3	
            delay_before_retry 3
            connect_port 80
            }
     }
}
```
###### 将配置文件拷贝给keepalived备
```java
# scp /etc/keepalived/keepalived.conf root@1.1.1.2:/etc/keepalived/keepalived.conf
```
###### 修改备的配置文件
```java
# vi /etc/keepalived/keepalived.conf
router_id backup
state BACKUP
priority 90
```
###### 启动主从的keepalived服务
```java
# systemctl restart keepalived
```
###### 配置Nginx（两台同样步骤）
```java
# 配置虚拟IP
# cd /etc/sysconfig/network-scripts/
# cp ifcfg-lo ifcfg-lo:1
# vi ifcfg-lo:1
DEVICE=lo:1
IPADDR=1.1.1.111	//虚拟IP
NETMASK=255.255.255.255
NAME=lo:1
# 多余的删除
```
> 可以通过ifconfig命令来配置不过是临时IP重启失效

>ifconfig lo:1 1.1.1.111 netmask 255.255.255.255
###### 重启网卡
```java
systemctl restart network
```
###### 修改系统内核文件
```java
# vim /etc/sysctl.conf
net.ipv4.conf.lo.arp_ignore=1
net.ipv4.conf.default.arp_ignore=1	
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.default.arp_announce=2
net.ipv4.conf.all.arp_announce=2
# sysctl -p
```
###### 修改web首页文件（第二台web改成NO.2）
```java
# echo "Wecom to nginx NO.1" > /usr/local/nginx/html/index.html
```
###### 放行防护墙
```java
# firewall-cmd --add-port=80/tcp --permanent
# firewall-cmd --add-service=nginx --permanent
# firewall-cmd --reload
# setenforce 0
```
###### 客户端验证
```java
# curl 1.1.1.111
wecom to nginx NO.1
```