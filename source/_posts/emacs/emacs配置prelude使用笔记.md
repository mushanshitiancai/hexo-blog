---
title: emacs配置prelude使用笔记
date: 2016-01-27 16:42:12
tags: [tools,emacs]
---

Perlude也算是emacs上一个很有名的配置的了，在github上有2000多的start。

## 安装

    curl -L https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh

## 更新
更新插件：

    M-x package-list-packages RET U x

更新Perlude本身：

    cd ~/.emacs.d && git pull

## 开关模块
perlude包含了许多模块，但是默认并没有全部开启。模块配置文件在`~/.emacs.d/prelude-modules.el`中：

```
;; Emacs IRC client
(require 'prelude-erc)
(require 'prelude-ido) ;; Super charges Emacs completion for C-x C-f and more
;; (require 'prelude-helm) ;; Interface for narrowing and search
;; (require 'prelude-helm-everywhere) ;; Enable Helm everywhere
(require 'prelude-company)
;; (require 'prelude-key-chord) ;; Binds useful features to key combinations
;; (require 'prelude-mediawiki)
;; (require 'prelude-evil)

;;; Programming languages support
(require 'prelude-c)
;; (require 'prelude-clojure)
...
```

需要什么模块，去掉前面的注释就可以了。

## 配置文件
那我们需要在哪里添加我们自己的自定义配置呢？Perlude提供了一个`personal`目录。里面的所有elisp脚本都会被被调用

`personal/preload`中的所有elisp脚本会在Prelude开始前调用。

## Helm
默认，prelude不开启helm。

    (require 'prelude-helm-everywhere)

安装失败

    File error: https://melpa.org/packages/helm-ag-20160119.454.el, Not found

这是helm-ag模块安装失败了。目前原因不明，先把这个模块关闭吧，`.emacs.d/modules/prelude-helm-everywhere.el`：

```
;; (prelude-require-packages '(helm-descbinds helm-ag))  注释掉这一行
```


## 源码阅读笔记

















