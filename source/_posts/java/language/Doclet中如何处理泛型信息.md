---
title: Doclet中如何处理泛型信息
date: 2016-12-22 18:06:03
categories: [Java]
tags: [java,doclet]
---

在使用Doclet的过程中发现一个问题：无法获得泛型类型信息。为什么呢？明明模式的Doclet生成的HTML页面中，泛型信息是被正确展示的。

比如对于这样的一个字段：

```
public List<String> field;
```

获得这个字段的doc对象，并获取type，这是符合直觉的做法了：

```
Type type = field.type();
System.out.println(type);  // 输出 java.util.List
```

发现type的toString信息里面没有包含泛型信息，是显示了List类。

观察Type类，发现一个方法：`asParameterizedType`，注释说明如果这个类型是泛型类或者接口，这个方法会返回ParameterizedType，其他类型，返回null。我试了一下：

```
ParameterizedType parameterizedType = type.asParameterizedType();
System.out.println(parameterizedType);  // 输出 java.util.List
```

日了狗，怎么还是没有包含泛型信息？？？

百思不得其解，最后还是Stack Overflow给我答案：

[Doclet- Get generics of a list]: http://stackoverflow.com/questions/5731619/doclet-get-generics-of-a-list

回答指出需要在doclet类中添加：

```
/**
 * NOTE: Without this method present and returning LanguageVersion.JAVA_1_5,
 *       Javadoc will not process generics because it assumes LanguageVersion.JAVA_1_1
 * @return language version (hard coded to LanguageVersion.JAVA_1_5)
 */
public static LanguageVersion languageVersion() {
   return LanguageVersion.JAVA_1_5;
}
```

如果不指定这个回调函数，java doclet会默认使用java1.1的逻辑来处理，所以就不处理泛型信息了。

搞定。

这个LanguageVersion类竟然只有两个枚举：

```
public enum LanguageVersion {

    /** 1.1 added nested classes and interfaces. */
    JAVA_1_1,

    /** 1.5 added generic types, annotations, enums, and varArgs. */
    JAVA_1_5
}
```

不得不叹服1.5做出的改变之大，边边角角都有受到影响。

同时，大家可以到http://hg.openjdk.java.net/jdk7u/jdk7u/langtools/file/f1ffea3bd4a4/src/share/classes/com/sun，这里来下载dotlet的源码。

搜索源码发现了默认设置java1.1的地方：

```
/**
 * Return the language version supported by this doclet.
 * If the method does not exist in the doclet, assume version 1.1.
 */
public LanguageVersion languageVersion() {
    try {
        Object retVal;
        String methodName = "languageVersion";
        Class<?>[] paramTypes = new Class<?>[0];
        Object[] params = new Object[0];
        try {
            retVal = invoke(methodName, JAVA_1_1, paramTypes, params);
        } catch (DocletInvokeException exc) {
            return JAVA_1_1;
        }
        if (retVal instanceof LanguageVersion) {
            return (LanguageVersion)retVal;
        } else {
            messager.error(null, "main.must_return_languageversion",
                           docletClassName, methodName);
            return JAVA_1_1;
        }
    } catch (NoClassDefFoundError ex) { // for boostrapping, no Enum class.
        return null;
    }
}
```

doclet是通过反射来调用languageVersion这个方法。如果没有指定就设置为1.1。搞不懂为什么不弄一个doclet接口，第一需要实现的方法，搞得这么玄虚。

同时发现一个类：`AbstractDoclet`，实现了一部分方法了，比如返回1.5的languageVersion。所以我们直接继承这个类就行了。

[Doclet- Get generics of a list]: http://stackoverflow.com/questions/5731619/doclet-get-generics-of-a-list