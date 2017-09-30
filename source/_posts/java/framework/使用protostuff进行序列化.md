---
title: 使用protostuff进行序列化
date: 2016-09-02 17:46:55
categories: [Java]
tags: [java,protocol-buffers]
---

按官方的说法，protostuff是一个序列化库，提供了向后兼容和验证的内置支持。

而我们用protostuff的原因，也就是他真正牛逼的地方在于，他可以把一个POJO序列化为多种格式：

* protobuf
* protostuff (native)
* graph (protostuff with support for cyclic references. See Serializing Object Graphs)
* json
* smile (binary json useable from the protostuff-json module)
* xml
* yaml (serialization only)
* kvp (binary uwsgi header)

只要一个POJO+protostuff就能转换为这么多格式！用过protobuf的应该知道，谷歌PB官方是不支持处理POJO的，每个语言平台都只能用protoc生成的代码来进行序列化反序列化，而protoc生成的代码非常复杂，是整合了序列化逻辑的一个类，这个类除了用来进行protobuf格式的序列化，无法用作其他用途了。而POJO我们都爱，所以我们选择了使用protobuf来把POJO序列化为protobuf格式的数据。

## 例子
写一个用protostuff进行protobuf格式的序列化的例子：

引入protostuff的依赖：

```
<dependency>
  <groupId>io.protostuff</groupId>
  <artifactId>protostuff-core</artifactId>
  <version>1.3.5</version>
</dependency>
<dependency>
  <groupId>io.protostuff</groupId>
  <artifactId>protostuff-runtime</artifactId>
  <version>1.3.5</version>
</dependency>
```

新建一个用于序列化的POJO：

```
public class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

编写序列化和反序列化例子：

```
Person p = new Person("mushan",20);

LinkedBuffer buffer = LinkedBuffer.allocate();
Schema<Person> schema = RuntimeSchema.getSchema(Person.class);

byte[] protobuf = ProtobufIOUtil.toByteArray(p, schema, buffer);

Person person = schema.newMessage();
ProtobufIOUtil.mergeFrom(protobuf,person,schema);
System.out.println(person);
```

输出：`Person{name='mushan', age='20'}`。说明反序列化成功。

## 定义字段顺序
使用过protobuf的一定知道，protobuf序列化反序列化不是依赖名称的，而是依赖字段的位置，也被成为字段的tag。默认情况下，protostuff使用字段的定义顺序作为字段的tag。但是需要注意的是，这个特性不是每种JVM都支持的。sun体系的JVM都没问题，但是比如像安卓的dalvik虚拟机，在反射的时候，获取的字段顺序就不一定是定义顺序了，所以有时候我们需要手动指定字段的tag。这时我们可以使用protostuff提供的Tag注解：

```
public final class Bar
{
  @Tag(8)
  int baz;
}
```

## protostuff生成的protobuf格式的数据能被protobuf自己生成的类解析么？
能。我只测试了简单类型。对于复杂类型会不会出现不兼容还不清楚，同时对于版本的兼容性也还不太清楚。

## 将POJO生成proto文件
这个需要使用[webbynet/protostuff-runtime-proto: Protostuff Runtime Proto Files Generator](https://github.com/webbynet/protostuff-runtime-proto)这个项目。

使用非常简单，通过RuntimeSchema得到schema后直接就可以生成proto：

```
String content = Generators.newProtoGenerator(schema).generate();
System.out.println(content);
```

## 参考资料
- [protostuff/protostuff: Java serialization library, proto compiler, code generator](https://github.com/protostuff/protostuff)
- [protostuff](http://www.protostuff.io/)
- [Protostuff详解 - chszs的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/chszs/article/details/50457206)


