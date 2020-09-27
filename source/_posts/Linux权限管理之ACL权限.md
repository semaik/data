title: Linux权限管理之ACL权限
author: Semaik.
date: 2020-09-24 11:22:22
tags:
---
##### ACL权限设置规则：

> 可以给任何的用户或用户组设置任何文件/目录的访问权限。

###### 添加ACL规则的命令格式：

　　①、给用户设定 ACL 权限：setfacl -m u:用户名:权限 指定文件名
  
　　②、给用户组设定 ACL 权限:setfacl -m g:组名:权限 指定文件名
  
###### 选项：

	-m：设定ACL权限
			例：setfacl -m [g/u]:[组名/用户名]:rwx 指定的目录/文件
            
	-x：删除指定的ACL权限
			例：setfacl -x [g/u]:[组名/用户名] 指定的目录/文件
            
	-b：删除所有的ACL权限
			例：setfacl -b 指定的目录/文件

##### 拿用户组来举例（当然拿某个用户也是一样的）

创建一个目录：
```java
[root@node1 /]# mkdir /pro
```
    
创建两个用户：
```java
[root@node1 /]# useradd zs
[root@node1 /]# useradd ls
```

切换zs用户或者ls用户去/pro目录中进行操作
```java
[root@node1 ~]# su zs
[zs@node1 root]$ cd /pro
[zs@node1 pro]$ touch file
touch: 无法创建"file": 权限不够
[root@node1 ~]# su ls
[ls@node1 root]$ cd /pro
[ls@node1 pro]$ touch file
touch: 无法创建"file": 权限不够

# 注意：这时通过zs用户去/pro目录下去操作，是无法进行操作的，该用户对此目录没有操作权限，当然ls用户也是一样。
```
创建一个用户组：
```java
[root@node1 ~]# groupadd userzu
```
将zs用户以及ls用户加入到userzu中
```java
[root@node1 ~]# usermod -G userzu zs
[root@node1 ~]# usermod -G userzu ls
[root@node1 ~]# groups zs
zs : zs userzu
[root@node1 ~]# groups ls
ls : ls userzu		# 将用户已经加入到组内
```
当然之加入到组中也是没有权限的，需要通过acl对此目录绑定权限：
```java
[root@node1 ~]# setfacl -m g:userzu:rwx /pro
[root@node1 ~]# chmod 775 /pro		# 允许用户组有读写执	行权限
[root@node1 ~]# getfacl /pro
getfacl: Removing leading '/' from absolute path names
# file: pro
# owner: root
# group: root
user::rwx
group::rwx
group:userzu:rwx		# 这里已经显示由哪个组可以对该目录	进行操作，并拥有什么样的权限（可以绑定多个用户组）
mask::rwx
other::r-x
```
再次切换zs用户去/pro目录进行操作
```java
[zs@node1 pro]$ touch {1..3}
[zs@node1 pro]$ ls
1  2  3
[zs@node1 pro]$ ll
总用量 0
-rw-rw-r--. 1 zs zs 0 9月  12 17:34 1
-rw-rw-r--. 1 zs zs 0 9月  12 17:34 2
-rw-rw-r--. 1 zs zs 0 9月  12 17:34 3

# 可以成功的进行操作！！！（ls用户也是一样）
```
