---
title: java学习路线
date: 2016-02-20 20:47:19
tags: [java]
---

我想像`100 Days of Swift`或者`30DaysofSwift`那样通过例子来学习java。

## 学习路线图

![](/img/java/java-load-map1.jpg)

![](/img/java/java-load-map2.jpg)

上面是随便在网上找的Java学习路线图。当我向别人说我要转Java时，他们总是说别，人太多了，为何太多？培训机构遍地都是。这的确是中国特有的现象，像我一个同学，三本学校，学校里什么技术都没交，最后大四让学生自己去报java培训班，然后他就走上javaee之路。扯远了，我的意思是国内培训机构如此多，历史也比较悠久了，他们总结的路线图还是很有道理的，基本成了最佳实践了，你看上面两个机构的线路图基本是一样的。

总体上，首先要学的是javase部分，也就是java基础部分。这部分我已经学过了，大学的时候是写安卓的，所以java基础还是有的。但是不扎实。。所以需要夯实一下，尤其是**集合**部分，一直没有系统的学习。

java界面部分，不学。java高级知识，涉及**NIO，网络通信，反射，多线程**。这部分是java炫技重中之重，一定要学好。

其实后台开发，超过一半的时间都是和数据库打交道，所以和数据库打交道的JDBC要学习。之后的WEB开发基础大致了解，不学。

接下来就到了java web开发。其实现在java在web开发领域没什么优势了，尤其是web栈中靠近前端展示的部分，太笨重。而web又是时时根据业务变化的。所以JSP什么的感觉没必要学，现在页面部分基本都由前端负责了，后端只要输出变量或者json就行了。但是servlet还是要学，这是javaee的基础。

接着就到了SSH部分。Spring+Struct2+Hibrnate，现在也过时了，现在的组合是Spring+SpringMVC+Mybatis

注意：
- 不要崇拜框架。这是我很容易犯的一个毛病。作为工具控，我很崇尚编程语言，编辑器，IDE，框架等。但是基础没打好，框架自然不好掌握，舍本逐末。
- 不要崇拜新特性。公司里的很多环境都比较旧，还是先把经典特性学号吧。
- 我一开始觉得公司面试会问框架，现在我觉得应该更多的问的是java基础。努力吧！

## 参考书籍
《Java编程思想》，打算先吃了这本，看英文版？~~实验了一下，发现看英文，看不懂了看中文，这种效果很好。~~ 太慢了，还是看中文版吧。

## 一步一步
这里记录每一步的博文或者例子。

开发工具：懒得去破解intelliJ IDEA，就用eclispe吧。

### 2016年02月21日 P215-224 10P 3:06
建立了github仓库learn-java。运行hello world。
《Java编程思想》第十一章，持有对象。P215-247 32P

- 如果我们能够知道我们需要几个对象，对象的生命周期是多长，那程序会非常简单，这是理想情况，大部分情况下我们两个都不知道，所以我们需要集合。
- java.util提供了许多容器类来解决这个问题。基础的几个接口是：List,Set,Map,Queue。
- java se5以前没有泛型，所以容器可以加入所有类型（因为都是Object的子类），这会导致运行时错误。有了泛型后，会在编译期阻止插入不合法的类型。
- 指定一个类型作为泛型参数，并不会限制你只能放这个确切的类型到容器中，还可以放置子类到容器中，向上转型对泛型有效。
- java容器类分为两个不同的概念：
  - Collection：独立元素的序列。包括List,Set,Queue接口。
  - Map：由键值对组成的对象。
- Collection接口概括了`序列`的概念。一种存放一组对象的方式。
  - Collection的`add`的语义是`确保这个Collection包含指定的元素`，这是为了兼容Set和List
  - 所有的Collection都可以被foreach遍历。
- java.util的Arras和Collections（注意最后有一个s）包含了很多实用方法。
  - Arrays.asList()
  - Collections.addAll()
  - Collection.addAll()
- 构造一个空Collection然后addAll比构造函数传入Collection快。
- **注意：**如果你直接实用Arrays.asList的结果，你需要注意，他的本质还是一个数组，所以如果你使用了add或delete，会报错`java.lang.UnsupportedOperationException`
- **注意：**书中提到了Arrays.asList的一个缺陷，就是他只会根据元素推测出最合适的类型，而不管他将要赋值给谁：

  ```
class Snow {}
class Powder extends Snow {}
class Light extends Powder {}
class Heavy extends Powder {}
class Crusty extends Snow {}
class Slush extends Snow {}

List<Snow> snow2 = Arrays.asList(
  new Light(), new Heavy());
  ```

  书中说这段代码会报错，但是我实验了一下并不会。应该是jdk后面修复了这个问题吧。

  ```
  List<Snow> snow3 = new ArrayList<Snow>();
    Collections.addAll(snow3, new Light(), new Heavy());
  ```

  这种`显式类型参数说明`就更加不会有问题了。
