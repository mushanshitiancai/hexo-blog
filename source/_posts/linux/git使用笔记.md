---
title: git使用笔记
date: 2016-03-18 17:13:44
tags: linux
---

## mac下git显示中文被转义
默认下，mac的git显示中文是被转义的：

    "source/_posts/git\344\275\277\347\224\250\347\254\224\350\256\260.md"

配置`core.quotepath`为false，就可以让git不转义：

    git config core.quotepath false

然后`git st`的显示效果为：

    source/_posts/linux/git使用笔记.md

## 参考地址
- [git 中文文件名 乱码 mac - beike - ITeye技术网站](http://beike.iteye.com/blog/1075682)