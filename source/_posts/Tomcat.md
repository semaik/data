title: Tomcat
author: Semaik.
tags:
  - 微服务
categories:
  - 微服务
date: 2020-09-18 19:02:00
---
##### Tomcat 是什么?
Tomcat 由JAVA语言开发的Java容器，实现了对 Servlet 和 JSP 的支持，并提供了作为Web服务器的一些特有功能，Tomcat是一种类似于IIS、Apache Http的Web服务端程序， Tomcat 本身也内含了一个 HTTP 服务器，它也可以被视作一个单独的 Web 服务器。也就是Web容器。


Servlet：是应用在服务端的小程序，由JAVA语言编写，本身支持各种JAVA相关的请求，但是大多用于接收web服务发来的请求，与数据库交互并将响应交给web服务




JDK：JAVA开发工具包。

常用工具：

>Java：运行编译后的类文件

>Jar：对类文件进行打包

>Javac：对源文件中的注释提取文档

>Jconsole：远程连接工具

>Jre：JAVA运行环境

##### 部署tomcat
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
##### Tomcat多实例
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

##### Tomcat多虚拟主机

在hosts文件中添加域名
```java
# vim /etc/hosts
```
![upload successful](/images/pasted-41.png)

再一个tomcat实例中添加多个Host模块，匹配多个站点目录供客户端访问

修改server.xml主配置文件
```java
# vim /usr/local/tomcat/conf/server.xml
```
![upload successful](/images/pasted-42.png)
```java
<Host name="www.one.com" appBase="/one"></Host>		//客户端如果访问的url域名为www.one.com，则匹配的站点目录为/one
        <Host name="www.two.com" appBase="/two">		//客户端如果访问的url域名为www.two.com，则匹配的站点目录为/two
        </Host>
```
重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh
```
创建站点目录/one和/two，并添加web应用
```java
# mkdir -p /one/o
# echo one > /one/o/aa.jsp
# mkdir -p /two/t
# echo two > /two/t/bb.jsp
```
在默认的webapps站点目录下创建目录cc，并添加web应用
```java
# mkdir /usr/local/tomcat/webapps/three
# echo nin ben ci fang wen de ye mian lai zi zhan dian mu lu wei webapps xia > /usr/local/tomcat/webapps/three/cc.jsp
```
验证：

```java
# curl www.one.com:8080/o/aa.jsp
one
# curl www.two.com:8080/t/bb.jsp
two
```
访问www.three.com:8080/three/cc.jsp`（本次访问的url在配置文件中没有指定域名所对应的站点目录，所以访问该域名的内容来自tomcat默认的站点目录webapps下的three的web应用）`
```java
# curl www.three.com:8080/three/cc.jsp
nin ben ci fang wen de ye mian lai zi zhan dian mu lu wei webapps xia
```

##### 自定义web应用的访问位置
修改配置文件
```java
# vim /usr/local/tomcat/conf/server.xml
```

![upload successful](/images/pasted-44.png)
> 如果客户端访问的url中域名为www.two.com则匹配到的站点目录为/two
如果客户端访问的url中域名为www.two.com:8080/myself，则匹配的站点目录为/self

重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh

```
创建/self站点目录
```java
# mkdir /self
# echo this is myself > /self/self.jsp
```
访问
```java
# curl www.two.com:8080/t/bb.jsp
two
# curl www.two.com:8080/myself/self.jsp
myself
```
##### 编写内存测试页面
```java
mkdir /one/memtest
vim /one/memtest/meminfo.jsp
<%
Runtime rtm = Runtime.getRuntime();		# 获取运行时间
long mm = rtm.maxMemory()/1024/1024;	# 给JVM分配的最大内存
long tm = rtm.totalMemory()/1024/1024;	# Java程序用掉的JVM内存
long fm = rtm.freeMemory()/1024/1024;	# 给JVM分配完后剩余的内存

out.println("memory info:<br>");
out.println("jvm max memory:"+mm+"MB"+"<br>");
out.println("jvm used:"+tm+"MB"+"<br>");
out.println("system free:"+fm+"MB"+"<br>");
out.println("can be used:"+(mm+fm-tm)+"MB"+"<br>");
%>
```
访问测试：

![upload successful](/images/pasted-45.png)

