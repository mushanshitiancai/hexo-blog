---
title: JavaScript笔记-tabindex特性
date: 2018-01-21 15:06:38
categories: [JavaScript]
tags: [javascript,js]
toc: true
---

用tab键来遍历界面上所有可以操作的元素是一个非常普遍的用户交互了，这种交互方式也被成为键盘导航。在网页中，虽然使用这种交互的场景较少，但是对于交互复杂的单页面应用，还是需要键盘导航的，尤其是在需要考虑无障碍的场景。

<!-- more -->

默认情况下，网页中的超链接`<a>`以及表单元素`<input>`，`<textarea>`等支持键盘导航。按下tab键可以发现这些元素被蓝色的框框包围，这是这些元素获得焦点的默认样式。元素获得焦点后就能接收按键输入了，比如`<input>`，`<textarea>`就可以输入内容了，`<a>`元素可以用回车键或者空格键进行跳转。

那我们可以为自定义的元素实现键盘导航吗？比如实现了一个菜单控件，希望它可以被tab选中，按回车键触发。假设我们的菜单是用`<div>`或者`<span>`实现的，默认情况下这些元素不是focusable的（关于focusable的说明，参考文章：TODO），是不能被按键导航也无法接受键盘输入的。但是通过tabindex这个全局特性，我们可以为任何元素添加按键导航的能力。

tabindex有三种取值：

- 负值，通常是`"-1"`
    表示元素是可聚焦的。但是无法通过键盘导航访问到，只能通过鼠标点击或者js聚焦。
- `"0"`
    表示元素是可聚焦的。可以通过键盘访问到，其顺序由其在DOM的位置来决定。
- 正值
    表示元素是可聚焦的。可以通过键盘访问到，其数值决定其访问顺序，如果多个元素有同样的tabindex值，顺序由在DOM中的位置来决定。

例子：

```html
<!DOCTYPE html>
<html>
<body>
  <div tabindex="3">tabindex="3"</div>
  <div tabindex="0">tabindex="0_1"</div>
  <div tabindex="-1">tabindex="-1"</div>
  <div tabindex="0">tabindex="0_2"</div>
  <div tabindex="1">tabindex="1"</div>
  <input type="text" value="input">
  <div tabindex="2">tabindex="2"</div>
</body>
</html>
```

这些元素都是focusable的。一下列出所有交互场景：

- 默认情况下按tab，聚焦DOM数中第一个focusable元素，也就是`tabindex="3"`，然后的tab顺序：`tabindex="0_1"` -> `tabindex="0_2"` -> `input`
- 点击`tabindex="0_1"`，tab聚焦顺序：`tabindex="0_2"` -> `input`
- 点击`tabindex="-1"`，tab聚焦顺序：`tabindex="0_2"` -> `input`
- 点击`tabindex="0_2"`，tab聚焦顺序：`input`
- 点击`tabindex="1"`，tab聚焦顺序：`tabindex="2"` -> `tabindex="3"` -> `tabindex="0_1"` -> `tabindex="0_2"` -> `input`
- 点击input，tab跳出页面元素
- 点击`tabindex="2"`，tab聚焦顺序：`tabindex="3"` -> `tabindex="0_1"` -> `tabindex="0_2"` -> `input`

可以归纳出几点：

- 当前无聚焦元素，则tab聚焦页面中第一个focusable元素
- 当前聚焦`tabindex="0"`元素，则tab触发DOM中下一个tabindex="0"或者超链接，表单元素
- 当前聚焦`tabindex="-1"`元素，则tab触发DOM中下一个tabindex="0"或者超链接，表单元素
- 当前聚焦`tabindex="正数"`元素，则下一个触发页面中tabindex数值大于等于当前的元素，如果没有，则触发页面第一个tabindex="0"或者超链接，表单元素

在键盘导航中，超链接，表单元素的效果和tabindex="0"的效果是一样的。

实验地址：http://jsbin.com/munahegita/2/edit?html,output

因为`tabindex="0"`可以让元素变成focusable的，同时不会加入键盘导航。所以一般我们如果想让元素接受键盘输入事件，我们可以在元素上设置这个特性值为`tabindex="0"`。

## 参考资料
[tabindex - HTML（超文本标记语言） | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Global_attributes/tabindex)
- - [键盘导航的JavaScript组件 - 无障碍 | MDN](https://developer.mozilla.org/zh-CN/docs/Web/Accessibility/Keyboard-navigable_JavaScript_widgets)