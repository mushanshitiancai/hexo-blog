---
title: JDK源码阅读-ArrayList
date: 2016-06-17 07:09:28
categories: [java,JDK源码阅读]
tags: java
toc: true
---

ArrayList可能是最常使用的集合类了。他使用array作为底层存储来实现List接口。

### 成员变量

```java
//用于存放ArrayList的数据的数组
transient Object[] elementData; // non-private to simplify nested class access

//当前ArrayList存放的数据的个数
private int size;
```

`elementData`是ArrayList中最重要的属性，用于存放数据。但是这个存放数据的数组为什么用`transient`修饰呢？大家知道`transient`表示在序列化的时候不会序列化该字段，那ArrayList的数据都存在这个数据里，不序列化这个数组，还怎么序列化ArrayList呢？

这是因为`elementData`的大小一般比ArrayList当前存放的数据个数要大，如果序列化的时候直接把整个`elementData`序列化了，会很浪费空间的，所以ArrayList并没有这么做，而是在`writeObject`和`readObject`中自定义序列化、反序列化的方法。

### 常量
ArrayList中定义的常量，不多：

```java
//ArrayList默认的初始大小为10
private static final int DEFAULT_CAPACITY = 10;

//大小为0的ArrayList默认共享使用这个数组
private static final Object[] EMPTY_ELEMENTDATA = {};

//不指定大小的ArrayList默认共享使用这个数据。这个数据和EMPTY_ELEMENTDATA的区别在于有不同的增长方式
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

//最大可以申请的数组大小，在ArrayList增长的时候会用到
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
```

`EMPTY_ELEMENTDATA`和`DEFAULTCAPACITY_EMPTY_ELEMENTDATA`是两个空数组。为什么要定义这两个*空数组*呢。因为大部分代码在实例化ArrayList的时候都是这么写的：

    List<Integer> list = new ArrayList<Integer>();

如果每个空ArrayList都分配一个默认大小的数组，像`new array[DEFAULT_CAPACITY]`，这样做会有两个问题，第一个问题是会降低实例化ArrayList的速度，因为你每次都要申请空间，第二个问题是可能会浪费空间。

所以ArrayList的策略是实例化时，如果不指定容器大小，那么默认把`elementData`设为一个空数组，等到第一次操作的时候再进行扩容。而且编写者进一步把空数组定义为常量，这样就不用每次申请空数组，节约时间，节约空间（虽然很少）。

还有一个问题，就是为什么要定义两个*一样*的空数组？因为编写者认为对于以下这两种写法，使用者的心态是不一样的：

```
List<Integer> list = new ArrayList<Integer>();
List<Integer> list = new ArrayList<Integer>(0);
```

第一种写法，`elementData`会被初始化为`DEFAULTCAPACITY_EMPTY_ELEMENTDATA`，第二中写法`elementData`会被初始化为`EMPTY_ELEMENTDATA`。

这两者本质上是一样的。但是第一次add时就不一样了。ArrayList认为不指定capacity的实例化方式是用户对于容器大小没有预期，所以他会在第一次add时把容器扩展为默认大小，也就是`DEFAULT_CAPACITY`。

而第二种写法，ArrayList认为用户对于容器的大小是有预期的，就是0，所以在第一次add时，ArrayList不会默认吧容器扩展为默认大小，而是按照一般的增长方式来增长容器大小。

### 构造函数

```java
//指定初始化容量的构造函数
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        //如果指定的初始化空间为0，则elementData=EMPTY_ELEMENTDATA
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    }
}

//不指定初始化容量的构造函数，
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

//复制一个集合的数据到新建的ArrayList中
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // replace with empty array.
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```

ArrayList构造函数的核心逻辑是`this.elementData = new Object[initialCapacity]`，对于新建空的ArrayList的逻辑上面已经说过了。

### 随机访问数据

```java
//返回指定位置上的元素
public E get(int index) {
    rangeCheck(index); //检查下标是否合法

    return elementData(index);
}

//检查下标是否合法，只是简单的检查是否大于size，至于是否小于零，交给数组判断
private void rangeCheck(int index) {
    if (index >= size)
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

//获取指定位置元素，并进行类型转换
E elementData(int index) {
    return (E) elementData[index];
}
```

### 追加替换元素

