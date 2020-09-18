title: Ansible常用模块
author: Semaik.
tags:
  - Ansible
categories:
  - Ansible
date: 2020-09-18 17:32:00
---
###### ping模块：
检测各主机之间的连接状况

如：
```sh
[root@localhost ~]# ansible all -m ping
```
###### command模块：
主要用于执行简单的shell命令：单个命令

如：ls、cat等类似简单命令，不带有管道符类似操作的使用shell模块

例：
```sh
[root@localhost ~]# ansible dbserver -m command -a 'ls /root'
# 配置主机清单时dbserver中，只写入了1.4，所以结果只有1.4主机运行ls /root
192.168.1.4 | CHANGED | rc=0 >>
anaconda-ks.cfg
initial-setup-ks.cfg
公共
模板
视频
图片
文档
下载
音乐
桌面
```
###### shell模块
执行linux复杂命令
```sh
[root@localhost ~]# ansible dbserver -m shell -a 'ls /root/ | wc -l'
192.168.1.4 | CHANGED | rc=0 >>
10
```
###### args
如果在编译安装包时，需要进入目录进行配置，使用以下
```sh

- shell: ./configure && make && make install
  args:
    chdir: 解压包路径
```
###### cron模块
执行计划任务，用于为被控制端设置自动化任务
```sh

# 设置任务
[root@localhost ~]# ansible dbserver -m cron -a 'minute="*/2" job="date >> /tmp/date.txt" name="show date" state=present'
state=persent:一般表示新增
# 删除任务，只需要指定name即可
[root@localhost ~]# ansible dbserver -m cron -a ' name="show date" state=absent'
state=absent：一般表示移除，可以用来删除计划任务
# cron的其他关键字参考
[root@localhost ~]# ansible-doc -s cron
```
###### user模块
常用操作
```sh
useradd 用户名		# 创建普通用户
passwd 用户名		# 设置用户密码
useradd -M -s /sbin/nologin 用户名		# 创建的用户没有家目录，不能登录
useradd -u 用户id -g gid 用户名   # 创建用户时指定uid和gid
userdel -r 用户			# 连同用户家目录一起删除用户
```
以上操作通过ansible来完成
```sh
ansible 操作对象 -m user -a 'name=用户名 state=present'	# 创建用户
# openssl passwd "123.com"用来获取加密后的密码
ansible 操作对象 -m user -a 'name=用户名 password="加密密码" state=present'   # 创建用户并设置密码
ansible 操作对象 -m shell -a 'echo "123.com" | passwd --stdin 用户名'   # 设置用户密码
# 创建无家目录，不能登录的用户
ansible 操作对象 -m user -a 'name=用户名 create_home=no shell=/sbin/nologin state=present'  
# 创建用户是指定uid和基本组
ansible 操作对象 -m user -a 'name=用户名 uid=id号 group=组名 state=present'
# 连同用户家目录一同删除
ansible 操作对象 -m user -a 'name=用户名 remove=yes state=absent'
```
###### group模块
```sh
添加组
ansible 操作对象 -m group -a 'name=组名 system=yes state=present gid=ID号'
system=yes：是否是公共组
删除组
ansible 操作对象 -m group -a 'name=组名 state=absent'
```
###### copy模块
1、从主控端复制文件到被控端（类似scp）
```sh
ansible all -m copy -a 'src=主控端文件路径 dest=被控端保存路径'
# 在被控端查看是否复制文件成功
ansible all -m shell -a 'ls 被控端保存文件路径'
```
2、主控端控制被控端复制和粘贴被控端的文件
```sh
ansible 操作对象 -m copy -a 'src=被控端源文件路径 dest=被控端目标位置 remote_src=yes'
# 验证ansible的幂等性，remote_src=yes，当发现同文件名时，不执行此命令
ansible 操作对象 -m copy -a 'src=被控端源文件路径 dest=被控端目标位置 remote_src=yes backup=yes'
# 修改被控端/root/resolv.conf的内容，使其可以发生文件覆盖，此时在加上backup进行文件覆盖前的备份
```
###### file模块
1、修改文件属性（owner（属主） group（属组） mode（权限） 对应linux命令 chown chmod

```sh
# 改变属主属组
ansible 操作对象 -m file -a 'path=被控端都存在的要修改属主属组的文件路径 owner=被控端都存在的用户 group=被控端都存在的组 recurse=yes'
 recurse=yes：表示递归设置属主属组
# 修改文件权限
ansible 操作对象 -m file -a 'path=被控端存在的文件路径 mode=7777 recurse=yes'
 使用mnnn样式的四位8进制数表示，recurse=yes：对当前目录中的所有内容递归权限
``` 

2、软链接、硬链接

```sh
# 软链接
ansible 操作对象 -m file -a 'src=被控端源文件 dest=软链接文件路径 state=link'
# 硬链接
ansible 操作对象 -m file -a 'src=被控端源文件 dest=硬链接文件路径 state=hard'
```
3、创建文件和目录
```sh
# 创建文件
ansible 操作对象 -m file -a 'path=文件路径及文件名 state=touch'
# 创建目录
ansible 操作对象 -m file -a 'path=目录路径及目录名 state=directory'
# 删除文件或者目录
ansible 操作对象 -m file -a 'path=被控端删除文件或目录路径 state=absent'
```
###### yum模块
主控端控制被控端，使其使用yum安装rpm包

