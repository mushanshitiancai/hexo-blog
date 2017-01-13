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
CodeMirror支持mark一段文本，可以为其添加css或者是其他的一些特性。这是非常强大的功能。Abricotine就是用了这个特性实现了实时预览。

```
myCodeMirror.markText({line:0,ch:0},{line:0,ch:2},{
    className: "mark",
    atomic: true,
});
```

上面的这个例子这个标记第0行的前两个字符，为其添加mark这个css，并且设置`atomic`为true，也就是在移动和删除时，这两个字符是作为一个原子来处理的。

## 扩展CodeMirror
CodeMirror提供了极强的扩展能力。我们可以定制我们我们想要的特性。我们来看看如何做。

### 添加自定义配置API
除了CodeMirror自带的配置，我们可以添加配置，这样就可以在插件中使用我们自定义了配置了。

**CodeMirror.defineOption(name: string, default: any, updateFunc: function)**

为CodeMirror定义新的配置项。updateFunc回调函数的参数为CodeMirror实例和new value。调用时机为编辑器初始化后，和每次配置修改时。

### 定义扩展API
为CodeMirror定义扩展其实就是在CodeMirror类上添加我们的自定义方法，来看看API说明：

**CodeMirror.defineExtension(name: string, value: any)**

defineExtension会把value添加到CodeMirror实例上，value一般是方法。

**CodeMirror.defineDocExtension(name: string, value: any)**

和defineExtension类似，但是是把value添加到Doc类上。

我们来看看具体的代码就明白了：

```
CodeMirror.defineExtension = (name, func) => {
  CodeMirror.prototype[name] = func
}

CodeMirror.defineDocExtension = (name, func) => {
  Doc.prototype[name] = func
}
```

看了这几个API对于如何实现一个CodeMirror插件毫无帮助啊。。。那么具体要如何实现一个呢？我们可以来看看CodeMirror自带的一些插件。

### CodeMirror插件dialog.js解析

```js
// 添加并返回对话框DIV
function dialogDiv(cm, template, bottom) {

  // 获取CodeMirror对应的真实DOM节点
  var wrap = cm.getWrapperElement();
  var dialog;
  dialog = wrap.appendChild(document.createElement("div"));

  // 使用bottom选项来指定对话框显示在编辑器的上方还是下方
  if (bottom)
    dialog.className = "CodeMirror-dialog CodeMirror-dialog-bottom";
  else
    dialog.className = "CodeMirror-dialog CodeMirror-dialog-top";

  if (typeof template == "string") {
    dialog.innerHTML = template;
  } else { // Assuming it's a detached DOM element.
    dialog.appendChild(template);
  }
  return dialog;
}

CodeMirror.defineExtension("openDialog", function(template, callback, options) {
  if (!options) options = {};

  closeNotification(this, null);

  // 新建dialog div
  var dialog = dialogDiv(this, template, options.bottom);
  var closed = false, me = this;

  // 关闭对话框逻辑
  function close(newVal) {
    if (typeof newVal == 'string') {
      inp.value = newVal;
    } else {
      if (closed) return;
      closed = true;
      dialog.parentNode.removeChild(dialog);
      me.focus();

      if (options.onClose) options.onClose(dialog);
    }
  }

  // 对话框一般用于用户输入，所以要么包含一个input，要么包含一个button
  var inp = dialog.getElementsByTagName("input")[0], button;
  if (inp) {
    inp.focus();

    // 如果选项指定了，则设置初始值
    if (options.value) {
      inp.value = options.value;
      if (options.selectValueOnOpen !== false) {
        inp.select();
      }
    }

    // 对话框的输入框的回调，CodeMirror.on见下文说明
    if (options.onInput)
      CodeMirror.on(inp, "input", function(e) { options.onInput(e, inp.value, close);});
    if (options.onKeyUp)
      CodeMirror.on(inp, "keyup", function(e) {options.onKeyUp(e, inp.value, close);});

    CodeMirror.on(inp, "keydown", function(e) {
      if (options && options.onKeyDown && options.onKeyDown(e, inp.value, close)) { return; }
      if (e.keyCode == 27 || (options.closeOnEnter !== false && e.keyCode == 13)) {
        inp.blur(); // 移除键盘焦点
        CodeMirror.e_stop(e);
        close();
      }
      if (e.keyCode == 13) callback(inp.value, e);
    });

    if (options.closeOnBlur !== false) CodeMirror.on(inp, "blur", close);
  } else if (button = dialog.getElementsByTagName("button")[0]) {
    CodeMirror.on(button, "click", function() {
      close();
      me.focus();
    });

    if (options.closeOnBlur !== false) CodeMirror.on(button, "blur", close);

    button.focus();
  }
  return close;
});
```

代码在处理事件回调函数注册时使用了`CodeMirror.on()`，这是CM提供的是一个事件注册函数。

```js
// codemirror/src/util/event.js

const noHandlers = []

// 支持在DOM原数上添加时间处理回调
export let on = function(emitter, type, f) {
  if (emitter.addEventListener) {
    emitter.addEventListener(type, f, false)
  } else if (emitter.attachEvent) {
    emitter.attachEvent("on" + type, f)
  } else {

    // 否则认为是在CodeMirror上添加事件处理回调
    let map = emitter._handlers || (emitter._handlers = {})
    map[type] = (map[type] || noHandlers).concat(f)
  }
}

...

// 为了兼容IE的一些工具方法
export function e_preventDefault(e) {
  if (e.preventDefault) e.preventDefault()
  else e.returnValue = false
}
export function e_stopPropagation(e) {
  if (e.stopPropagation) e.stopPropagation()
  else e.cancelBubble = true
}
export function e_defaultPrevented(e) {
  return e.defaultPrevented != null ? e.defaultPrevented : e.returnValue == false
}
export function e_stop(e) {e_preventDefault(e); e_stopPropagation(e)}


// mixin设计，需要类可以使用这个语句植入事件处理功能
export function eventMixin(ctor) {
  ctor.prototype.on = function(type, f) {on(this, type, f)}
  ctor.prototype.off = function(type, f) {off(this, type, f)}
}
```

然后使用Mixin的方式植入需要事件处理的类上：

```
eventMixin(CodeMirror)
```

好了，大致看完了dialog这个插件的代码。其实一个CodeMirror插件就是扩展CodeMirror这个类。这是最原始也是最强大的扩展方式了。一个扩展就是一个方法，可以调用CodeMirror上的所有方法。



## 参考网址
- [CodeMirror: User Manual](http://codemirror.net/doc/manual.html)
- [CodeMirror: User Manual](http://codemirror.net/doc/manual.html#api)
- [详解addEventListener的三个参数之useCapture_javascript技巧_脚本之家](http://www.jb51.net/article/62293.htm)
- [js中的preventDefault与stopPropagation详解_javascript技巧_脚本之家](http://www.jb51.net/article/46379.htm)