```java
//替换index位置上的元素，返回老元素
public E set(int index, E element) {
    rangeCheck(index);

    E oldValue = elementData(index);
    elementData[index] = element;
    return oldValue;
}

//在ArrayList尾部添加数据
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // 确保ArrayList的大小可以装下当前数据，如果不够了，扩大容量
    elementData[size++] = e;
    return true;
}

//确保ArrayList容量（包含了默认大小的逻辑）
private void ensureCapacityInternal(int minCapacity) {
    //如果ArrayList是不指定大小实例化的，则至少把容量扩展到默认大小（10）
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
    }

    ensureExplicitCapacity(minCapacity);
}

//确保ArrayList容量
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;

    // 如果当前容量小于指定容量，则扩展
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}

//扩展容器容量
private void grow(int minCapacity) {
    // 新容量=老容量+老容量/2
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);

    // 如果算出的新容量小于老容量，则新容量为指定容量
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;

    // 如果新容量大于最大容量数组最大容量
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);

    // 使用Arrays.copyOf函数把原数据复制到新的数组中
    elementData = Arrays.copyOf(elementData, newCapacity);
}

//如果申请大于MAX_ARRAY_SIZE的数组时的检查
private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ?
        Integer.MAX_VALUE :
        MAX_ARRAY_SIZE;
}
```

添加和替换是ArrayList的核心操作。这里主要说两点：

第一，Java文档中没有明确定义ArrayList的增长方式，所以具体的增长方式是由各个JDK自己实现决定的。我看的Java8的实现，是`newCapacity = oldCapacity + (oldCapacity >> 1)`也就是增加原来的一半。

在老的实现中，使用的代码是`newCapacity = (oldCapacity * 3)/2 + 1`，使用到了乘法和除法，会比新算法慢一点，而且计算的结果比老算法多1。

第二，是`hugeCapacity`这个函数。这个函数乍一看很奇怪。因为ArrayList中定义了一个常量`MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8`，为什么要减8呢？是因为在大部分的JVM实现中，数组的头部会存放一些必要的信息，所以最大最安全可以申请的数据大小为`Integer.MAX_VALUE - 8`。

但是也并不是所有的JVM都有这个限制，所以当ArrayList增长的时候，会判断是否增长的大于`MAX_ARRAY_SIZE`这个值，如果大于了，ArrayList会认为或许是这个用户想利用最大长度的array。所以`hugeCapacity`函数直接返回`Integer.MAX_VALUE`。结果有两种，一种是对于没有限制的JVM，用户真正利用到了最大的空间。另外一种情况是对于普通的JVM，用户得到错误提示：`java.lang.OutOfMemoryError: Requested array size exceeds VM limit`，这个也没有什么不妥，因为你在往一个已经极限大的数组里添加数据，得到报错也是应该的嘛。

不过，更经常的情况是你根本就申请不到那么大的内存，2^32byte=4GB，基本上在此之前都会爆出堆内存不够用了：`java.lang.OutOfMemoryError: Java heap space`。

### 插入删除元素

```java
//在指定位置插入元素
public void add(int index, E element) {
    rangeCheckForAdd(index);

    //容量+1
    ensureCapacityInternal(size + 1);  
    //把index以及之后的元素往后移动一个位置
    System.arraycopy(elementData, index, elementData, index + 1,
                     size - index);
    //这是index位置为插入的元素
    elementData[index] = element;
    size++;
}

//插入的时候，判断位置是否合法，上下限都要判断
private void rangeCheckForAdd(int index) {
    if (index > size || index < 0)
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

//删除指定位置上的元素
public E remove(int index) {
    rangeCheck(index);

    modCount++;
    E oldValue = elementData(index);

    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
    elementData[--size] = null; // 把原来的最后一个元素设置为null，提醒JVM GC

    return oldValue;
}

//删除指定元素（从前往后，遇到第一个相等的就删除）
public boolean remove(Object o) {
    if (o == null) {
        for (int index = 0; index < size; index++)
            if (elementData[index] == null) {
                fastRemove(index);
                return true;
            }
    } else {
        for (int index = 0; index < size; index++)
            if (o.equals(elementData[index])) {
                fastRemove(index);
                return true;
            }
    }
    return false;
}

//内部使用的删除方法，没有范围检查
private void fastRemove(int index) {
    modCount++;
    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
    elementData[--size] = null; // clear to let GC do its work
}

//清空ArrayList，原理是把每个元素都设置为null，同时这是size为0
public void clear() {
    modCount++;

    // clear to let GC do its work
    for (int i = 0; i < size; i++)
        elementData[i] = null;

    size = 0;
}
```