- 打印容器
  - 数组是不能直接输出的，默认会输出`[Ljava.lang.String;@6d06d69c`这样的东西。需要使用Arrays.toString()
  - 容器可以直接输出

    ```
    [rat, cat, dog]
    {dog=Spot, cat=Rags, rat=Fuzzy}
    ```

#### Collection
**抽象方法：**

```
//查询操作：
int size()
返回集合中元素的个数
boolean isEmpty()
判断集合是否为空
boolean contains(Object o) 
判断集合中是否存在o
Iterator<E> iterator()
返回一个迭代器
Object[]    toArray()
返回包含集合中所有元素的数组，**类型是Object**
<T> T[] toArray(T[] a)
返回包含集合中所有元素的数组，**类型由泛型参数决定**

//修改操作：
boolean add(E e) 
确保这个集合包含这个特定元素
boolean remove(Object o)
如果集合中存在这个对象，删除他。**只会删除一个**

//批量操作：
boolean addAll(Collection<? extends E> c) 
添加c中的所有元素到集合中
boolean containsAll(Collection<?> c) 
判断集合中是否存在c中所有元素
boolean removeAll(Collection<?> c)
删除所有这个集合中存在于c集合中的对象。**会删除全部**
boolean retainAll(Collection<?> c)
指保留同时存在于本集合和c集合的元素，也就是求**交集**。
void    clear() 
清空所有元素

//比较和hash
int hashCode() 
返回这个结合的hashCode
boolean equals(Object o) 
判断两个集合是否相等（比较每一个元素）
```

**默认方法（default methods）：**TODO
这是1.8的新特性，可以在接口中定义方法实现。

```
//批量操作：
default boolean removeIf(Predicate<? super E> filter)

//无分类：
default Stream<E>   parallelStream()
Returns a possibly parallel Stream with this collection as its source.
default Spliterator<E>  spliterator()
Creates a Spliterator over the elements in this collection.
default Stream<E>   stream()
Returns a sequential Stream with this collection as its source.
```

#### List
- 有两个类型的List：
  - ArrayList：随机访问快，中间插入/删除慢
  - LinkedList：随机访问慢，中间插入/删除快。特性比ArrayList多。

**抽象方法：**
这里列出的是List在Collection基础上添加的方法，因为List指的是顺序存储的，所以在Collection上加入了**基于位置的操作**。

```
//查询操作：
无添加

//修改操作：
无添加

//批量操作：
boolean addAll(int index, Collection<? extends E> c)
在本集合的特定位置(index)处插入c集合中的内容

//比较和hash
无添加

//位置访问操作（新增）：
E get(int index)
获取特定位置上的元素
E set(int index, E element)
使用element来替换特定位置上的元素
void add(int index, E element)
在特定位置插入元素
E remove(int index)
删除特定位置上的元素

//搜索操作（新增）：
int indexOf(Object o)
返回特定对象在list中第一次出现的位置，如果没有，返回-1
int lastIndexOf(Object o)
返回特定对象在list中最后一次出现的位置，如果没有，返回-1

//List迭代器（新增）：
ListIterator<E> listIterator()
返回这个list的list迭代器
ListIterator<E> listIterator(int index)
返回一个从index位置开始的迭代器

//视图（新增）：
List<E> subList(int fromIndex, int toIndex)
获取子列表，包含fromIndex，不包含toIndex
```

**默认方法：**TODO

```
//批量操作：
default void replaceAll(UnaryOperator<E> operator)

default void sort(Comparator<? super E> c)

//视图：
default Spliterator<E> spliterator()
```

问题：
- 书中用到了`for(Apple c : apples)`，这是哪个版本的特性？
- Arrays这个类还不太了解。需要看一下数组的章节。


## 参考地址
- [100 Days of Swift - samvlu.com](http://samvlu.com/)
- [allenwong/30DaysofSwift: A self taught project to learn Swift.](https://github.com/allenwong/30DaysofSwift)