#!/bin/bash
git add .	> /dev/null
git commit  -m "file"	> /dev/null
git push -u origin master

# 将hexo目录中的数据上传到远程data仓库做备份。
