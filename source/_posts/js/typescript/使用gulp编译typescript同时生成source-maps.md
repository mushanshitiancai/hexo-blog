---
title: 使用gulp编译typescript同时生成source maps
date: 2017-01-15 17:53:52
categories:
tags: [js,ts,gulp]
---

编译typescript的方法有很多，但是如果你已经在使用gulp工作流的话，整合编译任务到gulp中是非常不错的选择。

<!--more-->

我们使用[gulp-typescript][gulp-typescript]这个gulp插件项目来生成typescript。

```
npm install --global gulp
npm install gulp
npm install gulp-typescript typescript
```

简单示例：

```js
var gulp = require('gulp');
var ts = require('gulp-typescript');

gulp.task('default', function () {
    return gulp.src('src/**/*.ts')
        .pipe(ts({
            noImplicitAny: true,
            out: 'output.js'
        }))
        .pipe(gulp.dest('built/local'));
});
```

这里直接在ts函数中传入对应配置。根据typescript官方文档，一般typescript工程都有一个`tsconfig.json`配置文件。我们想导入这个配置也是可以的：

```js
var tsProject = ts.createProject('tsconfig.json');

gulp.task('scripts', function() {
    var tsResult = gulp.src("lib/**/*.ts") // or tsProject.src()
        .pipe(tsProject());

    return tsResult.js.pipe(gulp.dest('release'));
});
```

不过需要注意的是，gulp-typescript不会使用tsconfig.json中的`sourceMap`配置项。所以生成的代码默认是不带source map的。这个是因为gulp-typescript想更多的兼容gulp生态的设计风格。在gulp生态中，生成sourceMap一般交由别的插件来完成。gulp-typescript推荐的是gulp-sourcemaps。

```
var gulp = require('gulp')
var ts = require('gulp-typescript');
var sourcemaps = require('gulp-sourcemaps');

gulp.task('scripts', function() {
    return gulp.src('lib/*.ts')
        .pipe(sourcemaps.init()) // This means sourcemaps will be generated
        .pipe(ts({
            // ...
        })).js
        .pipe( ... ) // You can use other plugins that also support gulp-sourcemaps
        .pipe(sourcemaps.write()) // Now the sourcemaps are added to the .js file
        .pipe(gulp.dest('release/js'));
});
```

在gulp-typescript流之前使用`pipe(sourcemaps.init())`，在流之后使用`pipe(sourcemaps.write())`就可以生成sourcemap了。默认会生成inline sourcemap，也就是sourcemap和编译后的代码在同一个文件中。

默认生成的inline sourcemap没有携带足够的调试信息，我在调试的时，vscode在断点处提示和生成的代码对不上，无视断点。

第一，我们需要在独立的文件中生成sourcemap，`sourcemaps.write("./maps")`，第二，我们需要设置`sourceRoot`，指定源码所在的目录：

```
gulp.task('typescriptForTest', function () {
    return gulp.src(["./lib/**/*.ts*", "./test/**/*.ts"], { base: "./" })
        .pipe(sourcemaps.init())
        .pipe(tsProject()).js
        .pipe(sourcemaps.write("./maps", {
            sourceRoot: function (file) {
                return p.join(file.cwd, 'lib');
            }
        }))
        .pipe(gulp.dest("test-out/"));
});
```

这样的生成的sourcemap的属性和源码就对上了，调试OK！

[gulp-typescript]: https://github.com/ivogabe/gulp-typescript