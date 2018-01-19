---
title: 掌握Java-Bean Validation
date: 2018-01-18 19:50:26
categories: [Java,掌握Java]
tags: [java]
---

数据校验虽然简单，但是却是一个繁琐的事。我在无数的代码看到if判断参数，然后错了打日志抛异常，一片一片的这种代码，如果有点重复了，再弄出N个xxUtil来归纳代码。虽然这种做法可以达到效果，但是代码散乱，一个是编写麻烦，一个是不易阅读。

Java业界最喜欢搞规范，所以参数校验作为一个痛点，JSR 303 - Bean Validation规范出现了。

<!--more-->

[JSR 303 – Bean Validation](https://jcp.org/en/jsr/detail?id=303)是一个数据验证的规范，2009年11月确定最终方案。2009年12月Java EE 6发布，Bean Validation作为一个重要特性被包含其中。Hibernate Validator是 Bean Validation 的参考实现。Hibernate Validator提供了JSR 303规范中所有内置constraint的实现，除此之外还有一些附加的constraint。

constraint就是约束条件，比如不能为空之类的，这些条件被定义，然后就能被复用，而不是每次都在if语句里写。Bean Validation为Bean的验证定义了元数据模型和API，这里的元数据就是constant，元数据默认的形式是注解，还可以使用xml来定义constraint。

## 引入Bean Validation

```xml
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
    <version>1.1.0.Final</version>
</dependency>
<dependency>
    <groupId>org.hibernate</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>5.0.2.Final</version>
</dependency>
<dependency>
    <groupId>javax.el</groupId>
    <artifactId>javax.el-api</artifactId>
    <version>3.0.0</version>
</dependency>
<dependency>
    <groupId>org.glassfish.web</groupId>
    <artifactId>javax.el</artifactId>
    <version>2.2.6</version>
</dependency>
```

## 例子

我们先看看Bean Validation怎么用，有个大体的认识。首先声明需要被校验的Java Bean：

```java
public class User {

    @NotNull(message = "用户名不能为空")
    private String name;

    @Min(value = 1, message = "年龄不能小于1")
    @Max(value = 200, message = "年龄不能大于200")
    private int age;

    // 构造函数，getter，setter略
}
```

在User Bean中我们使用了几个注解来修饰字段，name字段上添加`@NotNull`表示这个字段不能为空，age字段上添加`@Min`和`@Max`注解，表示限制其最大和最小值。这些constraint注解是Bean Validation规范内置的。全部内置的constraint说明见下文。

然后编写入口函数，实例化Bean并进行校验：

```java
public static void main(String[] args) {
    Validator validator = Validation.buildDefaultValidatorFactory().getValidator();
    Set<ConstraintViolation<User>> validate = validator.validate(new User(null, 0));
    for (ConstraintViolation<User> violation : validate) {
        System.out.println(violation.getMessage());
    }
}
```

输出：

```
用户名不能为空
年龄不能小于1
```

## Bean Validation内置constraint

JSR 303内置了常用的constraint，我们可以直接使用。

### 空检查
- `@Null`	被注释的元素必须为 null (任何类型)
- `@NotNull`	被注释的元素必须不为 null (任何类型)

### 布尔检查
- `@AssertTrue`	被注释的元素必须为 true (boolean或者Boolean)
- `@AssertFalse`	被注释的元素必须为 false (boolean或者Boolean)

### 数字检查
- `@Min(value)`	被注释的元素必须是一个数字，其值必须大于等于指定的最小值 (BigDecimal,BigInteger,byte,short,int,long及其包装类)
- `@Max(value)`	被注释的元素必须是一个数字，其值必须小于等于指定的最大值
- `@DecimalMin(value)`	被注释的元素必须是一个数字，其值必须大于等于指定的最小值 (CharSequence，BigDecimal,BigInteger,byte,short,int,long及其包装类)
- `@DecimalMax(value)`	被注释的元素必须是一个数字，其值必须小于等于指定的最大值 
- `@Digits (integer, fraction)`	被注释的元素必须是一个数字，其值必须在可接受的范围内 (BigDecimal,BigInteger,byte,short,int,long及其包装类)

### 字符串（集合）检查
- `@Size(max, min)`	被注释的元素的大小必须在指定的范围内 (CharSequence,Collection,Map,Array)
- `@Pattern(value)`	被注释的元素必须符合指定的正则表达式 (CharSequence)

### 时间检查
- `@Past`	被注释的元素必须是一个过去的日期 (Date,Calendar)
- `@Future`	被注释的元素必须是一个将来的日期 (Date,Calendar)

## Hibernate Validator扩展的constraint

Hibernate除了实现标准的constraint，还实现了一些扩展constraint。

- `@NotEmpty`	被注释的字符串的必须非空
- `@NotBlank`	被注释的字符串的必须非空白

- `@Range`	被注释的元素必须在合适的范围内 (内部使用`@Min`和`@Max`实现)

- `@Length`	被注释的字符串的大小必须在指定的范围内（同`@Size`）
- `@URL` 被注释的字符串必须是合法的URL
- `@Email`	被注释的元素必须是电子邮箱地址
- `@SafeHtml` 被注解的字符串必须是合法的HTML
- `@CreditCardNumber` 被注释的元素必须是合法的信用卡号，使用的是Luhn算法

- `@ScriptAssert` 直接指定脚本进行校验，算是最灵活的了

## Object Graph验证

Object Graph是指对象的拓扑结构，比如对象的引用关系。Bean Validation支持Object Graph验证。

默认如果A对象引用B对象是不会对B对象进行校验的。需要在B对象的字段或者getter使用`@Valid`注解才行。

## 自定义Constraint

虽然Bean Validation规范提供了内置的constraint，但是对于实际使用来说是根本不够用的，业务的规则千奇百怪，是需要自己自定义constraint的。

定制一个constraint需要两个部分，一个是constraint注解，一个是执行校验逻辑的类。

比如我们想要定制一个UUID格式字符串的constraint，可以这么写：

```java
@Target({ElementType.METHOD, ElementType.FIELD, ElementType.ANNOTATION_TYPE, ElementType.CONSTRUCTOR, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Constraint(validatedBy = UUIDValidator.class)
public @interface UUID {
    String message() default "UUID不合法";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
```

constraint注解需要使用`@Constraint(validatedBy = UUIDValidator.class)`来指定这个注解是一个Bean Validation注解，并且指定对应的校验规则实现类。

同时，constraint注解必须是`@Retention(RetentionPolicy.RUNTIME)`，因为在运行是需要使用到注解。

然后编写校验规则实现类：

```java
public class UUIDValidator implements ConstraintValidator<UUID, String> {
    public static final Pattern UUID_PATTERN = Pattern.compile("[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}");

    @Override
    public void initialize(UUID uuid) {
    }

    @Override
    public boolean isValid(String object, ConstraintValidatorContext constraintValidatorContext) {
        if (object == null){
            return true;
        }

        return UUID_PATTERN.matcher(object).matches();
    }
}
```

实现类需要实现`ConstraintValidator<A extends Annotation, T>`接口，泛型参数`A`指定该类作用于什么constraint注解上，`T`指定这个校验规则作用于什么数据类型。

因为一个constraint注解是可以作用于多种数据类型上的，比如`@Size`即可用于String上，也可以用于集合上，如何做到的呢？就是为一个constraint注解实现多个校验规则实现类，并指定不同的`T`参数。

### 组合constraint

上面介绍的是常规的constraint自定义方式。其实还可以利用现有的constraint注解的功能，实现“继承”校验规则。具体看例子：

```java
@Documented
@Constraint(validatedBy = { })
@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
@Retention(RUNTIME)
@Min(0)
@Max(Long.MAX_VALUE)
@ReportAsSingleViolation
public @interface Range {
	@OverridesAttribute(constraint = Min.class, name = "value") long min() default 0;

	@OverridesAttribute(constraint = Max.class, name = "value") long max() default Long.MAX_VALUE;

	String message() default "{org.hibernate.validator.constraints.Range.message}";

	Class<?>[] groups() default { };

	Class<? extends Payload>[] payload() default { };

	/**
	 * Defines several {@code @Range} annotations on the same element.
	 */
	@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
	@Retention(RUNTIME)
	@Documented
	public @interface List {
		Range[] value();
	}
}
```

这是Hibernate扩展的`@Range`，可以发现这个注解上使用了`@Min(0)`和`@Max(Long.MAX_VALUE)`这两个注解，constraint注解还可以用在constraint注解上的，实现的效果是组合这些已有的注解的校验能力。也就是说通过添加这两个注解，`@Range`拥有了“必须大于等于0且小于等于Long.MAX_VALUE”的校验能力。

但是`@Range`注解应该要有能力指定最小值和最大值，但是如果通过组合constraint注解的方式，其入参是写死的，所以在`@Range`的实现中，使用了`@OverridesAttribute(constraint = Min.class, name = "value") long min() default 0;`的写法，意思是`@Range`的min字段是用于覆盖`@Min`的value字段的。

通过这种灵活的方式，我们可以利用现有的constraint注解，极大的简化了甚至可以不用写校验逻辑实现类了。

## 高级特性

Bean Validation还有一些高级特性，比如组，组序列可以参考：[Bean Validation 技术规范特性概述](https://www.ibm.com/developerworks/cn/java/j-lo-beanvalid/)

## 与Spring结合

参考：[Spring3.1 对Bean Validation规范的新支持(方法级别验证) - CSDN博客](http://blog.csdn.net/u014351782/article/details/51729181)

## Bean Validation 2.0

上面说的都是Bean Validation 1.0和1.1。这两个分别是在JavaEE6和JavaEE7中的。对应的JSR是JSR 303和JSR 349。

在2017年8月，[Bean Validation 2.0](http://beanvalidation.org/news/2017/08/07/bean-validation-2-0-is-a-spec/)发布了。

Bean Validation 2.0是JavaEE8的一部分，只支持Java8+。对应的JSR是JSR 380。

Bean Validation的新功能：

- 支持验证泛型参数，比如`List<@Positive Integer> positiveNumbers`
  - 可以更灵活的验证集合中的Bean，比如`Map<@Valid CustomerType, @Valid Customer> customersByType`
  - 支持`java.util.Optional`
  - 支持JavaFX声明的属性
- `@Past`和`@Futur`支持JSR 310的时间类型
- 新增内置constraint：@Email, @NotEmpty, @NotBlank, @Positive, @PositiveOrZero, @Negative, @NegativeOrZero, @PastOrPresent and @FutureOrPresent
- 所有的内置constraint都是repeatable的
- `ConstraintValidator#initialize()`是default方法，可选实现

引入Bean Validation 2.0：

```xml
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
    <version>2.0.0.Final</version>
</dependency>
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.0.2.Final</version>
</dependency>
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator-annotation-processor</artifactId>
    <version>6.0.2.Final</version>
</dependency>
<dependency>
    <groupId>javax.el</groupId>
    <artifactId>javax.el-api</artifactId>
    <version>3.0.0</version>
</dependency>
<dependency>
    <groupId>org.glassfish.web</groupId>
    <artifactId>javax.el</artifactId>
    <version>2.2.6</version>
</dependency>
```

## 参考资料
- [Bean Validation - Home](http://beanvalidation.org/)
- [Bean Validation Sneak Peek part I - In Relation To](http://in.relation.to/2008/03/25/bean-validation-sneak-peek-part-i/)
- [Bean Validation Sneak Peek part II: custom constraints - In Relation To](http://in.relation.to/2008/04/01/bean-validation-sneak-peek-part-ii-custom-constraints/)
- [JSR 303 - Bean Validation 介绍及最佳实践](https://www.ibm.com/developerworks/cn/java/j-lo-jsr303/)
- [Java Bean Validation Basics | Baeldung](http://www.baeldung.com/javax-validation)
- [遇到Caused by: java.lang.NoClassDefFoundError: javax/validation/ParameterNameProvider - c3tc3tc3t - 博客园](http://www.cnblogs.com/or2-/p/3519111.html)
- [Bean Validation 技术规范特性概述](https://www.ibm.com/developerworks/cn/java/j-lo-beanvalid/)