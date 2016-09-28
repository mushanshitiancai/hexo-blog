---
title: 在nodejs项目中使用electron
date: 2016-09-24 10:09:18
categories:
tags: [javascript]
---

前一阵，为vscode写了一个能够粘贴图片的插件[Paste Image][Paste Image]，在这个过程中我发现了vscode设计上的一个操蛋的地方。vscode和atom一样都是基于electron，所以按理来说，插件是应该可以访问electron的接口的，这样插件就可以调用所有的底层API，做出炫目的特效，比如atom就是这样的。但是vscode的插件机制就不一样了，vscode的插件环境是一个普通的nodejs环境，所以在插件中除了调用vscode暴露的API外，就只能只用普通的nodejs标准库与第三方库。这是一个多么傻逼的设计啊，因为很多操作系统的API普通的nodejs包是不会提供的，而electron是提供了的，比如操作剪贴板，操作系统通知等。因为vscode没有暴露，所以vscode的插件可定制化程度就大打折扣了。也正是因为这一点，所以我的插件没法调用electron提供的操作系统剪贴板图片的API，所以我只能用Applescript写了个一个操作剪贴板的小脚本，然后在插件中调用，虽然实现了功能，但是只能支持mac。

没想到的是，一段时间后，竟然有人在我的插件项目主页上提了issue，询问为什么electron提供了这么方便的操作剪贴板接口，而你的插件只支持mac呢。。。我解释了一下原因，他提出可以在插件中启动一个子进程，在子进程中运行一个小electron app，获取剪贴板，然后在回传到插件中。。。。我之前看过这种实现，嗤之以鼻后就没管了。因为这种做法只是在vscode没有提供electron api下的一种很丑陋的做法。这一点都不漂亮，还是得等微软意识到这个问题，然后暴露底层接口才是最终的解决办法。

但是又有人留言说希望能支持Linux，想想也是，弄了一个插件但是只是支持mac也不太好，所以打算来研究一下如何在nodejs程序中启动一个electron程序。





[Paste Image]: https://marketplace.visualstudio.com/items?itemName=mushan.vscode-paste-image
[Windows / Linux support · Issue #1 · mushanshitiancai/vscode-paste-image]: https://github.com/mushanshitiancai/vscode-paste-image/issues/1