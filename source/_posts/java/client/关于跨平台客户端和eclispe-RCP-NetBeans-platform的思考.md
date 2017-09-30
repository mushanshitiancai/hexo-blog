---
title: '关于跨平台客户端和eclispe RCP,NetBeans platform的思考'
date: 2016-03-16 15:21:01
categories: [Java]
tags: java
---

一直想自己做一个笔记软件，因为市面上的笔记软件都太不合用了。本来是打算在Atom上扩展的，但是不习惯coffeescript，外加Atom本身还不稳定(甚至没有官方的UI框架，space-pen曾经是，被Atom自己否定了，替代方案还没有)。

个人对于强类型比较偏执，因为强类型可以得到IDE的完美分析，看代码的时候跳转查看代码结构很方便。而像js这种类型的语言，IDE只要遇到灵活一点的语法就完全歇菜了，所以看代码特别累。如果自己写，问题就更大，想要重构也无从下手。当初也是因为这个问题，在Atom上写着写着就停下了。

所以想用Java来写一个。直接从swing或者是javafx上开始写是不太可能的，工作量太大了，editor组件什么的还得自己写。这时，我想到了eclispe。以前就知道eclispe是个可以定制的平台，不是插件定制，而是可以eclispe的最基础层上构建，xmind什么的一看就可以看出来是基于eclispe的。

这个平台叫eclispe rcp([下载地址][eclipse_rcp_download])。整个系统定制性还是很高的样子。主要是提供了很多的基础设施，想eclispe ide中的那些组件都是可以服用的。

上网搜了一下eclispe rcp的资料，有，但是都很久，集中在eclispe rcp3，书籍也是。现在最新的eclispe rcp出到4了(后面成为e4)。去官网搜了一下，咦，怎么找不到文档呢。只看到了一本e4书《Eclipse 4 RCP》。

![](/img/eclispe/eclispe-rcp-document.png)

而这本书不是免费的。他的作者是Lars Vogel，是e4的主要开发者。

我继续搜，网上果然有吐槽的([地址][stackoverflow_e4_decument])，一个人三年前问的e4文档的问题，基本没人回答，最后楼主在两年后回答了自己的问题：

> After almost 2 years there has been no decent response to this question. So i'm considering the Eclipse E4 platform efectively dead, as there are still people voting for this question and can't find an answer.

可见e4真的是没有文档。而且是在几年时间里都没有人管的。

这位楼主说他最后是转向了NetBeans platform(下面简称np)。eclispe和NetBeans是java开源界最大的两个IDE了。NetBeans一直没怎么关注，因为大部分使用的还是eclispe。不同于eclispe使用swt，NetBeans作为sun的亲儿子，使用的是纯粹的swing的。

NetBeans platform和eclispe rcp一样，为大型客户端软件提供了一套基础架构。我去np的官网看了下，果然如楼主说的，文档支持要比e4好了很多。但是我下载了NetBeans试用了一下，eclispe的界面不算漂亮了，NetBeans则更。。。

其实我真的没想到e4的环境竟然是这样的，因为eclispe还是很火的一个开源项目的，现在也有不少像xmind这样的软件基于eclispe的。但是这么大的一个平台竟然没有什么人维护了？让人觉得有一丝丝凉意。

或许这象征的是传统GUI开发技术的没落吧。其实我明白，现在以及未来，是属于HTML5的。但是选择HTML5就以为这选择js，即使现在有很多语言可以编译到js，其实根本没什么用，比如我用过typescript，ide支持什么的还是很不错的，但是，你总难免需要调用现有的js资源，而这些资源都是用js写的，不带类型信息的。即使社区维护了一个流行js库的typescript类型信息的项目，但是上面的更新总是不能完全coverjs库本身的。于是你还需要自己用到什么api写什么api的类型信息。想着都觉得烦。

其实，计算机语言这个领域发展还是很慢的。现在还没有到小康时代吧。因为依然是特定的领域只有特定的语言可用。所以，其实你没有选择。即使你学了什么haskell，学了什么lisp，但是，你用不上。那天我们不是被动的选择语言，而是出于风格选择，那才是语言的小康时代吧。

所以，最后，我还是回到了electron+html5这个方案上来。对于语言，我无选择。

## 参考文章
- [Rich Client Platform - Eclipsepedia](https://wiki.eclipse.org/Rich_Client_Platform)
- [Eclipse RCP (Rich Client Platform) - Tutorial](http://www.vogella.com/tutorials/EclipseRCP/article.html)
- [Eclipse 4 RCP (aka E4) documentation - Stack Overflow][stackoverflow_e4_decument]
- [Eclipse Community Forums: Newcomers » Eclipse 4 RCP (e4) documentation](https://www.eclipse.org/forums/index.php/t/485982/)
- [暂时放弃e4，回到Eclipse 3.x RCP](http://m.blog.csdn.net/article/details?id=7924394)
- [DukeScript：随处运行Java的新尝试](http://www.tuicool.com/m/articles/6bAjUb)

[eclipse_rcp_download]: http://www.eclipse.org/downloads/packages/eclipse-rcp-and-rap-developers/keplersr2 "Eclipse for RCP and RAP Developers | Packages"
[stackoverflow_e4_decument]: http://stackoverflow.com/questions/16325693/eclipse-4-rcp-aka-e4-documentation "Eclipse 4 RCP (aka E4) documentation - Stack Overflow"