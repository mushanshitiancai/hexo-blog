---
title: tmux启动脚本
date: 2016-05-20 10:47:34
tags: [linux,tmux]
---

每次机器关闭后，再次打开tmux需要重复执行新建窗口，panel等操作，能否用脚本自动化？可以！

tmux的命令，既可以在tmux内执行(`perfix :`)，也可以在命令行中作为tmux的参数执行，通过制定session，就可以在外部控制这个session的各种行为。后者就给了shell脚本控制tmux的机会！

首先我们先来了解一些脚本中需要用到的tmux命令：



注意：
我使用了zsh，`new-window -n windown_name`老是不能生效，新窗口的名字还是当前目录名。这是因为zsh会设置当前shell标题为当前目录名，bash就没有这个问题。

zsh的这个功能可以通过设置`export DISABLE_AUTO_TITLE="true"`来关闭。

## 参考资料
- [铃儿响叮当 / tmux 自动启动程序](http://binli.github.io/posts/tmux.html)
- [zsh - Disallowing windows to rename themselves in tmux - Super User](http://superuser.com/questions/739391/disallowing-windows-to-rename-themselves-in-tmux)