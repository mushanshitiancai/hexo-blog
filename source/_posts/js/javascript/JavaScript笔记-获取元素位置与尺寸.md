---
title: JavaScript笔记-获取元素位置与尺寸
date: 2018-02-04 14:57:21
categories: [JavaScript]
tags: [javascript,js]
toc: true
---

<!-- more -->

## 获取窗口尺寸

网页区域大小：

```js
window.innerWidth
window.innerHeight
```

整个浏览器窗口大小：

```js
window.outerWidth
window.outerHeight
```

## 获取DOM元素尺寸

`Element.getClientRects()`
`Element.getBoundingClientRect()`

返回`DOMRect`对象。


| 属性   | 类型  | 说明                                                          |
| ------ | ----- | ------------------------------------------------------------- |
| left   | float | X 轴，相对于视口原点（viewport origin）矩形盒子的左侧。只读。 |
| top    | float | Y 轴，相对于视口原点（viewport origin）矩形盒子的顶部。只读。 |
| bottom | float | Y 轴，相对于视口原点（viewport origin）矩形盒子的底部。只读。 |
| right  | float | X 轴，相对于视口原点（viewport origin）矩形盒子的右侧。只读。 |
| width  | float | 矩形盒子的宽度（等同于 right 减 left）。只读。                |
| height | float | 矩形盒子的高度（等同于 bottom 减 top）。只读。                |
