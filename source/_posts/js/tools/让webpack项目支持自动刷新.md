---
title: 让webpack项目支持自动刷新
date: 2016-12-25 22:06:55
categories:
tags: [js,nodejs,webpack]
---

配置完webpack后，虽然可以通过`-w`属性，让webpack在代码发生改变时自动重新编译，但是你需要手动刷新页面才能看到效果。其实webpack还支持调试服务器，支持自动刷新。

<!-- more -->

```
npm install webpack-dev-server --save-dev
```

webpack-dev-server会在node_modules/.bin/下生成可执行文件webpack-dev-server，直接执行，webpack-dev-server就会去执行项目下的webpack.config.js，启动本地服务器，监听8080端口，所以你只要访问http://localhost:8080/webpack-dev-server/就行了。

然后其实并没有这么简单，webpack-dev-server编译之后，并不会输出到output.filename指定的文件中去，而是输出到内存，那要如何访问呢？

看这样的一个配置：

```
var path = require("path");
module.exports = {
  entry: {
    app: ["./app/main.js"]
  },
  output: {
    path: path.resolve(__dirname, "build"),
    publicPath: "/assets/",
    filename: "bundle.js"
  }
};
```

这里，ouput中指定了publicPath字段，webpack-dev-server编译后的代码可以通过这个路劲来访问，比如上面这个配置，编译后的bundle.js可以通过`localhost:8080/assets/bundle.js`访问到。所以需要修改你的index.html。改为访问这个地址下的bundle.js才可以正常使用webpack-dev-server。

比如在  这个项目中的做法：

```
script.src = (process.env.HOT)
          ? 'http://localhost:' + port + '/dist/bundle.js'
          : './dist/bundle.js';
```

不过我直接都是写`dist/bundle.js`，也没什么问题。

webpack-dev-server支持两种自动刷新的技术，可以使用不同的地址来访问：

- Iframe mode

	页面被渲染到一个iframe中，刷新页面是刷新这个iframe。上面的配置对应的地址为：`http://localhost:8080/webpack-dev-server/index.html`
	
	- 页面上方有一个状态栏显示当前状态
	- 应用的URL变化**不会**反映到浏览器的地址栏中

- Inline mode (a small webpack-dev-server client entry is added to the bundle which refresh the page on change)

	一个小型的webpack-dev-server客户端会添加到打包文件中，来支持刷新页面。上面的配置对应的地址为：`http://localhost:8080/index.html`
	
	- 在console中显示当前状态
	- 应用的URL变化**会**反映到浏览器的地址栏中

## 参考资料
- [webpack dev server](http://webpack.github.io/docs/webpack-dev-server.html)