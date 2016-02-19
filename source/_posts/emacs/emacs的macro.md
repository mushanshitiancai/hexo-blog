---
title: 【TODO】emacs的macro
date: 2016-02-18 10:19:49
tags: [emacs]
---

lisp的宏使你可以定义新的控制流程和其他语言特性。宏的定义特别像函数，但是函数是告诉解释器如何计算一个值，而宏则是告诉解释器如何计算出另外一个lisp表达式。我们称这个表达式为这个宏的展开。

宏之所以可以做到这些，是因为宏可以在未求值的lisp表达式上操作，而函数只能在参数的值上操作

## 参考文章
- [GNU Emacs Lisp Reference Manual: Macros](http://www.gnu.org/software/emacs/manual/html_node/elisp/Macros.html#Macros)
