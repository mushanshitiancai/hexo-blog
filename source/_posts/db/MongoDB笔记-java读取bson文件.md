---
title: MongoDB笔记-java读取bson文件
date: 2018-02-02 11:14:32
categories: MongoDB
tags: [db,mongodb]
---

BSON（Binary JSON）是一种二进制方式存储JSON的格式。MongoDB使用BSON这种结构来存储数据和网络交换。MongoDB的mongodump工具导出的数据格式也是BSON。Java要如何读取BSON文件呢？

<!--more-->

MongoDB的Java driver自带了序列化和反序列化功能。

```xml
<dependency>
    <groupId>org.mongodb</groupId>
    <artifactId>mongodb-driver</artifactId>
    <version>3.4.2</version>
</dependency>
```

使用`BSONDecoder`可以直接解析BSON流：

```java
public static void main(String[] args) throws IOException {
    File file = new File("D:\\mongo导出\\test\\xx.bson");

    BufferedInputStream inputStream = new BufferedInputStream(new FileInputStream(file));
    BSONDecoder bsonDecoder = new BasicBSONDecoder();
    int count = 0;
    while (inputStream.available() > 0) {
        BSONObject bsonObject = bsonDecoder.readObject(inputStream);
        if (bsonObject == null) break;

        System.out.println(bsonObject.get("_id"));
        count++;
    }

    System.out.println(count);
}
```

## 参考资料
- [Java read bson file](http://blog.csdn.net/mrlin6688/article/details/70213409)