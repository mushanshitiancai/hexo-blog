---
title: 说说maven依赖冲突，依赖调解，依赖传递和依赖范围
date: 2016-07-29 09:58:30
categories: [Java]
tags: [java,maven]
---

说maven依赖冲突之前需要先说说maven的 **依赖传递**。

## 依赖传递
当前项目引入了一个依赖，该依赖的依赖也会被引入项目。更加准确的说法是，maven会解析直接依赖的POM，将那些必要的间接依赖，以传递依赖的形式引入到当前项目中。

为什么说是’必要的间接依赖‘呢？这是因为不是所有的间接依赖都会被引入的。这还得说说maven的 **依赖范围**。

## 依赖范围
maven引入依赖，并不是把jar包拷贝到项目中来，而是把jar包下载到本地仓库，然后通过制定classpath来在项目中引入具体的jar包。maven管理着3套classpath，分别是 **编译classpath**，**测试classpath**，**运行classpath**。

依赖范围就是用来控制着3个classpath的，maven的依赖范围有：

- **compile**: 编译依赖范围。对全部classpath都有效。例子：spring-core
- **test**: 测试依赖范围。只对测试classpath有效。例子：junit
- **provided**: 已提供依赖范围。对编译和测试classpath有效。例子：servlet-api
- **runtime**: 运行时依赖范围。对测试和运行classpath有效。例子：JDBC驱动
- **system**: 系统依赖范围。对编译和测试classpath有效。通过systemPath显式指定。
- **import**: 导入依赖范围。不会对classpath产生影响。

依赖范围除了控制classpath，还会对依赖传递产生影响。如果A依赖B，B依赖C，则A对于B是第一直接依赖。B对于C是第二直接依赖。A对于C是传递性依赖。结论是：第一直接依赖的范围和第二直接依赖的范围决定了传递性依赖的范围。

用《Maven实战》上的表格来说明：

| 第一直接依赖\第二直接依赖    | compile  | test | provided | runtime  |
|---------------------------|----------|------|----------|----------|
| compile                   | compile  | -    | -        | runtime  |
| test                      | test     | -    | -        | test     |
| provided                  | provided | -    | provided | provided |
| runtime                   | runtime  | -    | -        | runtime  |

第一列是第一直接依赖，第一行是第二直接依赖，中间表示传递性依赖范围。

## 依赖冲突和依赖调解
真是因为依赖传递，所以才带来了依赖冲突的可能。比如A->X(1.0)，A->B->X(2.0)。A直接依赖了1.0版本的X，而A依赖的B依赖了2.0版本的X。如果依赖范围合适的话，B中依赖的X也是会传递到A项目中的。而两个X的版本不一致，这就产生了依赖冲突。

在依赖冲突发生时，maven不会直接提示错误，而是用一套规则来进行 **依赖调解**。规则有两条：

1. 路径最近者优先。
2. 第一声明者优先。

依赖路径指的是项目到依赖的长度，比如A->X(1.0)长度为1，A->B->X(2.0)长度为2，所以最终会使用1.0版本的X。

如果两者的路径一样呢？比如A->B->X(2.0)和A->C->X(3.0)，这两个依赖路径的长度都是2，那用哪个呢？这就需要第二个规则了，也就是哪个先声明就用哪个。

大部分情况下maven这种自动的依赖调解能帮我们解决问题了。但是有时候我们不得不手动处理依赖冲突。这种冲突可能不是同一个依赖的不同版本（这个依赖调解能搞定），而是不能同时出现的两个依赖。比如slf4j-log4j和logback这两个依赖是不能同时出现的，但是因为他们的坐标不一样，所以maven不会对齐进行处理。这个时候我们就需要手动进行 **排除依赖** 了。

## 排除依赖
下面的例子就是排除依赖的例子，排除依赖的时候就不用指定版本了：

```
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>2.5.3</version>
    <exclusions>
        <exclusion>
            <groupId>org.springframework</groupId>
            <artifactId>spring</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

这种排除是很方便来了，如果有许多相同的间接依赖需要排除的话，会比较麻烦，可以参考：[maven实现依赖的“全局排除”](http://my.oschina.net/liuyongpo/blog/177301)

## 检查依赖冲突
因为maven在依赖冲突发生时使用依赖调解，所以不会有任何提示。那我们要如何检查呢？方法有两种。

第一种是使用`mvn dependency:tree -Dverbose`来列出项目的所有依赖以及传递性依赖。对于重复和冲突的依赖，会提示`omitted for duplicate`和`omitted for conflict with x.x.x`。

第二个方法是使用maven的enforcer插件。在项目POM中加入：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-enforcer-plugin</artifactId>
            <version>1.4.1</version>
            <executions>
                <execution>
                    <id>enforce</id>
                    <configuration>
                        <rules>
                            <dependencyConvergence/>
                        </rules>
                    </configuration>
                    <goals>
                        <goal>enforce</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

这样在用maven编译时，如果存在依赖冲突，就会有错误提示：

```Dependency convergence error for org.slf4j:slf4j-api1.6.1 paths to dependency are:
 
[ERROR]
Dependency convergence error for org.slf4j:slf4j-api:1.6.1 paths to dependency are:
+-org.myorg:my-project:1.0.0-SNAPSHOT
  +-org.slf4j:slf4j-jdk14:1.6.1
    +-org.slf4j:slf4j-api:1.6.1
and
+-org.myorg:my-project:1.0.0-SNAPSHOT
  +-org.slf4j:slf4j-nop:1.6.0
    +-org.slf4j:slf4j-api:1.6.0
```

## 参考资料
- 《Maven实战》
- [maven实现依赖的“全局排除” - liuyongpo的个人空间 - 开源中国社区](http://my.oschina.net/liuyongpo/blog/177301)
- [Maven依赖排除 禁止依赖传递 取消依赖的方法 - 推酷](http://www.tuicool.com/articles/uyuURfq)

