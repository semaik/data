title: Ansible自动化运维工具
author: Semaik.
tags:
  - Ansible
categories:
  - Ansible
date: 2020-09-18 17:16:00
---
![upload successful](/images/timg.jpg)

##### Ansible及自动化介绍
ansible：提高效率的工具，实现自动化运维

自动化：系统自动化（PXE+KS/PXE+COBBLER)
程序自动化（Ansible/Saltstack/Puppet）
代码自动化（Jenkins）

程序自动化工具分为两类：

（1）C/S架构：Saltstack /Puppet

（2）无客户端模式：Ansible（主控端/被控端）

区别：

Ansible：基于python开发，使用ssh协议，没有客户端，200-300台，适用于中小型应用环境，一个系统控制多台主机，有两个角色：主控端和被控端

Saltstack ：基于python开发，支持统一管理，比较轻量级 支持管理500台服务器，python编写，需要部署agent，主控端通过安装在被控端的代理来对被控端进行操作

Puppet：Ruby语言编写，重型程序，适合大型环境，谷歌公司在用，软件过于复杂，国内一般不到1000+

##### Ansible特性
* 模块化：调用特定的模块，完成特定的任务，约3000模块，每个模块功能不同
* 有paramiko（基于ssh开发，主要做远程控制）PyYAML（可以实现剧本）Jinja2（模板语言），这三个模块是Ansible的核心
* 支持自定义模块（python）
* 安全，基于openssh
* 支持playbook编排任务（PyYAML)
* 幂等性：一个任务执行一遍和n变效果一样，不会因为重复执行而带来意外情况（如：复制文件时，执行两次会报是否覆盖，而使用Ansible可以避免这种情况，后面copy模块会讲到）

##### 部署Ansible环境
------------------------------------------

实验环境：四台linux服务器


* 192.168.1.1（用作Ansible服务器）

* 192.168.1.4（被控端）

* 192.168.1.5（被控端）

* 192.168.1.6（被控端）

实验目的：使用控制端来控制3个被控端工作

实验步骤：
控制端部署
在控制端（192.168.1.1）安装epel-release和Ansible（使用网络yum）

epel-release：Extra Packages for Enterprise Linux（企业版linux扩展包）
```java
创建yum缓存，加快yum安装速度
[root@localhost ~]# yum makecache fast
epel是一个系统扩展yum源
[root@localhost ~]# yum -y install epel-release
[root@localhost ~]# yum -y install ansible
```
##### 设置控制端免密登录被控端
通过ssh密钥对实现
```java
[root@localhost ~]# ssh-keygen				# 生成私钥和公钥，一直回车即可
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:2puXlUxjnsxKrVhnGbNahVhbZLJrMr9q/8B9uDr144Y root
The key's randomart image is:
+---[RSA 2048]----+
|            ..o  |
|            .+.  |
|           o.+   |
|          . O..  |
|        S oOoX   |
|       o  o*/... |
|      . .+ X+.+..|
|        .oB .E =.|
|        oo.o++=..|
+----[SHA256]-----+
 
# 默认生成在当前用户的.ssh/目录下
[root@localhost ~]# ls /root/.ssh
id_rsa  id_rsa.pub
 
# 将生成的公钥文件发送到指定的控制端，需要用到root密码
[root@localhost ~]# ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.1.4
[root@localhost ~]# ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.1.5
[root@localhost ~]# ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.1.6
# 此时在1.4的被控端的用户目录下的.ssh目录下会生成一个authorized_keys文件
[root@localhost ~]# ls /root/.ssh
authorized_keys
# 在控制端使用ssh登录到1.4，发现不使用密码即可
[root@localhost ~]# ssh root@192.168.1.4
```
##### 配置Ansible的配置文件
ansible.cfg Ansible主配置文件

hosts 被控端的主机清单

roles 角色

修改主机清单：将被控端写入

在使用ansible操作时，可以通过分组名对，组中所有主机进行相同操作

格式为：
```sh
[分组名]
被控端ip1
被控端ip2
...
```
例：

```sh
在文件末尾添加，如果有DNS，直接写域名也可以
[root@localhost ~]# vim /etc/ansible/hosts 
添加：
[dbserver]
192.168.1.4			# 被控端
 
[webserver]
192.168.1.5			# 被控端
192.168.1.6			# 被控端
```
##### Ansible简单操作
```sh
ansible --version			# 查看ansible版本
ansible-doc -l		# 查看ansible支持模块
ansible-doc -s 模块名		# 关于模块的帮助信息
如：ansible-doc -s ping
ansible-doc -h   	# 帮助信息
 
-------关于模块操作的语法-------
ansible 操作对象 -m 模块名 -a '模块参数'
	-a：在某些模块中可以省略
ansible 操作对象 -m 模块名 -a '模块参数' --limit x.x.x.x
    --limit：可以指定操作对象中的某个ip来执行该模块
```