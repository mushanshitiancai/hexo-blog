---
title: jQuery笔记-基本使用
date: 2018-01-15 22:44:51
categories: [JavaScript]
tags: [javascript,js,jquery]
---

jQuery常用方法备忘。

<!-- more -->

## jQuery包装集基本操作
- `size()` 返回包装集大小
- `get(index)` 返回包装集中对应下标的元素，如果没有传index，则将所有元素以数组形式返回
- `index(element)` 返回对应的element在包装集中的下标
- `add(expression)` 添加元素到包装集，expression可以是（选择器字符串，HTML字符串，元素，元素数组）
- `not(expression)` 去掉包装集中元素，expression可以是（选择器字符串，元素，元素数组）
- `filter(expression)` 过滤选择器元素，expression可以是（选择器字符串，函数）
- `slice(begin,end)` 返回子包装集，左闭右开
- `is(selector)` 如果包含匹配选择器的元素，返回true

### 链式操作相关方法
- `end()` 回退到jQuery命令链的前一个包装集
- `andSelf()` 合并命令链最近产生的两个包装集

## 根据DOM关系获取包装集
### 子级
- `children()` 获取直接子元素
- `contents()` 获取所有子元素，包含文本节点 
- `find(selector)` 过滤所有子元素。和`children()`的区别是`children()`只获取直接子元素，而`find()`会在所有子元素上过滤，同时`find()`不指定参数返回空，`children()`不指定参数返回所有子元素

### 同级
- `next()` 获取后面紧邻的元素
- `nextAll()` 获取后面所有元素
- `prev()` 获取前面紧邻的元素
- `prevAll()` 获取前面所有元素
- `siblings()` 获取同级的所有元素

### 父级
- `parent()` 获取直接父元素
- `parents()` 获取所有父元素

注：以上方法除了`contents()`都可以传入字符串参数用于过滤

## 修改元素特性和属性

先看看属性和特性的区别：[DOM对象属性(property)与HTML标签特性(attribute)](http://blog.csdn.net/html5_/article/details/39156593)

- `attr(name)` 获取包装集中第一个元素的**特性**值
- `attr(name,value)` 设置特性值
- `attr(attributes)` 批量设置特性值
- `removeAttr(name)` 删除特性值

## 修改元素样式

### Class相关
- `addClass(names)` 添加类到元素
- `removeClass(names)` 删除元素上的类
- `toggleClass(name)` 开关类名
- `hasClass(name)` 判断是否包含类

### CSS相关
- `css(name,value)` 设置元素CSS样式
- `css(properties)` 批量设置元素CSS样式
- `css(name)` 获取元素CSS样式

- `width(value)` 设置宽度
- `height(value)` 设置高度
- `width()` 获取宽度
- `height()` 获取高度

## 操作元素内容

### 获取设置HTML内容
- `html()` 获取第一个元素的html内容
- `html(text)` 设置所有元素的html内容

### 获取设置文本内容
- `text()` 获取所有元素的文本内容
- `text(content)` 设置所有元素的文本内容

### 删除元素
- `remove()` 删除元素。被删除的元素从DOM上**脱离**，并**返回**。
- `empty()` 清空内容

例子：替换元素 `$('.toReplace').after('<p>new</p>').remove()`

### 在元素前后插入内容
- `append(content)` 在最后一个子元素后追加内容。content可以是HTML字符串，元素，包装集
- `appendTo(target)` 将内容追加到目标的最后一个子元素后。target可以是选择器字符串，元素，包装集
- `prepend(content)` 在第一个子元素前插入内容
- `prependTo(target)` 将内容插入到目标第一个子元素前
- `after(content)` 在元素后追加内容
- `insertAfter(target)` 将内容追加到目标元素后
- `before(content)` 在元素前插入内容
- `insertBefore(target)` 将内容插入到目标元素前

关于操作元素是移动还是复制的逻辑：

如果content是包装集，比如`$(".target").append(".source")`
1. `$(".target")`包装集只包含一个元素，则`.source`选中的元素会**移动**到`.target`下
2. `$(".target")`包装集包含多个元素，则`.source`选中的元素会**克隆**到`.target`选中的元素下，除了最后一个。`.source`选中的元素会**移动**到`.target`包装集的最后一个元素中

### 包裹元素
- `wrap(wrapper)` 用指定的内容包裹选中的元素。wrapper可以是字符串，元素，包装集，函数
- `wrapAll(wrapper)` 用指定的内容包裹全部选中的元素
- `wrapInner(wrapper)` 用指定的内容包裹选中元素的内容

### 克隆元素
- `clone(copyHandlers)` copyHandlers为布尔值，表示是否复制事件处理

## jQuery版本的选择

引用[jQuery选择什么版本 1.x? 2.x? 3.x?](https://www.cnblogs.com/osfipin/p/6211468.html)的说法：

**1.x**：兼容ie678,使用最为广泛的，官方只做BUG维护，功能不再新增。因此一般项目来说，使用1.x版本就可以了，最终版本：1.12.4 (2016年5月20日)
**2.x**：不兼容ie678，很少有人使用，官方只做BUG维护，功能不再新增。如果不考虑兼容低版本的浏览器可以使用2.x，最终版本：2.2.4 (2016年5月20日)
**3.x**：不兼容ie678，只支持最新的浏览器。除非特殊要求，一般不会使用3.x版本的，很多老的jQuery插件不支持这个版本。目前该版本是官方主要更新维护的版本。最新版本：3.2.1（2017年3月20日）

1.X大版本下，细分版本非常多，各个版本的函数都会有一定的差异。网上看到的很多教程大多是1.x版本的。jquery官方手册：http://api.jquery.com/

维护ie678是意见头疼的事情，一般我们都会额外加载一个css和js单独处理。值得庆幸的是使用这些浏览器的人也逐步减少，电脑端用户已经逐步被移动端用户所取代，如果没有特殊要求的话，一般都会选择放弃对ie678的支持。

## 参考资料
- 《jQuery实战》
