---
title: tmux启动脚本
date: 2016-05-20 10:47:34
tags: [linux,tmux]
---

每次机器关闭后，再次打开tmux需要重复执行新建窗口，panel等操作，能否用脚本自动化？可以！

<!-- more -->

tmux的命令，既可以在tmux内执行(`perfix :`)，也可以在命令行中作为tmux的参数执行，通过制定session，就可以在外部控制这个session的各种行为。后者就给了shell脚本控制tmux的机会！

首先我们先来了解一些脚本中需要用到的tmux命令：

**新建对话**

    new-session [-AdDEP] [-c start-directory] [-F format] [-n window-name] [-s session-name] [-t target-session] [-x width] [-y height] [shell-command]

新建一个tmux会话。

`[-s session-name]`指定会话的名字。

`-d`让当前的终端打开这个tmux对话。在脚本中我们一般会带上这个参数，因为如果直接让当前终端打开这个tmux对话，脚本就不会继续执行了，也就无法定制这个tmux对话了。

`[-n window-name]`指定新建的会话的第一个窗口的名字。新建一个会话默认会新建一个窗口。

`[shell-command]`指定在新建的窗口中执行的shell命令

**判断一个对话是否存在**

    has-session [-t target-session]

判断指定的tmux对话是否存在，如果存在返回码为0，不存在返回码为1

**新建窗口**

    new-window [-adkP] [-c start-directory] [-F format] [-n window-name] [-t target-window] [shell-command]

新建一个window

`[-t target-window]`指定在哪个session新建window

`[-n window-name]`指定新window的名字

`[shell-command]`指定在新建的窗口中执行的shell命令

**选择一个窗口**

    select-window [-lnpT] [-t target-window]

`[-t target-window]`切换到指定的window

**新建一个panel**

    split-window [-bdhvP] [-c start-directory] [-l size | -p percentage] [-t target-pane] [shell-command] [-F format]

`-h`,`-v` 水平、垂直分割。这里我感觉tmux的分割和说的是相反的。。。因为-h会在中间画一条竖线。。。

`[-t target-pane]`指定需要划分的面板

**发送按键到对应的panel**

    send-keys [-lMR] [-t target-pane] key ...

key可以指定快捷键，比如C-a，C-m等。

**附加到一个session上**

    attach-session [-dEr] [-c working-directory] [-t target-session]

`[-t target-session]`打开对应的tmux对话

## target-window和target-panel的命名规则

`mysession:1`指mysession对话的第一个窗口

`mysession:name`指mysession对话的叫name的窗口

`mysession:1.0`指mysession对话的第一个窗口的第0个面板。

tmux还支持很多灵活的命名方法来定位对应的窗口或者面板，具体的可以参考tmux的man文档。

注意：窗口和面板默认从0开始编码，但是可以通过设置来修改。我吧窗口设置为从1开始编码，这样切换窗口的时候比较方便。

## 关于执行shell命令
这里的shell-command虽然是在tmux中执行命令，但是和手动在tmux中执行是不一样的。

比如`new-window 'vi /etc/passwd'`，tmux会这样执行：`/bin/sh -c 'vi /etc/passwd'`

比如`$ tmux new-window vi /etc/passwd`，tmux会这样执行：`vi /etc/passwd`

这两种情况，当你退出这个vim的时候，这个窗口也会结束！因为这个窗口运行的进程退出了，窗口也会退出。

那如果我只想在窗口的bash中执行命令作为子进程呢？

可以使用`send-keys`命令。

## 例子
了解了一些tmux命令后，就可以弄一个启动tmux的demo脚本了。

我的配置可以参考：[tmux使用与配置](http://mushanshitiancai.github.io/2016/03/02/linux/tmux%E4%BD%BF%E7%94%A8%E4%B8%8E%E9%85%8D%E7%BD%AE/)

要求：启动tmux，第一个窗口打开家目录，窗口的名字为home。第二个窗口打开vi，名字为edit。默认显示第一个窗口。第三个窗口水平分割。

```
#!/bin/bash
#
# tumx启动脚本
# mushan 2016-05-20

# 兼容zsh
export DISABLE_AUTO_TITLE="true"

session="test"

tmux has-session -t $session
if [ $? = 0 ];then
    tmux attach-session -t $session
    exit
fi

tmux new-session -d -s $session -n home
tmux send-keys -t $session:1.0 'cd ~' C-m
tmux new-window -t $session:2 -n edit vi
tmux new-window -t $session:3
tmux split-window -t $session:3 -v

tmux select-window -t $session:1
tmux attach-session -t $session
```

为什么第一行有一个`export DISABLE_AUTO_TITLE="true"`呢？

这是因为我使用了zsh，`new-window -n windown_name`老是不能生效，新窗口的名字还是当前目录名。这是因为zsh会设置当前shell标题为当前目录名，bash就没有这个问题。

zsh的这个功能可以通过设置`export DISABLE_AUTO_TITLE="true"`来关闭。

还有，因为我使用了`set -g base-index 1`这个配置，所以窗口是从1开始编码的，这一点大家需要注意一下。

## 参考资料
- [tmux man](http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/tmux.1)
- [铃儿响叮当 / tmux 自动启动程序](http://binli.github.io/posts/tmux.html)
- [zsh - Disallowing windows to rename themselves in tmux - Super User](http://superuser.com/questions/739391/disallowing-windows-to-rename-themselves-in-tmux)
- [tmux-Productive-Mouse-Free-Development_zh](https://pityonline.gitbooks.io/tmux-productive-mouse-free-development_zh/content/)