---
title: ctags使用笔记
date: 2016-01-29 15:45:21
tags: [tools]
---

ctags是用来生成编程语言的tag文件的工具。tag文件可以用来定位代码中的各种符号，比如变量，函数，类等。像vim，emacs，sublime等文本编辑器想要实现IDE的跳转到函数定义，重命名函数等功能，一般都是借助ctags来实现的。

一般说的ctags指的是[Exuberant Ctags][Exuberant Ctags]。虽然这个项目09年就停止维护了，但是现在网上的教程和各个Linux的软件仓库使用的还是这个ctags，版本为5.8。

## 安装

    yum install ctags

## 生成tag文件

    ctags -R *

这是ctags最经典的用法。`-R`表示递归的处理目录中的所有文件。`*`匹配任意任意文件。

执行完毕后，ctags会在执行目录下生成一个`tags`文件。

## 在vim中使用ctags
vim默认就支持ctags。vim默认在当前启动目录中寻找`tags`文件。如果`tags`存在，可以使用这些快捷和命令：

- `vi -t tag` 启动vi，并跳转的tag的位置
- `:ta tag` 搜素tag
- `Ctrl-]` 跳转到光标所指的标示符的定义处
- `Ctrl-T` 回到跳转前的位置

## 在emacs中使用ctags
emacs默认支持的是etags。etags是emacs自带的一个tag生成工具。和ctags生成的`tags`文件不同，etags生成的是`TAGS`，而且其中的格式也是不一样的。

`Exuberant Ctags`提供了etags的兼容模式，可以生产etags风格的tag文件。只需要加上`-e`参数即可。

emacs默认在当前启动目录中寻找`TAGS`文件，这一点和vim一样。如果`TAGS`文件存在，可以使用以下命令或快捷键：

- `M-x visit−tags−table <RET> FILE <RET>` 指定一个tag文件
- `M-.` 跳转到标示符的第一个定义。默认使用光标所指的标示符，如果光标没有指向一个标示符，则让用户输入。（这个和vim不一样，vim是提示光标所指的不是标示符）
- `M-*` 回到跳转前的地方
- `C-u M-.` 跳转到之前指定的tag的下一个定义

## 详细参数
ctags的参数太多了，目前够用了，以后用到了再来记录吧。

```
--list-languages 列出支持的语言
--list-kinds 列出支持的语言具体的支持情况
--list-maps 列出ctags文件后缀名到语言的映射关系
```

## 参考网址
- [CTAGS](http://ctags.sourceforge.net/ctags.html)
- [Programming in Emacs Lisp: etags](https://www.gnu.org/software/emacs/manual/html_node/eintr/etags.html)

[Exuberant Ctags]: http://ctags.sourceforge.net/

