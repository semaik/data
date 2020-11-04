title: Linux环境更新Python3.8
author: Semaik.
tags:
  - Linux
categories:
  - Linux
date: 2020-11-03 12:41:00
---
#### 进入Python官网下载软件包：https://www.python.org/downloads/

![upload successful](/images/pasted-101.png)

> 下载需要更新的软件包

![upload successful](/images/pasted-102.png)

#### 我就拿3.8.5软件包举例

###### 创建一个存储目录
```java
[root@one /]# mkdir /usr/local/python3-8
```
###### 安装依赖
```java
[root@one /]# yum install gcc libffi-devel zlib* openssl-devel
```
###### 解压

```java
[root@one /]# unzip Python-3.8.5.zip
[root@one /]# cd Python-3.8.5/
[root@one Python-3.8.5]# ./configure --prefix=/usr/local/python3-8 && make && make install
```
###### 给予权限
```java
[root@one /]# chmod 777 /usr/local/python3-8/
```
###### 备份Python2的文件
```java
[root@one /]# cp /usr/bin/python /usr/bin/python2.bak
[root@one /]# rm -rf /usr/bin/python
```
###### 将Python3的文件链接到/usr/bin/下
```java
[root@one /]# ln -s /usr/local/python3-8/bin/python3.8 /usr/bin/pyhton
```
###### 验证
![upload successful](/images/pasted-103.png)

![upload successful](/images/pasted-104.png)
> 如果pip的版本未更换成3.8就需要手动操作了

###### 如果Yum出现以下错误

```java
[root@one /]# yum -y install openssl*
  File "/usr/bin/yum", line 30
    except KeyboardInterrupt, e:
                            ^
SyntaxError: invalid syntax

或

总下载量：3.9 M
Downloading packages:
  File "/usr/libexec/urlgrabber-ext-down", line 28
    except OSError, e:
                  ^
```
###### 以上报错需要修改yum解释器

```java
[root@one /]# vi /usr/bin/yum
[root@one /]# vi /usr/libexec/urlgrabber-ext-down
# 都修改成同样的python2.7
```
![upload successful](/images/pasted-105.png)