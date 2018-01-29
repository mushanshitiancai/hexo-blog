---
title: jQuery笔记-事件
date: 2018-01-28 22:31:26
categories: [JavaScript]
tags: [javascript,js,jquery]
---

jquery事件绑定弄了好几次老是忘记。记录一下。

<!-- more -->

## 历史
从jQuery1.7开始，推荐使用`.on()`来绑定事件。之前的版本大家一般使用的`.bind()`,`.delegate()`,`.live()`来绑定事件，其中`.live()`在1.7版本中被标记为弃用，1.9版本中被移除。`.bind()`,`.delegate()`虽然一直保留到现在，但是也是不推荐使用的。

对于jQuery3.x，绑定事件用`.on()`，取消绑定使用`.off()`，一次性绑定使用`.one()`。

## on方法
`.on()`有两种调用方式：

调用方式一：

```
.on( events [, selector ] [, data ], handler )
```

参数：
- `events`(String)
  一个或者多个事件名，多个的话用空格隔开。
- `selector`(String)
  用来筛选当前元素子元素的选择器。如果为`null`或者是不填，则事件到达当前元素的时候就触发。
- `data`(Anything)
  传递给`event.data`的参数。
- `handler`(Function( Event eventObject [, Anything extraParameter ] [, ... ] ))
  事件触发时执行的函数。如果把`handler`设置为`false`，则相当于是一个返回`false`的函数。

调用方式二：

```
.on( events [, selector ] [, data ] )
```

这种调用方式与方式一的区别是`events`不是一个字符串而是一个对象。这个对象的key是事件字符串，value是对应的处理回调函数。所以这个方式也就不需要`handler`参数了。

事件处理函数返回false，或者指定事件处理函数为false的效果是调用了`event.stopPropagation()`和`event.preventDefault()`

事件处理函数中的`this`变量，如果是直接绑定，则是`this`就是这个元素的引用。如果是事件委托，则是`selector`指定的元素。

jQuery传递给事件处理函数的Event对象是对浏览器的event对象的规范化处理后的对象，如果想要拿到原始的event对象，可以从`event.originalEvent`属性获取。

## 直接事件和代理事件

指定`selector`参数时，是使用了**事件委托**模式。js事件处理中，事件委托是非常重要的一个模式。它有两个优点：

1. 提高性能。因为js中函数也是对象，所以如果为所有的元素都直接添加事件处理函数，会产生很多的对象，对内存消耗比较大，对象和页面见要建立联系，也会拖慢页面的速度。还有如果你修改/替换了页面的元素，而没有解绑事件处理函数，很可能会导致这些函数和页面元素都无法被垃圾回收。通过事件委托，减少事件处理函数，以及其和元素的连接，会提高性能。
2. 对于新添加的子元素，事件委托可以直接生效。如果不用事件委托，需要在新加子元素是都添加事件处理函数，麻烦且低性能。

## 事件命名空间

jQuery在指定事件名称时，可以指定事件的命名空间，用于方便地触发或者删除事件。

比如指定事件名称"click.myPlugin.simple"，那么可以使用`.off("click.myPlugin")`或者`.off("click.simple")`方法来删除这个事件处理函数，而不影响别的时间处理函数。

## 简便写法

对于常用的事件，jQuery提供了特定的方法进行事件处理：

- click
- dbclick
- mousedown
- mouseup
- mousemove
- mouseenter
- mouseleave
- mouseover
- mouseout
- contextmenu

- keydown
- keypress
- keyup

- blur
- focus
- focusin
- focusout

- ready
- resize
- change
- scroll
- select
- submit

简便写法无法指定selector参数。

废弃的方法：

- load
- unload
- error

## 触发事件

使用jQuery提供的trigger可以触发事件，事件是会冒泡的：

- `trigger( eventType [, extraParameters ] )`
- `trigger( event [, extraParameters ] )` event是一个`jQuery.Event`对象

还有一个triggerHandler方法：

- `triggerHandler( eventType [, extraParameters ] )`
- `triggerHandler( event [, extraParameters ] )`

triggerHandler方法只会触发元素上绑定的所有事件处理函数，而不会让事件冒泡。

注意：
1. 除了window对象，在其他的任何对象上调用trigger，如果没有调用`event.preventDefault()`，会调用这个对象上和方法同名的方法，比如`.triggerHandler( "submit" )`会尝试调用`submit`方法。而`triggerHandler`不会这么做
2. trigger和triggerHandler，都会尝试调用对象上on前缀的和evnet同名的方法。 

## 参考资料
- [.on() | jQuery API Documentation](https://api.jquery.com/on/)
- [.trigger() | jQuery API Documentation](https://api.jquery.com/trigger/)
- [jQuery事件与事件对象 - Localhost - 博客园](http://www.cnblogs.com/oneword/archive/2010/11/22/1884413.html)
- [解密jQuery事件核心 - 绑定设计（一） - 【Aaron】 - 博客园](http://www.cnblogs.com/aaronjs/p/3444874.html)