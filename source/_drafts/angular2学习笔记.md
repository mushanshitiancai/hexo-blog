---
title: angular2学习笔记
date: 2016-12-02 15:14:49
categories:
tags: [js,angularjs]
---

## 搭建本地学习环境
Angularjs官方提供了一个用于学习的quickstart项目。

```
git clone https://github.com/angular/quickstart.git quickstart
cd quickstart
npm install
npm start
```

这样你在修改代码代码时，浏览器就会自动刷新，很方便。

这个quickstart包含了很多的文件，我们需要注意三个文件，app下的：

- app.component.ts 定义跟组件AppComponent
- app.module.ts 定义跟模块AppModule
- main.ts 使用JIT编译器编译项目，同时在浏览器中启动项目。这不是唯一选择。

一个很好的入门教程例子：[Tutorial: Tour of Heroes - ts - TUTORIAL](https://angular.io/docs/ts/latest/tutorial/)

## Angular CLI
Angularjs2提供了一个命令行工具来加速Angularjs2程序的开发：[Angular CLI](https://cli.angular.io/)

我们可以使用Angular CLI的`ng new`命令来新建Angular工程，使用`ng serve`来运行调试程序，你的修改浏览器会自动刷新。同时还可以使用`ng generate`命令来快速新建components, routes, services, pipes等。

### 新建项目

```
ng new PROJECT_NAME
cd PROJECT_NAME
ng serve
```

### 新建Components, Directives, Pipes and Services
使用`ng generate`或者`ng g`来新建angular中的构建

```
Component:
ng g component my-new-component

Directive:
ng g directive my-new-directive

Pipe:
ng g pipe my-new-pipe

Service:
ng g service my-new-service

Class:
ng g class my-new-class

Interface:
ng g interface my-new-interface

Enum:
ng g enum my-new-enum

Module:
ng g module my-module
```

### 构建项目

```
ng build
```

会在dist目录下生成编译压缩好的项目。

## 总结
- angular中使用了typescript+依赖注入，这对于我这个后台开发来说，简直不能再爽。同时也说明了后端设计的先进性，静态类型的优良性
- 但是模板写起来还是非常不爽的，是代码分析，自动提示，重构的盲区