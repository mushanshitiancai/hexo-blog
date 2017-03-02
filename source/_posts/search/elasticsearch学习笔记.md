---
title: Elasticsearch学习笔记
date: 2017-02-28 17:04:13
categories:
tags: [elasticsearch]
---

## 安装

安装Elasticsearch

1. 下载[Download Elasticsearch Free • Get Started Now | Elastic](https://www.elastic.co/downloads/elasticsearch)
2. 解压
3. 启动 `bin/elasticsearch`
4. 访问 `curl http://localhost:9200/`

安装Kibana

1. 下载[Download Kibana Free • Get Started Now | Elastic](https://www.elastic.co/downloads/kibana)
2. 解压

安装X-Pack

1. 安装X-Pack到Elasticsearch `bin/elasticsearch-plugin install x-pack`
2. 启动Elasticsearch `bin/elasticsearch`
3. 安装X-Pack到Kibana `bin/kibana-plugin install x-pack`
4. 启动Kibana `bin/kibana`
5. 访问Kibana `http://localhost:5601/`， 使用默认账号登录`elastic:changeme`

安装了X-Pack后，访问ES都是需要验证身份的，默认账号密码是`elastic:changeme`，所以在CURL访问ES中，需要加上`--user`参数：

```
curl --user elastic:changeme -XPUT 'localhost:9200/idx'
```

参考：[HTTP/REST Clients and Security | X-Pack for the Elastic Stack [5.2] | Elastic](https://www.elastic.co/guide/en/x-pack/current/http-clients.html)


## 概念

Elasticsearch和MongoDB类似，都是面向文档的。Elasticsearch可以对文档进行索引，搜索，排序，过滤操作。

Elasticsearch有自己专用的术语，Indices索引，Types类型，Documents文档，Fields字段。和传统关系型数据库的术语对应起来就很好理解了：

```
Relational DB -> Databases -> Tables -> Rows -> Columns
Elasticsearch -> Indices   -> Types  -> Documents -> Fields
```

这里比较难理解的是索引。因为在ES中他有三个含义：

- 索引（名词），这里索引指的是文档存储的地方，类似关系型数据库中的Database
- 索引（动词），索引一个文档，指的是把文档存储到索引（名词）中
- 倒排索引，这个就是关系型数据库中索引的意思，指的是使用一种数据结构来加速搜索。在关系型数据库中使用的是B-Tree。在ES中使用的是倒排索引。

## Quick Start


## Java API

```xml
<dependency>
    <groupId>org.elasticsearch.client</groupId>
    <artifactId>transport</artifactId>
    <version>5.1.2</version>
</dependency>
```

ES默认使用Log4j，可以使用SLF4J bridge桥接到兼容slf4j的日志组件。

```xml
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-to-slf4j</artifactId>
    <version>2.7</version>
</dependency>
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
    <version>1.7.21</version>
</dependency>

<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-simple</artifactId>
    <version>1.7.21</version>
</dependency>
```

Java中使用Client与ES交互。最简单的一个Client类是TransportClient。


因为安转了X-Pack，所以Java连接也需要提供身份认证。

[在 Java 应用程序中使用 Elasticsearch](http://www.ibm.com/developerworks/cn/java/j-use-elasticsearch-java-apps/)


## X-Pack
- [Installing X-Pack | X-Pack for the Elastic Stack [5.2] | Elastic](https://www.elastic.co/guide/en/x-pack/current/installing-xpack.html)

## 参考资料
- [入门 | Elasticsearch权威指南（中文版）](https://es.xiaoleilu.com/010_Intro/00_README.html)
- [编程实践7—升级 Elasticsearch5.0 之x-pack - abcd_d_的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/abcd_d_/article/details/53178297)