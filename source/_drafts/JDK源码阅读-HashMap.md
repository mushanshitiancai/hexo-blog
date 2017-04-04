---
title: JDK源码阅读-HashMap
date: 2017-03-23 11:29:21
categories: [Java,JDK源码阅读]
tags: java
toc: true
---


## 原理

## 成员变量

```java
// 保存数据的数组
transient Entry<K,V>[] table = (Entry<K,V>[]) EMPTY_TABLE;

// 当前Map存储的数据个数
transient int size;

// 指定达到多少数据量时进行扩容，值等于(capacity * load factor)
int threshold;

// 负载系数
final float loadFactor;

// 修改次数，用于快速失败
transient int modCount;


transient int hashSeed = 0;
```

## 常量

```java
// 默认初始化大小，必须是2的N次方
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16

// 最大允许的容量，如果在构造函数中指定容量，大于这个值会被压缩为这个值
static final int MAXIMUM_CAPACITY = 1 << 30;

// 默认的负载系数
static final float DEFAULT_LOAD_FACTOR = 0.75f;

// 空数组，所有空的HashMap共享
static final Entry<?,?>[] EMPTY_TABLE = {};

// 
static final int ALTERNATIVE_HASHING_THRESHOLD_DEFAULT = Integer.MAX_VALUE;
```

## 构造函数

主构造函数：

```java
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " +
                                            initialCapacity);

    // 最大容量不能超过MAXIMUM_CAPACITY
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " +
                                            loadFactor);

    this.loadFactor = loadFactor;

    // 新建时，增长阈值与初始化容量一样
    threshold = initialCapacity;
    init();
}
```

其他构造函数是对主构造函数的调用：

```java
public HashMap(int initialCapacity) {
    this(initialCapacity, DEFAULT_LOAD_FACTOR);
}

public HashMap() {
    this(DEFAULT_INITIAL_CAPACITY, DEFAULT_LOAD_FACTOR);
}

public HashMap(Map<? extends K, ? extends V> m) {
    this(Math.max((int) (m.size() / DEFAULT_LOAD_FACTOR) + 1,
                    DEFAULT_INITIAL_CAPACITY), DEFAULT_LOAD_FACTOR);
    inflateTable(threshold);

    putAllForCreate(m);
}
```

主构造函数中最后调用了init，在HashMap实现中为空函数：

```java
void init() {
}
```

这个是模板方法模式，允许继承HashMap的子类自己重载定义在初始化后，使用前的操作。

## hash算法

```java
final int hash(Object k) {
    int h = hashSeed;
    if (0 != h && k instanceof String) {
        return sun.misc.Hashing.stringHash32((String) k);
    }

    h ^= k.hashCode();

    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).
    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}
```









## 参考资料
- [深入Java集合学习系列：HashMap的实现原理 - 莫等闲 - ITeye技术网站](http://zhangshixi.iteye.com/blog/672697)