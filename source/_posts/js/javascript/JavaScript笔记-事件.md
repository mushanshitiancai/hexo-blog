---
title: JavaScript笔记-事件
date: 2018-01-20 12:57:04
categories: [JavaScript]
tags: [javascript,js]
toc: true
---

《JavaScript高级程序设计》事件部分笔记。

<!-- more -->

## 事件流

事件流描述的是页面的元素接收事件的顺序。

当时IE4.0提出了冒泡模型，而Netscape4.0提出的是捕获模型。

比如这样的一个页面：

```html
<!DOCTYPE html>
<html>
<head>
    <title>Event Bubbling Example</title>
</head>
<body>
    <div id="myDiv">Click Me</div>
</body>
</html>
```

事件冒泡是这样的：

![](/img/js/event-bubbling.png)

- 所有浏览器都支持
- 会一直冒泡到window对象（图片只画到了document对象）
- 不是所有事件都会冒泡

事件捕获是这样的：

![](/img/js/event-capturing.png)

- DOM2级事件规范从document对象开始传播，但是浏览器实现都是从window对象开始传播
- IE9、Safari、Chrome、Firefox 和 Opera 9.5 及更高版本

DOM2事件流则是两种的整合:

![](/img/js/event-dom-event-flow.png)

- 有三个阶段：1.事件捕获阶段 2.目标阶段 3.事件冒泡阶段
- DOM2级事件规范要求捕获阶段目标不会收到事件。也就是说，例子中，div被点击了，首先是捕获阶段document > html > body就结束了。但是目前的浏览器实现，会在捕获阶段也让目标收到事件，也就是捕获阶段变为：document > html > body > div。
- IE9、Safari、Chrome、Firefox 和 Opera 9.5 及更高版本支持

## 事件处理程序

### HTML事件处理程序
使用HTML特性指定事件的处理代码。不推荐使用了。

```html
<input type="button" value="Click Me" onclick="alert(&quot;Clicked&quot;)" />
```

- 可以使用一些特殊变量：`this`，`event`

### DOM0级事件处理程序

DOM0级的特点是简单粗暴。每个元素（包括window和document）都有自己的事件处理程序属性，一般命名是在事件名称前加上on，比如`onclick`。

```js
var btn = document.getElementById("myBtn");
btn.onclick = function(){
    alert(this.id);    //"myBtn"
};

btn.onclick = null; //删除事件处理程序
```

### DOM2级事件处理程序

DOM0级事件处理程序虽然简单，但是有明显缺点，就是一个元素只能绑定一个事件处理函数。所以DOM2级规范定义了两个方法：`addEventListener()`和`removeEventListener()`。

`addEventListener(type, listener[, useCapture])`有三个参数：

- `type` 事件名称
- `listener` 事件处理函数
- `useCapture` 是否在捕获阶段调用处理程序。ture表示在捕获阶段，false表示在冒泡阶段。

```js
var btn = document.getElementById("myBtn");
btn.addEventListener("click", function(){
    alert(this.id);
}, false);
```

`removeEventListener()`和`addEventListener()`拥有一样的方法签名。只是指定的`listener`是你想要删除的事件处理函数的**引用**。

## 事件对象

在DOM上触发事件时，会产生一个event对象。通过这个对象我们可以知道发生了什么事件，目标是谁等等。不同的事件产生的event对象的属性是不一样的。共有的属性有：

| 属性/方法                  | 类型         | 读写 | 说明                                                                                             |
| -------------------------- | ------------ | ---- | ------------------------------------------------------------------------------------------------ |
| bubbles                    | Boolean      | 只读 | 表明是否冒泡                                                                                     |
| cancelable                 | Boolean      | 只读 | 表明是否可以取消事件的默认行为                                                                   |
| currentTarget              | Element      | 只读 | 事件处理程序绑定的元素                                                                           |
| defaultPrevented           | Boolean      | 只读 | 为true表示已经调用了preventDefault()(DOM3级事件中新增)                                           |
| detail                     | Integer      | 只读 | 与事件相关的细节信息                                                                             |
| eventPhase                 | Integer      | 只读 | 调用事件处理程序的阶段:1表示捕获阶段，2表示“处于目标”，3表示冒泡阶段                           |
| preventDefault()           | Function     | 只读 | 取消事件的默认行为。如果cancelable是true，则可以使用这个方法                                     |
| stopImmediatePropagation() | Function     | 只读 | 取消事件的进一步捕获或冒泡，同时阻止任何事件处理程序被调用(DOM3级事件中新增)                     |
| stopPropagation()          | Function     | 只读 | 取消事件的进一步捕获或冒泡。如果bubbles为true，则可以使用这个方法                                |
| target                     | Element      | 只读 | 事件的目标                                                                                       |
| trusted                    | Boolean      | 只读 | 为true表示事件是浏览器生成的。为false表 示事件是由开发人员通过JavaScript创建的(DOM3级事件中新增) |
| type                       | String       | 只读 | 被触发的事件的类型                                                                               |
| view                       | AbstractView | 只读 | 与事件关联的抽象视图。等同于发生事件的window对象                                                 |

