---
title: JavaScript笔记-JavaScript Modules
date: 2018-01-14 08:05:57
categories: [JavaScript]
tags: [javascript,js]
---

无意发现2017年9月，Chrome推出的61版本已经支持JavaScript Modules了！

![](/img/js/js-modules-chrome-support.png)

我作为一个非前端工作者，业余爱好者，对于前端目前的构建系统是非常恐惧的，gulp，grunt，webpack，browserify，babel等等等等，加上一大坨插件，学习这些构建工具的难度已经超过了我要写的东西的难度了。。而且用了这套系统后，修改代码需要等待编译才能生效，简直是并超越赶上Java的复杂度了。所以最后退回了原始JavaScript的道路。

现在浏览器支持原生Modules了，可以尝试一下，至少在开发的时候，不用编译，等到需要把代码输出到低版本浏览器的时候，再编译一下就行了。而且写出来的文件，可以直接用于Node或者Electron（目前还是不行。。）。

<!-- more -->

## JavaScript Modules语法

JavaScript的语法可以学习阮一峰的教程：

- [Module 的语法 - ECMAScript 6入门](http://es6.ruanyifeng.com/#docs/module)
- [Module 的加载实现 - ECMAScript 6入门](http://es6.ruanyifeng.com/#docs/module-loader)

## 实验

`index.html`，首页，在页面中使用`type="module"`的script标签：

```html
<html>
<head>
    <title>JavaScript Modules Test</title>
</head>
<body>
    <script type="module" src="index.js"></script>
</body>
</html>
```

`index.js`，主脚本，使用JavaScript Modules的语法引入了`config.js`：

```js
import {text} from './config.js'

let e = document.createElement("div")
e.innerHTML = text
document.body.appendChild(e)
```

`config.js`，模块化脚本示例：

```js
export var text = "hello"
```

在浏览器中打开`index.html`，发现错误：

![](/img/js/js-module-file-protocol-cors.png)

为什么？

- [javascript - ES6 module support in Chrome 62/Chrome Canary 64, does not work locally, CORS error - Stack Overflow](https://stackoverflow.com/questions/46992463/es6-module-support-in-chrome-62-chrome-canary-64-does-not-work-locally-cors-er)
- [javascript - Access to Image from origin 'null' has been blocked by CORS policy - Stack Overflow](https://stackoverflow.com/questions/41965066/access-to-image-from-origin-null-has-been-blocked-by-cors-policy)

看了以上的资料得知，JavaScript Modules是被“同源策略”（Same-origin policy）保护的，所以无法使用本地文件。

## Same-origin policy与CORS

那什么是同源策略，什么是错误信息中的CORS呢？

同源策略，它是由Netscape提出的一个著名的安全策略。它限制网页中的js只能访问同一个源下的资源。怎么算同一个源呢？同协议，同域名，同端口才可以认为是同一个源。

CORS是一个W3C标准，全称是"跨域资源共享"（Cross-origin resource sharing）。用于解决在同源策略下不同源共享资源的问题。

同源策略和CORS的详细学习参考资料：

- [浏览器同源政策及其规避方法 - 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html)
- [跨域资源共享 CORS 详解 - 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/04/cors.html)
[HTTP访问控制（CORS） - HTTP | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS)

JavaScript Modules是使用CORS来实现资源共享的，所以我们可以从请求中看到`Origin`这个头部：

![](/img/js-modules-file-protocol-origin-null.png)

## 搭建本地Server

因为同源策略的限制，我们无法使用浏览器直接打开本地文件的方式开发了，我们需要搭建一个本地的简单静态Server，Node.js可以很简单的做到，比如使用[http-server](https://www.npmjs.com/package/http-server)这个包。

```
# 安装
npm install -g http-server

# 到项目目录下
cd xxx

# 把当前目录作为网站根目录，建立一个静态资源服务器
http-server
```

So easy吧，然后访问控制台提示的域名，可以看到例子顺利地跑起来了：

![](/img/js/js-modules-local-server.png)

这里其实没有使用到跨域的特性，因为所有module都在一个源下。如果需要`http-service`支持CORS，可以使用`--cors`参数。

## 在Node/Electron中使用模块

Node.js默认使用的是CommonJS模块。在8.5.0版本后，Node.js支持了JavaScript Modules标准。但是需要添加参数`--experimental-modules`来开启。默认支持估计要到Node.js 10 LTS了。

同时为了区分使用CommonJS的代码和ES modules的代码，Node.js要求使用ES modules的代码使用`.mjs`作为后缀名。

详细信息可以参考：[Using ES modules natively in Node.js](http://2ality.com/2017/09/native-esm-node.html)

那有没有办法在Node.js 8.5.0前的版本中使用JavaScript Modules呢？有的，可以使用[standard-things/esm: ES modules in Node today!](https://github.com/standard-things/esm)项目。

还有我比较关心的是，在Electron中可以使用JavaScript Modules了吗？

参考资料：
- [版本发布 | Electron](https://electronjs.org/releases)
- [javascript - ES6 syntax import Electron (require..) - Stack Overflow](https://stackoverflow.com/questions/35374353/es6-syntax-import-electron-require)

目前Electron的版本为1.8.2，而在1.8.1中，Electron更新Node.js的版本为`8.2.1`，所以看来是不支持的，更何况`8.5.0`还只是试验性支持。

## 参考资料
- [Module 的语法 - ECMAScript 6入门](http://es6.ruanyifeng.com/#docs/module)
- [Module 的加载实现 - ECMAScript 6入门](http://es6.ruanyifeng.com/#docs/module-loader)
- [Chrome支持JavaScript Module啦 - CNode技术社区](http://cnodejs.org/topic/59af63c17e43e29b0490051c)
- [ECMAScript modules in browsers - JakeArchibald.com](https://jakearchibald.com/2017/es-modules-in-browsers/)
- [ES6 Modules in Chrome M61+ – Dev Channel – Medium](https://medium.com/dev-channel/es6-modules-in-chrome-canary-m60-ba588dfb8ab7)
- [standard-things/esm: ES modules in Node today!](https://github.com/standard-things/esm)