前提：被控端的yum可用
```sh
# 安装rpm某包
ansible 操作对象 -m yum -a 'name=包名,包名1... state=installed/present    # 默认不写state是installed/present
# 卸载rpm包
ansible 操作对象 -m yum -a 'name=包名,包名1... state=removed/absent
```
###### service模块
操控被控端开启、关闭、重启、重载（视具体服务而定）

notice：service可用管理rpm包安装的服务，源码安装的服务建议使用shell模块直接打命令

服务状态：started/stopped/restarted/reloaded
```sh
ansible 操作对象 -m service -a 'name=服务名 state=服务状态'
```
###### hostname模块
修改主机名操作

hostname 主机名 临时

hostnamectl set-hostname 主机名 永久

vim /etc/hosts 修改配置文件
```sh
ansible 操作对象 -m hostname -a 'name=主机名'
```

###### script模块
用于将主控端的脚本在被控端执行，shell脚本和python脚本

写一个简单创建用户的脚本
```sh
!/bin/bash
for i in {1..10}
    do
        useradd user$i
        echo '123.com' | passwd --stdin user$i
    done
```
添加脚本可执行权限

`chmod +x users.sh
`
使用script模块执行脚本
```sh
# 执行脚本
ansible 操作对象 -m script -a '脚本文件在主控端的路径'
# 验证
ansible 操作对象 -m shell -a 'tail /etc/passwd'
```
###### setup模块
用于获取被控端的ansible变量值，主要用于模板剧本中，可以利用变量，实现对被控端的快速配置和差异化配置

ansible变量：用于记录所有主控端和被控端的连接信息

ansible dbserver -m setup 查看所有的变量值

常用选项：ansible 操作对象 -m setup -a 'filter="*变量关键字*"' filter用于筛选变量

如：
```sh
# 关于cpu的变量
ansible dbserver -m setup -a 'filter="*cpu*"'
```
###### fetch模块
拿取被控端文件
```sh
# 存放时，会将每台被控端创建一个ip目录
ansible 操作对象 -m fetch -a 'src=被控端文件路径 dest=主控端存放路径'
```
###### replace模块
可以实现对文件内容的替换
```sh
# 替换文件中所有匹配的字符
ansible dbserver -m replace -a 'path=被控端文件路径 regexp='匹配要替换的字符' replace='替换后的字符''
# 替换指定行
```
###### template模块
主要用于主控端使用模板配置被控端配置文件的场景

需要用到模板文件，文件必须以.j2结尾

以web应用apache为例

主控端和被控端都通过yum模块按照了httpd，在主控端更改配置文件，并重命名.j2结尾
```sh
ansible webserver -m template -a 'src=.j2文件路径 dest=被控端主配置文件路径'
如：
ansible webserver -m template -a 'src=httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf'
```
也可以在主控端配置文件中引用变量，在主机清单文件中修改
```sh
[root@localhost ~]# vim /etc/ansible/hosts
[webserver]
192.168.1.5 http_port=88
192.168.1.6 http_port=90
```
修改.j2文件
```sh
[root@localhost ~]# vim httpd.conf.j2 
 {{http_port}} 引用变量
ServerName www.example.com {{http_port}}
```
将.j2文件传送
```sh
ansible webserver -m template -a 'src=httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf'
```
这个时候查看被控端的配置文件中，发现1.5的端口为88,16的端口为90

###### unarchive模块
将主控端的压缩文件，解压后放在被控端

在主控端有一个nginx安装包，执行以下操作直接解压到被控端
```sh
ansible 操作对象 -m unarchive -a 'src=主控端安装包路径 dest=解压后的被控端存放路径'
```
###### lineinfile模块
修改配置文件时，修改指定行的内容，或者添加到指定行前和指定行后

可以实现在文件加入内容

命令参数说明：

| 参数 | 含义 |
| :---: | :---: |
| path | 指定要操作的文件对象 |
|egexp	|匹配条件|
|insertbefore	|在指定行前插入|
|insertafter	|在指定行后插入|
|line	|要写入的文件内容|
|state	|present（添加）absent（删除）|

insertbefore和insertafter的特殊值

BOF：begin of file（文件起始位置）
EOF：end of file （文件结束位置）

使用insertbefore和insertafter，还有regexp时，需要指定state，其他不需要

在文件开头插入内容 
```sh
ansible 操作对象 -m lineinfile -a 'path=文件路径 insertbefore=BOF line="插入的内容"'
如：
ansible dbserver -m lineinfile -a 'path=/root/nginx.conf insertbefore=BOF line="# nihao a"'
 在nginx.conf文件开头添"# nihao a"
```
在文件结束插入内容
```sh
ansible 操作对象 -m lineinfile -a 'path=文件路径 insertbefore=EOF line="插入的内容"'
如：
ansible dbserver -m lineinfile -a 'path=/root/nginx.conf insertbefore=EOF line="# nihao a"'
 在nginx.conf文件的末尾添加# nihao a
```
在文件指定位置加入内容
```sh
ansible 操作对象 -m lineinfile -a 'path=文件路径 insertbefore="指定位置的内容" line="插入的内容" state=present
如：
ansible dbserver -m lineinfile -a 'path=/root/nginx.conf insertbefore="  server {" line="root html" state=present'
 在nginx.conf的server {的上一行添加root html
```
删除文件中的指定内容
```sh
ansible 操作对象 -m lineinfile -a 'path=文件路径 regexp="要删除的内容" line="插入的内容" state=absent
如：
ansible dbserver -m lineinfile -a 'path=/root/nginx.conf regexp=" server {" state=absent'
 删除nginx.conf的server { 这一行
```