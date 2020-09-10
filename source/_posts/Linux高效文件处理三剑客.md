---
title: Linux高效文件处理三剑客
date: 2020-09-10 14:39:48
categories: Linux
tags: 
    - Linux
---
> grep、sed、awk我们叫他们三剑客，掌握它们可以更好的运维，提升工作效率，即使不是运维，对我们处理数据都是非常方便的～就很多数据处理来讲，写程序肯定是也能处理的，但是远没有已经存在特定功能的命令更高效，我们只需要操作命令即可。通过本文可以讲解三剑客的一些基础知识和实用;

### Grep
简介
grep是一款强大的文本搜索工具，支持正则表达式。
全称（ global search regular expression(RE) and print out the line）
语法:grep [option]... PATTERN [FILE]...
常用:
```java
usage: grep [-abcDEFGHhIiJLlmnOoqRSsUVvwxZ] [-A num] [-B num] [-C[num]]
 [-e pattern] [-f file] [--binary-files=value] [--color=when]
 [--context[=num]] [--directories=action] [--label] [--line-buffered]
 [--null] [pattern] [file ...]
```
常用参数：
```java
            -v        取反
            -i        忽略大小写
            -c        符合条件的行数
            -n        输出的同时打印行号
            ^*        以*开头         
            *$         以*结尾 
            ^$         空行 
```
实际使用
准备好一个小故事txt：
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# cat monkey
One day,a little monkey is playing by the well.一天,有只小猴子在井边玩儿.
He looks in the well and shouts :它往井里一瞧,高喊道：
“Oh!My god!The moon has fallen into the well!” “噢!我的天!月亮掉到井里头啦!”
An older monkeys runs over,takes a look,and says,一只大猴子跑来一看,说,
“Goodness me!The moon is really in the water!” “糟啦!月亮掉在井里头啦!”
And olderly monkey comes over.老猴子也跑过来.
He is very surprised as well and cries out:他也非常惊奇,喊道：
“The moon is in the well.” “糟了,月亮掉在井里头了!”
A group of monkeys run over to the well .一群猴子跑到井边来,
They look at the moon in the well and shout:他们看到井里的月亮,喊道：
“The moon did fall into the well!Come on!Let’get it out!”
“月亮掉在井里头啦!快来!让我们把它捞起来!”
Then,the oldest monkey hangs on the tree up side down ,with his feet on the branch .
然后,老猴子倒挂在大树上,
And he pulls the next monkey’s feet with his hands.拉住大猴子的脚,
All the other monkeys follow his suit,其他的猴子一个个跟着,
And they join each other one by one down to the moon in the well.
它们一只连着一只直到井里.
Just before they reach the moon,the oldest monkey raises his head and happens to see the moon in the sky,正好他们摸到月亮的时候,老猴子抬头发现月亮挂在天上呢
He yells excitedly “Don’t be so foolish!The moon is still in the sky!”
它兴奋地大叫：“别蠢了!月亮还好好地挂在天上呢!
```
#### 直接查找符合条件的行
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep moon monkey
“Oh!My god!The moon has fallen into the well!” “噢!我的天!月亮掉到井里头啦!”
“Goodness me!The moon is really in the water!” “糟啦!月亮掉在井里头啦!”
“The moon is in the well.” “糟了,月亮掉在井里头了!”
They look at the moon in the well and shout:他们看到井里的月亮,喊道：
“The moon did fall into the well!Come on!Let’get it out!”
And they join each other one by one down to the moon in the well.
Just before they reach the moon,the oldest monkey raises his head and happens to see the moon in the sky,正好他们摸到月亮的时候,老猴子抬头发现月亮挂在天上呢
He yells excitedly “Don’t be so foolish!The moon is still in the sky!”
```
#### 查找反向符合条件的行
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep -v  moon monkey
One day,a little monkey is playing by the well.一天,有只小猴子在井边玩儿.
He looks in the well and shouts :它往井里一瞧,高喊道：
An older monkeys runs over,takes a look,and says,一只大猴子跑来一看,说,
And olderly monkey comes over.老猴子也跑过来.
He is very surprised as well and cries out:他也非常惊奇,喊道：
A group of monkeys run over to the well .一群猴子跑到井边来,
“月亮掉在井里头啦!快来!让我们把它捞起来!”
Then,the oldest monkey hangs on the tree up side down ,with his feet on the branch .
然后,老猴子倒挂在大树上,
And he pulls the next monkey’s feet with his hands.拉住大猴子的脚,
All the other monkeys follow his suit,其他的猴子一个个跟着,
它们一只连着一只直到井里.
它兴奋地大叫：“别蠢了!月亮还好好地挂在天上呢!”
```
#### 直接查找符合条件的行数
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep -c  moon monkey
8
```
#### 忽略大小写查找符合条件的行数
先来看一下直接查找的结果
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep my monkey
```
#### 忽略大小写查看
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep -i my monkey
“Oh!My god!The moon has fallen into the well!” “噢!我的天!月亮掉到井里头啦!”
```
#### 查找符合条件的行并输出行号
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep -n monkey monkey
1:One day,a little monkey is playing by the well.一天,有只小猴子在井边玩儿.
4:An older monkeys runs over,takes a look,and says,一只大猴子跑来一看,说,
6:And olderly monkey comes over.老猴子也跑过来.
9:A group of monkeys run over to the well .一群猴子跑到井边来,
13:Then,the oldest monkey hangs on the tree up side down ,with his feet on the branch .
15:And he pulls the next monkey’s feet with his hands.拉住大猴子的脚,
16:All the other monkeys follow his suit,其他的猴子一个个跟着,
19:Just before they reach the moon,the oldest monkey raises his head and happens to see the moon in the sky,正好他们摸到月亮的时候,老猴子抬头发现月亮挂在天上呢
```
#### 查找开头是J的行
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep '^J' monkey
Just before they reach the moon,the oldest monkey raises his head and happens to see the moon in the sky,正好他们摸到月亮的时候,老猴子抬头发现月亮挂在天上呢
```
#### 查找结尾是呢的行
```java
[root@iz2ze76ybn73dvwmdij06zz ~]# grep "呢$" monkey
Just before they reach the moon,the oldest monkey raises his head and happens to see the moon in the sky,正好他们摸到月亮的时候,老猴子抬头发现月亮挂在天上呢
```

