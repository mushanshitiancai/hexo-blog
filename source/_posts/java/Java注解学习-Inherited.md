---
title: Java注解学习-@Inherited
date: 2017-02-15 11:15:51
categories: [Java]
tags: [java]
---

`@Inherited`注解是Java提供的注解在注解之上的注解（元注解）。表示这个注解会被继承。

<!--more-->

含义很简单，但是有容易歧义的地方：注解被继承的表现是什么？什么情况下会被继承？

我一开始的理解是所有的注解被`@Inherited`注解后，都会有“可以被继承”这个特性。比如方法上的注解会被子类覆盖的方法继承。然而，实验证明，这个理解是错的。

来看看`@Inherited`的源码：

```java
/**
 * Indicates that an annotation type is automatically inherited.  If
 * an Inherited meta-annotation is present on an annotation type
 * declaration, and the user queries the annotation type on a class
 * declaration, and the class declaration has no annotation for this type,
 * then the class's superclass will automatically be queried for the
 * annotation type.  This process will be repeated until an annotation for this
 * type is found, or the top of the class hierarchy (Object)
 * is reached.  If no superclass has an annotation for this type, then
 * the query will indicate that the class in question has no such annotation.
 * 声明一个注解是会被自动继承的。
 * 如果使用Inherited元注解注解了一个注解，然后用户在一个没有实现这个注解的类上查询这个注解，
 * 那么这个类的父类会自动被叫来查询是否有这个注解，如果没有，则继续向父类的父类搜索，直到Object。
 * 如果其中有某个级别的父类有这个注解就会返回这个`被继承`的注解，否则则认为这个类没有包含这个注解。
 *
 * <p>Note that this meta-annotation type has no effect if the annotated
 * type is used to annotate anything other than a class.  Note also
 * that this meta-annotation only causes annotations to be inherited
 * from superclasses; annotations on implemented interfaces have no
 * effect.
 * 注意：1. 这个元注解只在注解在类上使用时生效。2. 这个元注解只会让子类继承父类的注解，而不会继承接口上的注解
 *
 * @author  Joshua Bloch
 * @since 1.5
 * @jls 9.6.3.3 @Inherited
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Inherited {
}
```

看了网上各种文章，发现最靠谱的还是这段注释。注释总结来有这么几点：

1. 被`@Inherited`注解的注解只有在class上使用才会有“自动继承的特性”
2. “自动继承的特性”是指如果在子类上搜索注解，其父类上的被`@Inherited`注解过的注解会考虑在内

## 参考资料
- [inheritance - How to use @inherited annotation in Java? - Stack Overflow](http://stackoverflow.com/questions/23973107/how-to-use-inherited-annotation-in-java)