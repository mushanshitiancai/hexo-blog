---
title: npm的package.json学习
date: 2016-03-20 19:38:18
tags: [js,nodejs]
---

一下翻译自npmjs官方文档。

`package.json`必须是一个json文件。

先说说新建项目的字段：

- name
- version
- description
- repository
- license

同时`README`文件也是必要的。

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

## license
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

也可以按格式写成一个字符串：

```
"Barney Rubble <b@rubble.com> (http://barnyrubble.tumblr.com/)"
```

## files
files是一个数组，他指定了你的工程需要包含的文件。如果指定的是目录，则目录下的文件也会被包含进来。

你也可以建立一个`.npmignore`文件在，他的用法和`.gitignore`一样。

有一些文件是默认包含的，不受配置影响：

- package.json
- README
- CHANGELOG
- LICENSE / LICENCE

有些文件则是总是排除的：

- .git
- CVS
- .svn
- .hg
- .lock-wscript
- .wafpickle-N
- *.swp
- .DS_Store
- ._*
- npm-debug.log

## main
main字段指定你的程序主模块ID(module ID)。

比如，你的包叫foo，别人安装后，通过`require("foo")`获取的就是main指定的模块执行后的结果。

main指定的模块ID，是相对于包的根目录指定的。

大多数的包都有一个main脚本？(For most modules, it makes the most sense to have a main script and often not much else.)

## bin
很多的包都有一个或者多个可执行文件，他们希望能把可执行文件安装到PATH变量中。npm可以很容易做到这个。

在配置中指定bin字段，他是一个命令名称与命令文件的键值对。安装的时候，npm会在`prefix/bin`中建立软链，或者在`./node_modules/.bin/`中建立软链。前者是系统级别的，后者是工程级别的。

举个例子：

```
{ "bin" : { "myapp" : "./cli.js" } }
```

安装这个应用后，会建立一个软链接文件`/usr/local/bin/myapp`，其指向`cli.js`。

如果你只有一个可执行文件，而且他的名字就包名，你可以直接指定一个脚本路径的字符串：

```
{ "name": "my-program"
, "version": "1.2.5"
, "bin": "./path/to/program" }

这两者是一样的：

{ "name": "my-program"
, "version": "1.2.5"
, "bin" : { "my-program" : "./path/to/program" } }
```

## man
指定一个文件，或者是文件的数组，来让`man`程序找到你的帮助文档。

如果只有一个文件，格式如下：

```
{ "name" : "foo"
, "version" : "1.2.3"
, "description" : "A packaged foo fooer for fooing foos"
, "main" : "foo.js"
, "man" : "./man/doc.1"
}
```

无论man字段指定的文件名如何，都可以`man <pkgname>`访问，这里通过`man foo`访问。

如果有多个帮助文档，那么帮助文档的名字就有意义了：

```
{ "name" : "foo"
, "version" : "1.2.3"
, "description" : "A packaged foo fooer for fooing foos"
, "main" : "foo.js"
, "man" : [ "./man/foo.1", "./man/bar.1" ]
}
```

这样可以通过`man foo`和`man foo-bar`访问。

或者是：

```
{ "name" : "foo"
, "version" : "1.2.3"
, "description" : "A packaged foo fooer for fooing foos"
, "main" : "foo.js"
, "man" : [ "./man/foo.1", "./man/foo.2" ]
}
```

这样可以通过`man foo`和`man 2 foo`访问。

