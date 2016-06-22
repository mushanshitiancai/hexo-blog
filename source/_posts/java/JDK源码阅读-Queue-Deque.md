---
title: JDK源码阅读-Queue/Deque
date: 2016-06-19 15:40:28
categories: [Java,JDK源码阅读]
tags: java
toc: true
---

## Queue
Queue是一个很重要的接口。尤其是在并发编程中，比如像BlockingQueue就是继承自Queue接口的。Queue的实现也很多种多样，有最常见的ArrayDeque，LinkedList，这些是按插入顺序排序的。还有具有特殊功能的队列，比如优先级队列PriorityQueue。

先来看看Queue接口的代码

```java
public interface Queue<E> extends Collection<E> {

    //将元素插入队列，总是返回true，如果失败，抛出异常
    //比如如果队列的容量不够了，抛出IllegalStateException
    boolean add(E e);

    //将元素插入队列，如果插入成功返回true，插入失败，返回false
    boolean offer(E e);

    //返回并移除队列的头部，如果队列为空，抛出NoSuchElementException
    E remove();

    //返回并移除队列的头部，如果队列为空，返回null
    E poll();

    //返回队列头部，如果队列为空，抛出NoSuchElementException
    E element();

    //返回队列的头部，如果队列为空，返回null
    E peek();
}
```

**两种系列的操作：**

首先要说的是，Queue的操作分为两个系列，一个是在失败时抛出异常，一个是在失败时返回特殊值(null或者false)。对于插入操作，后者是针对有空间限制的队列特有的，其他类型的队列在插入是不会出错的.

| 操作 | 失败时抛出异常  | 失败时返回特殊值    |
|-----|----------------|-------------------|
| 插入 | add(e)         | offer(e)         |
| 删除 | remove(e)      | poll(e)          |
| 获取 | element(e)     | peek(e)          |

**不一定是FIFO：**

队列一般是按照先入先出(FIFO)的方式排序的，但是也不一定是。比如优先级队列和LIFO队列(栈)。Queue接口只是定义了插入了获取的方式，具体的实现，由底层决定。

**最好不要插入null：**

队列中最好插入null元素，虽然他的实现允许，比如LinkedList，但是因为poll方法使用null判断队列是否为空，所以在队列中插入null会引起歧义。

PS. 个人觉得，element这个函数名取得简直傻逼。

## Deque
Queue是单端的操作。Deque是双端的操作。

```java
public interface Deque<E> extends Queue<E> {

    //在头部插入元素，如果空间不够，抛出IllegalStateException
    void addFirst(E e);

    //在尾部追加元素，如果空间不够，抛出IllegalStateException。和add等价
    void addLast(E e);

    //在头部插入元素，成功返回true，失败返回false
    boolean offerFirst(E e);

    //在尾部追加元素，成功返回true，失败返回false
    boolean offerLast(E e);

    //返回并删除头部元素，如果队列为空，抛出NoSuchElementException
    E removeFirst();

    //返回并删除尾部元素，如果队列为空，抛出NoSuchElementException
    E removeLast();

    //返回并删除头部元素，如果队列为空，返回null
    E pollFirst();

    //返回并删除尾部元素，如果队列为空，返回null
    E pollLast();

    //返回头部元素，如果队列为空，抛出NoSuchElementException。和element等价
    E getFirst();

    //返回尾部元素，如果队列为空，抛出NoSuchElementException
    E getLast();

    //返回头部元素，如果队列为空，，返回null
    E peekFirst();

    //返回尾部元素，如果队列为空，，返回null
    E peekLast();

    //删除从前往后第一个出现的相等元素
    boolean removeFirstOccurrence(Object o);

    //删除从后往前第一个出现的相等元素
    boolean removeLastOccurrence(Object o);

    // *** 队列相关方法 ***

    //和addLast等价
    boolean add(E e);

    //和offerLast等价
    boolean offer(E e);

    //和removeFirst等价
    E remove();

    //和pollFirst等价
    E poll();

    //和getFirst等价
    E element();

    //和peekFirst等价
    E peek();

    // *** 栈相关方法 ***

    //和addFirst等价
    void push(E e);

    //和removeFirst等价
    E pop();


    // *** Collection methods ***

    //和removeFirstOccurrence等价
    boolean remove(Object o);

    boolean contains(Object o);

    public int size();

    Iterator<E> iterator();

    Iterator<E> descendingIterator();

}
```

**两种系列的操作：**

和Queue一样，Deque也分为两种风格的操作。

| 操作 | 失败时抛出异常               | 失败时返回特殊值           |
|------|------------------------------|----------------------------|
| 插入 | addFirst(e)/addLast(e)       | offerFirst(e)/offerLast(e) |
| 删除 | removeFirst(e)/removeLast(e) | pollFirst(e)/pollLast(e)   |
| 获取 | getFirst(e)/getLast(e)       | peekFirst(e)/peekLast(e)   |

**Queue和Deque等价的方法：**

因为Deque是继承自Queue的，而且Deque为了名义，所以函数名都是指定First/Last的，所以Queue中的方法，会和Deque中相应的方法等价：

| Queue方法  |  等价的Deque方法   |
|------------|--------------|
| add(e)     | addLast(e)    |
| offer(e)   | offerLast(e)   |
| remove()   | removeFirst()  |
| poll()     | pollFirst()    |
| element()  | getFirst()     |
| peek()     | peekFirst()   |

规则是：取头插尾

**堆栈的方法：**

Java集合除了失败的Stack类，并没有定义新的Stack方法，而是把Stack的方法定义在Deque里了。

| Stack方法 |  等价的Deque方法  | 等价的Queue方法  |
|-----------|-----------------|----------------|
|  push(e) | addFirst(e)     |   无            |
|  pop()   | removeFirst()   |   remove()      |
|  peek()  | peekFirst()     |   peek()        |

因为Stack都是针对头部的操作，而Queue是取头插尾，所以只有取的方法有Queue接口对应的方法，push就没有了。

使用Deque来作为Stack：

```java
Deque<Integer> stack = new ArrayDeque<Integer>();
```

**最好不要插入null：**

这一点和Queue一样。

PS. Deque继承自Queue，两套方法交杂在一起，Deque可以使用Queue中的方法，但是却很不名义，还是有些乱的。

## 参考资料
- http://tool.oschina.net/apidocs/apidoc?api=jdk-zh