---
title: 使用yeoman创建项目生成器
date: 2017-01-09 10:33:32
categories:
tags: [js]
toc: true
---

![](https://github.com/yeoman/yeoman/raw/master/yeoman-illustration.png)

在为VSCode开发插件时，使用到了yeoman这个项目。yeoman是一个项目生成系统，可以根据指定的模板项目和配置，来生成一个可用于使用的项目。VSCode就是通过yeoman来生成插件项目的。

## 新建一个yeoman项目生成器项目
一个yeoman项目就是一个普通的npm项目。但是他有一些硬性规定：

1. 项目名称必须以`generator-`开头，比如`generator-name`，其中name就是你的生成器的名字
2. package.json的keywords数组必须包含一个`"yeoman-generator"`
3. package.json的files数组必须包含用于生成的文件或者目录
4. package.json必须包含`yeoman-generator`依赖，你可以执行代码来包含`npm install --save yeoman-generator`

这几点是yeoman识别一个npm项目为yeoman项目的条件。

一个合格的package.json文件可能是这样的：

```json
{
  "name": "generator-name",
  "version": "0.1.0",
  "description": "",
  "files": [
    "generators"
  ],
  "keywords": ["yeoman-generator"],
  "dependencies": {
    "yeoman-generator": "^1.0.0"
  }
}
```

项目的目录结构可能是这样的：

```
├───package.json
└───generators/
    ├───app/
    │   └───index.js
    └───router/
        └───index.js
```

一个生成器项目可以有多个生成器，比如生成不同部件的生成器。这些生成器放在package.json指定的目录下。**app生成器目录是必须存在的**。因为默认执行`yo test`其实调用的是`yo test:app`。

每个生成器目录下有自己的逻辑，逻辑代码在对应目录下的index.js中。生成器代码框架为：

```
var Generator = require('yeoman-generator');

module.exports = class extends Generator {};
```

注意，这个**框架代码是必须有的**，否则yeoman会提示`You don’t seem to have a generator with the name “xxx” installed.`这样的错误信息。

不过只有一个空的生成器代码yeoman也是会提示错误的：`AssertionError: This Generator is empty. Add at least one method for it to run.`，意思就是生成器不能是啥也不干的，那样就没有意义了。

所以让我们来添加一些方法把：

```
module.exports = class extends Generator {
  method1() {
    console.log('method 1 just ran');
  }

  method2() {
    console.log('method 2 just ran');
  }
};
```

这样，最简单的yeoman生成器项目就写好了，我们要如何运行呢？因为我们在本地开发，这个npm module还不是全局module，我们要把它安装到全局：

```
npm link
```

这个命令会在全局npm库里建立一个指向当前项目的软链接。这样就可以在全局环境下使用本项目了。这是npm的一个常用技巧。

运行`yo name`，可以看到输出了：

```
method 1 just ran
method 2 just ran
```

你的猜测没错，添加到Generator子类中的方法会依次执行。

## yeoman是如何执行任务的？

上面我们提到了在Generator子类中添加方法，yeoman就会按顺序执行。这是yeoman执行任务最基本的一个规则。

生成器虽然需求各式各样，但是其流程上是有共性的，yeoman提取了这些步骤，定义了8个生成器的生命周期(run loop)：

1. initializing - 初始化方法，比如检查当前项目状态，读取配置
2. prompting - 提示用户输入一些选项，决定如何生成，一般这里你会调用this.prompt()
3. configuring - 保存配置和配置要生成的项目，比如新建.editorconfig或者其他配置
4. default - 如果方法不符合任何生命周期，就会放到这个组里
5. writing - 生成具体代码的地方，比如控制器代码，路由代码等
6. conflicts - 处理冲突的地方（内部使用）
7. install - 执行安装的地方，比如安装npm依赖
8. end - 最后一个生命周期，执行清理，say good bye等操作

yeoman在执行生成时，会安装这个顺序来执行。我们要如何在对应的生命周期上挂上我们的执行代码呢？有两个方法：

```
// 一个生命周期上只有一个方法
class extends Generator {
  initializing() {}
}

// 一个生命周期上挂载多个方法
Generator.extend({
  initializing: {
    method() {},
    method2() {}
  }
});
```

如果你需要做异步任务，可以这么写：

```
asyncTask() {
  var done = this.async();

  getUserEmail(function (err, name) {
    done(err);
  });
}
```

## 读取用户输入

一个生成器免不了和用户进行交互的，最基本的，你建立一个项目，得问问人家想取什么项目名称吧。

首先说一点，yeoman的野心很大，虽然目前是在命令行中运行，但是他被设计为可以在任何环境运行，比如编辑器中，或者GUI环境中，这意味着你不能假设当前在命令行中而写死一些代码，这样你的生成器在别的环境中显示就要出问题了。所以不要使用`console.log()`或`process.stdout.write()`，而是应该使用`this.log()`。

yeoman使用[Inquirer.js](https://github.com/SBoudrias/Inquirer.js)来和用户进行交互，异常强大。

```js
module.exports = class extends Generator {
  prompting() {
    return this.prompt([{
      type    : 'input',
      name    : 'name',
      message : 'Your project name',
      default : this.appname // Default to current folder name
    }, {
      type    : 'confirm',
      name    : 'cool',
      message : 'Would you like to enable the Cool feature?'
    }]).then((answers) => {
      this.log('app name', answers.name);
      this.log('cool feature', answers.cool);
    });
  }
};
```

prompt具体的API可以去[Inquirer.js](https://github.com/SBoudrias/Inquirer.js)项目上查看。

保存用户的上次输入作为默认输入，这也是一种交互的最佳设计了，为此，yeoman中扩展了Inquirer.js API，添加了一个`store`属性：

```js
this.prompt({
  type    : 'input',
  name    : 'username',
  message : 'What\'s your Github username',
  store   : true
});
```

如果`store: true`，就会保存用户的输入。下次使用输入作为默认输入。

## 接受参数和选项

接受参数的例子：

```
yo webapp my-project
```

例子：

```js
var _ = require('lodash');

module.exports = class extends Generator {
  // 注意：参数和选项都必须定义在构造函数中
  constructor(args, opts) {
    super(args, opts);

    // 注册参数，指定类型，和是否必须
    this.argument('appname', { type: String, required: true });

    // 使用this.options.xxx来访问对应参数
    this.log(this.options.appname);
  }
};
```

使用`this.argument()`来注册参数，第一个参数是选项名称，第二个参数是参数选项，支持的选项有：

- `desc` 参数描述
- `required` Boolean 参数是否是必须的
- `type` String, Number, Array 参数类型(可以指定函数来处理命令行输入的原始字符串)
- `default` 参数的默认值

如果指定参数类型为Array，那么会包含之后的所有参数。

再来看看选项的例子：

```
yo webapp --coffee
```

代码：

```js
module.exports = class extends Generator {
  // 注意：参数和选项都必须定义在构造函数中
  constructor(args, opts) {
    super(args, opts);

    // 注册--coffee选项
    this.option('coffee');

    // 使用this.options.xxx来访问选项
    this.scriptSuffix = (this.options.coffee ? ".coffee": ".js");
  }
});
```

option函数的选项有：

- `desc` 描述
- `alias` 选项的短名称
- `type` 选项类型Boolean, String or Number(可以指定函数来处理命令行输入的原始字符串)
- `default` 默认值
- `hide` Boolean 是否在help中隐藏改选项

## 与文件系统交互
yeoman有两个上下文，一个是目标上下文（Destination context），一个是模板上下文（Template context）。一般操作是从模板文件夹中拷贝文件到目标文件夹中

### 目标上下文
目标指的是yeoman要在其中生成代码的目录。一般是执行yo命令的目录，或者是包含`.yo-rc.json`文件的父目录。

```js
// 假设目标根目录是~/projects
class extends Generator {
  paths() {
    this.destinationRoot();
    // 获取目标路径
    // returns '~/projects'

    this.destinationPath('index.js');
    // 在目标路径后join
    // returns '~/projects/index.js'

    var cwd = this.contextRoot;
    // 执行yo命令的目录
  }
}
```

### 模板上下文 
模板文件夹默认是`./templates/`，可以使用`generator.sourceRoot('new/template/path')`修改默认位置。

```js
class extends Generator {
  paths() {
    this.sourceRoot();
    // returns './templates'

    this.templatePath('index.js');
    // returns './templates/index.js'
  }
});
```

### 操作文件系统
生成代码最需要注意的一件事情就是不要随意就覆盖了用户已经存在的代码，这可能呢带来灾难，所以yeoman在执行文件操作是，都是在内存中操作的（in memory）。只有到了最后才会统一写入，如果发生覆盖，则走处理冲突的流程。这个减少了风险，但是意味着所有文件系统的操作都是异步的了。

为了利用yeoman提供的基于内存的文件系统操作库，我们要使用`this.fs`。完整的API见[mem-fs-editor](https://github.com/sboudrias/mem-fs-editor)

这里举一个例子：copyTpl函数用于拷贝一个模板文件，模板文件中可以指定变量，拷贝过程中会进行模板替换，模板语言是`ejs`。

```html
// ./templates/index.html
<html>
  <head>
    <title><%= title %></title>
  </head>
</html>
```

```js
class extends Generator {
  writing() {
    this.fs.copyTpl(
      this.templatePath('index.html'),
      this.destinationPath('public/index.html'),
      { title: 'Templating with Yeoman' }
    );
  }
}
```

执行后：

```html
// public/index.html
<html>
  <head>
    <title>Templating with Yeoman</title>
  </head>
</html>
```

## 为生成的项目安装依赖
你可能需要为你的项目安装依赖，yeoman为js世界的依赖管理工具提供了对应的函数来安装依赖。（yeoman不限定用来生成js项目，也可以用来生成其他语言的项目）。

```js
class extends Generator {
  installingLodash() {
    this.npmInstall(['lodash'], { 'save-dev': true });
  }
}
```

相当于是：

```
npm install lodash --save-dev
```

```js
generators.Base.extend({
  installingLodash: function() {
    this.yarnInstall(['lodash'], { 'dev': true });
  }
});
```

相当于：

```
yarn add lodash --dev
```

或者使用用其他任何命令行命令：

```js
class extends Generator {
  install() {
    this.spawnCommand('composer', ['install']);
  }
}
```

注意`spawnCommand`必须在`install`内调用。

## 保存配置
上文我们提到了在pomp中可以指定store为true，这样就会保存用户输入作为默认输入。yeoman还提供了单独的存储模块，可以用户在目标目录中存放配置，存放配置的文件就是之前提到过的`.yo-rc.json`。


**`generator.config.save()`**

保存配置到.yo-rc.json文件，如果没有则新建。在`:app`生成器中新建.yo-rc.json是最佳事件，这样其他的生成器就可以准确找到目标根目录了。

调用set就会自动保存，所以这个函数没必要手动调用。

**`generator.config.set()`**

保存一个key-value，或者一个object。

**`generator.config.get()`**

根据key获取value

**`generator.config.getAll()`**

获取全部配置

**`generator.config.delete()`**

删除一个配置

**`generator.config.defaults()`**

设置一个object作为默认配置，如果配置项已经存在，不做操作，不过配置项不存在，则添加。

## 组合生成器
组合可以让一个系统变得非常强大。yeoman也是基于组合来设计的。一个生成器中可以使用另外一个生成器，这个生成器可以是本项目中的其他子生成器，也可以是已经发布了的其他生成器。

`generator.composeWith()`用于执行其他生成器。

- generatorPath - 指定需要组合的生成器的全路径，一般使用require.resolve()
- options - 传递给生成器的参数

例子：

```js
// In my-generator/generators/turbo/index.js
module.exports = class extends Generator {
  prompting() {
    console.log('prompting - turbo');
  }

  writing() {
    console.log('writing - turbo');
  }
};

// In my-generator/generators/electric/index.js
module.exports = class extends Generator {
  prompting() {
    console.log('prompting - zap');
  }

  writing() {
    console.log('writing - zap');
  }
};

// In my-generator/generators/app/index.js
module.exports = class extends Generator {
  initializing() {
    this.composeWith(require.resolve('../turbo'));
    this.composeWith(require.resolve('../electric'));
  }
};
```

输出：

```
prompting - turbo
prompting - zap
writing - turbo
writing - zap
```

组合生成器的生命周期我们需要注意，我这里做了一个实验：

app生成器，其中组合了part生成器和tool生成器：

```js
const Generator = require("yeoman-generator");

module.exports = class extends Generator{
    default() {console.log("app - default");}
    writing() {console.log("app - writing");}
    conflicts() {console.log("app - conflicts");}
    install() {console.log("app - install");}
    end() {console.log("app - end");}
    initializing() {console.log("app - initializing");}
    prompting() {console.log("app - prompting");}
    configuring() {console.log("app - configuring");} 

    default(){
        this.composeWith(require.resolve("../part"),{});
        this.composeWith(require.resolve("../tool"),{});
    }
}
```

part生成器：

```js
const Generator = require("yeoman-generator");

module.exports = class extends Generator {
    default() {console.log("part - default");}
    writing() {console.log("part - writing");}
    conflicts() {console.log("part - conflicts");}
    install() {console.log("part - install");}
    end() {console.log("part - end");}
    initializing() {console.log("part - initializing");}
    prompting() {console.log("part - prompting");}
    configuring() {console.log("part - configuring");} 
}
```

tool生成器：

```js
const Generator = require("yeoman-generator");

module.exports = class extends Generator {
    default() {console.log("tool - default");}
    writing() {console.log("tool - writing");}
    conflicts() {console.log("tool - conflicts");}
    install() {console.log("tool - install");}
    end() {console.log("tool - end");}
    initializing() {console.log("tool - initializing");}
    prompting() {console.log("tool - prompting");}
    configuring() {console.log("tool - configuring");} 
}
```

输出：

```
app - initializing
app - prompting
app - configuring
part - initializing
tool - initializing
part - prompting
tool - prompting
part - configuring
tool - configuring
part - default
tool - default
app - writing
part - writing
tool - writing
app - conflicts
part - conflicts
tool - conflicts
app - install
part - install
tool - install
app - end
part - end
tool - end
```

## 参考资料
- [Getting started with Yeoman | Yeoman](http://yeoman.io/learning/)
- [generator-generator/index.js at master · yeoman/generator-generator](https://github.com/yeoman/generator-generator/blob/master/app/index.js)