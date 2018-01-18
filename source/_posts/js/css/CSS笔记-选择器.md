---
title: CSS笔记-选择器
date: 2018-01-16 21:47:52
categories: [JavaScript]
tags: [css]
---

CSS选择器备忘。

<!-- more -->

## 基本选择器

- 通配选择器：`*`
- 元素选择器 `div`
- ID选择器 `#x`
- 类选择器 `.x`
- 多类选择器 `.a.b`：同时有a和b

## 层次选择器

- 后代选择器 `a b {`
- 子元素选择器 `a > b`
- 相邻兄弟元素选择器 `a + b`：**紧接**在a后面的同级b元素
- 兄弟元素选择器 `a ~ b`：在后面的**所有**同级b元素（不需要相邻）

## 属性选择器
- `a[x]`：包含x属性
- `a[href="xx"]` href属性为xx
- `a[href~="xx"]` href属性包含xx单词的 (`p.xxx`等价于`p[class~="xxx"]`)
- `a[href^="xx"]` href属性以xx开头的
- `a[href$="xx"]` href属性以xx结尾的
- `a[href*="xx"]` href属性包含xx的
- `a[href|="xx"]` href属性为xx，或者以xx-开头的

## 伪类选择器

- 链接伪类（只能应用在a上）：
  - `:link` 未访问的超链接
  - `:visited` 已访问的超链接
- 动态伪类（可以应用在任何元素上）：
  - `:focus` 当前拥有输入焦点的元素
  - `:hover` 鼠标悬停的元素
  - `:active` 被用户输入激活的元素（问题：active和focus的区别？）
- 表单伪类
  - `:enabled` 匹配表单中可用的元素
  - `:disabled` 匹配表单中禁用的元素
  - `:checked` 匹配表单中被选中的radio或checkbox元素

选择子元素的伪类：

1. child系列：
    - `:only-child` 选择作为唯一子元素出现的元素
    - `:first-child` 选择作为子元素出现的第一个元素
    - `:last-child` 选择作为子元素出现的最后一个元素
    - `:nth-child(n)` 作为第n个子元素出现的元素（**从1开始计数**）
    - `:nth-last-child(n)` 作为倒数第n个子元素出现的元素

2. of-type系列，和child系列的区别是只计算同类元素：
    - `:only-of-type` 选择作为唯一子元素出现的元素
    - `:first-of-type` 选择作为子元素出现的第一个元素
    - `:last-of-type` 选择作为子元素出现的最后一个元素
    - `:nth-of-type(n)` 作为第n个子元素出现的元素
    - `:nth-last-of-type(n)` 作为倒数第n个子元素出现的元素

其他：
- `:empty` 选择不包含子元素的元素
- `:not(selector)` 选择不匹配selector的元素

## 伪元素选择器

- 设置首字母样式 `::first-letter`
- 设置第一行样式 `::first-line`
- 设置选中内容的样式 `::selection` 
- 设置之前的样式 `::before`
- 设置之后的样式 `::after`

## 关于一个冒号和两个冒号

两个冒号是CSS3提出的，用于伪元素，但是`:first-line`、`:first-letter`、`:before`、`:after`伪元素是CSS2就提出来了，CSS2的时候伪元素也是用一个冒号，所以这四个是一个冒号，两个冒号都可以的。

## 参考资料
- [CSS3实例解析：伪类前的冒号和两个冒号的区别_百度知道](https://zhidao.baidu.com/question/1993200782457110147.html)