在事件处理函数内部，`this`始终等于`currentTarget`的值。而`target`始终指向触发事件的对象。

![](/img/js/event-object-test.png)
事件实验：http://jsbin.com/zucutidozi/2/edit?html,js,output

只有在事件处理程序执行期间，event 对象才会存在;一旦事件处理程序执行完 成，event 对象就会被销毁。

## 事件类型

DOM3级事件规定了一下几类事件：

- UI事件，当用户与页面上的元素交互时触发;
- 焦点事件，当元素获得或失去焦点时触发;
- 鼠标事件，当用户通过鼠标在页面上执行操作时触发;
- 滚轮事件，当使用鼠标滚轮(或类似设备)时触发;
- 文本事件，当在文档中输入文本时触发;
- 键盘事件，当用户通过键盘在页面上执行操作时触发;
- 合成事件，当为 IME(Input Method Editor，输入法编辑器)输入字符时触发;
- 变动(mutation)事件，当底层 DOM 结构发生变化时触发。
- 变动名称事件，当元素或属性名变动时触发。此类事件已经被废弃，没有任何浏览器实现它们。

全部事件的列表可以参考官方文档：[Event reference | MDN](https://developer.mozilla.org/en-US/docs/Web/Events)

事件涉及到的细节很多，比如每个事件是否是冒泡的，是否有默认行为，是否可以取消默认行为，是否会非常频繁的触发等等等等，所以最好是多查官方文档。

### UI事件

- `load`
    - 页面完全加载后在window上触发
    - 所有框架都加载完成后在框架集上触发
    - 图片加载完成后在img元素上触发
    - 嵌入内容加载完毕后在object元素上触发
- `unload`
    - 页面完全卸载后在window上触发（用户切换页面的时候发生）
    - 所有框架都卸载后在框架集上触发
    - 嵌入内容卸载后在object元素上触发
- `abort` 在用户停止下载过程时，如果嵌入的内容没有加载完，则在object元素上面触发
- `error` 
    - 当发生 JavaScript 错误时在 window 上面触发
    - 当无法加载图像时在img元素上面触 发
    - 当无法加载嵌入内容时在object元素上面触发
    - 当有一或多个框架无法加载时在框架集上面触发
- `select` 当用户选择文本框(input或texterea)中的一或多个字符时触发
    - 是否冒泡：是
    - 是否可以取消：否
    - 目标：Element
    - 默认行为：无
- `resize` 当窗口或框架的大小变化时在window或框架上面触发
    - 是否冒泡：否
    - 是否可以取消：否
    - 目标：defaultView
    - 默认行为：无
    - 变化1像素就会触发，所以会非常频繁的触发，所以事件处理程序不能有非常复杂的逻辑（写法见官方文档）
- `scroll` 当用户滚动带滚动条的元素中的内容时，在该元素上面触发。body元素中包含所加载页面的滚动条
    - 是否冒泡：普通元素上触发不会冒泡，但是如果是在document上触发，则会冒泡到window
    - 是否可以取消：否
    - 默认行为：无
    - 目标：defaultView, Document, Element
    - 如果是整个页面滚动，也就是document滚动，可以通过`document.documentElement`的`scrollTop`和`scrollLeft`属性获取滚动的距离
    - 如果是具体的元素滚动，则可以获取具体元素的`scrollTop`和`scrollLeft`属性获取滚动的距离

### 焦点事件

- `focus` 在元素获得焦点时触发。不冒泡
- `blur` 在元素失去焦点时触发。不冒泡
- `focusin` 在元素获得焦点时触发。冒泡
- `focusout` 在元素失去焦点时触发。冒泡

在焦点从一个元素到另外一个元素上时，事件触发顺序如下：

1. focusout 在失去焦点的元素上触发;
2. focusin 在获得焦点的元素上触发;
3. blur 在失去焦点的元素上触发;
4. focus 在获得焦点的元素上触发;

`focusin/focusout`相较于`focus/blur`，有两个优点：
1. `focusin/focusout`会冒泡，`focus/blur`不会
2. `focusin/focusout`的`FocusEvent.relatedTarget`字段会设置为前一个聚焦的元素/下一个聚焦的元素

### 鼠标与滚轮事件

- `click` 按下鼠标左键或者回车键触发
- `dbclick` 双击鼠标左键触发
- `mousedown` 按键任意鼠标按键触发
- `mouseup` 释放鼠标按键时触发
- `mouseenter` 在鼠标首次移动到元素范围内触发。不冒泡
- `mouseleave` 在鼠标移动到元数据范围外触发。不冒泡
- `mouseover` 在鼠标首次移动到元素范围内触发
- `mouseout` 在鼠标从一个元素移动到另外一个元素（可以是子元素）时触发
- `mousemove` 当鼠标在元素内移动时重复触发。

除了`mouseenter`和`mouseleave`都会冒泡，也可以被取消。

只有在同一个元素上触发了`mousedown`和`mouseup`事件才会触发`click`事件。如果其中一个被取消，就不会触发`click`事件。只有两次连续触发`click`事件才会触发`dbclick`事件。`mousedown`和`mouseup`事件不受其他事件影响。

`dbclick`完整的触发顺序如下：

1. mousedown 
2. mouseup 
3. click
4. mousedown 
5. mouseup
6. click
7. dblclick

鼠标事件产生的对象是`MouseEvent`对象。有一些有用的属性：

| 属性名          | 说明                                |
| --------------- | ----------------------------------- |
| x/y             | clientX/clientY的别名               |
| clientX/clientY | 以浏览器左上角为原点的鼠标点击位置   |
| pageX/pageY     | 以页面左上角为原点的鼠标点击位置     |
| screenX/screenY | 以屏幕左上角为原点的鼠标点击位置     |
| offsetX/offsetY | 以元素左上角为原点的鼠标点击位置     |
| shiftKey        | 事件发生时，shift键是否按下         |
| ctrlKey         | 事件发生时，ctrl键是否按下          |
| altKey          | 事件发生时，alt键是否按下           |
| metaKey         | 事件发生时，meta键是否按下          |
| button          | 鼠标按下的按键值，具体见下表         |
| buttons         | 鼠标按下的所有按键组合值，具体见下表 |
| detail          | 鼠标在该位置上连续点击几次           |

如果网页没有滚动，那么`clientX/clientY`和`pageX/pageY`是相等的。

button属性的取值：

- 0 左键
- 1 中键
- 2 右键
- 3 鼠标后退键
- 4 鼠标前进键

但是如果同时按下多个按键怎么办呢？可以用buttons字段：

- 0 没有按键
- 1 左键
- 2 中键
- 4 右键
- 8 鼠标后退键
- 16 鼠标前进键

这些按键的或(|)运算得出button的取值，所以可以通过buttons值算出当前有哪些按键按下。

如果事件是`mouseenter`，`mouseleave`，`mouseover`，`mouseout`，`MouseEvent.relatedTarge`会设置为响应的相关对象：

| 事件       | target属性    | relatedTarge属性 |
| ---------- | ------------- | ---------------- |
| mouseenter | 鼠标进入的元素 | 鼠标离开的元素    |
| mouseleave | 鼠标离开的元素 | 鼠标进入的元素    |
| mouseover  | 鼠标进入的元素 | 鼠标离开的元素    |
| mouseout   | 鼠标离开的元素 | 鼠标进入的元素    |


TODO。。。。

鼠标事件实验：http://jsbin.com/soqocumeva/1/edit?html,js,output

## 参考资料
- [DOM0, DOM1, DOM2, DOM3 - CSDN博客](http://blog.csdn.net/pxy_lele/article/details/49755071/)