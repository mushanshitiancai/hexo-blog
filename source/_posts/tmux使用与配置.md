---
title: 【TODO】tmux使用与配置
date: 2016-03-02 16:40:38
tags: tools
---

tmux是一个终端复用工具。就是你可以在一个终端中用tmux开很多终端。

公司使用统一的开发机开发，所以长时间登录是必须的，tmux可以保存会话，这样第二天来上班再次连接开发机时，一切保持原样，很方便，现在已经是不可或缺的工具之一了。

tmux使用分层的思想来管理终端：会话(session)>窗口(window)>面板(panel)。一个tmux是可以被多个客户端(client)访问的。

tmux命令常用操作：
- 新建会话：tmux new -s xxx
- 进入会话：tmux attach -t xxx

进入tmux后，可以使用快捷键进行切换窗口等操作。tmux的快捷键都是双段的，默认的快捷键前缀为`ctrl-b`，然后可以接的快捷键有：

```
c 新建窗口
" 上下划分当前panel
% 左右划分当前panel

0-9 切换0-9号window

d 退出当前client，session会继续存在
& 关闭当前window
x 关闭当前panel

$ 重命名当前会话
, 重命名当前窗口


C-b 发送ctrl-b到tmux的终端中
C-o
C-z 挂起当前client

```



我的tmux配置。

```
set -g default-terminal "screen-256color"
set-window-option -g mode-keys vi

set -g base-index 1

setw -g mouse-resize-pane on
setw -g mouse-select-pane on
setw -g mouse-select-window on
setw -g mode-mouse on

set -g status-bg black
set -g status-fg white
set -g status-left ""
set -g status-right "#[fg=green]#H"

#set-window-option -g status-left " #S "
set-window-option -g status-left ""
set-window-option -g status-left-fg black
set-window-option -g status-left-bg white

set-window-option -g status-right " %Y-%m-%d %H:%M"•
#set-window-option -g status-right-fg white
#set-window-option -g status-right-bg black

set-window-option -g window-status-format " #I: #W "

set-window-option -g window-status-current-format " #I: #W "
set-window-option -g window-status-current-fg green
set-window-option -g window-status-current-bg black

bind r source-file ~/.tmux.conf \; display "Reloaded!!!!!"
```

## 参考文章：
- [OpenBSD manual pages](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/tmux.1?query=tmux&sec=1)
- [tony/tmux-config: Example tmux configuration - screen + vim key-bindings, system stat, cpu load bar.](https://github.com/tony/tmux-config)
- [Tmux 速成教程：技巧和调整 - 博客 - 伯乐在线](http://blog.jobbole.com/87584/)

