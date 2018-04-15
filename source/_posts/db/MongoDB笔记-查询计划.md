---
title: MongoDB笔记-查询计划
date: 2018-04-15 17:16:38
categories: MongoDB
tags: [db,mongodb]
---

MongoDB在进行查询时，会分析查询语句，得出可能的查询计划。

<!-- more -->

这里的查询计划就是各种可能的具体查询方法，比如对于{name:1,age:1}的查询，可能是用{name:1}这个索引进行查询，或者是用{age:1}这个索引进行查询，这些查询步骤就被称为查询计划。

如果一个索引能够精确匹配这个查询，那么查询优化器就会直接使用这个查询计划，并且不做缓存。

比如对于{name:1,age:1}的查询，有一个{name:1,age:1}的索引，那么查询优化器就直接使用这个索引，不会有别的逻辑。

如果一个查询有多个查询计划，则查询优化器会并发执行这些查询计划，从中选择最高效的查询，缓存该查询计划。之后与此查询一样格式的查询（Query Shape一样），都会尝试使用这个查询计划。

这里说一下Query Shape：查询语句中query，sort，projection的格式定义。比如{age:1}和{age:2}的Query Shape是一样的。这样我们就可以对Query Shape进行处理，从而覆盖到很多查询语句。

更详细的查询步骤为：

1. 判断Plan Cache中是否有对应Query Shape的查询计划缓存
2. 如果没有缓存，则分析查询语句与全部的索引，得出所有可能的查询计划，然后并发执行查询计划，得到最优的查询计划。缓存最优查询计划到Plan Cache中，然后执行该查询计划得到结果。
3. 如果有缓存，则触发replanning机制，就是判断这个缓存的查询计划性能是否可以，如果可以的话执行这个查询计划得到结果。如果这个查询计划被认为性能不佳，则会从Plan Cache中清除掉，然后走没有命中查询计划缓存的步骤。

这个步骤的流程图如下：

