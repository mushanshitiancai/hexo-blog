---
title: 掌握Java-Array/List排序
date: 2016-07-03 18:15:22
categories: [Java,掌握Java]
tags: java
---

说Array/List排序之前先说两个和比较相关的重要接口：`Comparable`和`Comparator`。

## Comparable接口

```
public interface Comparable<T> {
    public int compareTo(T o);
}
```

Comparable接口表示实现它的类是可以被排序的。这种排序被称为类的natural ordering。

本对象**小于**比较对象，compareTo返回负数。本对象**大于**比较对象，compareTo返回正数。本对象**等于**比较对象，compareTo返回0。

大部分情况下`e1.compareTo(e2) == 0` 与 `e1.equals(e2)`应该有相同的结果。

## Comparator接口

```
public interface Comparator<T> {
    int compare(T o1, T o2);
    boolean equals(Object obj);
}
```


Comparable要求被比较的类实现它。而对于那些我们无法修改的类，就无法使用Comparable接口了。Comparator接口适用的就是这种场景。他不需要侵入被比较的类，而是可以作为一个外置的比较器。

compare函数返回的值和compareTo的规则一样。

## 排序方法
实现了Comparable接口的类的列表或者数组，可以使用Collections.sort或者Arrays.sort来排序。Collections.sort和Arrays.sort还有一个重载的版本，可以通过制定Comparator比较器来排序一般的对象列表或数组。

### 方法一：使用Comparable接口

```
// 实现了Comparable接口
static class A implements Comparable<A>{
    int a;
    A(int a) {
        this.a = a;
    }

    @Override
    public String toString() {
        return Integer.toString(a);
    }

    public int compareTo(A o) {
        return (a < o.a) ? -1 : ((a == o.a) ? 0 : 1);
    }
}

public static void main(String[] args) {
    List<A> list1 = new ArrayList<A>();
    list1.add(new A(3));
    list1.add(new A(1));
    list1.add(new A(2));

    Collections.sort(list1); // 因为类A实现了Comparable接口，所以可以直接进行排序

    System.out.println(list1);
}
```

### 方法二：使用Comparator接口

```
static class A{
    int a;

    A(int a) {
        this.a = a;
    }

    @Override
    public String toString() {
        return Integer.toString(a);
    }
}

public static void main(String[] args) {
    List<A> list1 = new ArrayList<A>();
    list1.add(new A(3));
    list1.add(new A(1));
    list1.add(new A(2));

    // 因为类A没有实现Comparable接口，所以必须使用比较器
    Collections.sort(list1, new Comparator<A>() {
        public int compare(A o1, A o2) {
            return (o1.a < o2.a) ? -1 : ((o1.a == o2.a) ? 0 : 1);
        }
    });

    System.out.println(list1);
}
```

### 方法三：使用List接口中的sort方法
观察Collections的sort方法定义：

```
public static <T extends Comparable<? super T>> void sort(List<T> list) {
    list.sort(null);
}

public static <T> void sort(List<T> list, Comparator<? super T> c) {
    list.sort(c);
}
```

发现其实只是简单的调用了list中的sort方法。对于没有指定比较器的情况，是往list的sort方法中传入null。所以我们也可以直接调用List的sort方法。

不过使用Collections中的方法会是更好的选择，因为其函数对List是否可以自然排序做出了要求。如果你对一个没有实现自然排序的对象的列表使用Collections.sort是会在编译的时候报错的。

来看看List.sort是如何定义的：

```
default void sort(Comparator<? super E> c) {
    Object[] a = this.toArray();
    Arrays.sort(a, (Comparator) c);
    ListIterator<E> i = this.listIterator();
    for (Object e : a) {
        i.next();
        i.set((E) e);
    }
}
```

看到default可以得知，这是在1.8中更新的代码。查看1.7的JDK代码，1.7中的Collections.sort代码如下：

```
public static <T extends Comparable<? super T>> void More ...sort(List<T> list) {
    Object[] a = list.toArray();
    Arrays.sort(a);
    ListIterator<T> i = list.listIterator();
    for (int j=0; j<a.length; j++) {
        i.next();
        i.set((T)a[j]);
    }
}
```

可以得知，1.7中List接口中是没有sort方法的，只能通过Collections的sort方法来排序，而1.8中，List接口添加了sort这个默认方法，Collections的sort也改为调用List中的sort方法了。

## 排序的原理
无论是1.8还是1.8之前，排序的核心代码都是：

```
Object[] a = this.toArray();
Arrays.sort(a, (Comparator) c);
ListIterator<E> i = this.listIterator();
for (Object e : a) {
    i.next();
    i.set((E) e);
}
```

步骤如下：

1. 首先列表调用了toArray方法，把自己转换成一个数组
2. 然后调用数组的排序Arrays.sort，排序数组
3. 最后再根据排序好的数组，利用迭代器，一个一个更新列表里的元素。

撇开Arrays.sort里的算法不说，因为toArray是会复制一份数据的，所以这里的排序不是在原来的底层存储上排序的，而是在拷贝上排序，然后在更新回去。

然后看看Arrays.sort的源码：

```
public static <T> void sort(T[] a, Comparator<? super T> c) {
    if (c == null) {
        sort(a);
    } else {
        if (LegacyMergeSort.userRequested)
            legacyMergeSort(a, c);
        else
            TimSort.sort(a, 0, a.length, c, null, 0, 0);
    }
}

public static void sort(Object[] a) {
    if (LegacyMergeSort.userRequested)
        legacyMergeSort(a);
    else
        ComparableTimSort.sort(a, 0, a.length, null, 0, 0);
}
```

Java1.7之前数组排序使用的是MergeSort，而1.7中升级为TimSort。但是Java1.7也允许使用MergeSort，只要添加参数`-Djava.util.Arrays.useLegacyMergeSort=true`即可。

关于MergeSort和TimSort算法的原理，下篇见分解。

## 总结

- 实现Comparable接口，使类可以被自然排序
- 可以使用实现了Comparator的比较器比较一个类
- 排序的入口方法为Collections.sort和Arrays.sort
- Collections.sort函数1.8中改为调用List的sort方法
- Collections.sort本质上是先把集合转为数组，再使用Arrays.sort排序，再更新集合
- Arrays.sort使用的算法是TimSort和MergeSort

## 参考资料
- [JAVA默认排序算法问题 - sells2012的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/sells2012/article/details/18947849)
