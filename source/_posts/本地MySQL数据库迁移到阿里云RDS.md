title: 本地MySQL数据库迁移到阿里云RDS
author: Semaik.
tags:
  - Linux
categories:
  - Linux
date: 2020-09-11 15:29:00
---
##### 连接本地数据库
```ruby
mysql -h localhost -u root -p
```

##### 创建账号
> 首先要在本地创建一个用来迁移的帐号，并给这个帐号设置权限。
```ruby
CREATE USER 'username'@'host' IDENTIFIED BY 'password';
```
> sername：待创建的账号。
> host：允许该账号登录的主机，如果允许该账号从任意主机登录数据库，可以使用百分号（%）
> password：账号的密码。 

EG：
```ruby
# 例如，创建一个账号，账号名为dtsmigration
# 密码为Dts123456，并允许从任意主机登录数据库，命令如下。
CREATE USER 'dtsmigration'@'%' IDENTIFIED BY 'Dts123456';
```

##### 用户授权
```ruby
GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION;
```
>privileges：授予该账号的操作权限，如SELECT、INSERT、UPDATE等，如果要授予该账号所有权限则使用ALL。
databasename：数据库名。如果要授予该账号具备所有数据库的操作权限，则使用星号（）。
tablename：表名。如果要授予该账号具备所有表的操作权限，则使用星号（）。
username：待授权的账号。
host：允许该账号登录的主机，如果允许该账号从任意主机登录，则使用百分号（%）。
>WITH GRANT OPTION：授予该账号使用GRANT命令的权限，该参数为可选。
   
EG:
```ruby
# 授予dtsmigration账号具备所有数据库和表的所有权限
# 并允许从任意主机登录数据库，命令如下。
GRANT ALL ON *.* TO 'dtsmigration'@'%';
```
   
### 本地数据库状态
##### 1.确认源库的binlog是否开启
```ruby
show global variables like "log_bin";
```
###### 不是的话配置一下my.cnf
```ruby
log_bin=mysql_bin
binlog_format=row
server_id=2 //设置大于1的整数
binlog_row_image=full     **//当自建MySQL的版本大于5.6时，则必须设置该项**
```
###### 修改之后重启MySQL
```ruby
systemctl restart mysql
```
##### 2.确认源库的binlog格式为row模式
```ruby
show global variables like "binlog_format";
```
###### 不是的话配置一下
```ruby
set global binlog_format=ROW;
```
##### 3.当地mysql版本大等于5.6.2时，确认源库的binlog_row_image=full
```ruby
show global variables like "binlog_row_image";
```
###### 不是的话配置一下
```ruby
set global binlog_row_image=full;
```
##### 进行迁移
>阿里云官方文档
[https://help.aliyun.com/document_detail/126875.html?spm=a2c4g.11186623.2.10.14554b43IHTNie](https://help.aliyun.com/document_detail/126875.html?spm=a2c4g.11186623.2.10.14554b43IHTNie)
需要先设置一下网关
[https://help.aliyun.com/document_detail/159587.html?spm=5176.10695662.1996646101.searchclickresult.1de2d223X9cjTe](https://help.aliyun.com/document_detail/159587.html?spm=5176.10695662.1996646101.searchclickresult.1de2d223X9cjTe)
注意设置好网关之后要使用无公网:Port的数据库（通过数据库网关DG接入）

