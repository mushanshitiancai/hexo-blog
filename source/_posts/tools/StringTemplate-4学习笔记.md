---
title: StringTemplate 4学习笔记
date: 2016-09-02 12:06:52
categories:
tags: [tools,java]
---

StringTemplate是一个模板引擎。模板引擎现在有很多，比如FreeMarker，比如velocity。ST有啥特别的呢？这就不提ST的兄弟项目Antlr了。Antlr是ANother Tool for Language Recognition的缩写，意思是另一个语法分析器。Antlr被大量用来开发DSL或者是分析现有语言。而作为ST的兄弟项目的ST，他的应用领域和Antlr一样，专注于语言分析之后的代码/文档生成。相较于普通的后端模板引擎，ST更加强大，也更加复杂一些。

## Hello World
让我们来写一个简单的例子来体验ST的功能：

添加依赖：

```
<dependency>
    <groupId>org.antlr</groupId>
    <artifactId>ST4</artifactId>
    <version>4.0.8</version>
</dependency>
```

编写例子：

```
public class Hello {
    public static void main(String[] args) {
        ST hello = new ST("Hello <name>");
        hello.add("name","World");
        System.out.println(hello.render());
    }
}
```

输出：

```
Hello World
```

## StringTemplate的基本语法
StringTemplate是基于MVC思想设计的。其中View是使用ST语法编写的模板，Model是Antlr解析语法后的数据或者是其他的自定义数据，Controller就是ST类，他吧数据传递给模板，并可以渲染输出。

本质上，ST的语法很简单，分为两个部分：文本和属性表达式(attribute expressions)。文本部分会被原样输出。属性表达式会被求值后输出。默认属性表达式使用尖括号包围，当然这个是可以自定义的，比如如果你要生成HTML代码，用尖括号就非常麻烦了，可以改用`%`。比如上面的例子中的模板：

```
Hello, <name>
```

这里有一个属性表达式，`<name>`，通过`.add("name","World")`设置属性的值后，`<name>`就被替换为了`World`，所以合起来的输出是`Hello World`。

## 模板组（Groups of templates）
在说更多的ST语法之前，先说说ST的模板组。代码生成是具有复杂逻辑的，一般不会在一个模板中搞定，而是分解为多个小的模板，然后拼装起来。就算是网页模板引擎，也会支持引入子模板这样的功能。ST的模板更加强大，可以有输入参数，写起来和编程语言很类似。一个模板组里可以定义多个模板，只有在同一个模板组里的模板才可以互相调用。

看代码：

```
STGroup stGroup = new STGroup();
stGroup.defineTemplate("thing","name","<name>");
stGroup.defineTemplate("say","name","Hello <thing(name)>");
ST st = stGroup.getInstanceOf("say");
st.add("name","World");
System.out.println(st.render());
```

定义了一个模板组stGroup，其中定义了两个模板。defineTemplate需要三个参数，分别是模板名称，模板参数，模板内容。代码中我们定义了两个模板，say和thing。这两个模板都需要一个name参数，并且say模板调用了thing模板。

然后我们拿到say模板的实例，传入参数，并渲染，得到输出`Hello World`。

## 从文件中读入模板组
在代码中定义模板真是很费劲的，所以一般都是把模板定义在文件中，在代码中载入：

```
// file /tmp/test.stg
decl(type, name, value) ::= "<type> <name><init(value)>;"
init(v) ::= "<if(v)> = <v><endif>"
```

stg是模板组文件，其中可以定义多个模板，每个模板的格式是：`模板名称(模板参数) ::= "模板内容"`

如果模板的内容有多行，可以这么写：

```
message(message) ::= <<
line1
line2
>>
```

在代码中载入模板：

```
STGroup group = new STGroupFile("/tmp/test.stg");
ST st = group.getInstanceOf("decl");
st.add("type", "int");
st.add("name", "x");
st.add("value", 0);
String result = st.render(); // yields "int x = 0;"
```

## 向模板赋值
### 传递数组
可以通过ST实例向模板传递参数。

```
say(name) ::= "hello, <name>"

st.add("name", "mushan");

// 输出： hello, mushan
```

如果多次add同一个参数的值，是不会覆盖的，而是追加，也就是每个参数其实是一个数组：

```
say(name) ::= "hello, <name>"

st.add("name", "mushan");
st.add("name","willing");

// 输出： hello, mushanwilling
```

我们还可以控制多个值的输出格式：

```
say(name) ::= "hello, <name;separator=\",\">"

st.add("name", "mushan");
st.add("name","willing");

// 输出： hello, mushan,willing
```

还可以使用模板来处理每一个元素：

```
say(name) ::= "hello, <name:bracket();separator=\",\">"
bracket(x) ::= "(<x>)"

st.add("name", "mushan");
st.add("name","willing");

// 输出： hello, (mushan),(willing)
```

是不是非常灵活😁。但，其实还可以很灵活，比如我们这里定义了一个bracket模板，但其实功能很小，能不能像编程语言一样，弄个一个匿名函数呢？可以！那就是匿名模板：

```
say(name) ::= "hello, <name:{x|[<x>]};separator=\",\">"

st.add("name", "mushan");
st.add("name","willing");

// 输出： hello, [mushan],[willing]
```

### 传递对象

除了上面的例子中简单的字符串和数字外，ST还支持向模板传递自定义的类作为数据。比如我们定义一个User类：

```
public static class User {
    public int id; // template can directly access via u.id
    private String name; // template can't access this
    public User(int id, String name) { this.id = id; this.name = name; }
    public boolean isManager() { return true; } // u.manager
    public boolean hasParkingSpot() { return true; } // u.parkingSpot
    public String getName() { return name; } // u.name
    public String toString() { return id+":"+name; } // u
}
```

注释的部分就是如何在模板中访问User类实例属性的方法。属性的范围是比较简单的，方法的访问有一套映射关系，比如对于`o.p`，st会在类上尝试访问getP(), isP(), hasP()，如果都不存在，则会报错。

```
ST st = new ST("<b>$u.id$</b>: $u.name$", '$', '$');
st.add("u", new User(999, "parrt"));
String result = st.render(); // "<b>999</b>: parrt"
```

可以看到在ST模板中使用Java类是非常简单的。但是和js中直接使用json相比，Java中定义一个类，只是为了传递数据就定义一个类是非常繁琐的，还好，ST为我们提供了一种简便的方法来传递对象性质的信息：

```
introduction(person) ::= "I'm <person.name>, I'm <person.age> years old."

st = stGroupFile.getInstanceOf("introduction");
st.addAggr("person.{name,age}","mushan",18);
System.out.println(st.render());

// 输出： I'm mushan, I'm 18 years old.
```

## StringTemplate模板语
ST模板的语法很丰富，可以实现复杂逻辑，以处理复杂的代码生成需求。上面我提到的语法是最常用的语法，全面的模板语法可以参考[stringtemplate4/cheatsheet.md][stringtemplate4/cheatsheet.md]

## 参考资料
- [stringtemplate4/java.md at master · antlr/stringtemplate4](https://github.com/antlr/stringtemplate4/blob/master/doc/java.md)
- [StringTemplate学习笔记(一) 简介 - - ITeye技术网站](http://orange5458.iteye.com/blog/1154339)

[stringtemplate4/cheatsheet.md]: https://github.com/antlr/stringtemplate4/blob/master/doc/cheatsheet.md
