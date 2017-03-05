---
title: simplenote源码阅读笔记
date: 2017-01-14 14:06:40
categories:
tags:
---

[simplenote][simplenote]是一款开源的多端简单笔记软件。其桌面端是基于Electron和React+Redux，是一个非常好的学习例子。

![](https://camo.githubusercontent.com/7ecb3f5e4692fb708a0c18a790f2ce86f284dc8d/68747470733a2f2f73696d706c656e6f7465626c6f672e66696c65732e776f726470726573732e636f6d2f323031362f30332f73696d706c656e6f74652d6c696e75782e706e67)

<!--more-->

simplenote麻雀虽小五脏俱全，基于simperium实现了多端数据同步。这种使用第三方服务快速实现为用户实现跨平台服务的做法也是目前的主流做法了。在产品早起是很好的做法。

而且我发现simplenote和simperium是一家公司的。。。所以simplenote可以算是这个云服务的DEOM项目吧，难怪免费。。。不过不妨碍我们学习。

## 运行simplenote

因为simplenote基于simperium，所以需要simperium的开发者账号：

- 注册地址 [Sign up here](https://simperium.com/signup/)
- 新建一个应用，用来给simplenote用 [Create a new app here](https://simperium.com/app/new/)

然后我们准备项目：

1. clone simplenote的git项目到本地`git clone https://github.com/Automattic/simplenote-electron.git`
2. 在项目根目录新建文件 `config.json`
3. 添加你注册的应用ID和Token到 `config.json`

    ```json
    {
    "app_id":     "your-app-id",
    "app_key":    "yourappkey"
    }
    ```

4. `npm install`
5. `npm start`
6. 打开 http://localhost:4000. 登录你的simperium账号。

对的，这种方式是在网页中使用simplenote。网页版的和桌面版的就是同一套代码。只不过桌面版的多了electron执行环境，还有一些额外代码，比如菜单，自动更新系统等。

我们可以使用electron来打开simplenote：

```
`npm bin`/electron .
```

### 在vscode中调试simplenote










[simplenote]: https://github.com/Automattic/simplenote-electron
