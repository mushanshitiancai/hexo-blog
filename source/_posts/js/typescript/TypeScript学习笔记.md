---
title: 【TODO】TypeScript学习笔记
date: 2016-08-07 15:15:50
categories: [JavaScript,TypeScript]
tags: [js,typescript]
---

觉得JavaScript很方便，也代表未来，但是割舍不下类型检查，IDE提示等，所以来学学TypeScript。

## 为什么有TypeScript，为什么选TypeScript

不管你是不是前端，JavaScript的火爆程度你铁定是有所耳闻的。因为所有浏览器都支持JavaScript，而基本现在都是都是浏览器，所以JavaScript现在也被称为web时代的汇编语言。现在新的语言想要自立门户是非常非常难的，即使像是google这样的公司，自己研发的Go语言，也经历了很多年，才到了现在的知名度，但是市场上的占有率还是比较低的。因为一个语言并不是本身优秀就能让大家转而使用他的，语言设计上的优点，只能算一个参考因素，更重要的是社区对他的支持程度，已经他的生态系统的完善程度。这种优势，不但需要花几年十几年的时间去积累，甚至要需要一个超有钱的干爹，当然，还需要开放。而在这些点做得最好的语言目前有两个，一个是Java，一个是JavaScript。

这是因为这种难以逾越的优势，所以目前有大量语言的思路是翻译成Java或者JavaScript，而不是自己自己门户。前者犹豫JVM的存在所以大部分语言是选择编译为字节码，而不是直接编译为Java（也有，比如Eclispe的Xtend）。比如Groovy,Scala,Clojure,Kotlin,Ceylon等语言就是编译为字节码运行在JVM中的，这样他们就可以直接使用Java生态圈的现有福利，比如海量的库。JavaScript生态圈目前比Java生态圈活跃了一个数量级，那些尝试编译为JavaScript的语言更是比比皆是，比如Scala，Clojure,Kotlin都有对应的编译到JavaScript的开发分支。。其他的还有TypeScript,CoffeeScript,LiveScript,PureScript等等等等，估计都有几百种了（[完整列表][List of languages that compile to JS]）。。。

这么多语言我们要如何选择呢？我个人（我不是一个前端，JavaScript也用得不多）建议是，都不要用。因为这些项目虽然多，但是谁能货到最后就很难说了。而且在ES2015被大多数浏览器实现后，现在的JavaScript比以前好用很多了，所以完全可以只用JavaScript，这样是最好的。

但是，可惜的是，我是一个静态类型检查语言控（目前可以确定，这是一个怪癖，因为很少人像我这么执着），让我写动态类型的代码，我会非常的难受，因为没有类型提示，没有各种提示，没法高效重构，等等等等，这让我有一种不是在写代码，而是在写纯文本的感觉。所以我一直希望有一个能结合动态类型和静态检查的语言，然后我看到了TypeScript。

TypeScript是微软的作品，这个干爹是合格的，更令我心动的是，他的发起人是安德斯·海尔斯伯格！你可能不太了解他，他是Turbo Pascal编译器的主要作者，Delphi、C#和TypeScript之父，同时也是·NET创立者。这些头衔够响亮了吧。。（我最早学习编程学的就是Pascal，用的Turbo Pascal IDE）。这也让我对TypeScript的质量很放心（要知道，.NET的技术一直比Java超前几年）。果然，不久后我看到了Google的Angular团队打算在AngularJS 2中使用TypeScript的消息。啧啧，能够让Google和微软合作，看来这个TypeScript的心态的确够开放，也说明TypeScript的设计与未来让人认可。对了TypeScript之所以能够发展到目前的程度，还有一个很大的原因是他不是单纯的重新设计语法，而是把目标设为JavaScript的超集，也就是说，你把一段JavaScript代码直接当做TypeScript来运行是不会出任何错的，TypeScript不断支持最新的JavaScript标准，设置是还未出台的标准，然后他可以编译为ECMAScript3（或更新版本）的JavaScript，这样开发者可以在TypeScript上享受到最新的ECMAScript特性，而且不会与JavaScript标准冲突，何乐而不为呢。正是这种向标准看齐的设计态度，让TypeScript为大家所接受。虽然不是微软粉丝，为这种转变点一个赞。

## 在Visual Studio Code中运行typescript

微软这几年开始从封闭，强势走向开放，迎合标准。这是一个很好的改变，微软如果早10年这么做，也不至于落到今天这种局面。现在微软开源了.NET和TypeScript，同时也为开发者准备了在其他平台可用的IDE和文本编辑器。比如Visual Studio Code（下面简称code）。code是基于Github开源的用H5技术开发桌面技术的Electron平台开发的，是一个小巧的编辑器，但是却很强大，包含了其他编辑器望尘莫及的调试能力。

一个有趣的事是，Github开源的Electron平台主要是为了开发他们的开源下一代编辑器Atom，所以一开始Electron的名字叫Atom Shell。Electron是一个通用的平台，所以很多第三方在上面开发新一代的桌面APP，其中包括了微软的Code。同样是编辑器，同样是基于Electron，但是Atom的开启速度，打开大文件的能力，响应速度等，都比Code差一些。。。这也可以从侧面看出微软的技术能力。


[Typescript Tutorials - Setup VS Code to Write, Run & Debug Typescript](http://www.mithunvp.com/typescript-tutorials-setting-visual-studio-code/)

## 使用DefinitelyTyped
我们在编写typescript时，如何与那些javascript代码交互呢？虽然本质上是一样的，但是javascript的代码是没有类型信息的。对于这一点，typescript开发者早就考虑到了如何与海量的现有javascript兼容。typescript支持`.d.ts`结尾的声明文件，这种文件是专门用来为现有代码定义类型信息的。

可是现在的javascript库这么多，都自己定义不是类似了。。。所以网上有开源组织维护了一个各种库的类型定义文件的仓库，也就是DefinitelyTyped项目。我们可以在上面查看是否有我们正要使用的项目的类型定义文件。

在TypeScript2.0之后，TypeScript官方支持了DefinitelyTyped，使用定义文件变得非常方便，因为只要用npm就行了，比如你要依赖lodash，执行：

```
npm install --save @types/lodash
```

编译器就会自动使用lodash的定义文件了。一般来说，模块的类型信息对应的模块为`@types/模块名`。如果你想要查询你想用的模块是否有对应的类型定义，可以在[TypeSearch](https://microsoft.github.io/TypeSearch/)上搜索。

## 参考资料
- [List of languages that compile to JS]
- [TypeScript Programming with Visual Studio Code][TypeScript Programming with Visual Studio Code]

[List of languages that compile to JS]: https://github.com/jashkenas/coffeescript/wiki/List-of-languages-that-compile-to-JS
[TypeScript Programming with Visual Studio Code]: https://code.visualstudio.com/docs/languages/typescript