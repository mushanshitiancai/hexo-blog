---
title: 'CSS IN JS,享受JS的一切'
date: 2016-12-21 14:23:54
categories: [JavaScript]
tags: [css]
---

[React: CSS in JS][React: CSS in JS]，这个PPT是2014年11月一个Facebook的员工发布的PPT。一切都从这个PPT说起。

<!-- more -->

在这个PPT中，作者首先列举出了CSS目前面临的一些问题：

![](/img/js/css-in-js-plan.png)

接着作者说了Facebook是如何解决这个问题的，Facebook通过扩展CSS语法，在class name中引入“包”的概念，编译工具会将这个包含了报名的class name进行编译，得到最终的class name。因为代码中无法知道最终的class name，所以需要通过cs这个工具函数来进行映射。通过这种hack方法，解决了他列出的7个问题。

但是，不完美。

最后，他提出了Facebook目前正在使用的技术：CSS IN JS。完全使用JS来写CSS：

![](/img/js/css-in-js-inline-style.png.png)

像写普通的Javascript Object一样，书写带有层次结构的CSS。同时使用React的style书写来赋予这个对象。对象中的样式会被编译为这个DOM节点的InLine Style。

以为使用JS书写，所以前五点问题都自然而然地解决了：

![](/img/js/css-in-js-plan2.png.png)

而且还可以利用其它JS的特性，比如更具条件决定样式，比如支持从外部传入样式等！

## 类库
Facebook这个PPT发出来之后，社区沸腾了。因为这个PPT只是提出了一个大致的方向，一些细节上的问题并没有解决，比如模式的CSS IN JS是无法支持伪类和媒体查询的。所以一时之间，社区冒出了十几个基于这个思想的工具库。

[React: CSS in JS techniques comparison][React: CSS in JS techniques comparison]这个项目对十几个css-in-js类库进行了特性对比。我们可以从中进行选择。

目前我的选择是：Radium

### Radium
[Radium][Radium]是一个React样式工具库。主要是对伪类和媒体查询的支持。

看个例子：

```
// 引入Radium
var Radium = require('radium');
var React = require('react');
var color = require('color');

// 使用Radium装饰器
@Radium
class Button extends React.Component {
  static propTypes = {
    kind: React.PropTypes.oneOf(['primary', 'warning']).isRequired
  };

  render() {
	// Radium扩展了React的style属性，支持传入一个数组。Radium会按顺序合并这些样式
	// 这个特性很有用，可以根据条件合并一些即时的样式，比如结合props或者state
    return (
      <button
        style={[
          styles.base,
          styles[this.props.kind]
        ]}>
        {this.props.children}
      </button>
    );
  }
}

// 样式就是普通的object
var styles = {
  base: {
    color: '#fff',

	// 添加:hover伪类，是不是不能再简单了。。。
	// 可以使用:hover, :focus, :active, or @media
    ':hover': {
      background: color('#0074d9').lighten(0.2).hexString()
    }
  },

  primary: {
    background: '#0074D9'
  },

  warning: {
    background: '#FF4136'
  }
};
```

这个例子基本上说完了Radium的核心用法。就是使用Radium修饰器，使React注解支持扩展语法的style对象。如果不支持修饰器，也可以用函数的方式：

```
// For ES6 and ES7
@Radium
class Button extends React.Component {
  // ...
}

// or
class Button extends React.Component {
  // ...
}
module.exports = Radium(Button);

// or
class Button extends React.Component {
  // ...
}
Button = Radium(Button);
```

## 参考资料
- [React: CSS in JS][React: CSS in JS]
- [React: CSS in JS techniques comparison][React: CSS in JS techniques comparison]
- [Radium][Radium]

[React: CSS in JS]: https://speakerdeck.com/vjeux/react-css-in-js
[React: CSS in JS techniques comparison]: https://github.com/MicheleBertoli/css-in-js
[Radium]: https://github.com/FormidableLabs/radium