---
title: Guava LoadingCache不能缓存null值
date: 2017-11-24 20:39:28
categories: [Java]
tags: [java,guava]
---

测试的时候发现项目中的LoadingCache没有刷新，但是明明调用了refresh方法了。后来发现LoadingCache是不支持缓存null值的，如果load回调方法返回null，则在get的时候会抛出异常。

<!--more-->

通过几个例子开看这个问题：

```java
public void test_loadNull() {
    LoadingCache<String, String> stringCache = CacheBuilder.newBuilder()
            .maximumSize(10)
            .build(new CacheLoader<String, String>() {
                @Override
                public String load(String s) throws Exception {
                    System.out.println("xx");
                    if (s.equals("hello"))
                        return "world";
                    else
                        return null;
                }
            });

    try {
        System.out.println(stringCache.get("hello"));

        // get触发load，load返回null则抛出异常：
        // com.google.common.cache.CacheLoader$InvalidCacheLoadException: CacheLoader returned null for key other_key.
        System.out.println(stringCache.get("other_key"));
    } catch (ExecutionException e) {
        e.printStackTrace();
    }
}
```

```java
public void test_loadNullWhenRefresh() {
    LoadingCache<String, String> stringCache = CacheBuilder.newBuilder()
            .maximumSize(10)
            .build(new CacheLoader<String, String>() {
                int i = 0;

                @Override
                public String load(String s) throws Exception {
                    if (i == 0) {
                        i++;
                        return "world";
                    }
                    return null;
                }
            });

    try {
        System.out.println(stringCache.get("hello"));
        System.out.println(stringCache.get("hello"));

        // refresh的时候，如果load函数返回null，则refresh抛出异常：
        // Exception thrown during refresh
        // com.google.common.cache.CacheLoader$InvalidCacheLoadException: CacheLoader returned null for key hello.
        stringCache.refresh("hello");

        System.out.println(stringCache.get("hello"));
    } catch (ExecutionException e) {
        e.printStackTrace();
    }
}
```

```java
public void test_loadNullAfterInvalidate() {
    LoadingCache<String, String> stringCache = CacheBuilder.newBuilder()
            .maximumSize(10)
            .build(new CacheLoader<String, String>() {
                int i = 0;

                @Override
                public String load(String s) throws Exception {
                    if (i == 0) {
                        i++;
                        return "world";
                    }
                    return null;
                }
            });

    try {
        System.out.println(stringCache.get("hello"));
        System.out.println(stringCache.get("hello"));

        // invalidate不会触发load
        stringCache.invalidate("hello");

        // invalidate后，再次get，触发load，抛出异常：
        // com.google.common.cache.CacheLoader$InvalidCacheLoadException: CacheLoader returned null for key hello.
        System.out.println(stringCache.get("hello"));
    } catch (ExecutionException e) {
        e.printStackTrace();
    }
}
```

```java
public void test_loadThrowException() {
    LoadingCache<String, String> stringCache = CacheBuilder.newBuilder()
            .maximumSize(10)
            .build(new CacheLoader<String, String>() {
                @Override
                public String load(String s) throws Exception {
                    if (s.equals("hello"))
                        return "world";
                    else
                        throw new IllegalArgumentException("only_hello");
                }
            });

    try {
        System.out.println(stringCache.get("hello"));

        // get触发load，load抛出异常，get也会抛出封装后的异常：
        // com.google.common.util.concurrent.UncheckedExecutionException: java.lang.IllegalArgumentException: only_hello
        System.out.println(stringCache.get("other_key"));
    } catch (ExecutionException e) {
        e.printStackTrace();
    }
}
```

所以如果你需要缓存“空”值，推荐的做法是使用Optional对象来封装结果：

```java
public void test_loadUseOptional() {
    LoadingCache<String, Optional<String>> stringCache = CacheBuilder.newBuilder()
            .maximumSize(10)
            .build(new CacheLoader<String, Optional<String>>() {
                @Override
                public Optional<String> load(String s) throws Exception {
                    if (s.equals("hello"))
                        return Optional.of("world");
                    else
                        return Optional.absent();
                }
            });

    try {
        Optional<String> hello = stringCache.get("hello");
        if(hello.isPresent()) {
            System.out.println(hello.get());
        }

        Optional<String> otherKey = stringCache.get("other_key");
        if(otherKey.isPresent()){
            System.out.println(otherKey.get());
        }
    } catch (ExecutionException e) {
        e.printStackTrace();
    }
}
```

如果你的场景中认为null是不存在的，那么你可以在load函数中抛出异常，这个异常会通过get抛出。

## 参考资料
- [Google Guava] 3-缓存 | 并发编程网 – ifeve.com
http://ifeve.com/google-guava-cachesexplained/
- Guava Cache使用笔记 - 代码说-Let code talk - ITeye博客
http://bylijinnan.iteye.com/blog/2225074
- guava - How to avoid caching when values are null? - Stack Overflow
https://stackoverflow.com/questions/13379071/how-to-avoid-caching-when-values-are-null