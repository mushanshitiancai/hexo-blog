---
title: Java测试-JUnit4学习笔记
date: 2016-08-01 17:52:05
categories: [Java]
tags: [java,junit]
toc: true
---

<!--more-->

## 入门
首先在项目中引入junit的依赖：

```
<dependency>
  <groupId>junit</groupId>
  <artifactId>junit</artifactId>
  <version>4.12</version>
  <scope>test</scope>
</dependency> 
```

编写业务类：

```
public class Server {
    public int add(int a, int b) {
        return a + b;
    }
}
```

编写测试类：

```
import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class DemoTest {
    @Test
    public void testAdd(){
        Server server = new Server();
        assertEquals("test add",10,server.add(8,2));
    }
}
```

然后执行`mvn clean test`：

```
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.mushan.learn.DemoTest
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.114 sec

Results :

Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
```

可以看到运行了一个测试，失败了0个测试。这就是用junit进行单元测试的整个基本流程。最后一步还可以使用IDE来执行，会更加直观。

## 丰富的断言
测试最关键的一个环节是判断逻辑是否正确，而这就是断言的用处。junit提供了许多方便我们使用的断言：

```
//判断条件是否成立
void assertTrue(String message, boolean condition)
void assertFalse(String message, boolean condition)

//判断对象是否相等，使用Object.equals判断。如果是null则直接用==判断
void assertEquals(String message, Object expected, Object actual)
void assertNotEquals(String message, Object unexpected, Object actual)

//判断整数是否相等
void assertEquals(String message, long expected, long actual)
void assertNotEquals(String message, long unexpected, long actual)

//判断浮点数是否相等，需要指定精度
void assertEquals(String message, float expected, float actual, float delta)
void assertEquals(String message, double expected, double actual, double delta)
void assertNotEquals(String message, float unexpected, float actual, float delta)
void assertNotEquals(String message, double unexpected, double actual, double delta)

//判断两个数组是否相等。会递归比较每个元素
void assertArrayEquals(String message, Object[] expecteds, Object[] actuals)
void assertArrayEquals(String message, boolean[] expecteds, boolean[] actuals)
void assertArrayEquals(String message, byte[] expecteds, byte[] actuals)
void assertArrayEquals(String message, char[] expecteds, char[] actuals)
void assertArrayEquals(String message, short[] expecteds, short[] actuals)
void assertArrayEquals(String message, int[] expecteds, int[] actuals)
void assertArrayEquals(String message, long[] expecteds, long[] actuals)
void assertArrayEquals(String message, double[] expecteds, double[] actuals, double delta)
void assertArrayEquals(String message, float[] expecteds, float[] actuals, float delta)

//判断是否为空
void assertNotNull(String message, Object object)
void assertNull(String message, Object object)

//判断两个对象是否是同一个对象（用==判断）
void assertSame(String message, Object expected, Object actual)
void assertNotSame(String message, Object unexpected, Object actual)

//高级断言
void assertThat(T actual, Matcher<? super T> matcher)
void assertThat(String reason, T actual, Matcher<? super T> matcher)
```

message参数用来指定这条断言的描述，这样在断言失败的时候，会打印这条描述。同时每个有message参数的函数都有一个没有message参数的重载版本，其内部其实都是传了一个值为null的message参数。

有了这些断言，我们可以方便的在测试函数中判断需要测试的函数的结果是否满足条件。

## 高级断言assertThat
除了基本的断言，junit提供了assertThat这个更加灵活的断言，用法和其他断言不一样，可以看看：

```
assertThat(x, is(3));
assertThat(x, is(not(4)));
assertThat(responseString, either(containsString("color")).or(containsString("colour")));
assertThat(myList, hasItem("3"));
```

大致的结构是：

```
assertThat([value], [matcher statement]);
```

可以很明显的看出来，相较于其他断言，assertThat断言有许多有点（更详细的描述见[探索 JUnit 4.4 新特性][探索 JUnit 4.4 新特性]）：

- 更加语义化。“主谓宾”的形式，符合人类思维
- 使用丰富的Matcher进行匹配，写起来更方便
- Matcher可以联合使用
- 错误信息更加丰富
- 用户可以通过实现Matcher接口，定制自己的Matcher

assertThat本来是另外一个项目（Hamcrest）的，正是因为这些优点，所以junit4.4直接把他包含到自己的代码中了。

junit包含了Hamcrest的所有核心Matcher：

