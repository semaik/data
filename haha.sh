#!/bin/sh
expect -c "
spawn hexo d
expect \"Username:\"
send \"zuxuan8@aliyun.com\r\"
expect \"Password:\"
send \"zuxuan520.\r\"
interact
"