## directories
CommonJS的[Packages](http://wiki.commonjs.org/wiki/Packages/1.0)标准说明你可以使用directories对象来说明你的包的结构。可以参考[npm's package.json](https://registry.npmjs.org/npm/latest)。

directories的有些字段目前还没有用处，以后或许会被利用上。

### directories.lib
告诉别人你的库的代码在哪个目录。没有其他额外处理了。

### directories.bin
If you specify a bin directory in directories.bin, all the files in that folder will be added.

Because of the way the bin directive works, specifying both a bin path and setting directories.bin is an error. If you want to specify individual files, use bin, and for all the files in an existing bin directory, use directories.bin.

不是太懂这个bin和顶级bin的区别。。。

### directories.man
指定一个包含man文件的目录。是一个生成man数组的语法糖。

### directories.doc
可以放markdown文件在这里。

### directories.example
放置例子脚本。

## repository
说明你项目的仓库位置。

```
"repository" :
  { "type" : "git"
  , "url" : "https://github.com/npm/npm.git"
  }

"repository" :
  { "type" : "svn"
  , "url" : "https://v8.googlecode.com/svn/trunk/"
  }
```

这里的url不是你项目页面的url，而是仓库的url地址。

如果是GitHub, GitHub gist, Bitbucket, or GitLab上的仓库，你可以用简写：

```
"repository": "npm/npm"

"repository": "gist:11081aaa281"

"repository": "bitbucket:example/repo"

"repository": "gitlab:another/repo"
```

## scripts
scripts字段提供了一个字典信息，key是工程生命周期的某一个环节，value是你希望这个环节运行的命令。

scripts字段主要是用来构建项目用的。具体参考[npm-scripts](https://docs.npmjs.com/misc/scripts)。

## config
config可以用来声明包脚本中用到的一些配置。比如：

```
{ "name" : "foo"
, "config" : { "port" : "8080" } }
```

然后有个`start`命令使用了`npm_package_config_port`这个环境变量，用户可以使用`npm config set foo:port 8001`来覆盖这个变量（全局还是局部？）。

## dependencies
dependencies字段用来说明项目的依赖。开发环境才需要的依赖只要放在`devDependencies`中就可以了。

dependencies的格式是一个object，key是包名，value是包的版本范围。版本范围使用的是[semver](https://docs.npmjs.com/misc/semver)语法。

- `version` 指定一个确定的版本
- `>version` 必须高于这个版本
- `>=version` 
- `<version`
- `<=version`
- `~version` 约等于这个版本。参考[semver](https://docs.npmjs.com/misc/semver)
- `^version` 和这个版本兼容的版本。参考[semver](https://docs.npmjs.com/misc/semver)
- `1.2.x` 可以是1.2.0, 1.2.1, 等。但是不能是1.3.0
- `http://...` See 'URLs as Dependencies' below
- `*` 匹配所有版本
- `""` 和`*`一样
- `version1 - version2` 和 `>=version1 <=version2`一样
- `range1 || range2` range1或者range2
- `git...` See 'Git URLs as Dependencies' below
- `user/repo` See 'GitHub URLs' below
- `tag` A specific version tagged and published as tag 参考[npm-tag](https://docs.npmjs.com/cli/tag)
- `path/path/path` See Local Paths below

例子：

```
{ "dependencies" :
  { "foo" : "1.0.0 - 2.9999.9999"
  , "bar" : ">=1.0.2 <2.1.2"
  , "baz" : ">1.0.2 <=2.3.4"
  , "boo" : "2.0.1"
  , "qux" : "<1.0.0 || >=2.3.1 <2.4.5 || >=2.5.2 <3.0.0"
  , "asd" : "http://asdf.com/asdf.tar.gz"
  , "til" : "~1.2"
  , "elf" : "~1.2.3"
  , "two" : "2.x"
  , "thr" : "3.3.x"
  , "lat" : "latest"
  , "dyl" : "file:../dyl"
  }
}
```

### URLs
可以直接指定一个依赖的url。npm安装的时候会直接从url下载。

### Git URLs

```
git://github.com/user/project.git#commit-ish
git+ssh://user@hostname:project.git#commit-ish
git+ssh://user@hostname/project.git#commit-ish
git+http://user@hostname/project/blah.git#commit-ish
git+https://user@hostname/project/blah.git#commit-ish
```

这里的`commit-ish`可以是tag，sha，branch。也就是可以传给`git checkout`的参数。默认是`master`。

### GitHub URLs
可以通过"foo": "user/foo-project"很方便的指定GitHub上的库：

```
{
  "name": "foo",
  "version": "0.0.0",
  "dependencies": {
    "express": "visionmedia/express",
    "mocha": "visionmedia/mocha#4727d357ea"
  }
}
```

### 本地路径
可以指定一个本地包的路径。

本地路径可以通过`npm install -S` 或 `npm install --save`保存（没懂）

```
../foo/bar
~/foo/bar
./foo/bar
/foo/bar
```

## devDependencies
别人在使用你的包的时候，并不喜欢下载你在开发过程中使用的测试框架，文件框架等开发过程中才需要的库。

这种情况，你可以把开发过程中才需要依赖的库放到devDependencies中。

当你在包的根目录下执行`npm link`或者`npm install`时，才会安装devDependencies中的依赖。

比如为了构建一个平台无关的包，比如吧Coffeescript或者其他非javascript语言编译为javascript，可以使用`prepublish`脚本来做到。`prepublish`中使用到的依赖就可以放在`devDependencies`中。

比如：

```
{ "name": "ethopia-waza",
  "description": "a delightfully fruity coffee varietal",
  "version": "1.2.3",
  "devDependencies": {
    "coffee-script": "~1.6.3"
  },
  "scripts": {
    "prepublish": "coffee -o lib/ -c src/waza.coffee"
  },
  "main": "lib/waza.js"
}
```

`prepublish`脚本会在发布前执行，所以用户就不需要自己再编译了。在开发模式下（本地执行`npm install`），也会执行这个脚本，这样便于测试。

## peerDependencies
比如你开发一个库的插件，你可能需要说明你兼容宿主库的哪些版本。这就用到了peerDependencies了。

比如：

```
{
  "name": "tea-latte",
  "version": "1.3.5",
  "peerDependencies": {
    "tea": "2.x"
  }
}
```

这里`tea-latte`兼容主版本为2的`tea`。

**注意：**在npm1，2中，如果依赖树中的库的版本没有达到`peerDependencies`中的要求，会自动安装对应版本的库。npm3中就不会这么做了，他只会给出了一个警告。

所以你的插件要竟可能的支持多的版本。如果是基于[semver](http://semver.org/)，主版本的变化才会改变api，所以你可以支持这个主版本下的所有版本"^1.0" 或者 "1.x"，如果你使用到了1.5.2中的某个新特性，你可以这么写：">= 1.5.2 < 2"

## bundledDependencies
一个数组，指定在发布时捆绑发布的其他包。

## optionalDependencies
可选依赖。如果你对于这个依赖不是强依赖，也就是在这个依赖安装失败的情况下npm依然继续工作，就可以把依赖放到optionalDependencies下。

同时，你的程序中需要做容错处理：

```
try {
  var foo = require('foo')
  var fooVersion = require('foo/package.json').version
} catch (er) {
  foo = null
}
if ( notGoodFooVersion(fooVersion) ) {
  foo = null
}

// .. then later in your program ..

if (foo) {
  foo.doFooThings()
}
```

optionalDependencies会覆盖dependencies中的依赖。所以最好只在一个地方声明。

## engines
可以指定你依赖的node版本：

```
{ "engines" : { "node" : ">=0.10.3 <0.12" } }
```

## os
你可以指定你的软件在哪个平台可以运行：

```
"os" : [ "darwin", "linux" ]
```

也可以指定哪个平台不可以运行：

```
"os" : [ "!win32" ]
```

可用的平台声明在`process.platform`中。

## cpu
如果你的包依赖于特定的cpu构架，可以通过cpu字段指定：

```
"cpu" : [ "x64", "ia32" ]
"cpu" : [ "!arm", "!mips" ]
```

可用的架构声明在`process.arch`中。

## preferGlobal
如果你的包主要是一个命令行程序，并且你希望安装在全局环境中，你可以吧preferGlobal设置为true，这样包在被安装到本地的时候就会有个提示。

## private
如果你设置`"private": true`，那npm就会拒绝发布他。

This is a way to prevent accidental publication of private repositories. If you would like to ensure that a given package is only ever published to a specific registry (for example, an internal registry), then use the `publishConfig` dictionary described below to override the `registry` config param at publish-time.

## publishConfig
这里配置一写在发布的时候需要使用到的配置。

This is a set of config values that will be used at publish-time. It's especially handy if you want to set the tag, registry or access, so that you can ensure that a given package is not tagged with "latest", published to the global public registry or that a scoped module is private by default.

Any config values can be overridden, but of course only "tag", "registry" and "access" probably matter for the purposes of publishing.

See [npm-config](https://docs.npmjs.com/misc/config) to see the list of config options that can be overridden.

## 默认值
npm提供了一些默认配置：

- `"scripts": {"start": "node server.js"}`

  如果包的根目录下存在一个server.js文件，npm会把start命令和他绑定。

- `"scripts":{"preinstall": "node-gyp rebuild"}`

  如果工程根目录下存在`binding.gyp`文件，preinstall生效。

- `"contributors": [...]`

  如果工程根目录下有一个`AUTHORS`文件，npm会认为这个文件中的没一行都是作者信息，格式为：`Name <email> (url)`。以`#`开头的行，或者是空行会被忽略。

## 参考资料
- [package.json | npm Documentation](https://docs.npmjs.com/files/package.json)






