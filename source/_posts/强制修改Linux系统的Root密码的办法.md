title: 强制修改Linux系统的Root密码的办法
author: Semaik.
tags:
  - Linux
categories:
  - Linux
  - ''
date: 2020-09-18 16:17:00
---
##### 1.在Linux 的引导界面按 E 键来进入内核编辑界面
![upload successful](/images/test0.png)

##### 2.按键盘下键，找到Linux16这一行，然后在最后边加入 rd.break命令，然后按Ctrl+X来重启修改过的内核!
![upload successful](/images/test1.png)
##### 3. 之后进入“紧急求援模式”

   输入以下命令（输入完一行回车！）

   mount -o remount,rw /sysroot

   chroot /sysroot

   passwd    # 当输入完这一行会系统会让你输入新密码和确认新密码，按照系统提示输入即可！

   touch /.autorelabel

   exit

   reboot
![upload successful](/images/test2.png)
##### 4.接着等待重启以后就可以使用root账号了