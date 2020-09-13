#!/bin/bash
git add .	> /dev/null
git commit  -m "file"	> /dev/null
# git push -u origin master

expect -c "
set timeout 1
spawn git push -u origin master
expect \"Username:\"
send \"zuxuan8@aliyun.com\r\"
expect \"Password:\"
send \"zuxuan520.\r\"
interact"


# 将hexo目录中的数据上传到远程data仓库做备份。
