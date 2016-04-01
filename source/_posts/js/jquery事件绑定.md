---
title: jQuery事件绑定
date: 2016-04-01 22:31:26
tags: js
---

jquery事件绑定弄了好几次老是忘记。记录一下。

<!-- more -->

## 历史
从jQuery1.7开始，推荐使用`.on()`来绑定事件。之前的版本大家一般使用的`.bind()`,`.delegate()`,`.live()`来绑定事件，其中`.live()`在1.7版本中被标记为弃用，1.9版本中被移除。`.delegate()`虽然一直保留到现在，但是也是不推荐使用的。

## `.on()`


## 参考资料
- [jQuery事件与事件对象 - Localhost - 博客园](http://www.cnblogs.com/oneword/archive/2010/11/22/1884413.html)