---
title: 【TODO】emacs标准库-thingatpt.el
date: 2016-02-20 10:36:52
tags: [emacs]
---

`thing-at-point`库用来快去获取光标下的元素，比如`symbol`, `list`, `sexp`, `defun`,
`filename`, `url`, `email`, `word`, `sentence`, `whitespace`,
`line`, and `page`。

    (require 'thingatpt)
    (thing-at-point 'sentence)

这样就可以获取光标下的句子了。

`thing-at-point`还有很多实用函数，比如`thing-at-point-url-at-point`可以获取光标下的链接。

## 参考地址
- [EmacsWiki: Thing At Point](https://www.emacswiki.org/emacs/ThingAtPoint)