##### 远程监控tomcat性能
编写脚本
```java
# vim /usr/local/tomcat/bin/catalina.sh
添加：（309行）
JAVA_OPTS="$JAVA_OPTS -Djava.rmi.server.hostname=1.1.1.1"	# 指定被连接的主机的IP/主机名/域名
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=9000"	# 指定被连接的主机的端口
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=true"	# 指定连接时使用的身份验证
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"	# 指定连接时使用的身份验证
```

![upload successful](/images/pasted-46.png)

设置用于远程连接的用户和密码
```
# cp /usr/local/java/jre/lib/management/jmxremote.password.template /usr/local/java/jre/lib/management/jmxremote.password
# vim  /usr/local/java/jre/lib/management/jmxremote.password
取消注释：
 用户名		  密码
monitorRole		123456
controlRole		123456
```

对password文件提权
```java
# chmod 600 /usr/local/java/jre/lib/management/jmxremote.password
```
重启服务：
```java
sh /usr/local/tomcat/bin/shutdown.sh && /usr/local/tomcat/bin/startup.sh
```

![upload successful](/images/pasted-47.png)

放行防火墙（不行就关闭防火墙）
```java
# firewall-cmd --add-port=8080/tcp
# firewall-cmd --add-port=8005/tcp
# firewall-cmd --add-port=8009/tcp
# firewall-cmd --add-port=9000/tcp
# setenforce 0
```
打开一台虚拟机（只需要部署JDK）

远程连接

jconsole

![upload successful](/images/pasted-48.png)

![upload successful](/images/pasted-49.png)

![upload successful](/images/pasted-50.png)

##### 自定义错误页面

初次访问一个不存在的错误页面结果

![upload successful](/images/pasted-51.png)
修改web页面配置文件
```java
# vim /usr/local/tomcat/conf/web.xml
添加：（117行）
<error-page>
        <error-code>404</error-code>
        <location>/notfound.jsp</location>	# 指定错误页面的文件
</error-page>
```
编写要返回给客户端的错误页面
```java
# vim /usr/local/tomcat/webapps/ROOT/notfound.jsp
Not Found！
```
重启服务
```java
# cd /usr/local/tomcat/bin/
# ./shutdown.sh
# ./startup.sh
```
如提示报错：（显示地址被占用）

![upload successful](/images/pasted-53.png)

![upload successful](/images/pasted-54.png)

直接杀死相关的进程号就OK！

kill -9 50831

再次关闭、启动就OK！

测试访问：（访问一个不存在的页面）
```java
# curl 127.0.0.1:8080/zx.jsp
Not Found!
```

##### 通过web页面来管理虚拟主机

将打包好的web应用bdqnweb.war拷贝到宿主目录下

![upload successful](/images/pasted-55.png)

修改配置文件
```java
取消注释并设置可访问管理界面的用户（最后）
# vim /usr/local/tomcat/conf/tomcat-users.xml
<role rolename="admin-gui"/>	# 设置可以访问host-manager这个web应用的html的权限
<role rolename="admin-script"/>	# 设置可以访问txt类型页面的权限
<user username="aa" password="123.com" roles="admin-gui,admin-script"/>	# 添加用户aa密码为123.com，拥有admin-gui和admin-script两个权限
```
重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh
```
验证

>访问管理虚拟主机页面并添加虚拟主机
```java
firefox 127.0.0.1:8080/host-manager
```

![upload successful](/images/pasted-56.png)

![upload successful](/images/pasted-57.png)

![upload successful](/images/pasted-58.png)
创建www.test.com域名所对应的站点目录，并添加web应用
```java
# mkdir -p /test/app1
# echo www.test.com > /test/app1/test.jsp
```
修改hosts文件添加域名
```java
# echo "1.1.1.1 www.test.com" >> /etc/hosts
```
验证：
```java
# curl www.test.com:8080/app1/test.jsp
www.test.com
```
设置允许其他地址访问`Host-manager管理界面`（`默认地址为127.0.0.1可访问`）

><u>如果使用本机的物理IP访问**host-manager**管理界面是不可以访问的因为在配置文件中没有指定其他IP访问管理界面，所以在配置文件中可以指定其他IP允许访问管理界面</u>
  
```java
vim /usr/local/tomcat/webapps/host-manager/META-INF/context.xml
```

![upload successful](/images/pasted-59.png)

>在正则表达式里面“点”为任意所有的意思，所以在这里需要用“\”这个符号进行转义（`^.*$代表允许所有地址可访问`）

重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh

```
验证
```java
firefox 1.1.1.1:8080/host-manager
```

