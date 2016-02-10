---
title: emacs快捷键改造计划
date: 2016-02-09 16:53:59
tags: [emacs]
---

emacs中充满了二段快捷键。就连退出这么常用的都是`C-x C-c`这种，这在一定程度上也成了VIM党的把柄，说什么小拇指疼啥的。

现代的快捷键都是单段的，比如保存是`C-s`，虽然快捷键数量较于多段，会少很多，但是更快捷，而且我们其实也用不了那么多的快捷键，很多操作直接敲命令（结合ido或helm）会更快。我们当前的习惯也是如此的。

多段快捷键还有一个问题，比如`C-x b`，这种类型的二段快捷键，如果当前处于中文输入法，在按b的时候就会遇到麻烦咯。作为中国人，不能不考虑这个问题

所以我希望能把最常用的一些快捷键能绑定在单段快捷键上，比如`C-q`，或者`C-S-q`。

## 快捷键绑定相关函数
一般使用`global-set-key`来绑定快捷键到对应函数。

    (global-set-key (kbd "C-x C-\\") 'next-line)

    (global-set-key key binding)
    ≡
    (define-key (current-global-map) key binding)

如果存在`C-l`这样的快捷键，如果你想要绑定`C-l C-l`，那么需要先解绑`C-l`，否则会提示：

    Warning (initialization): An error occurred while loading `/Users/mazhibin/.emacs':
    error: Key sequence C-l C-l starts with non-prefix key C-l

解绑使用`global-unset-key`：

    (global-unset-key "\C-l")
        ⇒ nil
    (global-set-key "\C-l\C-l" 'redraw-display)
        ⇒ nil
    (global-unset-key key)
    ≡
    (define-key (current-global-map) key nil)

## 退出改造
这是首当其冲的改造。目前使用`C-x C-c`真心不爽，这么常用的你让我按两下？至于VIM的`ESC S-; q`我就呵呵了。

`C-q`是个好选择，不过目前有绑定了([文档][insert-text])。`C-q`默认绑定的命令是`quoted-insert`用于插入特殊字符。好吧，这个功能我估计我一辈子都用不了一次，竟然绑定在q上，简直是暴殄天物。

    (global-set-key (kbd "C-q") 'save-buffers-kill-terminal)

> 总结：`C-q`，插入特殊字符=>保存退出


## 参考文章
- [GNU Emacs Lisp Reference Manual: Key Binding Commands](https://www.gnu.org/software/emacs/manual/html_node/elisp/Key-Binding-Commands.html)
- [GNU Emacs Manual: Inserting Text](http://www.gnu.org/software/emacs/manual/html_node/emacs/Inserting-Text.html)
- [GNU Emacs Lisp Reference Manual: Prefix Keys](https://www.gnu.org/software/emacs/manual/html_node/elisp/Prefix-Keys.html)



[insert-text] http://www.gnu.org/software/emacs/manual/html_node/emacs/Inserting-Text.html "GNU Emacs Manual: Inserting Text"