插入和删除的原理是一样的，都是需要移动操作的元素之后的元素。也就涉及到了数组元素复制，会比较慢。时间复杂度是O(n)。

### 操作容量

```java
//指定*最小*容量
public void ensureCapacity(int minCapacity) {
    int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
        // any size if not default element table
        ? 0
        // larger than default for default empty table. It's already
        // supposed to be at default size.
        : DEFAULT_CAPACITY;

    if (minCapacity > minExpand) {
        ensureExplicitCapacity(minCapacity);
    }
}

//修建容量为数据个数
public void trimToSize() {
    modCount++;
    if (size < elementData.length) {
        elementData = (size == 0)
          ? EMPTY_ELEMENTDATA
          : Arrays.copyOf(elementData, size); //修改的过程涉及到数组复制
    }
}
```

### 定位元素

```java
//查找元素位置，从头往后找
public int indexOf(Object o) {
    if (o == null) {
        for (int i = 0; i < size; i++)
            if (elementData[i]==null)     //如果是null，则直接使用==判断
                return i;
    } else {
        for (int i = 0; i < size; i++)
            if (o.equals(elementData[i])) //如果是对象，使用equals判断
                return i;
    }
    return -1;
}

//查找元素位置，从后往前找
public int lastIndexOf(Object o) {
    if (o == null) {
        for (int i = size-1; i >= 0; i--)
            if (elementData[i]==null)
                return i;
    } else {
        for (int i = size-1; i >= 0; i--)
            if (o.equals(elementData[i]))
                return i;
    }
    return -1;
}

//判断是否包含元素。使用indexOf来实现的
public boolean contains(Object o) {
    return indexOf(o) >= 0;
}
```

### 转为数组

```java
//返回一个包含所有元素的数组。是简单地拷贝数组并返回
public Object[] toArray() {
    return Arrays.copyOf(elementData, size);
}

//返回一个包含所有元素的数组，并且数据元素的类型是指定的类型。
public <T> T[] toArray(T[] a) {
    //如果a的大小小于当前数据的大小，则a只是用来提供类型信息，返回一个新建的数组
    if (a.length < size)
        return (T[]) Arrays.copyOf(elementData, size, a.getClass());

    //如果a可以装下当前ArrayList中的数据，则把数据拷贝到a中
    System.arraycopy(elementData, 0, a, 0, size);

    //把最后一个数据的后一个位置置为null。这是为了可以通过数组来判断ArrayList的数据个数。但是前提是ArrayList的数据中没有null。
    if (a.length > size)
        a[size] = null;
    return a;
}
```

所以`toArray`的用法有两种：

```
方法一：
Integer[] a = list.toArray(new Integer[0]);

方法二：
Integer[] a = new Integer[list.size()];
list.toArray(a);
```

方法一会快一点，因为在`toArray`的内部，使用`System.arraycopy`来新建数组，所以速度会快一点。

### 批量操作

