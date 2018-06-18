---
title: MongoDB遍历方式对比
date: 2018-06-07 14:58:53
categories: MongoDB
tags: [db,mongodb]
---

在处理数据时，需要遍历MongoDB全表数据。

<!-- more -->

以前的写法是：

```java
int count = 0;
int limit = 1000;
List<DBObject> ret = mongoTemplate.find(new Query().limit(limit).with(new Sort(Sort.Direction.ASC,"_id")), DBObject.class, "demo");
while (ret.size() == limit) {
    // do
    count += ret.size();
    ret = mongoTemplate.find(new Query(Criteria.where("_id").gt(ret.get(ret.size() - 1).get("_id"))).limit(limit).with(new Sort(Sort.Direction.ASC, "_id")), DBObject.class, "demo");
}
// do
count += ret.size();
```

通过多次批量查询的方式遍历全表。

后面发现可以调用更底层的find获取Cursor来遍历结果：

```java
DBCollection demo = mongoTemplate.getCollection("demo");
DBCursor cursor = demo.find((DBObject) JSON.parse("{}"));
while (cursor.hasNext()) {
    DBObject next = cursor.next();
    // do
    count++;
}
```

写法更加简单了，那两种方式的性能如何呢？

```
-----------------------------------------
ms     %     Task name
-----------------------------------------
10658  008%  cursor mode
115964  092%  batch mode
```

用cursor比多次批量查询快了10倍！为什么？

```java
// org.springframework.data.mongodb.core.MongoTemplate#find
public <T> List<T> find(final Query query, Class<T> entityClass, String collectionName) {

    if (query == null) {
        return findAll(entityClass, collectionName);
    }

    return doFind(collectionName, query.getQueryObject(), query.getFieldsObject(), entityClass,
            new QueryCursorPreparer(query, entityClass));
}
```

最终的执行函数为：

```java
private <T> List<T> executeFindMultiInternal(CollectionCallback<DBCursor> collectionCallback, CursorPreparer preparer,
        DbObjectCallback<T> objectCallback, String collectionName) {
    try {
        DBCursor cursor = null;
        try {
            cursor = collectionCallback.doInCollection(getAndPrepareCollection(getDb(), collectionName));

            if (preparer != null) {
                cursor = preparer.prepare(cursor);
            }

            List<T> result = new ArrayList<T>();

            while (cursor.hasNext()) {
                DBObject object = cursor.next();
                result.add(objectCallback.doWith(object));
            }

            return result;
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
    } catch (RuntimeException e) {
        throw potentiallyConvertRuntimeException(e, exceptionTranslator);
    }
}
```

`MongoTemplate#find`的内部实现也是使用`DBCursor`实现的。在内部遍历获取结果，放入ArrayList后返回。意味着用这个方法，会比直接使用`DBCursor`多了一次拷贝，而且因为ArrayList本身的增长还涉及到多次大的拷贝。

目前关于这两种方法的性能差异的推测为：
1. `DBCollection#find`的逻辑简单，直接查询，获取`DBCursor`返回
2. `MongoTemplate#find`有很多逻辑，查询得到`DBCursor`后，内部遍历，将结果放入ArrayList返回。这个遍历返回的过程也花了一定的时间（包含ArrayList扩容的时间）
3. `DBCollection#find`只需要进行一次查询，剩下的过程都是迭代这个查询得到的Cursor，而`MongoTemplate#find`需要进行很多次查询，目前推测查询比迭代光标耗时很多。

目前实验来看`MongoTemplate#find`便于平时业务逻辑使用，因为直接返回的可用的List，而且是Bean转换好的。

`DBCollection#find`则有更高的性能。

## `DBCursor#next`对应一个网络请求吗

`DBCursor`使用next获取下一条数据，那每次调用next都是网络请求MongoDB获取数据吗？那岂不是很慢？

`DBCursor#next`最终调用`MongoBatchCursorAdapter#next`：

```java
public T next() {
    if (!hasNext()) {
        throw new NoSuchElementException();
    }

    if (curBatch == null) {
        curBatch = batchCursor.next();
    }

    return getNextInBatch();
}

private T getNextInBatch() {
    T nextInBatch = curBatch.get(curPos);
    if (curPos < curBatch.size() - 1) {
        curPos++;
    } else {
        curBatch = null;
        curPos = 0;
    }
    return nextInBatch;
}
```

`MongoBatchCursorAdapter#next`调用`QueryBatchCursor#next`得到结果List，在从中取出一个返回。

```java
@Override
public List<T> next() {
    if (closed) {
        throw new IllegalStateException("Iterator has been closed");
    }

    if (!hasNext()) {
        throw new NoSuchElementException();
    }

    List<T> retVal = nextBatch;
    nextBatch = null;
    return retVal;
}
```

`QueryBatchCursor#next`中没有获取逻辑，而是直接返回`nextBatch`，这个`nextBatch`是在`hasNext`时就获取的了：