### Sed
> sed是一种流编辑器，是一款处理文本比较优秀的工具，可以结合正则表达式一起使用。
#### sed命令
命令: sed
语法 : sed [选项]... {命令集} [输入文件]...
```java
常用参数:
            d  删除选择的行    
            s   查找    
            y  替换
            i   当前行前面插入一行
            a  当前行后面插入一行
            p  打印行       
            q  退出     

 替换符:

            数字 ：替换第几处    
            g :  全局替换    
            \1:  子串匹配标记，前面搜索可以用元字符集\(..\)
            &:  保留搜索刀的字符用来替换其他字符
#### 操作
##### 替换操作
查看文件：
```java
# cat word
Twinkle, twinkle, little star
How I wonder what you are
Up above the world so high
Like a diamond in the sky
When the blazing sun is gone
```
替换：
```java
# sed 's/little/big/' word
Twinkle, twinkle, big star
How I wonder what you are
Up above the world so high
Like a diamond in the sky
When the blazing sun is gone
```
查看文本：
```java
# word1
Oh if there's one thing to be taught
it's dreams are made to be caught
and friends can never be bought
Doesn't matter how long it's been
I know you'll always jump in
'Cause we don't know how to quit
```
全局替换：
```java
# sed 's/to/can/g' word1
Oh if there's one thing can be taught
it's dreams are made can be caught
and friends can nev
```
按行替换（替换2到最后一行)
```java
# sed '2,$s/to/can/' word1
Oh if there's one thing to be taught
it's dreams are made can be caught
and friends can never be bought
Doesn't matter how long it's been
I know you'll always jump in
'Cause we don't know how can quit
```java
##### 删除操作:
查看文本:
```java
# cat word
Twinkle, twinkle, little star
How I wonder what you are
Up above the world so high
Like a diamond in the sky
When the blazing sun is gone
```
删除:
```java
# sed '2d' word
Twinkle, twinkle, little star
Up above the world so high
Like a diamond in the sky
When the blazing sun is gone
```
显示行号:
```java
# sed '=;2d' word
1
Twinkle, twinkle, little star
2
3
Up above the world so high
4
Like a diamond in the sky
5
When the blazing sun is gone
```
删除第2行到第四行:
```java
# sed '=;2,4d' word
1
Twinkle, twinkle, little star
2
3
4
5
When the blazing sun is gone
```
##### 添加行操作:
向前插入:
```java
# echo "hello" | sed 'i\kitty'
kitty
hello
```
向后插入:
```java
# echo "kitty" | sed 'i\hello'
hello
kitty
```
##### 修改行操作:
替换第二行为hello kitty
```java
# sed '2c\hello kitty' word
Twinkle, twinkle, little star
hello kitty
Up above the world so high
Like a diamond in the sky
When the blazing sun is gone
```
替换第二行到最后一行为hello kitty
```java
# sed '2,$c\hello kitty' word
Twinkle, twinkle, little star
hello kitty
```
##### 写入行操作
把带star的行写入c文件中,c提前创建
```java
# sed -n '/star/w c' word
# cat c
Twinkle, twinkle, little star
```
##### 退出
打印3行后，退出sed
```java
# sed '3q' word
Twinkle, twinkle, little star
How I wonder what you are
Up above the world so higher be bought
Doesn't matter how long it's been
I know you'll always jump in
'Cause we don't know how can quit
```

### Awk
> awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。

命令格式：
awk [option] 'scrip' var=value

参数：
option：
-F 指定输入的分割字符，默认为 空格
-v var=value 赋值一个用户自定义变量
-f scripfile 从脚本中读取 awk 命令
#### AWK 模式和操作awk 脚本是由模式和操作组成的。

##### 模式
模式可以是以下任意一个：
```java
/正则表达式/： 使用通配符的扩展集
关系表达式：    使用运算符进行操作，可以是字符串或者数字比较测试
模式匹配表达式：用运算符~9匹配和~！（不匹配）
BEGIN 语句块，pattern语句块、END语句块
```
##### 操作
操作有一个或者多个命令、函数、表达式组成，之间由换行符或分号隔开，并位于大括号内、主要部分有：
```java
变量或属组赋值
输出命令
内置函数
控制流程语句
```
##### 实例
例： 只是显示最近登录的5个帐号
```java
[root@localhost ~]# last -n 5 
root     pts/0        192.168.116.1    Fri Jun 12 10:59   still logged in   
reboot   system boot  3.10.0-862.el7.x Fri Jun 12 10:58 - 11:36  (00:38)    
reboot   system boot  3.10.0-862.el7.x Fri Jun  5 21:07 - 11:36 (6+14:28)   
root     pts/0        192.168.116.1    Fri Jun  5 18:40 - crash  (02:27)    
reboot   system boot  3.10.0-862.el7.x Fri Jun  5 17:28 - 11:36 (6+18:08)   