```java
//追加另外一个集合的元素到ArrayList
public boolean addAll(Collection<? extends E> c) {
    Object[] a = c.toArray(); //先把另外一个对象转为数组
    int numNew = a.length;
    ensureCapacityInternal(size + numNew);  // Increments modCount
    System.arraycopy(a, 0, elementData, size, numNew);
    size += numNew;
    return numNew != 0;
}

//在指定位置插入另外一个集合的元素
public boolean addAll(int index, Collection<? extends E> c) {
    rangeCheckForAdd(index);

    Object[] a = c.toArray();
    int numNew = a.length;
    ensureCapacityInternal(size + numNew);  // Increments modCount

    int numMoved = size - index;
    if (numMoved > 0)
        System.arraycopy(elementData, index, elementData, index + numNew,
                         numMoved);

    System.arraycopy(a, 0, elementData, index, numNew);
    size += numNew;
    return numNew != 0;
}

//指定范围批量删除，不包含toIndex指的元素
protected void removeRange(int fromIndex, int toIndex) {
    modCount++;
    int numMoved = size - toIndex;
    System.arraycopy(elementData, toIndex, elementData, fromIndex,
                     numMoved);

    // clear to let GC do its work
    int newSize = size - (toIndex-fromIndex);
    for (int i = newSize; i < size; i++) {
        elementData[i] = null;
    }
    size = newSize;
}

//批量删除指定元素
public boolean removeAll(Collection<?> c) {
    Objects.requireNonNull(c);
    return batchRemove(c, false);
}

//批量删除指定元素之外的元素
public boolean retainAll(Collection<?> c) {
    Objects.requireNonNull(c);
    return batchRemove(c, true);
}

//批量删除/保留元素的内部实现
private boolean batchRemove(Collection<?> c, boolean complement) {
    final Object[] elementData = this.elementData;
    int r = 0, w = 0;  //两个游标，r是当前检查的元素，w是当前写入的元素
    boolean modified = false;
    try {
        for (; r < size; r++)
            if (c.contains(elementData[r]) == complement)
                elementData[w++] = elementData[r];
    } finally {
        // 正常退出，r=size，但是如果中间出错了，就会出现r != size
        // 这种情况下，把r之后的元素向前拷贝
        if (r != size) {
            System.arraycopy(elementData, r,
                             elementData, w,
                             size - r);
            w += size - r;
        }
        if (w != size) {
            // clear to let GC do its work
            for (int i = w; i < size; i++)
                elementData[i] = null;
            modCount += size - w;
            size = w;
            modified = true;
        }
    }
    return modified;
}
```

### 序列化/反序列化

```java
//序列化
private void writeObject(java.io.ObjectOutputStream s)
    throws java.io.IOException{
    // 序列化前记录下当前集合的修改次数，用来判断序列化过程中是否对集合进行了修改
    int expectedModCount = modCount;

    // 写入非静态成员和非transient成员
    s.defaultWriteObject();

    // 写入size，为什么下面解释
    s.writeInt(size);

    // 把每个元素写入流中
    for (int i=0; i<size; i++) {
        s.writeObject(elementData[i]);
    }

    // 如果写入完毕后，发现集合被其他线程修改了，则报错
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
}

//反序列化
private void readObject(java.io.ObjectInputStream s)
    throws java.io.IOException, ClassNotFoundException {
    elementData = EMPTY_ELEMENTDATA;

    // 读取成员变量
    s.defaultReadObject();

    // 读取容量，为什么忽略，下面解释
    s.readInt(); // ignored

    if (size > 0) {
        // be like clone(), allocate array based upon size not capacity
        ensureCapacityInternal(size);

        Object[] a = elementData;
        // Read in all elements in the proper order.
        for (int i=0; i<size; i++) {
            a[i] = s.readObject();
        }
    }
}
```

序列化反序列化中有两个重要的知识点。第一个是为什么`size`写了两遍。第二个是`modCount`的作用

首先看看什么是size写了两遍。在`writeObject`中，`s.defaultWriteObject()`会写入当前对象的所有非静态，非transient成员。我们看了代码可以知道，ArrayList中的`size`这个变量是符合条件的。所以在这句的时候，`size`就已经写入了。

紧接着`s.writeInt(size)`，这不是又写了一遍size么？为什么？这个其实是一个历史包袱。在老的JDK中，ArrayList在序列化的时候，会写入当前ArrayList的容量，在反序列化的时候，会恢复容量。而在新的JDK中，反序列化的时候，并不会去恢复容量，而只是把容量恢复为和`size`一般大。

我们可以看看老的反序列化函数，看了你就明白了：

```java
private void readObject(java.io.ObjectInputStream s)
    throws java.io.IOException, ClassNotFoundException {
    // Read in size, and any hidden stuff
    s.defaultReadObject();

    // Read in array length and allocate array
    int arrayLength = s.readInt();
    Object[] a = elementData = new Object[arrayLength];

    // Read in all elements in the proper order.
    for (int i=0; i<size; i++)
        a[i] = s.readObject();
}
```

还有第二个知识点，就是modCount。读到这里我才明白之前看到的代码中`modCount++`是什么作用。这里的`modCount`应该是`modifyCount`的缩写。

在ArrayList中的每个执行修改操作的函数中，都会让`modCount`加一，表示操作次数加一。我们都知道想ArrayList这样的新的集合类不是线程安全的。所以在像序列化反序列化过程中，集合可能会被其他线程修改，如何感知到这种修改呢？就是通过`modCount`这个变量。

