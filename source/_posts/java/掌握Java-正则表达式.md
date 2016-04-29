---
title: 掌握Java-正则表达式
date: 2016-04-28 17:35:45
tags: java
---


## String中的正则表达式方法
在Java中使用正则表达式最简单的方式就是使用String类内置的一些支持正则表达式的方法。

以下函数都是jdk1.4添加的：

    public boolean matches(String regex)
    public String replaceFirst(String regex,String replacement)
    public String replaceAll(String regex,String replacement)
    public String[] split(String regex)
    public String[] split(String regex,int limit)

## CharSequence接口
接口CharSequence中CharBuff,String,StringBuffer,StringBuilder类中抽象出了字符序列的一般化定义：

```
public interface CharSequence {
    int length();
    char charAt(int index);
    CharSequence subSequence(int start, int end);
    public String toString();
}
```

提到这个类是因为大部分正则表达式操作接受CharSequence类型的参数。

## java.util.regex
java.util.regex包含了正则表达式相关的类。String中正则相关的函数本质上是调用这些类实现的。

### Pattern和Matcher
一个字符串表达的正则表达式需要先实例化为一个Pattern实例后，才能进行操作。然后可以使用Pattern实例来生成Matcher对象。后面包含了正则表达式所匹配的字符序列(CharSequence)信息。

生成Pattern对象，使用Pattern的工厂方法`Pattern.compile()`

然后使用Pattern对象的matcher方法获取对应输入字符序列的匹配对象Matcher。然后就可以使用Matcher提供的丰富的针对正则表达式的操作了。典型的代码是：

```
Pattern p = Pattern.compile("a*b");
Matcher m = p.matcher("aaaaab");
boolean b = m.matches();
```

Matcher上最常用的几个方法：

```
public boolean matches()
public boolean lookingAt()
public boolean find()
public boolean find(int start)
```

`matches`要求正则表达式匹配整个输入字符串。

`lookingAt`从输入字符串的开始位置匹配，如果匹配成功，就返回true。

`find`尝试去寻找输入字符串的**下一个匹配**。第一次运行find，起点是输入字符串起始位置。如果匹配成功，则匹配成功的字符的后一个字符为下一次运行find的起点位置。






Matcher是有状态的


