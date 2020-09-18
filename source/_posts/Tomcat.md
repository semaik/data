title: Tomcat
author: Semaik.
date: 2020-09-18 19:02:09
tags:
---
###### Tomcat 是什么?
Tomcat 由JAVA语言开发的Java容器，实现了对 Servlet 和 JSP 的支持，并提供了作为Web服务器的一些特有功能，Tomcat是一种类似于IIS、Apache Http的Web服务端程序， Tomcat 本身也内含了一个 HTTP 服务器，它也可以被视作一个单独的 Web 服务器。也就是Web容器。


Servlet：是应用在服务端的小程序，由JAVA语言编写，本身支持各种JAVA相关的请求，但是大多用于接收web服务发来的请求，与数据库交互并将响应交给web服务




JDK：JAVA开发工具包。

常用工具：

>Java：运行编译后的类文件

>Jar：对类文件进行打包

>Javac：对源文件中的注释提取文档

>Jconsole：远程连接工具

>Jre：JAVA运行环境

###### 部署tomcat
配置Java环境

解压软件包
```
# tar zxf jdk-8u201-linux-x64.tar.gz
```
将jdk解压后的目录移动到/usr/local/起名为java
```
# mv /root/jdk1.8.0_201/ /usr/local/java
```
删除原先的旧java
```
# rm -rf /usr/bin/java
```
配置Java环境变量
```
# echo 'export JAVA_HOME=/usr/local/java
# 设置jre（Jave Runtime Environment：java运行时环境）的安装目录变量
> export JRE_HOME=/usr/local/java/jre/
# 设置类文件路径，冒号代表加的意思，引用以上设置的变量
> export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib
# 最后一行，相当于windows系统的命令环境变量，就是新添了两个java以及jre的命令变量
# $PATH代表原有的环境变量，使用变量复用
> export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin' >> /etc/profile
```
加载编写的profile文件
```
# source /etc/profile
```
查看版本号
```
# java -version
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
```
安装Tomcat
```
tar zxf apache-tomcat-8.5.35.tar.gz 
mv apache-tomcat-8.5.35 /usr/local/tomcat
```
启动服务：`/usr/local/tomcat/bin/startup.sh`

停止服务：`/usr/local/tomcat/bin/shutdown.sh`

> 8080：接收客户端请求

> 8005：用于接收shutdown指令

> 8009：用于tomcat接受其他web服务发来的请求

server.xml主配置文件
```
vi /usr/local/tomcat/conf/server.xml
<Server port="8005" shutdown="SHUTDOWN"></Server>
port：server模块监听的端口号，可以自定义，只有端口号不冲突，为-1时表示不接受关闭指令
shutdown：server模块接收到的参数指定的指令时就关闭tomcat程序

<Service name="Catalina"></Service>
name：指定该servie的名字，可以有多个service通过名字来区分

<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" /></Connector>
<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
port：tomcat对客户端开放的端口号，8080是用于接收客户端发送的http请求，8009是用于tomcat接受其他web服务发来的请求
protocol：客户端连接tomcat使用的协议，AJP协议用于tomcat与其他web服务建立连接使用的
connectionTimeout：与tomcat的连接超时时间，单位毫秒
redirectPort：当tomcat配置为https时，如果客户端仍然使用http协议访问，强制对客户端使用的协议转换为https，并将端口转换为8443

<Engine name="Catalina" defaultHost="localhost"></Engine>
name：该engine的名字，如果有多个service用来区分不同的引擎，并在日志中通过 名字进行标识
default Host：引擎接受请求通过客户端请求的URL的IP/域名/主机名部分匹配Host模块，如果没有匹配到的则把请求交给defaultHost指定的主机处理，所以必须要有一个Host模块的主机名为defaultHost指定的名字

<Host name="localhost"  appBase="webapps"
          unpackWARs="true" autoDeploy="true">
<Context path=”/test” docBase=”/haha”></Context>
</Host>
name：该host也就是虚拟主机对应的名字，用来engine对客户端访问的url中的主机部分进行匹配
appBase：该虚拟主机对应的站点目录，webapps是一个相对路径，其绝对路径为“/usr/local/tomcat/webapps”
path：客户端访问的URL指定的名字如果是/test那么客户端要找的数据对应的位置就在/haha目录下
docBase：web应用存放位置
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
Directory：指定访问日志存放的位置，logs是相对路径，绝对路径为“/usr/local/tomcat/logs”
Prefix：指定访问日志文件的前缀
Suffix：指定访问日志文件的后缀
Pattern：指定日志文件的格式
- %h：记录发送该请求的主机的IP地址，可能是客户端的IP，可能是代理服务器的IP（谁最终将请求交给tomcat，这里就是谁的IP）
- %l：记录该请求使用的逻辑用户，如果没有就用-表示
- %u：记录该请求的真实用户，如果没有则用-表示
- %t：记录该请求的发送时间
- %quot；：表示“”引号
- %r：记录请求的请求行
- %s：记录对该请求响应的状态码	
- %b：记录该请求相应的字节数
- %D：记录该请求响应的时间，可以用来测试tomcat的性能
```
###### Tomcat多实例
> 通过修改不同tomcat结点的配置文件中的端口来启动不同的tomcat实例

示例一：
```
tar zxf apache-tomcat-8.5.33.tar.gz
cp /root/apache-tomcat-8.5.33 /usr/local/tomcat
sh /usr/local/tomcat/bin/startup.sh		//启动第一个实例
netstat -anpt | grep java		//查看到监听了三个端口8080、8005、8009
```
示例二：

```
cp /root/apache-tomcat-8.5.33 /usr/local/tomcat2
vim /usr/local/tomcat2/conf/server.xml
修改：
<Server port="8006" shutdown="SHUTDOWN">		//修改接收shutdown指令的端口
<Connector port="8081" protocol="HTTP/1.1"		//修改接收客户端请求的端口
<Connector port="8010" protocol="AJP/1.3" redirectPort="8443" />		//修改接收其他web服务发送请求的端口
sh /usr/local/tomcat2/bin/startup.sh		//启动第二个实例
netstat -anpt | grep java		//可以看到实例二所监听的端口8081、8006、8010
```
###### 验证：
通过访问这两个tomcat节点，可以在这两个节点的站点目录下添加不同的文件来访问

添加示例一测试文件：
```
mkdir /usr/local/tomcat/webapps/1
echo wo shi shi li yi > /usr/local/tomcat/webapps/1/1.jsp
```
添加示例二测试文件：
```
mkdir /usr/local/tomcat2/webapps/2
echo wo shi shi li er > /usr/local/tomcat2/webapps/2/2.jsp
```
访问：
![upload successful](/images/timg2.png)