`modCount`是定义在`AbstractList`的。在操作过程中发现`modCount`不一致并抛出错误被称为快速失败。

### 迭代器

```java
//获取从指定位置开始的List迭代器
public ListIterator<E> listIterator(int index) {
    if (index < 0 || index > size)
        throw new IndexOutOfBoundsException("Index: "+index);
    return new ListItr(index);
}

//获取包含全部元素的List迭代器
public ListIterator<E> listIterator() {
    return new ListItr(0);
}

//获取普通迭代器
public Iterator<E> iterator() {
    return new Itr();
}

private class Itr implements Iterator<E> {
    int cursor;       // index of next element to return
    int lastRet = -1; // index of last element returned; -1 if no such
    int expectedModCount = modCount;

    public boolean hasNext() {
        return cursor != size;
    }

    // 返回下一个元素
    @SuppressWarnings("unchecked")
    public E next() {
        checkForComodification();
        int i = cursor;
        if (i >= size)
            throw new NoSuchElementException();
        Object[] elementData = ArrayList.this.elementData;
        if (i >= elementData.length)
            throw new ConcurrentModificationException();
        cursor = i + 1;
        return (E) elementData[lastRet = i];
    }

    // 删除next中返回的元素
    public void remove() {
        if (lastRet < 0)
            throw new IllegalStateException();
        checkForComodification();

        try {
            ArrayList.this.remove(lastRet);
            cursor = lastRet;
            lastRet = -1;
            expectedModCount = modCount;
        } catch (IndexOutOfBoundsException ex) {
            throw new ConcurrentModificationException();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public void forEachRemaining(Consumer<? super E> consumer) {
        Objects.requireNonNull(consumer);
        final int size = ArrayList.this.size;
        int i = cursor;
        if (i >= size) {
            return;
        }
        final Object[] elementData = ArrayList.this.elementData;
        if (i >= elementData.length) {
            throw new ConcurrentModificationException();
        }
        while (i != size && modCount == expectedModCount) {
            consumer.accept((E) elementData[i++]);
        }
        // update once at end of iteration to reduce heap write traffic
        cursor = i;
        lastRet = i - 1;
        checkForComodification();
    }

    // 检查集合是否被外部修改
    final void checkForComodification() {
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
    }
}

private class ListItr extends Itr implements ListIterator<E> {
    ListItr(int index) {
        super();
        cursor = index;
    }

    public boolean hasPrevious() {
        return cursor != 0;
    }

    public int nextIndex() {
        return cursor;
    }

    public int previousIndex() {
        return cursor - 1;
    }

    @SuppressWarnings("unchecked")
    public E previous() {
        checkForComodification();
        int i = cursor - 1;
        if (i < 0)
            throw new NoSuchElementException();
        Object[] elementData = ArrayList.this.elementData;
        if (i >= elementData.length)
            throw new ConcurrentModificationException();
        cursor = i;
        return (E) elementData[lastRet = i];
    }

    public void set(E e) {
        if (lastRet < 0)
            throw new IllegalStateException();
        checkForComodification();

        try {
            ArrayList.this.set(lastRet, e);
        } catch (IndexOutOfBoundsException ex) {
            throw new ConcurrentModificationException();
        }
    }

    public void add(E e) {
        checkForComodification();

        try {
            int i = cursor;
            ArrayList.this.add(i, e);
            cursor = i + 1;
            lastRet = -1;
            expectedModCount = modCount;
        } catch (IndexOutOfBoundsException ex) {
            throw new ConcurrentModificationException();
        }
    }
}
```

迭代器是集合的通用访问接口，如果是针对ArrayList的话，使用迭代器并不高效。因为迭代器在迭代的过程中是不允许外部修改容器的，所以迭代器为了快速失败，每次都会进行相应的检查。

### 子列表

