#!/usr/bin/env sh
#!/usr/bin/expect
d=0

hexo clean && hexo g

set timeout 1

expect -c "
spawn hexo d
expect \"Username:\"
send \"zuxuan8@aliyun.com\r\"
expect \"Password:\"
send \"zuxuan520.\r\"
interact"

##############################################
# -c 选项用来标明需要在执行脚本内容之前来执行的命令。
# spawn 提出的交互式问题,spawn是进入expect环境后才可以执行的expect内部命令.
# expect 意思是判断上次输出结果里是否包含"Username:"的字符串.
# send 这里就是执行交互动作，与手工输入的动作等效。命令字符串结尾别忘记加上'\r'
# interact 执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。
##############################################

d=1
if d==1
	then
		hexo s &
else
	echo "No!!!"
fi



# 将新发布的内容提交的GitHub接管
