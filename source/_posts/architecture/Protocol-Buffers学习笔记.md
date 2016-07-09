---
title: Protocol Buffers学习笔记
date: 2016-07-05 22:14:59
categories:
tags: architecture
---

公司使用Protocol Buffers（下文简称PB）作为RPC架构的基础，所以我一直认为PB是一个RPC框架。今天面试官的反问才让我意识到，**PB不是一个RPC框架，而是一种数据格式**。PB官网对于PB是什么的描述：

> Protocol buffers are Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data – think XML, but smaller, faster, and simpler. You define how you want your data to be structured once, then you can use special generated source code to easily write and read your structured data to and from a variety of data streams and using a variety of languages.

> Protocol buffers是谷歌的语言无关的，平台无关的，可扩展的用于序列化结构数据的机制。像XML，但是更小，更快，更简单。你只要按照你的需求定义数据格式一次，然后你可以用生成的特殊代码，用不同语言，从不同的数据流中，很容易地读写你的格式化数据。

Protocol Buffers目前支持生成Java, Python和C++的调用代码。如果使用新的proto3语言格式，还可以支持Go, JavaNano, Ruby, 和 C#。

## 安装Protocol Buffers

```
$ sudo yum install -y autoconf automake libtool curl make g++ unzip

$ git clone https://github.com/google/protobuf.git
$ cd protobuf
$ ./autogen.sh
$ ./configure
$ make
$ make check
$ sudo make install
$ sudo ldconfig # refresh shared library cache.
```

安装过程需要翻墙，大家自备梯子。

## 编写数据格式文件
PB使用`.proto`文件定义数据结构的格式。PB也是根据proto文件生成对应语言的调用代码。

```
syntax = "proto2";

package test;

message User {
    required int32 id = 1;
    required string name = 2;
    optional string email = 3;
}
```

这里我写了一个非常简单的proto定义文件。PB中，结构化数据被称为message。message中可以包含多个字段，每个字段需要指明：修饰符，数据类型，名字，tag数字。

**修饰符** 修饰符用于表示该字段是必选，可选还是可重复的。取值有：

- `required`：表示该字段是必选的
- `optional`：表示该字段是可选的
- `repeated`：表示该字段是可重复的（也可以没有）

**数据类型** PB支持多种数据格式，有double, float, int32, int64, uint32, uint64, sint32, sint64, fixed32, fixed64, sfixed32, sfixed64, bool, string, bytes。

**tag数字** PB在二进制编码字段时会使用到tag。

## 生成代码

```
protoc --java_out=../java user.proto
```

使用protoc生成Java代码。上面的proto文件生成了一个UserOuterClass类，用这个类就可以操作User这个数据结构。

## 读写Protocol Buffers数据
生成的Java代码需要依赖PB的Java包，新建maven项目，导入依赖：

```
<dependency>
    <groupId>com.google.protobuf</groupId>
    <artifactId>protobuf-java</artifactId>
    <version>3.0.0-beta-3</version>
</dependency>
```

然后我们写最简单的读写例子：

```
public class Main {

    static void writeTest(){
        UserOuterClass.User.Builder user = UserOuterClass.User.newBuilder();

        //填充user
        user.setId(100);
        user.setName("mushan");
        user.setEmail("mushanmail@126.com");

        try {
            OutputStream outputStream = new FileOutputStream(new File("temp"));
            user.build().writeTo(outputStream);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    static void readTest(){
        try {
            //从文件中读取user
            InputStream inputStream = new FileInputStream(new File("temp"));
            UserOuterClass.User user = UserOuterClass.User.parseFrom(inputStream);
            
            System.out.println(user);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    public static void main(String[] args){
        writeTest();
        readTest();
    }
}
```

输出：

```
id: 100
name: "mushan"
email: "111@111.com"
```

说明从文件中读取了序列化的信息。

## RPC
PB是一个数据格式，已经操作这种数据格式的框架。他本身是不支持RPC的，需要自己封装。如何把RPC封装成PB数据，这我还不明白。不过2015年Google开源了gPRC，是其基于PB和HTTP2设计的一个RPC框架，有机会去了解一下。

## 序列化原理
为什么PB能够做到比XML小3-10倍，比XML快20-100倍呢。可以参考[Google Protocol Buffer 的使用和原理][Google Protocol Buffer 的使用和原理]。总结如下：

- Protocol Buffers使用了Varint压缩技术。Varint使用少的字节表示小的数字，用多的字节表示打的数字。比如对于int32类型，需要固定4个字节。而使用了Varint技术后，使用1-5个字节。根据统计学，会更节省空间。
- Varint技术的原理是使用高位bit来指定使用几个字节表示数字。如果是1表示下个字节也用来表示这个数字，如果是0表示这是这个数字的最后一个byte。
- Protocol Buffers使用小端顺序
- 存放Message的区块被称为Message Buffer。Message Buffer由Field组成，每个Field由Key和Value组成。Key用来表示这个字段是对应proto文件中的哪个字段。key的定义为 `(field_number << 3) | wire_type`，field_number也就是tag数字，所以使用位移就可以确定字段，速度极快。
- 负数的最高位固定为1，所以如果使用Varint技术，会固定使用5个字节，比较浪费。PB使用ZigZag技术压缩有符号数。原理是使用正整数表示所有正负数，比如`0，-1，1，2`经过ZigZag压缩后为`0，1，2，3`。这样就可以使用Varint压缩了。

## 参考资料
- [Protocol Buffers  |  Google Developers](https://developers.google.com/protocol-buffers/)
- [google/protobuf: Protocol Buffers - Google's data interchange format](https://github.com/google/protobuf)
- [protobuf/README.md at master · google/protobuf](https://github.com/google/protobuf/blob/master/src/README.md)
- [Protocol Buffer Basics: Java  |  Protocol Buffers  |  Google Developers](https://developers.google.com/protocol-buffers/docs/javatutorial)
- [Google Protocol Buffer 的使用和原理][Google Protocol Buffer 的使用和原理]

[Google Protocol Buffer 的使用和原理]: http://www.ibm.com/developerworks/cn/linux/l-cn-gpb/