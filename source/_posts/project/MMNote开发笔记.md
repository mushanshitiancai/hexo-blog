---
title: MMNote开发笔记
date: 2016-12-21 14:23:10
categories:
tags:
---


前文待补。。。


### 2016年12月22日 React动画
这两天从react-treebeard这个插件看起，了解其中使用到的Radium和velocity-react。因为这个插件在限制宽度的情况下，显示有些问题，所以要么进行修改，要么得自己写一个。

关于**树节点动画**，这个插件在展开节点时，会旋转左侧箭头(svg画的)，同时会动画展开其子列表。这个还不错。我一直以为所有的编辑器都有这个动画的，以为很基础嘛，没想到观察了一下,每个编辑器表现都不一样：

- sublime: 箭头无动画，展开有动画
- vscode: 都无动画
- atom: 都无动画
- TextMate: 箭头无动画，展开有动画

没想到，这两个动画竟然没有做全的。其中，看了vscode和atom的html，其箭头都是使用::before伪元素做到的，所以不支持动画吧。(2016年12月24日 补充：看了下ant design的树控件，使用伪元素，也是能做到动画的)

再说说**在有限空间内，各个编辑器是如何展示的条目**的：

- sublime: 不会压缩显示，可以横向滚动
- vscode: 压缩显示，条目名称最后压缩为省略号
- atom: 不会压缩显示，可以横向滚动
- TextMate: 压缩显示，条目名称中间压缩为省略号

我个人是倾向于不压缩显示的。

### 2016年12月25日 树控件 Webpack自动刷新 区分配置文件
今天早上竟然失眠，6点多就起来了，继续写树控件，现在有点样子了，整合了web font和max-content：

![](/img/mmnote/2016-12-25.png)

主要是解决了react-treebread空间的小空间换行问题和宽度不对问题。CSS的width是关键，具体参考了：[理解CSS3 max/min-content及fit-content等width值][理解CSS3 max/min-content及fit-content等width值]。

我一遍做一边参考atom和vscode（基于HTML5技术就是好啊，随时随地可以参考）。发现atom是常规做法，也就是整个树是一个ol或者ul，然后一个一个递归渲染出。对于没有打开的子目录是不会渲染到DOM上的。

但是vscode却不是。其目录树完全是一个div list。层级关系的表示都是在inline style中设置padding left做到的，应该是在代码中算出来的。而且，最最重要的一点，他没有渲染出整个已经打开的目录树，而是只渲染了但求可见范围内的节点！！！**这是多么机智的优化啊！！！**

这样就算你打开了N多文件的目录，页面也不会卡顿，因为他只渲染当前可以显示的这么十几条数据。学习了。

晚上：
学习了如何使用webpack的开发服务器，以及如何区分配置：

```
"hot-server": "cross-env NODE_ENV=development node --max_old_space_size=2096 -r babel-register server.js",
```

这是electron-react-boilerplate项目的一个npm script。通过cross-env这个包来指定环境变量，区分开发环境还是正式环境，然后在代码中判断该变量走不通配置等：

```
if (process.env.NODE_ENV === 'production') {
  module.exports = require('./configureStore.production'); // eslint-disable-line global-require
} else {
  module.exports = require('./configureStore.development'); // eslint-disable-line global-require
}
```

看了下[Redux 入门教程（三）：React-Redux 的用法 - 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/09/redux_tutorial_part_three_react-redux.html)，不是很懂。。。感觉结合Redux还是比较麻烦的，概念比较多。

这两天对整个React应用开发和CSS都加深了认识，但是完全不够啊，还是没有到达能够“开工”的标准。。。


### 2016年12月30-31日 新建工程
占时先不学习Redux了，直接开始写吧，新建工程走起。

```
mkdir mmnote
cd mmnote
npm init

npm install --save-dev webpack typescript awesome-typescript-loader source-map-loader  css-loader style-loader webpack-dev-server less less-loader
npm install --save react react-dom @types/react @types/react-dom lodash electron normalize.css
npm install --save codemirror @types/codemirror react-split-pane @types/react-split-pane

// fs-extra @types/fs-extra
```

//TODO 搭建项目笔记，记录目前搭建的步骤，随着项目不断推进，不断学习后更新。

![](/img/mmnote-2016-12-31-tree-demo.png)


### 2017年01月01日 星期日 树形控件与真实目录对应
今天雾霾好大，去奥林匹克公园逛了逛。今天争取吧目录树和真是目录对应上。

第一个问题是node.js中如何遍历目录树。

fs-extra这个包是fs包的扩展，其中包括了遍历目录树。

但是呢，依赖这种扩展，对应的ts声明又太久了，现在还懒得学习如何编写声明。还是看看对应的walk是如何实现的吧。

[node-klaw: A Node.js file system walker with a Readable stream interface][node-klaw: A Node.js file system walker with a Readable stream interface]

代码很简单，就一个文件，但是涉及的知识点很多。

我学着他的代码写了一个例子：

```
var Readable = require("stream").Readable;
var util = require("util");

function Walker() {
    var options = {
        objectMode: true
    };
    this.result = [];
    Readable.call(this, options);
}

Walker.prototype._read = function() {
    if (this.result.length == 3) {
        return this.push(null);
    }
    this.result.push("hello");
    this.push("hello");
}

util.inherits(Walker, Readable)

var walk = new Walker();
walk.on("data", function(data) {
    console.log(data);
});
walk.on("end", function(data) {
    console.log("end");
    console.log(data);
});
```

这是自定义Readable的最简单的一个例子了。

- 使用nodejs自带的util.inherits()来实现继承
- 继承Readable一定要实现_read()方法，其中使用this.push()来添加这次读取的内容，使用this.push(null)表示读取完毕

至于如何整合到项目中，目前觉得先使用fs.readdir()来实现即可。

ts的interface可以有默认值么？ -- 不能

今日进展：

![]（/img/mmnote-2017-01-02-tree-demo.png)

## 2017年01月02日 星期一 树形控件滚动条样式
看Atom的滚动条样式发现css的选择器中出现了`/deep/`这种写法。

[html5 - What do /deep/ and ::shadow mean in a CSS selector? - Stack Overflow](http://stackoverflow.com/questions/25609678/what-do-deep-and-shadow-mean-in-a-css-selector/25609679#25609679)

看来是为了能够修饰shadow dom内部而生的选择器。

滚动条样式目前看来没有同意写法，还好我们只用写webkit的：

[自定义浏览器滚动条的样式，打造属于你的滚动条风格](http://www.lyblog.net/detail/314.html)

修改了滚动条样式的效果：

![](/img/mmnote-2017-01-02-tree-demo2.png)

发现树控件中的选中是个麻烦事。点击一个节点，选中当前，但是需要把之前选中的取消选中，如果支持多选，就得用一个数组来保存了。

而且选中后的高亮也是麻烦事。vscode中因为不是数结构所以好做，但是Atom中就不容易了，需要用一个定位为absolute的before伪元素来做到。

服了，javascript中竟然没有清空数组的方法。。。see [How do I empty an array in JavaScript? - Stack Overflow](http://stackoverflow.com/questions/1232040/how-do-i-empty-an-array-in-javascript)



# TODO 
[React动画实践](http://www.alloyteam.com/2016/01/react-animation-practice/)






[理解CSS3 max/min-content及fit-content等width值]: http://www.zhangxinxu.com/wordpress/2016/05/css3-width-max-contnet-min-content-fit-content/
[node-klaw: A Node.js file system walker with a Readable stream interface]: https://github.com/jprichardson/node-klaw