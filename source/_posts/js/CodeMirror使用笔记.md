---
title: CodeMirror使用笔记
date: 2016-12-05 18:20:12
categories:
tags: [javascript]
---

CodeMirror是一个运行在浏览器中的代码编辑器。他是个很牛逼的编辑器，支持100多种语言，高度可定制。如果你在页面中需要嵌入一个代码编辑区，CodeMirror是一个不错的选择。

<!-- more -->

## 安装
从CodeMirror首页下载最新的代码：[codemirror.zip](http://codemirror.net/codemirror.zip)

我们需要依赖其中lib和mode中的文件：

```
<script src="lib/codemirror.js"></script>
<link rel="stylesheet" href="lib/codemirror.css">
<script src="mode/javascript/javascript.js"></script>
```

然后实例化一个编辑器：

```
var myCodeMirror = CodeMirror(document.body);
```

编辑器会追加在`document.body`中。这样就可以了，是不是很简单。

CodeMirror函数接受第二个参数，可以对编辑器进行配置：

```
var myCodeMirror = CodeMirror(document.body, {
  value: "function myScript(){return 100;}\n",
  mode:  "javascript"
});
```

这里value指定了编辑器中的默认内容，mode指定了编辑器目前的语言模式。对于模式，还需要引入模式对应的js文件才能使用。

如果想更灵活地处理如何安放编辑器，可以使用一个回调函数作为第一个参数，回调函数的参数就是编辑器元素，你可以在函数中直接操作，比如替换HTML原生的TextArea：

```
var myCodeMirror = CodeMirror(function(elt) {
  myTextArea.parentNode.replaceChild(elt, myTextArea);
}, {value: myTextArea.value});
```

不过对于这个用例，cm提供了一个快捷方法：

```
var myCodeMirror = CodeMirror.fromTextArea(myTextArea);
```

## 监听事件
CodeMirror对象在用户操作时会发出对应的事件，我们可以监听这些事件来指定处理函数：

比如在修改时，会触发`change`事件：

```
myCodeMirror.on("change",function(instance, changeObj){
    console.log(changeObj.origin);
});
```

## 标记文本
CodeMirror支持mark一段文本，可以为其添加css或者是其他的一些特性

```
myCodeMirror.markText({line:0,ch:0},{line:0,ch:2},{
    className: "mark",
    atomic: true,
});
```

上面的这个例子这个标记第0行的前两个字符，为其添加mark这个css，并且设置`atomic`为true，也就是在移动和删除时，这两个字符是作为一个原子来处理的。

## 整合CodeMirror和Angularjs2

TODO

## 参考网址
- [CodeMirror: User Manual](http://codemirror.net/doc/manual.html)
