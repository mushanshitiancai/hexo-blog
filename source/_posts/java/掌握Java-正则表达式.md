---
title: 掌握Java-正则表达式
date: 2016-04-28 17:35:45
tags: java
---

正则表达式在处理字符串的时候非常有用。虽然Java加入正则表达式的支持比较晚（1.4才支持），但是经过几个版本的发展，现在Java对于正则的支持已经非常完善了。我们来学学怎么在Java中使用正则表达式。

<!-- more -->

以下的方法，如果没有特别说明，就是1.4加入的。为什么要重视版本呢？我觉得这样可以跟踪jdk的发展，知道哪些方法是之后加入的，也就能感受到设计者的思路了。

## String类
正则表达式的主要功能有查找（匹配），替换，分割，无论是哪个功能，都是用来处理字符串的。所以在String类上使用正则表达式是理所当然的。

String类上支持正则操作的方法有：

```
public boolean matches(String regex)
public String replaceFirst(String regex,String replacement)
public String replaceAll(String regex,String replacement)
public String[] split(String regex)
public String[] split(String regex,int limit)
```

**boolean matches(String regex)**

判断正则表达式是否匹配**整个**字符串。

**String replaceFirst(String regex,String replacement)**
**String replaceAll(String regex,String replacement)**

替换正则表达式匹配的字符串为replacement参数指定的字符串。`replaceFirst`替换**第一个**匹配的字符串。`replaceAll`替换字符串中**所有**匹配的字符串。

**String[] split(String regex)**
**String[] split(String regex,int limit)**

根据正则表达式对目标字符串进行分割。需要注意的是有limit参数的这个重载版本（见下文详解）。

这些方法涵盖了匹配，替换，分割。基本满足了日常的使用。

String类中的正则方法，本质上是Pattern或者Matcher类相同方法的代理。是为了方便使用而封装的。如果你在使用String的正则方法时，遇到了如下问题：

- 功能不全。比如查找只有一个`matches`方法，只能整个匹配，如果想部分匹配就做不到了
- 正则表达式不能复用。每次使用这些正则方法，传入的都是正则字符串，在内部实例化为Pattern对象，下次使用还得再来一把，Pattern对象没有得到复用，效率低。

如果你遇到了这些问题，那么你可以考虑使用Java中真正的正则表达式类包`java.util.regex`中的类。

## java.util.regex
java.util.regex包是java1.4加入的正则表达式实现的包。这个包里主要的类有：

- Pattern
- Matcher
- MatchResult
- PatternSyntaxException

接下来来说说这些类的使用。

### Pattern
Pattern是java.util.regex中的核心类。她代表着一个正则表达式。对于正则操作来说，你首先需要一个正则对象，也就是Pattern，然后你就可以使用她来进行查找，替换，分割。

Pattern的构造函数是私有的，所以新建Pattern的方法是使用它的工厂函数：

```
public static Pattern compile(String regex)
public static Pattern compile(String regex, int flags)
```

compile函数通过一个正则字符串来新建Pattern类。他的一个重载版本支持flags参数，来设置正则表达式的一些属性，这个我们后面再细说。

我们来看看Pattern的实例方法：

```
public String pattern()
public int flags()
public String[] split(CharSequence input)
public String[] split(CharSequence input, int limit)
public Matcher matcher(CharSequence input)
```

**public String pattern()**
**public int flags()**

返回生成Pattern的正则表达式字符串和标志位。

**public String[] split(CharSequence input)**
**public String[] split(CharSequence input, int limit)**

根据正则分割字符串。String中的split引用的就是这个方法。我们来说说limit的参数的作用：

limit参数控制split对目标字符串进行几次(limit-1次)分割，最后得到limit个子串。

比如limit=2，那么split对字符串进行2-1=1次分割，得到2个子串。

注意一点，假设正则是"o",字符串`"o1oo"`理想情况下会被分割为`"","1","",""`，也就是**匹配与字符串的开头与结尾见认为有一个空字符串，两个相邻的匹配间，也认为有一个空字符串。**

再注意一点，目标字符串被正则分割的最多子串个数是固定的(假设为N)，所以limit如果大于这个固定数目后，作用等于N。

再再注意一点，limit可以取三类值：

- 正数

    安装上面说的规则，对目标字符串进行(limit-1)次分割

- 0

    对目标字符串进行尽可能多次(上文提到的N)的分割。**得到的子串，末尾的空字符串会被丢弃。**

    split(CharSequence input)相当于split(CharSequence input, 0)

- 负数

    数字大小无所谓

    对目标字符串进行尽可能多次(上文提到的N)的分割。**得到的子串，末尾的空字符串会保留。**

这里引用JavaDoc中的例子，目标字符串是"boo:and:foo"，看看limit在各种取值下的表现：

```
Regex       Limit       Result    
:           2           { "boo", "and:foo" }
:           5           { "boo", "and", "foo" }
:           -2          { "boo", "and", "foo" }
o           5           { "b", "", ":and:f", "", "" }
o           -2          { "b", "", ":and:f", "", "" }
o           0           { "b", "", ":and:f" }
```

**public Matcher matcher(CharSequence input)**

细心的你可能已经发现了，Pattern对象的实例方法，



