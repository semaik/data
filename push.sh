#!/usr/bin/expect
git add .	&> /dev/null
git commit  -m "file"	&> /dev/null

#expect -c "
#set timeout 1
spawn git push -u origin master
expect "Username for 'https://github.com':"
#send \"zuxuan8@aliyun.com\r\"
send "zuxuan8@aliyun.com\n"
expect "Password for 'https://zuxuan8@aliyun.com@github.com':"
#send \"zuxuan520.\r\"
send "zuxuan520.\n"
#interact"
expect off


# 将hexo目录中的数据上传到远程data仓库做备份。
