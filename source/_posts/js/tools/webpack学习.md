---
title: webpack学习
date: 2016-12-11 16:28:13
tags: [js,nodejs,webpack]
---

前端的编码越来越复杂，有不同风格的模块引用，有不同的编译到js的语言，有不同的编译到css的语言。所有的这些，都需要一个构建工具/打包工具来支持一个前端项目。webpack就是这样的一个打包器。他编译javascript模块到你的项目中。这样你就可以在前端项目中使用node模块了。

## 例子

```
mkdir webpack-demo && cd webpack-demo
npm init -y
npm install --save-dev webpack@2.1.0-beta.27
npm install --save lodash
```

注意一点，如果直接使用`npm install --save-dev webpack`安装的webpack版本是1.14.0。这里我们直接学习webpack2，所以需要手动指定版本。

最原始的前端编程，js里是不管依赖导入的，因为依赖导入都是在HTML中通过script来做到的。代码想这样：

app/index.js：

```
function component () {
  var element = document.createElement('div');

  /* lodash is required for the next line to work */
  element.innerHTML = _.map(['Hello','webpack'], function(item){
    return item + ' ';
  });

  return element;
}

document.body.appendChild(component());
```

index.html：

```
<html>
  <head>
    <title>Webpack demo</title>
    <script src="https://unpkg.com/lodash@4.16.6" type="text/javascript"></script>
  </head>
  <body>
    <script src="app/index.js" type="text/javascript"></script>
  </body>
</html>
```


这回带来很多问题。需要手动添加这些依赖，而且这些依赖还必须手动下载到开发目录中，然后通过对应的路径引入。如果引入的依赖还需要其他依赖，或者是依赖顺序我们没弄对，这就可怕了。所以依赖自动化管理是必然的结果。

所以我们可以使用node的引入包的模式来写提供给页面的js：

app/index.js：

```
import _ from 'lodash';

function component () {
  ...
```

我们像普通node项目一样，使用import语句来引入依赖。

index.html：

```
<html>
  <head>
    <title>Webpack demo</title>
  </head>
  <body>
    <script src="dist/bundle.js" type="text/javascript"></script>
  </body>
</html>
```

在html中，我们不再直接引入index.js，因为现在的index.js使用了Commonjs的引入依赖的方法。这个时候我们就需要webpack来帮忙分析js文件中的依赖，并最后编译为单个js文件。然后我们就可以在html中直接使用这个编译后的js文件，这里，也就是`dist/bundle.js`。

因为我们没有全局安装webpack，所以我们需要指定npm script来运行webpack命令：

```
"scripts": {
  "webpack2": "webpack app/index.js dist/bundle.js",
}
```

然后运行`npm run webpack2`，就会在dist目录下生成编译好的bundle.js。这个过程中，webpack分析项目的所有依赖，构成一个依赖图，按照正确的顺序引入依赖，最终编译出一个引入了所有依赖，浏览器可以识别的bundle.js。

查看bundle.js，发现竟然有一万七千多行，这是因为webpack把lodash及其依赖都编译到这个文件的结果。

## 使用config文件
webpack支持从webpack.config.js文件中读取配置信息来决定如何编译代码。

```
module.exports = {
    entry: './app/index.js',
    output: {
        filename: 'bundle.js',
        path: './dist'
    }
}
```

因为webpack默认会读取配置文件，所以npm script命令也可以简写为`webpack`

```
"scripts": {
  "webpack2": "webpack"
},
```

## 重要概念
我们通过例子对webpack有个大致的认识后，需要来了解一下webpack中的一些重要概念。

### Entry
webpack会构建一个项目中依赖的图，而这个图的入口节点就是Entry。我们需要告诉webpack哪个文件是入口节点，他才能从这个起点开始分析。

简单来说，也就是你的项目的入口文件。

在配置文件中，我们通过`entry`字段来指定入口文件：

```
module.exports = {
  entry: './path/to/my/entry/file.js'
};
```

entry字段有两种写法，一种是单实体写法，一种是对象写法。

上面的例子是单实体写法，表示只有一个入口文件。如果有多个入口文件，可以设置为字符串数组。

对象写法可以更完整地定义入口文件，像这样：

```
const config = {
  entry: {
    app: './src/app.js',
    vendors: './src/vendors.js'
  }
};
```

这里指定了两个入口，一个是app，一个是vendors。这是两个独立的入口，意味着webpack会单独处理这两个入口所需的依赖。我当时看到app和vendors这两个单词时，心里想，这个取名是有规定的么？其实是没有的，这里叫app和vendors是一种比较管用的名字而已。

比如你有三个独立的页面，你可以这么配置：

```
const config = {
  entry: {
    pageOne: './src/pageOne/index.js',
    pageTwo: './src/pageTwo/index.js',
    pageThree: './src/pageThree/index.js'
  }
};
```

单入口配置其实是缩写，本质上的配置是：

