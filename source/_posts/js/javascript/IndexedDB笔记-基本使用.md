---
title: IndexedDB笔记-基本使用
date: 2018-02-27 21:42:52
categories: [JavaScript]
tags: [javascript,js]
toc: true
---

Web Application，网页应用是大势所趋，网页如果要提供本地应用级别的体验，存储是不可缺少的功能。从最早的Cookie，到LocalStorage，到IndexedDB，前端存储方案从简单的键值对到现在的数据库，功能不断强大。

IndexedDB是一种可以让你在用户的浏览器内持久化存储数据的方法。IndexedDB为生成Web Application提供了丰富的查询能力，使我们的应用在在线和离线时都可以正常工作。IndexedDB是一个功能完备的NoSQL数据库。

<!-- more -->

## 打开数据库（database）

```js
let request = indexedDB.open("TestDB", 1);

request.onerror = function (e) {
    // 打开数据库失败
}
request.onsuccess = function(e){
    // 打开数据库成功，成功后request.result会被设置为db对象
    let db = request.result；
}
request.onupgradeneeded = function(e){
    // 在数据库版本升级时触发
}
```

从打开数据库和后端的编程体验就不一样了。首先IndexDB的所有操作都是异步的，打开数据库也不例外。

`open`函数打开一个数据库连接，第一个参数指定数据库名称，第二个是一个可选参数，指定数据库的版本，如果不指定，则看数据库是否已经存在，如果已经存在，则打开数据库并且不更新版本，如果数据库不存在，则创建该数据库并且版本为1。

`open`函数会立刻返回一个`IDBOpenDBRequest`对象，但是这会儿数据库还没打开好。如果数据库打开成功，则触发`success`事件，并设置Request对象的`result`字段为`IDBDatabase`实例。然后我们就可以用db实例来进行数据库操作了。

### 数据库版本

数据库的版本也是令人疑惑的一个地方，之前接触的后端数据库都没有版本的概念。一般我们在使用SQL数据库的时候，在应用开始使用数据库前，我们要执行建库建表语句，然后应用才能正常的使用数据库。而在开发的过程中，如果需要升级数据表的结构，我们需要通知DBA在夜深人静的时候执行更新数据表结构的语句。

对于后端开发，我们可以专门的有人有时间去维护数据库结构，而对于浏览器端则不一样了，你的代码在客户端建立了一个数据表，之后需要更新结构，是不会有专人去更新的，还是得你的JS代码来更新。那如何知这个用户的浏览器中的数据表需要更新了呢？一种方法就是程序根据当前需要来检测浏览器中的表结构，索引是否符合当前需求，但是随着程序的不断维护，这个检测代码会越发的复杂，所以IndexedDB设计上就考虑了这个场景，为数据库的结构定义版本，如果需要修改数据表结构，就增加版本。IndexedDB检测当前版本和客户端的版本是否一致，如果客户端的版本低于当前需要的版本，则触发`upgradeneeded`事件，让用户有机会去执行升级数据表结构的代码。

所以`onupgradeneeded`回调函数会在`open`一个大于浏览器中现存版本的数据库时触发，也只有在这个函数中可以更新对象存储空间和索引。

## Object Store

SQL数据库使用表来存储记录，IndexedDB中没有表，而是使用object store（对象存储空间）来存储记录。每条记录需要和一个键相关联。

可以指定记录中的一个字段作为键值（key path），或者可以使用自动生成的递增数字作为键值（key generate）。

| Key Path | Key Generator | 说明                                                                                                                          |
| -------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| No       | No            | 这个存储对象空间可以放任何类型的值（原始类型，对象），但是需要指定一个单独的Key与值进行关联                                   |
| Yes      | No            | 这个存储对象空间只能存放对象，这个对象必须有一个和KeyPath同名的属性                                                           |
| No       | Yes           | 这个存储对象空间可以放任何类型的值（原始类型，对象），与值关联的Key会自动生成，如果你要指定，也是可以的                       |
| Yes      | Yes           | 这个存储对象空间只能存放对象，这个对象必须有一个和KeyPath同名的属性，这个属性值会自动生成，但是如果属性值存在，则会使用属性值 |

