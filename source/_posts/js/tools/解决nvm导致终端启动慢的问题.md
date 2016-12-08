---
title: 解决nvm导致终端启动慢的问题
date: 2016-07-29 19:37:53
categories:
tags: [js,nodejs]
---

最近终端启动很慢，大概有一秒左右，一查原来是因为nvm的问题。nvm在安装的时候，需要在.zshrc中添加：

```
export NVM_DIR="/Users/mazhibin/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
```

就是`. "$NVM_DIR/nvm.sh"`拖慢了终端的启动。

nvm的github页面上有很多人提这个问题：

- [nvm.sh is slow (200ms+) · Issue #539 · creationix/nvm](https://github.com/creationix/nvm/issues/539)
- [Performance: `nvm use` takes about a second · Issue #860 · creationix/nvm](https://github.com/creationix/nvm/issues/860)
- [NVM starting too slow -- can I just add the bin folder to PATH? · Issue #782 · creationix/nvm](https://github.com/creationix/nvm/issues/782)
- [Shell startup can be improved by not printing npm version when sourcing nvm.sh · Issue #781 · creationix/nvm](https://github.com/creationix/nvm/issues/781)

虽然很多人提问，但是这个问题目前还没有被解决。综合参考了一下，我总结出下面这种方案，能在不影响使用的情况下，是nvm不影响终端启动。修改.zshrc配置如下：

```
export NVM_DIR="/Users/mazhibin/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
nvm() { . "$NVM_DIR/nvm.sh" ; nvm $@ ; }
export PATH=/Users/mazhibin/.nvm/versions/node/v6.2.0/bin/:$PATH
```

可以把这里的`v6.2.0`换成你想要的默认node版本。原理是启动终端的时候不执行nvm.sh脚本。而是直接把某个具体版本的node的路径放到PATH中。等到执行nvm的时候，再去执行nvm.sh脚本。
