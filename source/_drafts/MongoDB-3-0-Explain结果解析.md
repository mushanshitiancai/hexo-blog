---
title: MongoDB笔记-MongoDB 3.0+ Explain结果解析
date: 2017-06-26 09:59:40
categories: MongoDB
tags: [db,mongodb]
---

和传统SQL数据库一样，MongoDB提供了分析查询语句执行情况的命令，`db.collection.explain()`方法，`cursor.explain()`方法和`explain`命令，这三个方式都可以用来分析查询。

<!-- more -->

```js
db.task.find({_id:"51a8f322-fa50-4421-8b7f-ae728e07b194", "progress" : 0}).explain(true)
```

```json
{
	"queryPlanner" : {  // 查询优化器在选择查询计划时的详细信息
		"plannerVersion" : 1, 
		"namespace" : "local.task", // 查询的数据库和集合名称
		"indexFilterSet" : false,
		"parsedQuery" : { // 规整后的查询
			"$and" : [
				{
					"_id" : {
						"$eq" : "51a8f322-fa50-4421-8b7f-ae728e07b194"
					}
				},
				{
					"progress" : {
						"$eq" : 0
					}
				}
			]
		},
		"winningPlan" : { // 最优的执行计划
			"stage" : "FETCH", // 执行计划的stage，这里是FETCH，表示通过子stage返回的索引去检索具体的文档
			"filter" : { // FETCH stage特有参数，表示过滤条件
				"progress" : {
					"$eq" : 0
				}
			},
			"inputStage" : {
				"stage" : "IXSCAN", // IXSCAN索引查询
				"keyPattern" : { // 命中的索引内容
					"_id" : 1
				},
				"indexName" : "_id_", // 命中的索引名称
				"isMultiKey" : false, // 如果索引建立在array上，此处将是true
				"multiKeyPaths" : {
					"_id" : [ ]
				},
				"isUnique" : true, // 是否是唯一索引
				"isSparse" : false,
				"isPartial" : false,
				"indexVersion" : 1,
				"direction" : "forward", // 查询语句在索引上查询的方向
				"indexBounds" : { // 索引查询的区间，这里指定值，所以区间的最大值和最小值都是这个值
					"_id" : [
						"[\"51a8f322-fa50-4421-8b7f-ae728e07b194\", \"51a8f322-fa50-4421-8b7f-ae728e07b194\"]"
					]
				}
			}
		},
		"rejectedPlans" : [ ] // 被PK掉的非最优执行计划
	},
	"executionStats" : { // 详细的执行信息
		"executionSuccess" : true, // 是否执行成功
		"nReturned" : 1, // 返回的结果条数
		"executionTimeMillis" : 0, // 整体执行时间
		"totalKeysExamined" : 1, // 索引扫描次数
		"totalDocsExamined" : 1, // document扫描次数
		"executionStages" : { // 具体的执行步骤
			"stage" : "FETCH", // 步骤类型-根据索引扫描文档
			"filter" : {
				"progress" : {
					"$eq" : 0
				}
			},
			"nReturned" : 1, // 返回的结果条数
			"executionTimeMillisEstimate" : 0,
			"works" : 2, // 操作单元次数。因为走到结束分支也算一次，所以是多一次
			"advanced" : 1, // 返回的中间结果条数
			"needTime" : 0,
			"needYield" : 0,
			"saveState" : 0,
			"restoreState" : 0,
			"isEOF" : 1, // 是否结束
			"invalidates" : 0,
			"docsExamined" : 1, // 文档扫描次数
			"alreadyHasObj" : 0,
			"inputStage" : {
				"stage" : "IXSCAN", // 步骤类型-索引扫描
				"nReturned" : 1,
				"executionTimeMillisEstimate" : 0,
				"works" : 2,
				"advanced" : 1,
				"needTime" : 0,
				"needYield" : 0,
				"saveState" : 0,
				"restoreState" : 0,
				"isEOF" : 1,
				"invalidates" : 0,
				"keyPattern" : {
					"_id" : 1
				},
				"indexName" : "_id_",
				"isMultiKey" : false,
				"multiKeyPaths" : {
					"_id" : [ ]
				},
				"isUnique" : true,
				"isSparse" : false,
				"isPartial" : false,
				"indexVersion" : 1,
				"direction" : "forward",
				"indexBounds" : {
					"_id" : [
						"[\"51a8f322-fa50-4421-8b7f-ae728e07b194\", \"51a8f322-fa50-4421-8b7f-ae728e07b194\"]"
					]
				},
				"keysExamined" : 1,
				"seeks" : 1,
				"dupsTested" : 0,
				"dupsDropped" : 0,
				"seenInvalidated" : 0
			}
		},
		"allPlansExecution" : [ ]
	},
	"serverInfo" : {
		"host" : "20170228",
		"port" : 27017,
		"version" : "3.4.4",
		"gitVersion" : "888390515874a9debd1b6c5d36559ca86b44babd"
	},
	"ok" : 1
}
```

好的文章：

- [MongoDB干货系列2-MongoDB执行计划分析详解（1）](http://www.mongoing.com/eshu_explain1)
- [MongoDB干货系列2-MongoDB执行计划分析详解（2）](http://www.mongoing.com/eshu_explain2)
- [MongoDB干货系列2-MongoDB执行计划分析详解（3）](http://www.mongoing.com/eshu_explain3)

## 例子

[mongodb调优那些事（二）-索引](http://blog.csdn.net/zxmsdyz/article/details/50925402)

## 参考资料
- [Explain Results — MongoDB Manual 3.6](https://docs.mongodb.com/manual/reference/explain-results/)
- [Mongodb 3.0+ explain输出参数解析 - 梁阳波的个人空间](https://my.oschina.net/foreverhui/blog/639240?p={{totalPage}})
- [MongoDB性能篇 － 索引,explain执行计划,优化器profile,性能监控mongosniff - 胡杰的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/huwei2003/article/details/47256295)
- [mongodb索引讲解与性能调优_百度文库](https://wenku.baidu.com/view/c54a663067ec102de2bd891e.html)