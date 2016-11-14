---
title: Fastjson的一些坑
date: 2016-11-14 14:41:17
categories: [Java]
tags: java
---

说是fastjson的坑有点哗众取宠了，应该说是使用fastjson的一些注意事项吧。

比如这样的一个实体类：

```
public class People {
    private String Name;
    private int Age;

    public People(String name, int age) {
        Name = name;
        Age = age;
    }

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public int getAge() {
        return Age;
    }

    public void setAge(int age) {
        Age = age;
    }
}
```

因为之前的协议中的json使用大写开头的字符串作为key，所以我为了兼容，把变量名也用大写开头。我的本意是以为fastjson会使用变量的名字作为key，但是实际的输出是：

```
People people = new People("mushan", 20);
String json = JSON.toJSONString(people);
System.out.println(json);

// {"age":20,"name":"mushan"}
```

**fastjson序列化后的key是小写开头的**。这是需要注意的第一点。

那我要如何做到大写开头的key呢？可以使用`JSONField`这个注解，这个注解可以指定这个属性序列化后的名字，这里指定的字符串，fastjson就不会做额外的处理了。

```
@JSONField(name = "Name")
private String Name;
@JSONField(name = "Age")
private int Age;
```

再次运行，WTF？！怎么还是`{"age":20,"name":"mushan"}`。为什么`JSONField`没有生效？

经过排查，**发现属性是大写开头的，其`JSONField`不会生效**。。。这是需要注意的第二点。

## 总结

- fastjson序列化后的key是小写开头的
- 属性是大写开头的，其`JSONField`不会生效

