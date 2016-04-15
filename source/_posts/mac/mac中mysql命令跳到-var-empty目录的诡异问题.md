---
title: mac中mysql命令跳到/var/empty目录的诡异问题
date: 2016-04-13 14:57:53
tags: mac
---

在mac中输入`mysql`，结果直接跳到了目录`/var/empty`，这是啥情况？

<!-- more -->

这是因为我使用了zsh，zsh的一个功能就是输入用户名直接跳转到这个用户的家目录。查看`/etc/passwd`，发现有有不少用户：

```
...
_svn:*:73:73:SVN Server:/var/empty:/usr/bin/false
_mysql:*:74:74:MySQL Server:/var/empty:/usr/bin/false
_sshd:*:75:75:sshd Privilege separation:/var/empty:/usr/bin/false
...
```

所以当你还未安装mysql的时候，如果你执行mysql，就会被zsh认为是你要进入mysql用户的目录，匹配为`_mysql`用户，最后进入了其家目录`/var/empty`。

按mysql后就不会有这个问题了。因为在PATH寻找可执行文件的优先级比认为是用户名的优先级高。

## 参考资料
- [osx, mysql command goes in /var/empty - Stack Overflow](http://stackoverflow.com/questions/7956345/osx-mysql-command-goes-in-var-empty)
