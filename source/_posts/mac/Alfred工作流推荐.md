---
title: Alfred工作流推荐
date: 2016-08-11 19:55:50
categories: [自动化]
tags: [mac,automation]
---

Alfred我主要是用于快熟应用切换的。因为我经常会开十几个程序几十个窗口，所以跳转很是问题，以前在用windows的时候，就一直想找一个能够快速切换程序的工具，可惜没有找到。换了Mac后，遇到了Alfred，一拍即合，的确是不可离开的利器了。

工作流我现在用的还不多，但是前几天结合Apple Script倒腾了一个自动登录跳板机再登录对应主机的自动化脚本，生产力大幅提高，所以以后打算好好的倒腾一下这个workflow。

Alfred的workflow本身并不太复杂，但是他可以调用外部程序，或者是执行脚本来执行逻辑，结合Alfred这个快捷入口与操作方式，就变得非常强大了，有一种UNIX管道的感觉。

下面我给大家推荐一些我日常中用到的工作流：

## 使用JetBrains系列IDE快速打开项目

项目地址：[bchatard/jetbrains-alfred-workflow: Open project with one of JetBrains' product.](https://github.com/bchatard/jetbrains-alfred-workflow)

效果如图：

[![](https://raw.githubusercontent.com/bchatard/jetbrains-alfred-workflow/master/doc/img/jetbrains-projects-secret-light.png)](https://raw.githubusercontent.com/bchatard/jetbrains-alfred-workflow/master/doc/img/jetbrains-projects-secret-light.png)

我使用这个项目，最主要的目的倒还不是“打开”某个项目，而是为了“切换”到某个项目。因为IDEA和Eclispe不一样，一个窗口里只能打开一个项目，所以经常会打开好几个IDEA的窗口，这时切换工程就成为一个问题了，使用这个工作流，如果是打开一个已经打开的工程，就会自动切换到那个工程的IDEA窗口，爽！

缺点：
1. 菜单反馈的延迟有点高
2. 如果当前激活的是IDEA，则可以切换，但是如果不是激活的IDEA，那么就不会切到那个窗口，这个问题还比较严重

第二个问题解决了！其实这个工作量调用的是idea命令来打开工程目录的（参考我的文章），idea命令执行后，如果当前已经打开了这个工程，会把这个窗口激活，但是不是Alfred中的激活概念（切换到当前应用），而是在所有打开的IDEA窗口中，这个窗口是被激活的。所以这时再用Alfred的激活功能来激活IDEA，就会切换到这个窗口了！！

我修改了一下这个工作量，把最后烦人的notification去掉，换成激活IDEA，搞定😊

![](/img/java/alfred-idea.png)