看着这两个的定义还是有点复杂的。我们可以联系SQL数据库来思考。SQL的表结构包含多个字段，必须有一个主键。主键可以设置为自增或者是自定义。IndexedDB只不过是存储结构有一些不同，它更加灵活，它也需要一个主键，只是这个可以是数据上的，也可以是数据外的。KeyPath为No，也就是不在数据中保存主键，所以存储对象空间可以存放任何类型，而KeyPath为Yes，则需要在数据中保存主键，所以数据也就只能是对象了。Key Generator则是指定主键是否是自增的，如果是Yes，则主键自增，但是也可以自己指定，如果为No，则主键必须用户自己指定。

`key path`和`key generate`配置的是对象存储空间的主键和是否自增。IndexedDB还支持索引和唯一索引，前提是对象存储空间存储的是对象。

新建对象存储空间方法：

```js
var objectStore = IDBDatabase.createObjectStore(name, options);
```

`name`参数指定对象存储空间名称，`options`参数是可选的，可选的属性有：

- `keyPath`： 指定主键，可以是一个数组。如果没有指定，则会使用独立的键值（out-of-line keys）作为主键
- `autoIncrement`：对应上面说的Key Generator配置，默认false

新建索引方法：

```js
var myIDBIndex = objectStore.createIndex(indexName, keyPath, objectParameters);
```

`indexName`指定索引名称。`keyPath`指定索引的键，可以是一个数组。`objectParameters`参数是可选的，可选的属性有：

- `unique`：指定索引为唯一索引
- `multiEntry`：

## 事务

IndexedDB所有操作都需要在事务上进行，而且事务都是显式的。我们通过数据库对象得到事务，然后在事务上提交操作。

IndexedDB事务有三种模式`readonly`，`readwrite`和`versionchange`。如果事务只有读取数据库的操作，则使用`readonly`模式，如果事务需要更新数据库需要使用`readwrite`模式。`versionchange`事务用于更新数据库结构，一般情况下我们无法获取这种模式的事务，但是在指定更高version来打开数据库时，数据库会开启此事务，并触发`onupgradeneeded()`回调，这就是为啥只能在`onupgradeneeded()`中更新数据库结构的原因。

开启事务：

```js
var IDBTransaction = IDBDatabase.transaction(storeNames, mode);
```

- `storeNames` object store名称数组，用于指定事务操作覆盖的object store
- `mode` 事务模式，可选值为`readonly`，`readwrite`，默认值为`readonly`

```js
// 该事务需要操作'my-store-name'和'my-store-name2'这两个对象存储空间
var transaction = db.transaction(['my-store-name', 'my-store-name2']); 

// 该事物只操作my-store-name这个对象存储空间，可以直接用字符串
var transaction = db.transaction('my-store-name');

// 该事物需要操作所有的对象存储空间
var transaction = db.transaction(db.objectStoreNames);
```

个人观点是，事务在声明时就需要指定模式和之后操作涉及的对象存储空间，其实是比较麻烦的，为什么这么做，应该是为了更容易的优化性能。指定操作的模式，那对于自读模式，可以不用加锁的并发，对于读写模式，则可能需要加锁。同时指定了操作的object store，则可以确定要对那些object store（以上属于推测）。

事务能接收三中DOM事件：`error`, `abort`, `complete`。在事务中提交的操作发生的错误都会冒泡到事务（然后冒泡到db实例）。在事务发生错误时，事务会回滚，除非你在错误处理函数中调用`preventDefault()`。如果你没有处理错误或者调用了事务的`abort()`方法，则事务回滚，并触发`abort`事件。如果事务成功，触发`complete`事件。

```js
let transaction = db.transaction("user", "readwrite");
transaction.onerror = function (e) {
    // 事务失败时触发
};
transaction.oncomplete = function (e) {
    // 事务成功结束时触发
};
transaction.onabort = function (e) {
    // 事务回滚时触发
}
```

