---
title: npm的package.json学习
date: 2016-03-20 19:38:18
tags: js
---

一下翻译自npmjs官方文档。

`package.json`必须是一个json文件。

## name
这是最重要的一个字段。是**必须**的字段。

命名的一些规则：

- 名字需要小于等于214个字符。 This includes the scope for scoped packages.
- 名字不能以`.`或者是`_`开头
- 名字中不能有大写字符
- 包的名字将会是url的一部分，命令行的一部分，还可能是目录的名字，所以名字里不能有`non-URL-safe`字符

命名的一些提示：

- 不要用Node核心模块的名字
- 不要在名字中出现`js`或者`node`。It's assumed that it's js, since you're writing a package.json file, and you can specify the engine using the "engines" field. (See below.)
- 包的名字将会是`require()`函数的参数，所以竟可能的短一些，但是也必须表达清楚
- 在你确定之前，上https://www.npmjs.com/看一下这个名字是否被别人用过了

名字可以有一个作用域前缀比如`@myorg/mypackage`。具体说明：[npm-scope](https://docs.npmjs.com/misc/scope)

## version
和name字段一样重要。因为由名字和版本可以唯一确定一个包。version字段也是**必须**的。

version会被[node-semver](https://github.com/isaacs/node-semver)解析。

更多关于语义化版本的说明：[semver](https://docs.npmjs.com/misc/semver)

## description
说明文本，帮助用户了解你的包。`npm search`会列出description。

## keywords
关键词数组，帮组用户搜索到你的包。`npm search`会列出keywords。

## homepage
项目主页的URL。

NOTE: This is not the same as "url". If you put a "url" field, then the registry will think it's a redirection to your package that has been published somewhere else, and spit at you.

Literally. Spit. I'm so not kidding.

上面这个我真没看懂。。。

## bugs
你项目的问题跟踪页面，或者是邮件列表。格式如下:

```
{ "url" : "https://github.com/owner/project/issues"
, "email" : "project@hostname.com"
}
```

如果只有一个url，bugs的值也可以直接是个字符串。

## licence
说明这个包使用的许可证。

```
{ "license" : "BSD-3-Clause" }
```

许可证的ID可以在[the full list of SPDX license IDs](https://spdx.org/licenses/)上找，要用[OSI](https://opensource.org/licenses/alphabetical)提供的。

如果你不想别人使用：

```
{ "license": "UNLICENSED"}
```

同时可以设置`"private": true`。

## author, contributors
author设置个人信息，contributors是多个贡献者个人信息的数组。个人信息格式：

```
{ "name" : "Barney Rubble"
, "email" : "b@rubble.com"
, "url" : "http://barnyrubble.tumblr.com/"
}
```

## 参考资料
- [package.json | npm Documentation](https://docs.npmjs.com/files/package.json)






