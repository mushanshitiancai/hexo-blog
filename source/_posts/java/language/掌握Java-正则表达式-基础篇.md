---
title: 掌握Java-正则表达式(基础篇)
date: 2016-04-28 17:35:45
categories: [Java,掌握Java]
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

### Pattern类
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

细心的你可能已经发现了，Pattern对象的实例方法，只包含了分割的操作，那查找和替换呢？

Java正则表达式系统的设计者认为（同时也是一种正则的通用设计了），查找和替换操作有其特殊性，比如查找可能是会进行多次的，查找的过程中还可能穿插着替换操作。这一系列操作就需要有很多状态变量记录当前的查找位置等，而同一正则针对不同的字符串或者相同的字符串不同批次的操作，都有不同的状态，所以这些状态是不可以杂糅进Pattern类的。而是应该针对不同的输入字符串，新建一个对象，对其进行操作，保存其状态。这个类就是Matcher类。

Pattern通过`Matcher matcher(CharSequence input)`方法建立针对目标字符串的Matcher类，之后就可以使用Matcher类进行查找和替换的操作了。

### Matcher类
上文说过了，一个Matcher类，代表的是针对特定输入字符串的查找替换操作集合，同时还记录了查找过程中的各种状态。

Matcher类的方法比较多，我们通过不同的功能来分类说明。

#### 替换相关函数

```
public String replaceFirst(String replacement)
public String replaceAll(String replacement)
```

替换正则表达式匹配的字符串为replacement参数指定的字符串。`replaceFirst`替换**第一个**匹配的字符串。`replaceAll`替换字符串中**所有**匹配的字符串。

String类的`replaceFirst`和`replaceAll`引用的就是这两个函数。

注意：**replaceFirst和replaceAll在内部调用了reset函数（后文介绍），所以match相关的一些状态，对于这两函数无效。**

#### 查找(匹配)相关函数

```
public boolean matches()

public boolean lookingAt()

public boolean find()
public boolean find(int start)
```

**public boolean matches()**

判断正则表达式是否匹配**整个**字符串。

String类的`matches`引用的就是这个函数。

**public boolean lookingAt()**

判断正则表达式是否匹配字符串的前缀。

**public boolean find()**
**public boolean find(int start)**

最自由的匹配，也就是我们通常在文本编辑器中使用的查找。find中字符串开头向后搜索，如果匹配到一个子串就放回true。

重载版本可以通过start制定从那个字符开始查找。

需要注意的是，find是可以被多次调用的。如果find查找成功，那么匹配成功的子串的后一个字符串的位置会被记录下来，下一次find就会从这里开始搜索。

所以查找一个字符串中所有匹配的的典型代码是：

```
Pattern pattern = Pattern.compile("\\d");
Matcher matcher = pattern.matcher("a1b2c3");

while(matcher.find()){
    System.out.println("find!");
}

// 输出
find!
find!
find!
```

find只会返回是否找到，那我们怎么获得这次匹配到的子串内容呢？以及这次匹配的子串的起止位置呢？别着急，用接下来介绍的组(group)相关函数就可以获取到。

#### 组(group)相关函数
组是正则表达式中的一个概念。正则中，用括号括起来的一段子正则被称为一个组。整个正则也是一个组，是第0组。其他的组，从左往右，从1开始编号。

那么组有什么用处呢？最重要的用处就是我们可以在正则，或者匹配字符串中引用组的内容。每次查找也可以查看每个组匹配的字符串。

比如，输入一个身份证号，我们想要取出生日的字段，可以用以下代码：

```
Pattern pattern = Pattern.compile("\\d{6}((\\d{4})(\\d{2})(\\d{2}))[\\dX]{4}");
Matcher matcher = pattern.matcher("150144199305011417");

while(matcher.find()){
    System.out.println(matcher.group());  //整个身份证号
    System.out.println(matcher.group(1)); //生日
    System.out.println(matcher.group(2)); //生日-年
    System.out.println(matcher.group(3)); //生日-月
    System.out.println(matcher.group(4)); //生日-日
}

//输出
150144199305015417
19930501
1993
05
01
```

可以看到，在组这个功能的支持下，我们可以提取正则表达式所匹配的各个组的子串，很方便。group函数是组相关函数的其中一个，接下来我们来全面介绍组相关的函数。

```
public int groupCount()

public String group()
public String group(int group)

public int start()
public int start(int group)

public int end()
public int end(int group)
```

**public int groupCount()**

返回正则表达式中组的个数。不计入第0组。

**public String group()**
**public String group(int group)**

返回上一次匹配所匹配的子串。不带参数的group表示第0组，也就是整个正则所匹配的结果。

如果上一次匹配没有成功或者不存在上一次匹配，则抛出`java.lang.IllegalStateException`异常。

**public int start()**
**public int start(int group)**

返回上一次匹配所匹配的子串的起始位置。不带参数的group表示第0组，也就是整个正则所匹配的结果的起始位置。

如果上一次匹配没有成功或者不存在上一次匹配，则抛出`java.lang.IllegalStateException`异常。

**public int end()**
**public int end(int group)**

返回上一次匹配所匹配的子串的结束位置**的后一个位置**。不带参数的group表示第0组，也就是整个正则所匹配的结果的结束位置**的后一个位置**。

如果上一次匹配没有成功或者不存在上一次匹配，则抛出`java.lang.IllegalStateException`异常。

结合使用find和组相关函数，就可以实现非常复杂的查找操作。

#### 重置状态相关函数
find是会保存中间状态的，那如果我们find一半，想从头find怎么办呢？重新生成一个Matcher类？不用，可以使用Matcher的的重置相关函数，重置Matcher的状态，还可以中途切换目标字符串或者正则表达式！

```
public Matcher reset()
public Matcher reset(CharSequence input)
public Matcher usePattern(Pattern newPattern)
```

**public Matcher reset()**
**public Matcher reset(CharSequence input)**

重置Matcher的内部状态。如果指定input，则可以替换目标字符串。

**public Matcher usePattern(Pattern newPattern)**

切换正则表达式。

注意切换正则表达式会丢失上一次的匹配的组的信息，但是Matcher的状态不会丢失。

```
Pattern pattern = Pattern.compile("\\d");
Matcher matcher = pattern.matcher("a1b2c");

matcher.find();
System.out.println(matcher.group());

matcher.usePattern(Pattern.compile("[a-z]"));
System.out.println(matcher.group());

matcher.find();
System.out.println(matcher.group());

//输出
1
null
b           <- 切换正则表达式后，依然从1后面开始搜索
```


上文提到的正则表达式操作，覆盖了常用的正则表达式操作。虽然Matcher还有其他的一些函数，但是都是比较少用到的，这些将会在[掌握Java-正则表达式(进阶篇)](http://mushanshitiancai.github.io/2016/05/02/java/%E6%8E%8C%E6%8F%A1Java-%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F-%E8%BF%9B%E9%98%B6%E7%AF%87/)中提到。
