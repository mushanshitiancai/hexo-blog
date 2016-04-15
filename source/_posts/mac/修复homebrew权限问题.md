---
title: 修复homebrew权限问题
date: 2016-04-13 14:38:57
tags: mac
---

使用homebrew安装mysql遇到一个错误提示：

    Error: Permission denied - /usr/local/var

根据github上的回答：

> You may have sudo installed something which altered permissions on /usr/local. Try: sudo chown -R $USER:admin /usr/local

也就是可能之前我sudo安装了一些东西，导致`/usr/local`被刷新为root的了。

需要设置回来：

    sudo chown -R "$USER":admin /usr/local
    sudo chown -R "$USER":admin /Library/Caches/Homebrew


## 参考资料
- [osx - How to fix homebrew permissions? - Stack Overflow](http://stackoverflow.com/questions/16432071/how-to-fix-homebrew-permissions/16450503)
- [gitHub's homebrew issue tracker](https://github.com/mxcl/homebrew/issues/19670)