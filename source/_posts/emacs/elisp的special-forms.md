---
title: elisp的special forms
date: 2016-02-15 17:24:24
tags: [emacs]
---

Special Forms是lisp中特殊的存在。Special Forms是特殊的原始函数，他的参数不会总被被求值（普通函数的参数会被求值）。多数的特殊形式用于定义控制结构（分支，循环等），值绑定。这些是普通函数做不了的。

每个特殊形式有他自己的规则，那些参数会被求值，那些参数不会被求值。一个特定的参数是否会被求值，可能受另外一个参数的求值结果影响（比如分支）。



## 参考文章
- [GNU Emacs Lisp Reference Manual: Special Forms](http://www.gnu.org/software/emacs/manual/html_node/elisp/Special-Forms.html)
