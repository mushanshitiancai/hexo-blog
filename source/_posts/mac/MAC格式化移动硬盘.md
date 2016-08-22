---
title: MAC格式化移动硬盘
date: 2016-08-11 13:52:15
categories:
tags: mac
---

买了个西部数据的移动硬盘，My Passport Ultra 升级版 1TB 2.5英寸。买的时候已经看到提示了，说是在Mac上使用是需要重新格式化的，买来插上Mac，电脑可以识别硬盘但是不能写：

![](/img/mac/wd-readonly-info.png)

看来对于NTFS格式的，Mac是不能写的。那我们就格式化吧。打开磁盘工具：

![](/img/mac/disk-utility.png)

点击“抹掉”进行格式化：

![](/img/mac/disk-utility-format.png)

还可以点击分区进行分区，我把256GB的空间格式化为ExFAT，这样windows也能用了，不过网上有人说ExFAT格式不稳定，用着看看吧。

![](/img/mac/disk-utility-format-2.png)