wtmp begins Thu Oct 10 22:36:04 2019
[root@localhost ~]# last -n 5 | awk '{print $1}'
root
reboot
reboot
root
reboot
```
例： 只显示/etc/passwd的账户
```java
[root@localhost ~]# cat /etc/passwd | awk -F ':' '{print $1}'
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
operator
games
ftp
nobody
systemd-network
dbus
polkitd
tss
sshd
postfix
chrony
mysql
```
例：只显示/etc/passwd的账户和账户对应的shell,而账户与shell之间以tab键分割
```java
[root@localhost ~]# cat /etc/passwd | awk -F ':' '{print $1"\t"$7}' 
dbus    /sbin/nologin
polkitd    /sbin/nologin
tss    /sbin/nologin
sshd    /sbin/nologin
postfix    /sbin/nologin
chrony    /sbin/nologin
mysql    /bin/bash
```
例：只是显示/etc/passwd的账户和账户对应的shell,而账户与shell之间以逗号分割,而且在所有行添加列名name,shell,在最后一行添加”blue,/bin/nosh”
```java
[root@localhost ~]# cat /etc/passwd | awk -F ':' 'BEGIN {print "name,shell"} {print $1"\t"$7} END {print "Hello,/bin/nosh"}'
dbus    /sbin/nologin
polkitd    /sbin/nologin
tss    /sbin/nologin
sshd    /sbin/nologin
postfix    /sbin/nologin
chrony    /sbin/nologin
mysql    /bin/bash
Hello,/bin/nosh
```
> awk工作流程是这样的：先执行BEGING，然后读取文件，读入有/n换行符分割的一条记录，然后将记录按指定的域分隔符划分域，填充域，$0则表示所有域,$1表示第一个域,$n表示第n个域,随后开始执行模式所对应的动作action。接着开始读入第二条记录······直到所有的记录都读完，最后执行END操作。

```java
第一步： 执行 BEGIN {commond} 指令
第二步： 从文件或标准输入{stdin}读取一行然后执行 pattern { commmod } 
第三步； 从读至输入流末尾，执行 END {commod}语句
```
> BEGIN 在awk 开始输入读取之前被执行，属于一个可选的模块，一般用于变量初始化、打印输出表头
> 
> pattern 通用命令，是最重要的一块，属于可选的，一般用于打印出指定的列，如果没有指定 petter 模块，则默认执行 {print $0} 既打印出所有读取到的内容
> 
> END 在 AWK 从输入流中读取完所有的内容之后再执行，在 awk 整个语句输入中末尾执行

例：搜索 /etc/passwd 有 root 关键字的行
```java
[root@localhost ~]# awk -F: '/root/' /etc/passwd
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```
例：搜索/etc/passwd有root关键字的所有行，并显示对应的shell
```java
[root@localhost ~]# awk -F: '/root/{print $7}' /etc/passwd
/bin/bash
/sbin/nologin
```
