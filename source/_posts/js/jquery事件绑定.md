---
title: jQuery事件绑定
date: 2016-04-01 22:31:26
tags: [js,jquery]
---

jquery事件绑定弄了好几次老是忘记。记录一下。

<!-- more -->

## 历史
从jQuery1.7开始，推荐使用`.on()`来绑定事件。之前的版本大家一般使用的`.bind()`,`.delegate()`,`.live()`来绑定事件，其中`.live()`在1.7版本中被标记为弃用，1.9版本中被移除。`.bind()`,`.delegate()`虽然一直保留到现在，但是也是不推荐使用的。

现在大家使用的基本都是jQuery2.x吧，绑定事件用`.on()`，取消绑定使用`.off()`，一次性绑定使用`.one()`。

## `.on()`
`.on()`有两种调用方式：

调用方式一：

    .on( events [, selector ] [, data ], handler )

参数：
- events(String)
  一个或者多个事件名，多个的话用空格隔开。
- selector(String)
  用来筛选当前元素子元素的选择器。如果为`null`或者是不填，则事件到达当前元素的时候就触发。
- data(Anything)
  传递给`event.data`的参数。
- handler(Function( Event eventObject [, Anything extraParameter ] [, ... ] ))
  事件触发时执行的函数。如果把`handler`设置为`false`，则相当于是一个返回`false`的函数。

调用方式二：

    .on( events [, selector ] [, data ] )

这种调用方式与方式一的区别是`events`不是一个字符串而是一个对象。这个对象的key是事件字符串，value是对应的处理回调函数。所以这个方式也就不需要`handler`参数了。

## 直接事件和代理事件
TODO

## 事件命名空间


## 参考资料
- [jQuery事件与事件对象 - Localhost - 博客园](http://www.cnblogs.com/oneword/archive/2010/11/22/1884413.html)
- ✨[解密jQuery事件核心 - 绑定设计（一） - 【Aaron】 - 博客园](http://www.cnblogs.com/aaronjs/p/3444874.html)