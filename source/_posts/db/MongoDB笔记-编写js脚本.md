---
title: MongoDB笔记-编写js脚本
date: 2017-12-22 10:30:21
categories: MongoDB
tags: [db,mongodb]
---

MongoDB原生支持js，所以在平时查询或者跑数据的时候，写段js是非常方便的。

<!--more-->

## 遍历并输出数据

我们一般使用`db.collection.find(query, projection)`这个方法来查询数据，这个方法返回一个`cursor`对象，可以理解为指向查询结果集的一个指针，需要迭代它才能一条一条获取结果。

```js
var myCursor = db.users.find( { type: 2 } );

while (myCursor.hasNext()) {
   print(tojson(myCursor.next()));
}
```

`myCursor.next()`得到的就是具体的Document对象了，可以直接访问对应的字段。

这里有两个重要函数：

- tojson：把对象转为JSON字符串
- print：打印内容到控制台

可以`printjson`来替换`print(tojson())`调用。同时`cursor`对象支持`forEach`方法：

```js
var myCursor =  db.users.find( { type: 2 } );

myCursor.forEach(printjson);
```


## 参考资料
- [db.collection.find() — MongoDB Manual 3.6](https://docs.mongodb.com/manual/reference/method/db.collection.find/#db.collection.find)
- [Iterate a Cursor in the mongo Shell — MongoDB Manual 3.6](https://docs.mongodb.com/manual/tutorial/iterate-a-cursor/#read-operations-cursors)