```java
//获取子列表，注意，因为这是List接口中的方法，所以返回的不是一个ArrayList
public List<E> subList(int fromIndex, int toIndex) {
    subListRangeCheck(fromIndex, toIndex, size);
    return new SubList(this, 0, fromIndex, toIndex);
}

//检查子列表的范围是否合法
static void subListRangeCheck(int fromIndex, int toIndex, int size) {
    if (fromIndex < 0)
        throw new IndexOutOfBoundsException("fromIndex = " + fromIndex);
    if (toIndex > size)
        throw new IndexOutOfBoundsException("toIndex = " + toIndex);
    if (fromIndex > toIndex)
        throw new IllegalArgumentException("fromIndex(" + fromIndex +
                                           ") > toIndex(" + toIndex + ")");
}

//子列表类
private class SubList extends AbstractList<E> implements RandomAccess {
    private final AbstractList<E> parent;
    private final int parentOffset;
    private final int offset;
    int size;

    SubList(AbstractList<E> parent,
            int offset, int fromIndex, int toIndex) {
        this.parent = parent;
        this.parentOffset = fromIndex;
        this.offset = offset + fromIndex;
        this.size = toIndex - fromIndex;
        this.modCount = ArrayList.this.modCount;
    }

    public E set(int index, E e) {
        rangeCheck(index);
        checkForComodification();
        E oldValue = ArrayList.this.elementData(offset + index);
        ArrayList.this.elementData[offset + index] = e;
        return oldValue;
    }

    public E get(int index) {
        rangeCheck(index);
        checkForComodification();
        return ArrayList.this.elementData(offset + index);
    }

    public int size() {
        checkForComodification();
        return this.size;
    }

    public void add(int index, E e) {
        rangeCheckForAdd(index);
        checkForComodification();
        parent.add(parentOffset + index, e);
        this.modCount = parent.modCount;
        this.size++;
    }

    public E remove(int index) {
        rangeCheck(index);
        checkForComodification();
        E result = parent.remove(parentOffset + index);
        this.modCount = parent.modCount;
        this.size--;
        return result;
    }

    protected void removeRange(int fromIndex, int toIndex) {
        checkForComodification();
        parent.removeRange(parentOffset + fromIndex,
                           parentOffset + toIndex);
        this.modCount = parent.modCount;
        this.size -= toIndex - fromIndex;
    }

    public boolean addAll(Collection<? extends E> c) {
        return addAll(this.size, c);
    }

    public boolean addAll(int index, Collection<? extends E> c) {
        rangeCheckForAdd(index);
        int cSize = c.size();
        if (cSize==0)
            return false;

        checkForComodification();
        parent.addAll(parentOffset + index, c);
        this.modCount = parent.modCount;
        this.size += cSize;
        return true;
    }

    public Iterator<E> iterator() {
        return listIterator();
    }

    public ListIterator<E> listIterator(final int index) {
        checkForComodification();
        rangeCheckForAdd(index);
        final int offset = this.offset;

        return new ListIterator<E>() {
            int cursor = index;
            int lastRet = -1;
            int expectedModCount = ArrayList.this.modCount;

            public boolean hasNext() {
                return cursor != SubList.this.size;
            }

            @SuppressWarnings("unchecked")
            public E next() {
                checkForComodification();
                int i = cursor;
                if (i >= SubList.this.size)
                    throw new NoSuchElementException();
                Object[] elementData = ArrayList.this.elementData;
                if (offset + i >= elementData.length)
                    throw new ConcurrentModificationException();
                cursor = i + 1;
                return (E) elementData[offset + (lastRet = i)];
            }

            public boolean hasPrevious() {
                return cursor != 0;
            }

            @SuppressWarnings("unchecked")
            public E previous() {
                checkForComodification();
                int i = cursor - 1;
                if (i < 0)
                    throw new NoSuchElementException();
                Object[] elementData = ArrayList.this.elementData;
                if (offset + i >= elementData.length)
                    throw new ConcurrentModificationException();
                cursor = i;
                return (E) elementData[offset + (lastRet = i)];
            }

            @SuppressWarnings("unchecked")
            public void forEachRemaining(Consumer<? super E> consumer) {
                Objects.requireNonNull(consumer);
                final int size = SubList.this.size;
                int i = cursor;
                if (i >= size) {
                    return;
                }
                final Object[] elementData = ArrayList.this.elementData;
                if (offset + i >= elementData.length) {
                    throw new ConcurrentModificationException();
                }
                while (i != size && modCount == expectedModCount) {
                    consumer.accept((E) elementData[offset + (i++)]);
                }
                // update once at end of iteration to reduce heap write traffic
                lastRet = cursor = i;
                checkForComodification();
            }

            public int nextIndex() {
                return cursor;
            }

            public int previousIndex() {
                return cursor - 1;
            }

            public void remove() {
                if (lastRet < 0)
                    throw new IllegalStateException();
                checkForComodification();

                try {
                    SubList.this.remove(lastRet);
                    cursor = lastRet;
                    lastRet = -1;
                    expectedModCount = ArrayList.this.modCount;
                } catch (IndexOutOfBoundsException ex) {
                    throw new ConcurrentModificationException();
                }
            }

            public void set(E e) {
                if (lastRet < 0)
                    throw new IllegalStateException();
                checkForComodification();

                try {
                    ArrayList.this.set(offset + lastRet, e);
                } catch (IndexOutOfBoundsException ex) {
                    throw new ConcurrentModificationException();
                }
            }

            public void add(E e) {
                checkForComodification();

                try {
                    int i = cursor;
                    SubList.this.add(i, e);
                    cursor = i + 1;
                    lastRet = -1;
                    expectedModCount = ArrayList.this.modCount;
                } catch (IndexOutOfBoundsException ex) {
                    throw new ConcurrentModificationException();
                }
            }

            final void checkForComodification() {
                if (expectedModCount != ArrayList.this.modCount)
                    throw new ConcurrentModificationException();
            }
        };
    }

    public List<E> subList(int fromIndex, int toIndex) {
        subListRangeCheck(fromIndex, toIndex, size);
        return new SubList(this, offset, fromIndex, toIndex);
    }

    private void rangeCheck(int index) {
        if (index < 0 || index >= this.size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    private void rangeCheckForAdd(int index) {
        if (index < 0 || index > this.size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    private String outOfBoundsMsg(int index) {
        return "Index: "+index+", Size: "+this.size;
    }

    private void checkForComodification() {
        if (ArrayList.this.modCount != this.modCount)
            throw new ConcurrentModificationException();
    }

    public Spliterator<E> spliterator() {
        checkForComodification();
        return new ArrayListSpliterator<E>(ArrayList.this, offset,
                                           offset + this.size, this.modCount);
    }
}
```