```java
/******** 基本匹配符 ********/

//总是匹配成功的匹配符
static Matcher<Object>  anything() 
static Matcher<Object>  anything(String description) 

//重写现有Matcher的描述
static <T> Matcher<T> describedAs(String description, Matcher<T> matcher, Object... values) 

//判断两者是否逻辑相等(equals)的匹配符
static <T> Matcher<T> equalTo(T operand) 

/******** 针对字符串的匹配符 ********/

//判断目标是否包含子串
static Matcher<String>  containsString(String substring) 

//判断字符串已prefix为前缀
static Matcher<String>  startsWith(String prefix) 

//判断目标是否以suffix结尾
static Matcher<String>  endsWith(String suffix) 

/******** 针对类型判断的匹配符 ********/

//装饰其他匹配符，不会修改被修饰的匹配符的行为，只是使其更加语义化
static <T> Matcher<T> is(Matcher<T> matcher) 

//其实是is(equalTo(x))的缩写
static <T> Matcher<T> is(T value) 

//废弃，请使用isA(Class type)
static <T> Matcher<T> is(Class<T> type) 

//其实是is(instanceOf(SomeClass.class))的缩写
static <T> Matcher<T> isA(Class<T> type) 

//判断一个目标是null
static Matcher<Object>  nullValue() 
static <T> Matcher<T> nullValue(Class<T> type) 

//判断目标是否是一个类型的实例(Class.isInstance(Object))
static <T> Matcher<T> instanceOf(Class<?> type) 
static <T> Matcher<T> any(Class<T> type) 

//判断两个是否为同一个实例
static <T> Matcher<T> sameInstance(T target) 
static <T> Matcher<T> theInstance(T target) 

/******** 包含逻辑运算的匹配符 ********/

//对一个现有匹配符取非
static <T> Matcher<T> not(Matcher<T> matcher) 

//其实是not(equalTo(x))的简写
static <T> Matcher<T> not(T value) 

//其实是not(nullValue())的简写
static Matcher<Object>  notNullValue() 

//其实是not(nullValue(X.class))的简写
static <T> Matcher<T> notNullValue(Class<T> type) 

//所有条件都成立才通过，相当于逻辑与
static <T> Matcher<T> allOf(Iterable<Matcher<? super T>> matchers) 
static <T> Matcher<T> allOf(Matcher<? super T>... matchers) 
static <T> Matcher<T> allOf(Matcher<? super T> first, Matcher<? super T> second) 
static <T> Matcher<T> allOf(Matcher<? super T> first, Matcher<? super T> second, Matcher<? super T> third) 
static <T> Matcher<T> allOf(Matcher<? super T> first, Matcher<? super T> second, Matcher<? super T> third, Matcher<? super T> fourth) 
static <T> Matcher<T> allOf(Matcher<? super T> first, Matcher<? super T> second, Matcher<? super T> third, Matcher<? super T> fourth, Matcher<? super T> fifth) 
static <T> Matcher<T> allOf(Matcher<? super T> first, Matcher<? super T> second, Matcher<? super T> third, Matcher<? super T> fourth, Matcher<? super T> fifth, Matcher<? super T> sixth) 

//只要一个条件通过就通过，相当于逻辑或
static <T> AnyOf<T> anyOf(Iterable<Matcher<? super T>> matchers) 
static <T> AnyOf<T> anyOf(Matcher<? super T>... matchers) 
static <T> AnyOf<T> anyOf(Matcher<T> first, Matcher<? super T> second) 
static <T> AnyOf<T> anyOf(Matcher<T> first, Matcher<? super T> second, Matcher<? super T> third) 
static <T> AnyOf<T> anyOf(Matcher<T> first, Matcher<? super T> second, Matcher<? super T> third, Matcher<? super T> fourth) 
static <T> AnyOf<T> anyOf(Matcher<T> first, Matcher<? super T> second, Matcher<? super T> third, Matcher<? super T> fourth, Matcher<? super T> fifth) 
static <T> AnyOf<T> anyOf(Matcher<T> first, Matcher<? super T> second, Matcher<? super T> third, Matcher<? super T> fourth, Matcher<? super T> fifth, Matcher<? super T> sixth) 

//both语义匹配符，后面可以接and
static <LHS> CombinableMatcher.CombinableBothMatcher<LHS> both(Matcher<? super LHS> matcher) 

//either语义匹配符，后面可以接or
static <LHS> CombinableMatcher.CombinableEitherMatcher<LHS> either(Matcher<? super LHS> matcher) 
          
/******** 针对集合的匹配符 ********/

//创建一个匹配符，传入匹配符itemMatcher，只有所有的元素都匹配itemMatcher，才通过
static <U> Matcher<Iterable<U>> everyItem(Matcher<U> itemMatcher) 

//创建一个匹配符，传入匹配符itemMatcher，有一个元素都匹配itemMatcher，就通过
static <T> Matcher<Iterable<? super T>> hasItem(Matcher<? super T> itemMatcher) 

//创建一个匹配符，如果集合包含元素item，就通过
static <T> Matcher<Iterable<? super T>> hasItem(T item) 
          Creates a matcher for Iterables that only matches when a single pass over the examined Iterable yields at least one item that is equal to the specified item.

//创建一个匹配符，传入多个匹配符itemMatchers，每个itemMatcher都匹配通过，就通过
static <T> Matcher<Iterable<T>> hasItems(Matcher<? super T>... itemMatchers) 
          Creates a matcher for Iterables that matches when consecutive passes over the examined Iterable yield at least one item that is matched by the corresponding matcher from the specified itemMatchers.

//创建一个匹配符，如果集合包含所有items，就通过
static <T> Matcher<Iterable<T>> hasItems(T... items) 
          Creates a matcher for Iterables that matches when consecutive passes over the examined Iterable yield at least one item that is equal to the corresponding item from the specified items.
```

## 运行器Runner

【TODO】

## Spring Test

【TODO】

## 参考资料
- [JUnit - About](http://junit.org/junit4/)
- [Matchers and assertthat · junit-team/junit4 Wiki](https://github.com/junit-team/junit4/wiki/Matchers-and-assertthat)
- [JUnit使用经验 - 读过几年书 - ITeye技术网站](http://caoyanbao.iteye.com/blog/443756)
- [JUnit4高级篇-由浅入深 - Java我人生（陈磊兴）的技术博客 - 博客频道 - CSDN.NET](http://blog.csdn.net/chenleixing/article/details/44260359)
- [探索 JUnit 4.4 新特性][探索 JUnit 4.4 新特性]

[探索 JUnit 4.4 新特性]: http://www.ibm.com/developerworks/cn/java/j-lo-junit44/