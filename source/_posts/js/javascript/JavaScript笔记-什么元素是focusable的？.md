---
title: JavaScript笔记-什么元素是focusable的？
date: 2018-01-21 11:00:56
categories: [JavaScript]
tags: [javascript,js]
toc: true
---

focus:在元素获得焦点时触发。这个事件不会冒泡;所有浏览器都支持它。

介绍focus事件的时候，一般都是这么一句话，简单易懂，但是，问题是，什么元素是能被focus的呢？

<!-- more -->

结论是：**没有标准，由浏览器决定**。

虽然说没有标准，但是可以整理出常见的，大部分浏览器都支持的focusable元素。比如input和textarea就是很明显的focusable元素。

要想知道所有的focusable元素和定制focusable元素，还需要了解一些理论知识。

## 什么是"focusable"？

能被focus的元素称之为focusable元素。

不过focus有不同的类型，比如可以被鼠标激活，可以被键盘激活，可以被这鼠标/键盘激活等。

所有的HTML元素可以被归纳为以下5类：

- `Inert`
    元素是不能交互的，所以也就不是focusable的
- `Focusable`
    元素可以被脚本激活(element.focus())和鼠标激活，但是不能被键盘激活
- `Tabbable`
    可以被键盘，脚本，鼠标激活。键盘激活是指用tab按键可以选中。
- `Only Tabbable`
    可以被键盘，鼠标激活，但是无法被脚本激活（很少见）
- `Forwards Focus`
    元素会让别的元素获得焦点，而不是自己（很少见）

至于HTML元素是怎么分类的，要看具体的浏览器实现了。

[ally.js](https://allyjs.io)是一个处理网页元素可访问性的辅助库。重点就是对于元素focus的处理。所以它整理了一份所有元素在所有浏览器上focusable的表现的表格[Focusable Elements](https://allyjs.io/data-tables/focusable.html)：

![](/img/js/ally-focusable.png)

## 常用focusable元素

虽然从ally.js的表格来看，不同元素在不同浏览器上的focusable表现是比较复杂的，但是其实我们不会对这么多的元素进行操作，这里整理一下常用的focusable元素：

- 表单：input，textarea，button等元素（不能有disabled特性）
- 超链接：a元素（必须有href特性）
- 拥有tabindex特性的元素
- 拥有contenteditable特性的元素

非常总要的一点是，拥有tabindex特性的元素，是可以获取焦点的。tabindex特性可以让HTML元素纳入到tab激活的范围中。所以想让一般的div元素可以被激活，一般就是用tabindex特性，至于取值是小于等于大于0，要看具体的场景。可以参考文章：TODO

实验：[JS Bin](http://jsbin.com/munahegita/1/edit?html,output)

## 如何获取当前页面中focus的元素？

`document.activeElement`属性返回当前页面上获得焦点的元素。如果没有元素获得焦点，则返回`<body>`元素。

但是需要注意一点，即使整个页面失去焦点（比如在新窗口打开页面，那么原始页面就会失去焦点），`document.activeElement`依然会返回在页面失去焦点前的焦点元素。

所以还需要结合另外一个方法来查询页面中是否有元素获得了焦点：`Document.hasFocus()`方法返回一个 Boolean，表明当前文档或者当前文档内的节点是否获得了焦点。

看一个例子：

```html
<!DOCTYPE html>
<html>
<head>
  <style type='text/css'>
    #message { font-weight: bold; }
  </style>

<script type='text/javascript'>
      setInterval("CheckPageFocus()", 200);
  
      function CheckPageFocus() {
            var info = document.getElementById("message");
           if (document.hasFocus()) {
             info.innerHTML = "该页面获得了焦点.<br>" + document.activeElement;
            }
            else {
             info.innerHTML = "该页面没有获得焦点.<br>" + document.activeElement;
           }
      }
 
    function OpenWindow() {
           window.open ("http://developer.mozilla.org/", "mozdev",  
                     "width=640, height=300, left=150, top=260");
    }
</script>
</head>

<body>
 document.hasFocus 演示<br /><br />
<div id="message">等待用户操作</div><br />
<button onclick="OpenWindow()">打开一个新窗口</button>
</body>
</html>
```

正常情况下，在用户操作前，没有元素获得焦点，所以`document.activeElement`返回的元素是`HTMLBodyElement`：

![](/img/js/focus-activeElement-test1.png)

而用户点击按钮后，按钮获得了焦点，所以`document.activeElement`返回的元素是`HTMLButtonElement`：

![](/img/js/focus-activeElement-test2.png)

但是其实整个页面作为后台页面失去了焦点了，所以`Document.hasFocus()`方法返回false。

## 参考资料
- [Which HTML elements can receive focus? - Stack Overflow](https://stackoverflow.com/questions/1599660/which-html-elements-can-receive-focus)
- [Focusable Elements - Browser Compatibility Table](https://allyjs.io/data-tables/focusable.html)
- [Keyboard-navigable JavaScript widgets - Accessibility | MDN](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Keyboard-navigable_JavaScript_widgets)
- [What does "focusable" mean? - ally.js](https://allyjs.io/what-is-focusable.html)
- [document.activeElement - Web API 接口 | MDN](https://developer.mozilla.org/zh-CN/docs/Web/API/Document/activeElement)
- [document.hasFocus - Web API 接口 | MDN](https://developer.mozilla.org/zh-CN/docs/Web/API/Document/hasFocus)
- [键盘导航的JavaScript组件 - 无障碍 | MDN](https://developer.mozilla.org/zh-CN/docs/Web/Accessibility/Keyboard-navigable_JavaScript_widgets)