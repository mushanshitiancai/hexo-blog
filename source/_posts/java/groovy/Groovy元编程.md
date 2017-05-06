---
title: Groovy元编程-运行时元编程
date: 2017-04-19 16:45:04
categories: [Java,Groovy]
tags: [java,groovy]
toc: true
---

原文地址：[The Apache Groovy programming language - Runtime and compile-time metaprogramming](http://www.groovy-lang.org/metaprogramming.html)

## 1. 运行时元编程

有了运行时元编程，我们可以推迟到运行的时候再决定如何拦截，注入，设置是装配类和接口的方法。要想深入理解Groovy MOP，我们需要理解Groovy对象和Groovy的方法处理机制。在Groovy，我们使用三种类型的对象：POJO，POGO和Groovy Interceptors。Groovy支持在这三种对象上用不同的方式进行元编程。

- POJO - 传统Java对象，可以是用Java或者是任何其他JVM上的语言编写的
- POGO - Groovy对象，使用Groovy编写。它继承自`java.lang.Object`并且默认实现了`groovy.lang.GroovyObject`
- Groovy Interceptor - 一个Groovy对象，实现了`groovy.lang.GroovyInterceptable`接口，拥有方法拦截的能力

对于每一个方法调用，Groovy都检查所在方法是POJO还是POGO。如果是POJO，Groovy从`groovy.lang.MetaClassRegistry`获取它的`MetaClass`，然后把方法的调用代理到这个MetaClass实例。如果是POGO，Groovy会执行更复杂的判断流程，如下图：

![](http://docs.groovy-lang.org/latest/html/documentation/assets/img/GroovyInterceptions.png)

### 1.1 GroovyObject接口

`groovy.lang.GroovyObject`是Groovy中最主要的接口，其地位就行Object在Java中的地位。`groovy.lang.GroovyObjectSupport`实现了GroovyObject接口的方法，主要内容是把对应的方法调用转发到`groovy.lang.MetaClass`对象上。`GroovyObject`源码如下：

```groovy
package groovy.lang;

public interface GroovyObject {

    Object invokeMethod(String name, Object args);

    Object getProperty(String propertyName);

    void setProperty(String propertyName, Object newValue);

    MetaClass getMetaClass();

    void setMetaClass(MetaClass metaClass);
}
```

#### 1.1.1 invokeMethod

根据上面的流程图，这个方法会在调用的方法在对象中不存在时触发，下面是一个例子：

```groovy
class SomeGroovyClass {

    def invokeMethod(String name, Object args) {
        return "called invokeMethod $name $args"
    }

    def test() {
        return 'method exists'
    }
}

def someGroovyClass = new SomeGroovyClass()

assert someGroovyClass.test() == 'method exists'
assert someGroovyClass.someMethod() == 'called invokeMethod someMethod []'
```

#### 1.1.2 get/setProperty

对于属性的每次读取操作，都会被当前对象的`getProperty()`方法拦截。下面是一个例子：

```groovy
class SomeGroovyClass {

    def property1 = 'ha'
    def field2 = 'ho'
    def field4 = 'hu'

    def getField1() {
        return 'getHa'
    }

    def getProperty(String name) {
        if (name != 'field3')
            return metaClass.getProperty(this, name) 
        else
            return 'field3'
    }
}

def someGroovyClass = new SomeGroovyClass()

assert someGroovyClass.field1 == 'getHa'
assert someGroovyClass.field2 == 'ho'
assert someGroovyClass.field3 == 'field3'
assert someGroovyClass.field4 == 'hu'
```

对应的，对于属性的写操作都会被`setProperty()`方法拦截：

```groovy
class POGO {

    String property

    void setProperty(String name, Object value) {
        this.@"$name" = 'overridden'
    }
}

def pogo = new POGO()
pogo.property = 'a'

assert pogo.property == 'overridden'
```

#### 1.1.3 get/setMetaClass

你可以获取一个对象的`metaClass`或者是设置为你自己实现的`MetaClass`来覆盖默认的方法拦截机制:

```groovy
// getMetaclass
someObject.metaClass

// setMetaClass
someObject.metaClass = new OwnMetaClassImplementation()
```

### 1.2 get/setAttribute

这是`MetaClass`实现上的方法。默认的实现是你可以直接访问属性，而不会触发getter/setter：

```groovy
class SomeGroovyClass {

    def field1 = 'ha'
    def field2 = 'ho'

    def getField1() {
        return 'getHa'
    }
}

def someGroovyClass = new SomeGroovyClass()

assert someGroovyClass.metaClass.getAttribute(someGroovyClass, 'field1') == 'ha'
assert someGroovyClass.metaClass.getAttribute(someGroovyClass, 'field2') == 'ho'
```

```groovy
class POGO {

    private String field
    String property1

    void setProperty1(String property1) {
        this.property1 = "setProperty1"
    }
}

def pogo = new POGO()
pogo.metaClass.setAttribute(pogo, 'field', 'ha')
pogo.metaClass.setAttribute(pogo, 'property1', 'ho')

assert pogo.field == 'ha'
assert pogo.property1 == 'ho'
```

### 1.3 methodMissing

Groovy支持`methodMissing`的概念。和`invokeMethod`的区别是`methodMissing`只会在方法不存在时调用（更详细的解释见[Groovy探索之MOP 一 invokeMethod和methodMissing方法](http://blog.csdn.net/hivon/article/details/3019631)）

```groovy
class Foo {

   def methodMissing(String name, def args) {
        return "this is me"
   }
}

assert new Foo().someUnknownMethod(42l) == 'this is me'
```

使用`methodMissing`的典型场景是用于缓存函数调用的结果。

举个GORM中dynamic finders的例子，这个特性就是使用`methodMissing`实现的。代码大致是这样：

```groovy
class GORM {

   def dynamicMethods = [...] // an array of dynamic methods that use regex

   def methodMissing(String name, args) {
       def method = dynamicMethods.find { it.match(name) }
       if(method) {
          GORM.metaClass."$name" = { Object[] varArgs ->
             method.invoke(delegate, name, varArgs)
          }
          return method.invoke(delegate,name, args)
       }
       else throw new MissingMethodException(name, delegate, args)
   }
}
```

我们来看看是如何实现的，如果我们找到符合的方法进行调用，我们使用`ExpandoMetaClass`动态地注册这个新方法。这样，下次调用同一个方法时，就会直接调用这个方法，避免了再次搜索，提高了效率。这种使用`methodMissing`的方法，不需要覆盖`invokeMethod`，并且后续调用会快很多。

### 1.4 propertyMissing

Groovy支持`propertyMissing`的特性，当访问不存在的属性时，会触发这个方法。对于读访问，`propertyMissing`包含一个表示属性名的String类型的参数：

```groovy
class Foo {
   def propertyMissing(String name) { name }
}

assert new Foo().boo == 'boo'
```

`propertyMissing(String)`只会运行时找不到属性的getter方法时调用。

如果为不存在的属性赋值，可以使用包含一个额外value参数的`propertyMissing`来拦截：

```groovy
class Foo {
   def storage = [:]
   def propertyMissing(String name, value) { storage[name] = value }
   def propertyMissing(String name) { storage[name] }
}

def f = new Foo()
f.foo = "bar"

assert f.foo == "bar"
```

和`methodMissing`一样，使用它来动态注册新的属性到类上来加速之后的访问是最佳实践。

`methodMissing`和`propertyMissing`方法可以通过`ExpandoMetaClass`来添加静态方法和属性。

### 1.5 GroovyInterceptable

`groovy.lang.GroovyInterceptable`接口是一个没有方法的标记接口，他用于让Groovy运行时在运行这个对象时，所有这个对象上的方法，都要被方法派发机制拦截。

```groovy
package groovy.lang;

public interface GroovyInterceptable extends GroovyObject {
}
```

当一个Groovy对象实现了`GroovyInterceptable`接口，他的`invokeMethod()`会在所有方法调用时被触发。看例子：

```groovy
class Interception implements GroovyInterceptable {

    def definedMethod() { }

    def invokeMethod(String name, Object args) {
        'invokedMethod'
    }
}
```

下面的测试可以发现，不管是存在的方法还是不存在的方法都被`invokeMethod`方法拦截了：

```groovy
class InterceptableTest extends GroovyTestCase {

    void testCheckInterception() {
        def interception = new Interception()

        assert interception.definedMethod() == 'invokedMethod'
        assert interception.someMethod() == 'invokedMethod'
    }
}
```

我们不能使用默认的groovy方法，比如`println`，因为这些方法被注入到了所有的groovy对象中，所以他们也会被拦截。

如果我们想拦截所有方法但是不想实现`GroovyInterceptable`接口，我们可以在一个对象上的`MetaClass`中实现`invokeMethod()`方法。这个方法在POGO和POJO上都有效：

```groovy
class InterceptionThroughMetaClassTest extends GroovyTestCase {

    void testPOJOMetaClassInterception() {
        String invoking = 'ha'
        invoking.metaClass.invokeMethod = { String name, Object args ->
            'invoked'
        }

        assert invoking.length() == 'invoked'
        assert invoking.someMethod() == 'invoked'
    }

    void testPOGOMetaClassInterception() {
        Entity entity = new Entity('Hello')
        entity.metaClass.invokeMethod = { String name, Object args ->
            'invoked'
        }

        assert entity.build(new Object()) == 'invoked'
        assert entity.someMethod() == 'invoked'
    }
}
```

### 1.6 Categories

有时候让对象失控或者是拥有额外的方法是特别有用的。为了能够提供这种能力，Groovy实现了一种向Object-C学来的特性：`Categories`。

Categories是使用所谓的`category classes`来实现的。

Groovy内置了一些categories，这些categories为现有类添加了一些有用的方法，让他们在Groovy环境下更加有用：

- groovy.time.TimeCategory
- groovy.servlet.ServletCategory
- groovy.xml.dom.DOMCategory

Category类默认是不启用的。为了使用定义在Category中的方法，需要使用`use`方法：

```groovy
use(TimeCategory)  {
    println 1.minute.from.now  // TimeCategory adds methods to Integer
    println 10.hours.ago

    def someDate = new Date()       
    println someDate - 3.months  // TimeCategory adds methods to Date
}
```

`use`方法的第一个参数是category类，第二个参数是闭包。在闭包中的代码可以使用category类中定义的方法。比如上面的例子，TimeCategory类在`java.lang.Integer`和`java.util.Date`上添加了一些方便的时间操作函数，在use的闭包参数中，我们就可以调用这些方法。

一个Category不一定要直接暴露到用户代码中，看下面这个例子：

```groovy
class JPACategory{
  // Let's enhance JPA EntityManager without getting into the JSR committee
  static void persistAll(EntityManager em , Object[] entities) { //add an interface to save all
    entities?.each { em.persist(it) }
  }
}

def transactionContext = {
  EntityManager em, Closure c ->
  def tx = em.transaction
  try {
    tx.begin()
    use(JPACategory) {
      c()
    }
    tx.commit()
  } catch (e) {
    tx.rollback()
  } finally {
    //cleanup your resource here
  }
}

// user code, they always forget to close resource in exception, some even forget to commit, let's not rely on them.
EntityManager em; //probably injected
transactionContext (em) {
 em.persistAll(obj1, obj2, obj3)
 // let's do some logics here to make the example sensible
 em.persistAll(obj2, obj4, obj6)
}
```

看`groovy.time.TimeCategory`的源码会发现所有的扩展方法都是static方法。这是Category扩展方法必须遵守的：

```groovy
public class TimeCategory {

    public static Date plus(final Date date, final BaseDuration duration) {
        return duration.plus(date);
    }

    public static Date minus(final Date date, final BaseDuration duration) {
        final Calendar cal = Calendar.getInstance();

        cal.setTime(date);
        cal.add(Calendar.YEAR, -duration.getYears());
        cal.add(Calendar.MONTH, -duration.getMonths());
        cal.add(Calendar.DAY_OF_YEAR, -duration.getDays());
        cal.add(Calendar.HOUR_OF_DAY, -duration.getHours());
        cal.add(Calendar.MINUTE, -duration.getMinutes());
        cal.add(Calendar.SECOND, -duration.getSeconds());
        cal.add(Calendar.MILLISECOND, -duration.getMillis());

        return cal.getTime();
    }

    // ...
```

另外一个要求是，静态方法的第一个参数是想要扩展的目标对象实例，剩下的参数是调用时传入的普通参数。

因为参数和静态方法的这些规定，导致category方法可能不太像普通方法一样符合直觉。对此，Groovy提供了一个`@Category`注解来在编译时转换一个普通对象为category对象。

```groovy
class Distance {
    def number
    String toString() { "${number}m" }
}

@Category(Number)
class NumberCategory {
    Distance getMeters() {
        new Distance(number: this)
    }
}

use (NumberCategory)  {
    assert 42.meters.toString() == '42m'
}
```

使用`@Category`注解的好处是不用让每个扩展方法的第一个参数是被扩展对象了，被扩展对象作为注解的参数出传入。

### 1.7 Metaclasses

(官方文档未完成)

#### 1.7.1. Custom metaclasses

(官方文档未完成)

#### 1.7.2. Per instance metaclass

(官方文档未完成)

#### 1.7.3. ExpandoMetaClass

Groovy提供了一个特殊的`MetaClass`叫做`ExpandoMetaClass`。这个类特殊在他可以动态地添加或者修改方法，构造函数，属性，甚至是静态方法。

这个特性在mocking和stubbing时是非常有用的。

甚至`java.lang.Class`，Groovy都提供了一个`metaClass`属性，这个属性是指向`ExpandoMetaClass`的引用。这个实例可以用于修改现有对象的行为。

默认`ExpandoMetaClass`不会继承。如果想要开启这个特性，需要正在程序启动时调用`ExpandoMetaClass#enableGlobally()`。

下面介绍`ExpandoMetaClass`在不同场景下的使用。

##### Methods

使用`metaClass`属性获取`ExpandoMetaClass`引用后，就可以使用左移`<<`或者是`=`来添加方法。

注意，左移用于“追加”新方法。如果一个拥有相同名字，参数的public方法已经在class或者interface中定义了，包括在父class和父interface中定义的，但是不包括运行时添加到`metaClass`上的，那么在使用`<<`时会抛出一个异常。如果你想要“替换”已经存在的方法，可以使用`=`操作符。


```groovy
class Book {
   String title
}

Book.metaClass.titleInUpperCase << {-> title.toUpperCase() }

def b = new Book(title:"The Stand")

assert "THE STAND" == b.titleInUpperCase()
```

##### Properties

`ExpandoMetaClass`支持两种添加或者覆盖属性的机制。

第一种，通过直接给`metaClass`的属性赋值来声明一个可变属性：

```groovy
class Book {
   String title
}

Book.metaClass.author = "Stephen King"
def b = new Book()

assert "Stephen King" == b.author
```

另外一种方法是使用上面提到的添加方法的方式添加getter/setter方法：

```groovy
class Book {
  String title
}
Book.metaClass.getAuthor << {-> "Stephen King" }

def b = new Book()

assert "Stephen King" == b.author
```

上面这个例子通过添加getter方法声明了一个属性，这个属性是只读的。你可以添加对应的setter方法。

##### Constructors

可以使用特殊的`constructor`属性来添加构造函数。可以用`<<`或`=`操作符来添加闭包，闭包的参数会作为构造函数的参数。

```groovy
class Book {
    String title
}
Book.metaClass.constructor << { String title -> new Book(title:title) }

def book = new Book('Groovy in Action - 2nd Edition')
assert book.title == 'Groovy in Action - 2nd Edition'
```

在添加构造函数时要注意，因为他容易陷入stack overflow问题。（不太懂）

##### Static Methods

添加静态方法和添加普通方法是一样的，不过需要添加在`static`这个限定符下：

```groovy
class Book {
   String title
}

Book.metaClass.static.create << { String title -> new Book(title:title) }

def b = Book.create("The Stand")
```

##### Borrowing Methods 方法借用

集合Groovy的方法指针语法，ExpandoMetaClass可以从别的类上“借用”方法：

```groovy
class Person {
    String name
}
class MortgageLender {
   def borrowMoney() {
      "buy house"
   }
}

def lender = new MortgageLender()

Person.metaClass.buyHouse = lender.&borrowMoney

def p = new Person()

assert "buy house" == p.buyHouse()
```

##### Dynamic Method Names 动态方法名

因为Groovy支持使用字符串作为属性的名称，因此也支持在运行时动态的新建方法和属性名称：

```groovy
class Person {
   String name = "Fred"
}

def methodName = "Bob"

Person.metaClass."changeNameTo${methodName}" = {-> delegate.name = "Bob" }

def p = new Person()

assert "Fred" == p.name

p.changeNameToBob()

assert "Bob" == p.name
```

##### Runtime Discovery 动态发现

在运行时检查是否有其他属性或者方法存在是非常有用的特性，`ExpandoMetaClass`提供了一下方法来实现这个功能：

- getMetaMethod
- hasMetaMethod
- getMetaProperty
- hasMetaProperty

为什么不能直接用反射呢？因为Groovy是不一样的，他可以有只有在运行时才存在的方法。运行时能调用的方法被称为MetaMethods。

##### GroovyObject Methods

`ExpandoMetaClass`的另外一个特性是他允许你覆盖方法`invokeMethod`,`getProperty`和`setProperty`，这些方法都是`groovy.lang.GroovyObject`中的方法。

下面是覆盖`invokeMethod`方法的例子：

```java
class Stuff {
   def invokeMe() { "foo" }
}

Stuff.metaClass.invokeMethod = { String name, args ->
   def metaMethod = Stuff.metaClass.getMetaMethod(name, args)
   def result
   if(metaMethod) result = metaMethod.invoke(delegate,args)
   else {
      result = "bar"
   }
   result
}

def stf = new Stuff()

assert "foo" == stf.invokeMe()
assert "bar" == stf.doStuff()
```

`MetaMethod`是存在`MetaClass`上的方法，无论是运行时还是编译时添加的。

同样的逻辑可以用于覆盖`setProperty`或者`getProperty`：

```java
class Person {
   String name = "Fred"
}

Person.metaClass.getProperty = { String name ->
   def metaProperty = Person.metaClass.getMetaProperty(name)
   def result
   if(metaProperty) result = metaProperty.getProperty(delegate)
   else {
      result = "Flintstone"
   }
   result
}

def p = new Person()

assert "Fred" == p.name
assert "Flintstone" == p.other
```

##### Overriding Static invokeMethod 覆盖静态invokeMethod

`ExpandoMetaClass`甚至允许你覆盖静态方法，方法是使用特殊的`invokeMethod`语法：

```java
class Stuff {
   static invokeMe() { "foo" }
}

Stuff.metaClass.'static'.invokeMethod = { String name, args ->
   def metaMethod = Stuff.metaClass.getStaticMetaMethod(name, args)
   def result
   if(metaMethod) result = metaMethod.invoke(delegate,args)
   else {
      result = "bar"
   }
   result
}

assert "foo" == Stuff.invokeMe()
assert "bar" == Stuff.doStuff()
```

和覆盖普通方法基本一样，不一样的地方是访问`metaClass.static`和调用`getStaticMethodName`方法。

##### Extending Interfaces 扩展接口

使用`ExpandoMetaClass`可以添加方法到接口上。不过你需要开启这个特性，开启的方法是在程序运行的入口处调用`ExpandoMetaClass.enableGlobally()`。

```java
List.metaClass.sizeDoubled = {-> delegate.size() * 2 }

def list = []

list << 1
list << 2

assert 4 == list.sizeDoubled()
```

### 1.8 Extension modules 扩展模块

#### 1.8.1 Extending existing classes 扩展现有的类

使用扩展模块可以在现有的类上添加方法，包含那些已经编译好的类，比如JDK中的类。这些新方法，不像定义在metaclass或者category上的类，这些新方法是在全局有效的，比如：

```java
def file = new File(...)
def contents = file.getText('utf-8')
```

这里的`getText`方法是不存在在File类上的。但是Groovy知道他的存在，因为有一个特殊的类`ResourceGroovyMethods`：

```java
public static String getText(File file, String charset) throws IOException {
 return IOGroovyMethods.getText(newReader(file, charset));
}
```

你可以发现，一个扩展方法是被定义为static的，被定义在一个帮助类里，方法的第一个参数是被扩展的类，剩下的方法是传入扩展方法的参数。

定义一个扩展模块是非常简单的：

- 编写一个扩展类
- 编写模块描述文件

然后你要让Groovy能感知到你的扩展模块，这只要让你的扩展模块类和描述文件在classpath中即可，所以你有两个选择：

- 让扩展模块类和描述文件在classpath中
- 打包扩展模块到jar中以便于使用

扩展模块可以为类添加两种方法：

- 实例方法
- 静态方法

#### 1.8.4 Module descriptor 模块描述文件

为了让Groovy能加载你的扩展方法，你需要声明你的扩展帮助类，你需要定义一个名为`org.codehaus.groovy.runtime.ExtensionModule`到`META-INF/services`目录下：

```
moduleName=Test module for specifications
moduleVersion=1.0-test
extensionClasses=support.MaxRetriesExtension
staticExtensionClasses=support.StaticStringExtension
```

模块描述文件需要4个字段：

- moduleName：模块的名字
- moduleVersion：模块的版本
- extensionClasses：扩展版主类的列表，这些类提供的扩展方法是实例方法
- staticExtensionClasses：扩展版主类的列表，这些类提供的扩展方法是静态方法