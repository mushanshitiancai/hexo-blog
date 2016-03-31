---
title: express学习
date: 2016-03-23 18:12:22
tags: [js,nodejs]
---

## 自动重载express
[nodemon](http://nodemon.io/)是一个专门用来自动重新加载的node库。

    npm install -g nodemon

然后用nodemon来替代node运行程序即可。

## express的Request对象

```
req.app            express应用实例
req.baseUrl        路由模块挂载的url
req.body           用object表示的请求体，需要body-parsing中间件支持
req.cookies        用object表示的cookie，需要cookie-parser中间件支持
req.fresh          请求是否新鲜[fresh](http://www.expressjs.com.cn/4x/api.html#req.fresh)
req.hostname       主机名(header中的Host)
req.ip             客户端的IP
req.ips            列出请求途径的所有机子的IP地址
req.originalUrl    原始URL
req.params         路由路径里包含参数时(/user/:name)，参数会放到params中(req.params.name)
req.path           URL中的路径(example.com/users?sort=desc -> /users)
req.protocol       请求的协议(http/https)
req.query          保存请求URL中参数的object(/shoes?order=desc&shoe[color]=blue&shoe[type]=converse  -> req.query.order/req.query.shoe.color)
req.route          路由信息字符串
req.secure         如果使用了https则为true
req.signedCookies  
req.stale          fresh的反义词
req.subdomains     子域名(tobi.ferrets.example.com -> ["ferrets", "tobi"])
req.xhr            如果是ajax请求则为true
```

## 疑问
- 每个用户都对应一个User类，那这个类是每次用户请求都new呢？还是new一遍然后保存到session中？
- mysql连接，是后台启动后就connect，然后退出的时候才end，还是每次查询都connect/end？
- **注意：**保存类到session中，会丢失方法！所以保存类到session中不可行。

## 参考资料
- [cookie 和 session - Node.js 实战心得 - 极客学院Wiki](http://wiki.jikexueyuan.com/project/node-lessons/cookie-session.html)
