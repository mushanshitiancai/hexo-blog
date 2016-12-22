---
title: React学习笔记
date: 2016-03-19 23:00:09
tags: [js,react]
---


## React中使用CSS
### 传统
在React中可以像普通前端程序一样，使用普通CSS。使用普通CSS有两种做法：

1. 在HTML文件中引入CSS

	这是最最最传统的做法。毕竟即使你使用Commonjs的方法来写React，最后打包后也是一个被引入到HTML中的script。

2. 在代码中require('xx.css')

	这是比第一种新一点的做法，在代码中直接引入css，这个是需要打包工具支持的，比如如果你用的是webpack，你需要引入css-loader和style-loader。打包文件处理后，会把这个css编译到js文件中。在页面载入时，在页面的header中动态的添加style节点。

	这个做法本质上和第一点的一样，但是第一种做法，CSS和JS是分离的，我们无法知道这个js文件中的主角依赖的css到底是哪些。通过显式的import，我们可以关联这两者。

### JS IN CSS
但是Facebook已经无法忍受传统CSS带来的许多问题了，所以他们提出了[CSS in JS][React: CSS in JS]。推翻了目前的做法，完全使用js来写CSS。这能在没有hack的情况下阶级所有CSS的问题，还能享受目前javascript能用到的所有工具。大家可以看看链接里的PPT，一定会受益匪浅。

### css-modules
2016年12月18日。今天看electron-react-boilerplate这个项目的代码，发现了引入CSS的第四种方法`css-modules`。

首先像传统做法一样，在js中引入css文件：

```
import styles from './Counter.css';
```

然后在需要用到样式的地方：

```
<div className={styles.backButton}>
```

当时我就震惊了，import一个css文件能得到一个对象？查看css-loader的文档，发现原来css-loader支持一种叫做css-modules的规范。这个规范大体的意思是按文件来划分css模块。意味着，在不同文件中的相同名字选择器在编译后是两个选择器。本质上还是为了解决css最大的一个问题，也就是全局命名冲突。

具体表现在css-loader中，也就是如果你有两个css文件，都有一个`.hello`的选择器，编译后打开页面：

```
<style type="text/css">
._17VetehSM7hmgJzGP43vI0 {
    color: red;
}</style>

<style type="text/css">
._1sX5Vg62T-OfW574eQHUXG {
    color: blue;
}</style>
```

可以看到虽然两个css文件中，选择器名字是一样，但是在编译后是不一样的，而且名字是随机生成的。所以在代码中你就不能直接写`class="hello"`了，而是应该使用import返回的对象`styles.hello`，这个的值，对应当前生成的这个文件的这个选择器的名字。

默认css-loader没有开启这个功能，需要在添加参数`modules`：

```
{
    test: /\.css$/,
    use: ["style-loader", "css-loader?modules"]
}
```

不得不佩服前端发展之可怕，新思潮涌起。人，还是要站在浪尖上才能起飞啊。

回过头说说这个css-modules，觉得比传统做法高一筹，比css in js差一点。

## React渲染后的DOM是Shadow DOM么？
不是



react中文教材地址：[教程 | React](http://reactjs.cn/react/docs/tutorial.html)
sublime安装相关插件：[Sublime Text 3 搭建 React.js 开发环境](https://segmentfault.com/a/1190000003698071)
[學習 React.js：用 Node 和 React.js 創建一個實時的 Twitter 流-爱编程](http://www.w2bc.com/Article/34540)

## 参考资料
- [教程 | React](http://reactjs.cn/react/docs/tutorial.html)
- [为什么说Babel将推动JavaScript的发展](http://www.infoq.com/cn/news/2015/05/ES6-TypeScript)
- [Sublime Text 3 搭建 React.js 开发环境 - Whatif - SegmentFault](https://segmentfault.com/a/1190000003698071)
- [[译]什么是Shadow Dom？ · TooBug](https://www.toobug.net/article/what_is_shadow_dom.html)


[React: CSS in JS]: https://speakerdeck.com/vjeux/react-css-in-js