```
const config = {
  entry: {
    main: './path/to/my/entry/file.js'
  }
};
```

### Output
webpack处理好所有的依赖和资源后，我们还需要告诉webpack如何来打包这些资源，配置文件中的`output`字段说明了这个要求：

```
module.exports = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  }
};
```

`output.path`和`output.filename`这两个字段指定了打包好的文件的输出位置。

对于上面提到,我们可以定义多个入口entry，这会让webpack生成多个块(chunk)，但是我们只能定义一个output配置，我们可以使用`[name]`这个占位符来表示entry的名字，比如这样：

```
entry: {
  app: 'src/app.ts',
  vendor: 'src/vendor.ts'
},

output: {
  filename: '[name].js'
}
```

这样webpack就会输出处理后的app.js和vendor.js

`output.filename`可以使用三个占位符：

- `[name]` 使用块的名字替代，也就是entry中的key
- `[hash]` 使用编译时的hash替代
- `[chunkhash]` 使用块的hash替代

`[hash]`和`[chunkhash]`对于前端开发是非常有用的。因为如果这个块里的代码没有被修改，生成的块的名字的hash是不变的，这样浏览器在请求这个文件时，会使用缓存，加快页面载入。而如果块的内容改变了，hash改变，会强制让浏览器下载新的文件，打到避免使用缓存的目的。

正是因为这个问题，所以推荐的做法是把项目文件（易变）和项目依赖的库文件（不易变）分开来打包。具体见下文的**划分大文件**。

### Loaders
应该让你的项目中的所有资源都让webpack来处理，而不是留给浏览器来处理。webpack认为所有文件 (.css, .html, .scss, .jpg, etc.)都是模块，但是webpack本质上只理解JavaScript，所以需要使用loader来把这些文件转换成webpack识别的模块，进而再让webpack处理。

```
const config = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  },
  module: {
    rules: [
      {test: /\.(js|jsx)$/, use: 'babel-loader'}
    ]
  }
};
```

配置中，`test`指定处理的是哪些文件，`use`指定使用的loader。这个配置的意思是“如果webpack编译器发现在require/import语句中出现了.js/.jsx文件，那么先使用babel-loader来处理这些文件，然后在加入到编译中”。

### Plugins
因为loader只会处理单个文件，所以我们还需要plugin的力量。webpack的plugin系统是很强大的。为了使用插件，我们只需在配置文件中require对应的插件并使用即可。

```
const HtmlWebpackPlugin = require('html-webpack-plugin'); //installed via npm
const webpack = require('webpack'); //to access built-in plugins

const config = {
  entry: './path/to/my/entry/file.js',
  output: {
    filename: 'my-first-webpack.bundle.js',
    path: './dist'
  },
  module: {
    rules: [
      {test: /\.(js|jsx)$/, use: 'babel-loader'}
    ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin(),
    new HtmlWebpackPlugin({template: './src/index.html'})
  ]
};

module.exports = config;
```

这个例子中使用了webpack自带的插件和第三方插件。UglifyJsPlugin这个插件是一个非常常用的webpack自带插件，用于压缩生成的js代码。

### Target
javascript现在使用的范围很广，可能是在浏览器中运行，可能在服务端运行，也可能在electron中运行。webpack支持编译javascript到不同的平台上。

| target            | Description |
| ----------------- | ----------- |
| async-node        | 编译到Node.js相似的环境（fs和vm读取块的方式为异步） |
| electron          | 编译到Electron的render进程，提供了一些额外插件 |
| electron-renderer | 编译到Electron的render进程 |
| node              | 编译到Node.js相似的环境（使用Node.js要求的方式读取块）  |
| node-webkit       | 编译到在WebKit中使用的环境，使用JSONP读取块。  |
| web               | 编译到浏览器环境（默认值） |
| webworker         | 编译为WebWorker |

默认webpack是编译js到浏览器中运行的，所以target默认值为web。

我们有时候需要构建多个平台，就需要输出多个target，可以这样配置：

```
const config = {
	target: 'web',
    entry: "./index.js",
    output: {
        filename: "bundle.js"
    }
}

const nodeConfig = {
    target: 'node',
    entry: "./index.js",
    output: {
        filename: "node-bundle.js"
    }
}

module.exports = [config, nodeConfig];
```

更好的写法：

```
module.exports = {
  entry: './foo.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'foo.bundle.js'
  }
};
Multiple Targets
webpack.config.js

var path = require('path');
var webpack = require('webpack');
var webpackMerge = require('webpack-merge');

var baseConfig = {
  target: 'async-node',
  entry: {
    entry: './entry.js'
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js'
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin({
      name: 'inline',
      filename: 'inline.js',
      minChunks: Infinity
    }),
    new webpack.optimize.AggressiveSplittingPlugin({
        minSize: 5000,
        maxSize: 10000
    }),
  ]
};

let targets = ['web', 'webworker', 'node', 'async-node', 'node-webkit', 'electron-main'].map((target) => {
  let base = webpackMerge(baseConfig, {
    target: target,
    output: {
      path: path.resolve(__dirname, 'dist/' + target),
      filename: '[name].' + target + '.js'
    }
  });
  return base;
});

module.exports = targets;
```