![](https://docs.mongodb.com/manual/_images/query-planner-diagram.bakedsvg.svg)

## 清空Plan Cache

新建索引，或者drop集合都会清空Plan Cache。

重启MongoDB也会清空Plan Cache。

MongoDB2.6提供了操作Plan Cache的方法。

使用`PlanCache.clear()`可以清空Plan Cache。

使用`PlanCache.clearPlansByQuery()`可以清除某个Query Shape的Plan Cache。

## PlanCache对象

MongoDB2.6提供了操作Plan Cache的方法。

`db.collection.getPlanCache()`：获取集合的Plan Cache对象，可以进行进一步操作。
`PlanCache.clear()`：清空Plan Cache。
`PlanCache.clearPlansByQuery()`：清除某个Query Shape的Plan Cache。
`PlanCache.getPlansByQuery()`：获取某个Query Shape的执行计划缓存。
`PlanCache.listQueryShapes()`：获取缓存的Query Shape。

## IndexFilter

IndexFilter用于指定查询优化器对于特定Query Shape如何使用索引。IndexFilter只提供了索引供查询优化器分析，查询优化器最终还是根据分析与执行结果来决定用哪个执行计划。

如果对应的Query Shape有指定IndexFilter，则查询的hint会被无视。

IndexFilter可以通过命令移除，也将在实例重启后清空。

[MongoDB干货系列2-MongoDB执行计划分析详解（2）](http://www.mongoing.com/eshu_explain2)

## 实验

新建user集合，并插入数据：

```js
db.user.createIndex({name:1})
db.user.createIndex({age:1})

db.user.insert({ 
    "name" : "mushan", 
    "age" : 18, 
})
```

执行`db.user.find({name:1,age:1}).explain()`，看一下查询优化器都分析出了哪些查询计划：

```json
{ 
    "queryPlanner" : {
        "winningPlan" : {
            "stage" : "FETCH", 
            "filter" : {
                "age" : {
                    "$eq" : 1
                }
            }, 
            "inputStage" : {
                "stage" : "IXSCAN", 
                "indexName" : "name_1", 
            }
        }, 
        "rejectedPlans" : [
            {
                "stage" : "FETCH", 
                "filter" : {
                    "name" : {
                        "$eq" : 1
                    }
                }, 
                "inputStage" : {
                    "stage" : "IXSCAN", 
                    "indexName" : "age_1", 
                }
            }, 
            {
                "stage" : "FETCH", 
                "inputStage" : {
                    "stage" : "AND_SORTED", 
                    "inputStages" : [
                        {
                            "stage" : "IXSCAN", 
                            "indexName" : "name_1", 
                        }, 
                        {
                            "stage" : "IXSCAN", 
                            "indexName" : "age_1", 
                        }
                    ]
                }
            }
        ]
    }
}
```

可以看到，一共有三个查询计划：

1. 使用`name_1`索引
2. 使用`age_1`索引
3. 使用`age_1`和`name_1`索引结合`AND_SORTED`

对于MongoDB来说，他也没办法知道到底哪种方式是最快的，所以他就同时执行这三个查询计划，最终胜利的是使用`name_1`的查询计划。（这个例子中，使用`name_1`索引和使用`age_1`索引速度应该是一样的，这种情况下MongoDB就随便选一个了（具体的规则要看代码了））

按照上面的说明，对于这种有多个查询计划的语句，查询优化器会缓存最优查询计划，所以这里应该是缓存了使用`name_1`的查询计划，我们来查询看看。

执行`db.user.getPlanCache().listQueryShapes()`会发现为空，这是因为`explain()`不会去缓存查询计划。所以我们需要执行一下真实的查询：`db.user.find({name:1,age:1})`，然后执行`db.user.getPlanCache().listQueryShapes()`，得到结果：

```json
[
    {
        "query" : {
            "name" : 1, 
            "age" : 1
        }, 
        "sort" : {

        }, 
        "projection" : {

        }
    }
]
```

可以看到这个查询作已经被作为一个Query Shape缓存下来了。

然后我们执行`db.user.getPlanCache().getPlansByQuery({name:2,age:10})`来看看Plan Cache是如何这个查询的查询计划的：

```json
[
    {
        "details" : {
            "solution" : "(index-tagged expression tree: tree=Node\n---Leaf \n---Leaf { name: 1.0 }, pos: 0\n)"
        }, 
        "reason" : {
            "score" : 1.0003000000000002, 
            "stats" : {
                "stage" : "FETCH", 
                "filter" : {
                    "age" : {
                        "$eq" : 1
                    }
                }, 
                "inputStage" : {
                    "stage" : "IXSCAN", 
                    "indexName" : "name_1", 
                }
            }
        }
    }, 
    {
        "details" : {
            "solution" : "(index-tagged expression tree: tree=Node\n---Leaf { age: 1.0 }, pos: 0\n---Leaf \n)"
        }, 
        "reason" : {
            "score" : 1.0003000000000002, 
            "stats" : {
                "stage" : "FETCH", 
                "filter" : {
                    "name" : {
                        "$eq" : 1
                    }
                }, 
                "inputStage" : {
                    "stage" : "IXSCAN", 
                    "indexName" : "age_1", 
                }
            }
        }
    }, 
    {
        "details" : {
            "solution" : "(index-tagged expression tree: tree=Node\n---Leaf { age: 1.0 }, pos: 0\n---Leaf { name: 1.0 }, pos: 0\n)"
        }, 
        "reason" : {
            "score" : 1.0002, 
            "stats" : {
                "stage" : "FETCH", 
                "inputStage" : {
                    "stage" : "AND_SORTED", 
                    "inputStages" : [
                        {
                            "stage" : "IXSCAN", 
                            "indexName" : "name_1", 
                        }, 
                        {
                            "stage" : "IXSCAN", 
                            "indexName" : "age_1", 
                        }
                    ]
                }
            }
        }
    }
]
```

上面对输出进行了一些简化，可以看到，缓存中保存了全部的查询计划，但是根据得分进行了排序。从这里我们也可以看出使用`age_1`索引的查询计划于使用`name_1`索引的查询计划得分是一样的。

MongoDB查询优化器根据这个缓存结果，按照上文说的流程来进行replanning机制。

## 参考资料
- [Query Plans — MongoDB Manual 3.6](https://docs.mongodb.com/manual/core/query-plans/)
- [MongoDB干货系列2-MongoDB执行计划分析详解（1） | MongoDB中文社区](http://www.mongoing.com/eshu_explain1)
- [MongoDB干货系列2-MongoDB执行计划分析详解（2） | MongoDB中文社区](http://www.mongoing.com/eshu_explain2)
- [MongoDB索引-查询优化器 - CSDN博客](https://blog.csdn.net/wentyoon/article/details/78853962)