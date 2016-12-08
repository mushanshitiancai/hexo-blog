---
title: 【TODO】编写基于jQuery UI Widget Factory的插件
date: 2016-04-02 21:25:48
tags: [js,jquery]
---

前一篇文章([编写jQuery插件](http://mushanshitiancai.github.io/2016/04/02/js/%E7%BC%96%E5%86%99jquery%E6%8F%92%E4%BB%B6/))中我们介绍了如何编写jQuery插件。其中所讲解到的插件都是简单的，无UI的，无状态的插件。如果需要编写带UI的，有状态的插件，那么我们需要自己管理状态，这是比较麻烦的。jQuery UI提供了一个工厂方法帮助我们管理状态与触发回调。这里我们看看如何使用这个工厂方法。

<!-- more -->

## 介绍
工厂方法的签名是：

    jQuery.widget( name [, base ], prototype )

`jQuery.widget`是jQuery UI 1.8加入的，使用的时候注意一下版本。widget可以帮助我们做几件事：

1. 规范插件初始化/销毁
2. 管理插件的公开方法/私有方法
3. 统一管理插件配置，有专门的方法管理配置的更新，配置的更新会触发对应的回调函数
4. 方便的触发用户回调

接下来我们具体看一些如何使用这些特性。我们用一个progressbar插件作为例子。

## 新建插件

```
$.widget( "nmk.progressbar", {
 
    _create: function() {
        var progress = this.options.value + "%";
        this.element.addClass( "progressbar" ).text( progress );
    }
 
});
```

widget函数接受一个插件名name和一个包含插件逻辑的对象prototype。

注意，插件名需要使用命名空间，但是使用的时候不需要命名空间。

    $( "<div />" ).appendTo( "body" ).progressbar({ value: 20 });

## prototype参数
prototype对象规定了一些你需要实现（可选）的变量：

- `_create` 构造函数
- `_destroy` 析构函数
- `_setOption` 使用`option`函数更新配置时触发的回调函数

prototype对象中，包含了一些现成对象：

- `element` 插件对应的DOM对象的jQuery封装
- `options` 配置对象。插件新建时，传入的配置对象会合并到默认options中。

上面的例子没有定义默认options，那么默认options为空对象。你也可以显示指定默认配置：

```
$.widget( "nmk.progressbar", {
 
    // Default options.
    options: {
        value: 0
    },
 
    _create: function() {
        var progress = this.options.value + "%";
        this.element.addClass( "progressbar" ).text( progress );
    }
 
});
```

## 向插件中添加方法



- [Writing Stateful Plugins with the jQuery UI Widget Factory | jQuery Learning Center](https://learn.jquery.com/plugins/stateful-plugins-with-widget-factory/)
- [jQuery插件开发 - 其实很简单 - Jericho - 博客园](http://www.cnblogs.com/fromearth/archive/2009/07/08/1519054.html)
