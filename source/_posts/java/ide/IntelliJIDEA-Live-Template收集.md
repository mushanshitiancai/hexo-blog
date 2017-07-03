---
title: IntelliJIDEA Live Template收集
date: 2017-06-26 12:00:00
categories: [Java]
tags: [java,idea]
---

IntelliJIDEA的Live Template是一套非常强大的代码自动生成系统，合理使用会大大提升编码速度。这里记录一下我平时使用到的Live Template。

<!-- more -->

## 生成logger

IDEA默认提供了log相关的自动生成：

- logd 打印debug日志
- loge 打印error日志
- logi 打印info日志
- logt 打印trace日志
- logw 打印warning日志

但是没有提供声明logger变量的模板，所以我们可以添加一个：

模板缩写： `logger`

模板类容：

```
public static final org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger($CLASS$.class);
```

模板变量：

- `CLASS`： `className()`

## 打印方法错误日志

复制默认的`loge`，然后做一下修改：

模板缩写： `logme`

模板类容：

```
$LOGGER$.$LOGMETHOD$"$LOGID$$METHOD$ error$END$", $THROWABLE$);
```

模板变量：

- `METHOD`： `methodName()`