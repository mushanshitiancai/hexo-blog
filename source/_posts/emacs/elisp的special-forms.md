---
title: 【TODO】elisp的special forms
date: 2016-02-15 17:24:24
tags: [emacs]
---

Special Forms是lisp中特殊的存在。Special Forms是特殊的原始函数，他的参数不会总被被求值（普通函数的参数会被求值）。多数的特殊形式用于定义控制结构（分支，循环等），值绑定。这些是普通函数做不了的。

每个特殊形式有他自己的规则，那些参数会被求值，那些参数不会被求值。一个特定的参数是否会被求值，可能受另外一个参数的求值结果影响（比如分支）。

如果一个表达式的第一个标识符是special form，那这个表达式就必须按照这个特殊形式的规则来。否则emacs的行为是为知的（虽然他不会奔溃）。比如`((lambda (x) x . 3) 4)`包含一个以lambda开头的表达式，但是格式不不对，所以emacs可能触发一个error，或者返回3，或者返回4，或者有其他行为。

elisp中的所有特殊形式有：
- and
- catch
- cond
- condition-case
- defconst
- defvar
- function
- if
- interactive
- lambda
- let
- let*
- or
- prog1
- prog2
- progn
- quote
- save-current-buffer
- save-excursion
- save-restriction
- setq
- setq-default
- track-mouse
- unwind-protect
- while

common lisp的用户注意，cl和elisp的特殊形式有一些区别。`setq`,`if`,`catch`是两者都有的。`save-excursion`是elisp特有的，`throw`在cl中是特殊形式，而在elisp中是函数。

## function



## 参考文章
- [GNU Emacs Lisp Reference Manual: Special Forms](http://www.gnu.org/software/emacs/manual/html_node/elisp/Special-Forms.html)
- [GNU Emacs Lisp Reference Manual: Anonymous Functions](http://www.gnu.org/software/emacs/manual/html_node/elisp/Anonymous-Functions.html#Anonymous-Functions)