## 自动重新编译
webpack支持监视文件的修改，并在文件修改后自动重新编译，这对于开发是很有帮助的。开启watch模式有两种方法，一种是修改配置，`watch`配置项指定是否开启watch模式：

```
watch: true
```

开启了watch模式后，运行`webpack`执行编译后，程序不会退出，会继续监视文件。

第二种方法是命令行后添加参数`--watch`或者`-w`，就可以开启watch模式

## 支持CSS


## 支持JSX
如果你使用webpack编译react的代码，就需要处理jsx了。和上文所说的一样，webpack本身只懂javascript，所以需要loader来吧jsx转换成普通javascript来让webpack来处理，这里使用的是`babel-loader`。首先安装依赖：

```
npm install babel-core babel-loader babel-preset-react --save-dev
```

然后在webpack的配置文件中添加：

```
module: {
    rules: [{
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
            loader: 'babel-loader',
            options: {
                presets: ['react']
            }
        },
    }]
}
```

## 划分大文件
上文提到了，项目一般由项目代码和项目依赖的库代码组成，其中项目代码是易变的，库代码是不易变的。考虑到浏览器缓存的问题，我们依赖把这两个部分独立打包，这样库代码打包后的文件保持不变，可以最大粒度利用用户浏览器中的缓存。

比如我们有一个项目，使用`moment`这个库来处理时间：

```
var moment = require('moment');
console.log(moment().format());
```

我们使用webpack来打包这个项目：

```
module.exports = function(env) {
    return {
        entry: './index.js',
        output: {
            filename: '[chunkhash].[name].js`,
            path: './dist'
        }
    }
}
```

这样只会打包出一个文件，包含了项目文件和moment库文件。不好。所以我们要让webpack独立打包库文件：

```
module.exports = function(env) {
    return {
        entry: {
            main: './index.js',
            vendor: 'moment'
        },
        output: {
            filename: '[chunkhash].[name].js`,
            path: './dist'
        }
    }
}
```

这里我们指定了多个entry，一个入口是项目的index.js一个是moment库。打包后，生成两个js，**但是moment在两个文件中都出现了！**

对于这种情况，我们需要使用`CommonsChunkPlugin`这个webpack官方插件，这个插件可以提取公共的代码到独立的打包文件中，我们加入这个文件，然后指定公共的bundle为vender：

```
var webpack = require('webpack');
module.exports = function(env) {
    return {
        entry: {
            main: './index.js',
            vendor: 'moment'
        },
        output: {
            filename: '[chunkhash].[name].js`,
            path: './dist'
        },
        plugins: [
            new webpack.optimize.CommonsChunkPlugin({
                name: 'vendor' // Specify the common bundle's name.
            })
        ]
    }
}
```

这样打包后，main入口生成的文件中就不在包含vendor中的代码了。

但是，还有一个问题！如果你修改了main入口中对应文件的代码，再次打包时，vendor对应的打包文件的hash也发生了变化。也就是说，修改项目文件，会影响库文件的打包！如果这样的话，还怎么利用缓存嘛。。。。

这是因为在生成打包文件时，webpack会加入一些必要的运行时代码，这些代码是易变的。对于这个问题，webpack的解决方案是可以把这些易变的运行时代码再提取出来，放到一个叫manifest的打包文件中去：

```
var webpack = require('webpack');
module.exports = function(env) {
    return {
        entry: {
            main: './index.js',
            vendor: 'moment'
        },
        output: {
            filename: '[chunkhash].[name].js`,
            path: './dist'
        },
        plugins: [
            new webpack.optimize.CommonsChunkPlugin({
                names: ['vendor', 'manifest'] // Specify the common bundle's name.
            })
        ]
    }
};
```

终于，库文件生成的打包文件不在变化了！

## 参考资料
- [webpack](https://webpack.js.org/get-started/)
- [webpack-target](https://webpack.js.org/configuration/target/)
- [Webpack 简介 - ts - GUIDE](https://angular.cn/docs/ts/latest/guide/webpack.html)
- [JavaScript 模块化历程 - WEB前端 - 伯乐在线](http://web.jobbole.com/83761/)
- [[新姿势]前端革命，革了再革：WebPack - mcfog - SegmentFault](https://segmentfault.com/a/1190000002507327)
- [一小时包教会 —— webpack 入门指南 - vajoy - 博客园](http://www.cnblogs.com/vajoy/p/4650467.html)
- [用webpack来取代browserify - Code - SegmentFault](https://segmentfault.com/a/1190000002490637)