![upload successful](/images/pasted-60.png)

![upload successful](/images/pasted-61.png)
访问成功！！！

><u>重启服务后在管理界面添加的虚拟主机域名会消失，因为重启后服务会读取配置文件中的数据，在管理界面添加的虚拟主机不记录在配置文件中，所以会消失，但是消失的虚拟主机所对应的数据还在，只是虚拟主机的域名不存在。</u>

>访问manager控制界面（如果虚拟主机和发布web应用一起做的话一起修改tomcat-users配置文件，如果先做虚拟主机在做发布web应用中间在重启服务，虚拟主机就会消失，建议一起修改配置文件）

在配置文件中3yy，p复制粘贴这三行并修改
```java
vim /usr/local/tomcat/conf/tomcat-users.xml
<role rolename="manager-gui"/>	# 设置可以访问manager这个web应用的html权限
<role rolename="manager-script"/>	# 设置可以访问txt类型页面的权限
<user username="bb" password="123.com" roles="manager-gui,manager-script"/>	# 添加可以访问的用户bb，密码为123.聪明，拥有manager-gui和manager-script两个权限 
```

![upload successful](/images/pasted-62.png)
重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh
```
访问
```java
firefox 127.0.0.1:8080/manager
```

![upload successful](/images/pasted-63.png)
###### 第一种发布web应用方式

![upload successful](/images/pasted-64.png)

![upload successful](/images/pasted-65.png)

![upload successful](/images/pasted-68.png)
**发布成功后顶部显示OK**

![upload successful](/images/pasted-69.png)

当然在tomcat的默认站点目录webapps下会生成一个bdqnweb应用

![upload successful](/images/pasted-70.png)

访问bdqnweb应用
```java
firefox 127.0.0.1:8080/bdqnweb/
```

![upload successful](/images/pasted-71.png)

###### 第二种发布方式

![upload successful](/images/pasted-72.png)
**发布成功后顶部显示OK**


![upload successful](/images/pasted-73.png)
/hello不需要在webapps目录下提前创建，发布成功后会自动生成

![upload successful](/images/pasted-74.png)
访问
```java
# curl 127.0.0.1:8080/hello
Hello World!
```
设置允许其他地址访问**manager**管理界面（`默认地址为127.0.0.1可访问`）
修改配置文件
```java
vim /usr/local/tomcat/webapps/manager/META-INF/context.xml
```

![upload successful](/images/pasted-75.png)

**（^.*$代表允许所有地址可访问）**

重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh
```
验证访问

![upload successful](/images/pasted-76.png)


![upload successful](/images/pasted-77.png)

##### JVM常用内存优化参数
```java
# vim /usr/local/tomcat/bin/catalina.sh
添加：
JAVA_OPTS="-server -Xms512M -Xmx512M -XX:NewSize=300M -XX:OldSize=100M -XX:SurvivorRatio=2"
-Xms512：指定JVM初始化分配的内存
-Xmx512：指定JVM最大获取到的内存
-XX:NewSize=300M：指定新生代的内存容量
-XX:OldSize=100M：指定年老代的内存容量
-XX:SurvivorRatio=2：指定Survivor与Eden的占比
#-XX:PermSize：指定持久代的容量
#-XX:PermMaxSize：指定持久代的最大容量
#-XX:NewMaxSize：指定新生代的最大内存容量
```
指定线程池
```java
# vim /usr/local/tomcat/conf/server.xml
修改：去掉注释（56行）
指定线程池，名字为threadpool，最大可开启线程数量为150个，最下空闲进程数量4个
    <Executor name="threadPool" namePrefix="catalina-exec-"
        maxThreads="150" minSpareThreads="4"/>
连接器引用指定名字对应的线程池
    <Connector port="8080" protocol="HTTP/1.1"
        executor="threadPool"
               connectionTimeout="20000"
               redirectPort="8443" />
```
重启服务
```java
# sh /usr/local/tomcat/bin/shutdown.sh && sh /usr/local/tomcat/bin/startup.sh

```
验证访问
```java
# firefox www.new.com:8080/manager
```

![upload successful](/images/pasted-78.png)

![upload successful](/images/pasted-79.png)
