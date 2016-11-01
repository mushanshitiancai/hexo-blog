---
title: mongodb建立索引的dropDups参数的注意事项
date: 2016-11-01 17:45:37
categories:
tags: [db,mongodb]
---

在项目中看到了类似如下的代码段：

```
@Entity
@Indexes({
    @Index(fields = {@Field("name")},options = @IndexOptions(unique = true,dropDups = true))
})
public class UniqueEntity {
    @Id
    ObjectId id;

    @Property
    String name;
}
```

这里的`unique`属性可以理解，是建立唯一索引，那`dropDups`这个属性呢？

查看其代码：

```
/**
 * Tells the unique index to drop duplicates silently when creating; only the first will be kept
 */
boolean dropDups() default false;
```

结合[Create a Unique Index — MongoDB Manual 2.6][Create a Unique Index — MongoDB Manual 2.6]文档可以知道，在建立索引时，如果现有的数据有不符合唯一索引的，如果只指定`unique`属性，则会提示建立索引失败，而如果还额外指定了`dropDups`属性，则会只会保留第一条数据，其他的不符合唯一索引的数据都会被删除。

但是我在实验的时候，发现无论是否指定`dropDups`，都会提示建立索引失败，这是为什么？

参考：
- [Unique Indexes — MongoDB Manual 3.4][Unique Indexes — MongoDB Manual 3.4]
- [mongodb - mongo 3 duplicates on unique index - dropDups - Stack Overflow][mongodb - mongo 3 duplicates on unique index - dropDups - Stack Overflow]

原来在Mongo 2.7.5之后，`dropDups`字段就已经不建议使用了，所以如果你想要在一个已经有不符合你要建立的唯一索引的集合上创建索引，需要自己额外处理了。

## 参考资料
- [Create a Unique Index — MongoDB Manual 2.6][Create a Unique Index — MongoDB Manual 2.6]
- [Unique Indexes — MongoDB Manual 3.4][Unique Indexes — MongoDB Manual 3.4]
- [mongodb - mongo 3 duplicates on unique index - dropDups - Stack Overflow][mongodb - mongo 3 duplicates on unique index - dropDups - Stack Overflow]


[Create a Unique Index — MongoDB Manual 2.6]: https://docs.mongodb.com/v2.6/tutorial/create-a-unique-index/
[Unique Indexes — MongoDB Manual 3.4]: https://docs.mongodb.com/master/core/index-unique/
[mongodb - mongo 3 duplicates on unique index - dropDups - Stack Overflow]: http://stackoverflow.com/questions/30187688/mongo-3-duplicates-on-unique-index-dropdups