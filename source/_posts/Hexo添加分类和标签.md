---
title: Hexo添加分类和标签
date: 2020-09-10 13:21:18
tags:
    - Hexo
categories: Hexo
---
#### 1.创建"分类"选项
生成“分类”页并添加tpye属性,进入博客目录。执行命令下方命令
```java
$ hexo new page categories
```
categories文件夹下会有index.md这个文件，打开后默认内容是这样的：
```java

---
title: categories
date: 2019-04-22 14:47:40
---
```
添加type: "categories"到内容中，添加后是这样的：
```java

---
title: 分类
date: 2019-04-24 15:30:30
type: categories
---
```
保存并关闭文件。

给文章添加“categories”属性

打开需要添加分类的文章，为其添加categories属性。下方的categories:Hexo表示这篇文章添加到到“Hexo”这个分类。注意：一篇文章只会添加到一个分类中，如果是多个默认放到第一个分类中。
```java
---
title: Hexo 添加分类及标签
date: 2017-05-26 12:12:57
categories: Hexo
---
```
至此，成功给文章添加分类，点击首页的“分类”可以看到该分类下的所有文章。当然，只有添加了categories: xxx的文章才会被收录到首页的“分类”中。
#### 2.创建"标签"选项
生成“标签”页并添加tpye属性
```java
$ hexo new page tags
```
在tags文件夹下，找到index.md这个文件，打开后默认内容是这样的：
```java
---
title: 标签
date: 2019-04-22 14:22:08
---
```
添加type: "tags"到内容中，添加后是这样的：
```java
---
title: 标签
date: 2019-04-24 15:40:24
type: tags
---
```
保存并关闭文件。

给文章添加“tags”属性,打开需要添加标签的文章，为其添加tags属性。
```java
---
title: Hexo 添加分类及标签
date: 2019-04-24 15:40:24
categories: 
           - Hexo
tags:
           - 博客
---
```













