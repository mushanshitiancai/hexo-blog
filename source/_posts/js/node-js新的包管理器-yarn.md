---
title: node.js新的包管理器 - yarn
date: 2017-01-14 09:56:48
categories:
tags: [js]
---

npm现在如日中天，但是他的确有一些问题，比图不缓存已经下载过的依赖，每次都要重新下载，这对于天朝的屁民来说真是不能忍啊。Facebook也不能忍，于是就退出了新的包管理器 - yarn。

![](https://yarnpkg.com/assets/feature-speed.png)

<!--more-->

yarn的目标有三点quickly, securely, and reliably。其中quickly，怎么做到快的呢，就是缓存已经下载过的依赖。

## 安装

```
brew update
brew install yarn
```

## 基本命令

**新建node项目**

```
yarn init
```

**添加依赖**

```
yarn add [package]
yarn add [package]@[version]
yarn add [package]@[tag]
```

`yarn add`命令会添加安装的依赖到package.json中，甚至没有package.json还会去新建，虽然这个没啥含量，但是比npm方便多。

add命令的一些选项：

```
yarn add --dev 添加到devDependencies
yarn add --peer 添加到peerDependencies
yarn add --optional 添加到optionalDependencies
```

**更新依赖**

```
yarn upgrade [package]
yarn upgrade [package]@[version]
yarn upgrade [package]@[tag]
```

**删除依赖**

```
yarn remove [package]
```

**安装所有依赖**

```
yarn
```

或者

```
yarn install
```

安装的一些选项：

```
一个包只安装一个版本（平铺）: yarn install --flat
强制重新下载所有包: yarn install --force
只安装production版本的包: yarn install --production
```

和npm基本没什么两样，过渡成本很低。

## 其他命令

全部的命令文档见：[CLI Introduction | Yarn](https://yarnpkg.com/en/docs/cli/)