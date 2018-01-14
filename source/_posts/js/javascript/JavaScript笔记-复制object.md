---
title: JavaScript笔记-复制object
date: 2016-03-31 17:40:22
categories: [JavaScript]
tags: [javascript,js]
---

es6中，可以使用`Object.assign`来复制对象：

```
var obj = { a: 1 };
var copy = Object.assign({}, obj);
console.log(copy); // { a: 1 }
```

但是他执行的是浅复制：

```
var a = {
    1: 1,
    2: [1,2,3]
}

var b = Object.assign({},a);
b[2][2] = 99;

console.log(a); // { '1': 1, '2': [ 1, 2, 99 ] }
console.log(b); // { '1': 1, '2': [ 1, 2, 99 ] }
```

如何在js中执行深复制呢？

[javascript - What is the most efficient way to clone an object? - Stack Overflow](http://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-clone-an-object)这个问答提供了很多解决方法，同时也暴露了js基础设施不完善的缺点。

众多的方案中，我采用的是基于`underscore`的方法：

    var newObject = _.clone(oldObject);

还可以用`lodash`，他的API和`underscore`基本一样。

```
var newObject = _.clone(oldObject);
var newObject = _.cloneDeep(oldObject);
```

`_.clone`和`_.cloneDeep`对应浅复制和深复制。还是很方便的。