事务声明好了后，我们通过事务获取object storage，然后就可以对object storage进行操作了。获取[IDBObjectStore](https://developer.mozilla.org/en-US/docs/Web/API/IDBObjectStore)对象的方法如下，注意，这里只能获取在新建transaction时指定的object storage数组中的object storage：

```js
IDBObjectStore objectStore = IDBTransaction.objectStore(name);
```

## 添加数据

```js
IDBRequest request = objectStore.add(value);
IDBRequest request = objectStore.add(value, key);
```

拿到`IDBRequest`对象，可以通过`onerror`和`onsuccess`两个回调来监听操作是否成功或者失败。

如果object store没有使用key path，则需要指定数据的键，即使用`objectStore.add(value, key)`方法。

```js
let objectStore = transaction.objectStore("user");
let r = objectStore.add({...}, "name");
r.onsuccess = function (e) {
    console.log('add request success', e);
}
r.onerror = function(e){
    console.log('add request error', e);
}
```

## 删除数据

```js
IDBRequest request = objectStore.delete(Key);
IDBRequest request = objectStore.delete(KeyRange);

IDBRequest request = objectStore.clear();
```

## 更新数据

```js
IDBRequest request = objectStore.put(item);
IDBRequest request = objectStore.put(item, key);
```

## 统计数据数量

```js
IDBRequest request = ObjectStore.count();
IDBRequest request = ObjectStore.count(query);
```

## 查询数据

```js
IDBRequest request = objectStore.get(key);
IDBRequest request = objectStore.getKey(key);
```

```js
let request = db.transaction("user")
    .objectStore("user")
    .get("mushan");
request.onsuccess = function (e) {
    console.log(request.result);
}
```

因为传入的event对象的target属性会被设置为对应的request，所以还可以进一步简化：

```js
db.transaction("user")
    .objectStore("user")
    .get("mushan");
    .onsuccess = function (e) {
        console.log(request.result);
    }
```

## Key Range

IndexedDB除了对一个特定值进行查找，可以针对一个范围进行查找，使用到IDBKeyRange：

| Range               | Code                                 |
| ------------------- | ------------------------------------ |
| All keys ≤ x        | IDBKeyRange.upperBound(x)            |
| All keys < x        | IDBKeyRange.upperBound(x, true)      |
| All keys ≥ y        | IDBKeyRange.lowerBound(y)            |
| All keys > y        | IDBKeyRange.lowerBound(y, true)      |
| All keys ≥ x && ≤ y | IDBKeyRange.bound(x, y)              |
| All keys > x &&< y  | IDBKeyRange.bound(x, y, true, true)  |
| All keys > x && ≤ y | IDBKeyRange.bound(x, y, true, false) |
| All keys ≥ x &&< y  | IDBKeyRange.bound(x, y, false, true) |
| The key = z         | IDBKeyRange.only(z)                  |


## 使用Cursor查询数据

使用`get`方法只能获取到特定键对应的数据，如果要查询一个区间内的所有键对应的值，则需要使用Cursor对象来遍历。

```js
IDBRequest request = ObjectStore.openCursor();
IDBRequest request = ObjectStore.openCursor(query);
IDBRequest request = ObjectStore.openCursor(query, direction);

IDBRequest request = objectStore.openKeyCursor();
IDBRequest request = objectStore.openKeyCursor(query);
IDBRequest request = objectStore.openKeyCursor(query, direction);
```

`query`可以是key或者key range。

`direction`的取值有："next", "nextunique", "prev", "prevunique"。默认为 "next"，即正向遍历。"prev"为反向遍历。"nextunique"表示正向遍历，同时对于一个key有多个值的情况，只会获取第一个出现的值。"prevunique"同理。

```js
db.transaction(objectStoreName).objectStore(objectStoreName).openCursor().onsuccess = function (e) {
    let cursor = e.target.result;
    if (cursor) {
        console.log(cursor.key, cursor.value);
        cursor.continue();
    } else {
        console.log('end');
    }
};
```

所以用IndexedDB遍历数据还是非常麻烦的，把结果放入一个数组中可以这么写：

```js
var customers = [];

objectStore.openCursor().onsuccess = function(event) {
  var cursor = event.target.result;
  if (cursor) {
    customers.push(cursor.value);
    cursor.continue();
  }
  else {
    alert("Got all customers: " + customers);
  }
};
```

## 索引查询

IndexedDB除了支持主键搜索还支持索引搜索，使用`objectStore.index(name)`获得`IDBIndex`对象，就可以在索引上进行查找搜索操作：

```js
IDBIndex index = objectStore.index(name);
```

```js
IDBIndex.count()
IDBIndex.get()
IDBIndex.getKey()
IDBIndex.getAll()
IDBIndex.getAllKeys()
IDBIndex.openCursor()
IDBIndex.openKeyCursor()
```


## 参考资料
- [使用 IndexedDB - Web API 接口 | MDN](https://developer.mozilla.org/zh-CN/docs/Web/API/IndexedDB_API/Using_IndexedDB)