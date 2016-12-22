---
title: mvn package的两条重要结论
date: 2016-12-02 15:15:24
categories: [Java]
tags: [java,maven]
---

先说结论：

1. package如果会打包进所依赖的jar的话(比如war)，遵循maven的依赖调解规则来确定最终打包的依赖的版本
2. 如果在执行package之前，没有执行clean，那么会增量添加依赖

<!-- more -->

还有一则重要提醒：

- 一定要注意groupId发生迁移的项目，因为迁移前后的maven坐标不一样，不会算冲突，但是本质上却是一个项目，很容易引发问题。