建立子列表并没有进行复制操作，而是建立了一个原始列表的部分视图。所以操作子列表会修改原列表。

### 杂项

```
//克隆ArrayList，对elementData进行复制，元素本身不会被复制
public Object clone() {
    try {
        ArrayList<?> v = (ArrayList<?>) super.clone();
        v.elementData = Arrays.copyOf(elementData, size);
        v.modCount = 0;
        return v;
    } catch (CloneNotSupportedException e) {
        // this shouldn't happen, since we are Cloneable
        throw new InternalError(e);
    }
}
public int size() {
    return size;
}
public boolean isEmpty() {
    return size == 0;
}
```

## 总结

- ArrayList的无参数构造函数新建的长度为0，添加第一个元素后，长度为默认长度10
- ArrayList指定新建的长度为0，添加第一个元素后，长度为1，为正常增长结果
- ArrayList通过数组存放数据，成员是elementData
- ArrayList的增长方式是增加原来的一半
- elementData成员是transient的，不会被自动序列化
- ArrayList序列化/反序列化的逻辑：size+size+每个元素
- ArrayList的迭代器在迭代过程中如果发现数据源被修改，会快速失败，是通过modCount变量实现的
- ArrayList在序列化过程中如果发现数据源被修改，会快速失败
- subList不会建立新的数组，而是在原来的数据源上操作
- clone会复制存放数据的底层数组elementData，但是不会复制元素本身。

## 参考资料
- [java的arrayList中，数组为什么被transient修饰，这是因为什么原因而设计出来的？_百度知道](http://zhidao.baidu.com/link?url=2INEEQeNLOfZdrhnu-5g95990EDJjZ7H-T7sJNHagdKzedXz0qPRCVRm4kJUypVvNKOmfBE2964_RtH-IjCaQa)
- [Java 集合系列03之 ArrayList详细介绍(源码解析)和使用示例 - 如果天空不死 - 博客园](http://www.cnblogs.com/skywang12345/p/3308556.html)
- [Java 8 Arraylist hugeCapacity(int) implementation - Stack Overflow](http://stackoverflow.com/questions/35582809/java-8-arraylist-hugecapacityint-implementation)
- [java - ArrayList: how does the size increase? - Stack Overflow](http://stackoverflow.com/questions/4450628/arraylist-how-does-the-size-increase)
- [源码分析：ArrayList的writeobject方法中的实现是否多此一举？ - 知乎](https://www.zhihu.com/question/41512382)




