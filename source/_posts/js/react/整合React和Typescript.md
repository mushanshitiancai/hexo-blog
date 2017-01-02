---
title: 整合React，Typescript和Webpack
date: 2016-12-25 08:55:54
categories:
tags: [js,react]
---

习惯了强类型，而且在React设计中，也因为Javascript没有类型而设计了PropTypes，所以还不如直接用Typescript得了，重构还方便。这里来学习一下如何整合React，Typescript和Webpack。参考[官方教程][React & Webpack · TypeScript]

<!-- more -->

## 创建项目
首先我们搭建出一个项目骨架。代码凡在src中，这个共识了，而对于React编程来说，还有一个目录很重要，就是安放组件代码的目录，我们把他放在src/components中。

然后我们还得安装一些依赖。

```
mkdir react-ts
cd react-ts
mkdir src
mkdir src/components

npm init
npm install --save-dev webpack typescript awesome-typescript-loader source-map-loader
npm install --save react react-dom @types/react @types/react-dom
```

## 添加TypeScript配置文件
typescript支持一个标准的配置文件，即项目根目录下的`tsconfig.json`。在这个配置文件中，我们告诉ts编译器：

- 我们的代码在哪里 -> include
- 我们想要把编译出来的js文件放在哪里 -> compilerOptions.outDir
- 编译到哪个版本的js -> compilerOptions.target
- 是否支持jsx语法 -> compilerOptions.jsx
- 使用哪种js 模块标准 -> compilerOptions.module

```
{
    "compilerOptions": {
        "outDir": "./dist/",
        "sourceMap": true,
        "noImplicitAny": true,
        "module": "commonjs",
        "target": "es5",
        "jsx": "react"
    },
    "include": [
        "./**/*"
    ]
}
```

我们使用webpack来处理ts文件，对应的loader是awesome-typescript-loader，他会使用这个tsconfig.json文件。

## 写个Hello World
我们写一个Hello Component，首先我们不在需要PropTypes了，直接使用ts的interface来定义props的类型。

```
import * as React from "react";

export interface HelloProps { compiler: string; framework: string; }

// 'HelloProps' describes the shape of props.
// State is never set so we use the 'undefined' type.
export class Hello extends React.Component<HelloProps, undefined> {
    render() {
        return <h1>Hello from {this.props.compiler} and {this.props.framework}!</h1>;
    }
}
```

在使用Hello时，编辑器会分析其props的类型信息，并在你书写JSX的时候给予提示。非常的爽。

```
import * as React from "react";
import * as ReactDOM from "react-dom";

import { Hello } from "./components/Hello";

ReactDOM.render(
    <Hello compiler="TypeScript" framework="React" />,
    document.getElementById("example")
);
```

最后在项目根目录下添加index.html，引入打包后的js。这里我们不打包react和react-dom，这是为了让浏览器可以缓存这些js。所以我们要手动引入这两个js。

```
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Hello React!</title>
    </head>
    <body>
        <div id="example"></div>

        <!-- Dependencies -->
        <script src="./node_modules/react/dist/react.js"></script>
        <script src="./node_modules/react-dom/dist/react-dom.js"></script>

        <!-- Main -->
        <script src="./dist/bundle.js"></script>
    </body>
</html>
```

## 配置Webpack

```
module.exports = {
    entry: "./src/index.tsx",
    output: {
        filename: "bundle.js",
        path: __dirname + "/dist"
    },

    // Enable sourcemaps for debugging webpack's output.
    devtool: "source-map",

    resolve: {
        // Add '.ts' and '.tsx' as resolvable extensions.
        extensions: ["", ".webpack.js", ".web.js", ".ts", ".tsx", ".js"]
    },

    module: {
        loaders: [
            // All files with a '.ts' or '.tsx' extension will be handled by 'awesome-typescript-loader'.
            { test: /\.tsx?$/, loader: "awesome-typescript-loader" },
            { test: /\.css$/, loaders: ["style-loader", "css-loader?sourceMap"] }
        ],

        preLoaders: [
            // All output '.js' files will have any sourcemaps re-processed by 'source-map-loader'.
            { test: /\.js$/, loader: "source-map-loader" }
        ]
    },

    // When importing a module whose path matches one of the following, just
    // assume a corresponding global variable exists and use that instead.
    // This is important because it allows us to avoid bundling all of our
    // dependencies, which allows browsers to cache those libraries between builds.
    externals: {
        "react": "React",
        "react-dom": "ReactDOM"
    },
};
```

然后在package.json中添加：

```
"scripts": {
  "build": "webpack"
}
```

运行`npm run build`。编译完成后打开index.html就可以看到效果了。

## 如何在jsx中开启emmet
在书写HTML时，emmet可是大杀器啊，但是在vscode中，编辑js，jsx文件是无法使用emmet的，可以在配置文件中加入：

```
"emmet.syntaxProfiles": { "javascript": "jsx" }
```

来开启，而且emmet会自动使用className来替换class等。

参考：[Emmet with JS files (JSX) is not working. · Issue #4962 · Microsoft/vscode](https://github.com/Microsoft/vscode/issues/4962)

## 参考资料
- [React & Webpack · TypeScript][React & Webpack · TypeScript]

[React & Webpack · TypeScript]: https://www.typescriptlang.org/docs/handbook/react-&-webpack.html
[Cannot read property 'exclude' of undefined · Issue #190]: https://github.com/s-panferov/awesome-typescript-loader/issues/190