```java
@Override
public boolean hasNext() {
    if (closed) {
        throw new IllegalStateException("Cursor has been closed");
    }

    if (nextBatch != null) {
        return true;
    }

    if (limitReached()) {
        return false;
    }

    while (serverCursor != null) {
        getMore(); // 获取数据
        if (nextBatch != null) {
            return true;
        }
    }

    return false;
}
```

结论是在调用`com.mongodb.DBCursor#hasNext`时，MongoDB Driver就已经获取了一批数据（断点看是100条），然后调用`com.mongodb.DBCursor#next`返回这些结果，如果这一批使用完毕，则会再去获取一批。

也就是说Cursor已经帮我们做了按批次获取的优化了，我们也就不需要自己来做这个麻烦事了。

## 多线程

PS. 还做了多线程全表扫描的对比：

```java
public void multiTheradIterTest() throws ExecutionException, InterruptedException {
    ExecutorService executorService = Executors.newFixedThreadPool(8);

    StopWatch stopWatch = new StopWatch();

    DBCollection demo = mongoTemplate.getCollection("demo");
    System.out.println(demo.count());
    int count = 0;

    stopWatch.start("multi thread cursor mode");
    String minId = "000000000000000000";
    String maxId = "ffffffffffffffffff";
    List<Future<Integer>> futureList = new ArrayList<>();
    for (int i = 0; i < 16; i++) {
        String startId = "5b175" + Integer.toHexString(i) + minId;
        String endId = "5b175" + Integer.toHexString(i) + maxId;

        Future<Integer> future = executorService.submit(new Callable<Integer>() {
            @Override
            public Integer call() throws Exception {
                int count = 0;
                DBCursor cursor = demo.find((DBObject) JSON.parse(
                        "{ \"$and\" : [ { \"_id\" : { \"$gte\" : { \"$oid\" : \""
                                + startId +
                                "\"}}} , { \"_id\" : { \"$lte\" : { \"$oid\" : \""
                                + endId +
                                "\"}}}]}"));

                while (cursor.hasNext()){
                    DBObject next = cursor.next();
                    count++;
                }

                return count;
            }
        });
        futureList.add(future);
    }
    for (Future<Integer> future : futureList) {
        Integer aCount = future.get();
        count += aCount;
    }
    System.out.println("multi thread cursor mode=" + count);
    stopWatch.stop();

    stopWatch.start("multi thread batch mode");
    count = 0;
    int limit = 1000;
    futureList = new ArrayList<>();
    for (int i = 0; i < 16; i++) {
        String startId = "5b175" + Integer.toHexString(i) + minId;
        String endId = "5b175" + Integer.toHexString(i) + maxId;


        Future<Integer> future = executorService.submit(new Callable<Integer>() {
            @Override
            public Integer call() throws Exception {
                int count = 0;
//                    System.out.println(startId + "-" + endId);
                Criteria criteria = new Criteria();
                criteria.andOperator(Criteria.where("_id").gte(new ObjectId(startId)), Criteria.where("_id").lte(new ObjectId(endId)));
                Query query = new Query(criteria).limit(limit).with(new Sort(Sort.Direction.ASC, "_id"));
                List<DBObject> ret = mongoTemplate.find(query, DBObject.class, "demo");
//                    System.out.println(query + "  " + ret.size() + "  " + Thread.currentThread().getName());
                // do
                count += ret.size();

                if (ret.isEmpty() || ret.get(ret.size() - 1).get("_id").toString().equals(endId)) {
                    System.out.println();
                    return count;
                }

                while (true) {
                    criteria = new Criteria();
                    criteria.andOperator(Criteria.where("_id").gt(ret.get(ret.size() - 1).get("_id")), Criteria.where("_id").lte(new ObjectId(endId)));
                    Query query1 = new Query(criteria).limit(limit).with(new Sort(Sort.Direction.ASC, "_id"));
                    ret = mongoTemplate.find(query1, DBObject.class, "demo");
                    // do
                    count += ret.size();
//                        System.out.println(query1 + "  " + ret.size() + "  " + Thread.currentThread().getName());

                    if (ret.isEmpty() || ret.get(ret.size() - 1).get("_id").toString().equals(endId)) {
                        return count;
                    }
                }
            }
        });
        futureList.add(future);
    }
    for (Future<Integer> future : futureList) {
        Integer aCount = future.get();
        count += aCount;
    }
    System.out.println("multi batch cursor mode=" + count);
    stopWatch.stop();

    System.out.println(stopWatch.prettyPrint());
}
```

结果：

```
-----------------------------------------
ms     %     Task name
-----------------------------------------
09287  005%  multi thread cursor mode
192853  095%  multi thread batch mode
```

遇到了几个问题：
1. 多线程的代码会更加复杂，但依然是`DBCollection#find`的方式代码简单一些
2. 多线程需要考虑如何平分查询区间到每个执行线程，这边我是通过分割ObjectId区间来做，但是遇到一个问题，ObjectId是以时间戳开头的，所以我短时间造的数据前面几位是一样的，所以并没能很好的保证每个区间的任务强度一致，也就弱化了多线程的效果
3. 不同的id格式，代码还需要做调整才能适应，更增加了实现复杂度
4. 以上的实验结果来看多线程效果不是很明显（可能是因为代码还不够完善）