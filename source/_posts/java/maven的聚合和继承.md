---
title: maven的聚合和继承
date: 2016-08-01 11:10:05
categories: [Java]
tags: [java,maven]
---

maven是用面向对象的方式来管理项目的，所以OO里的聚合和继承在maven世界中也是有对应实现的。

## 聚合
一个大的项目一般都会多个模块，如果只能单独处理每个模块，那会是非常低效的。比如构建大项目还得单独构建每个模块。这时就可以使用聚合。我们可以建立一个`聚合模块`，然后他把其他的模块聚合到一起。

聚合模块也是一个普通的maven项目，但是他的packaging的值为pom。在聚合模块中执行构建，会先构建本身，然后会构建其所有子模块。

我们现在测试一下，新建一个test模块，是聚合模块，其中包含两个子模块，分别是test-1和test-2：

```
$ mvn archetype:generate -B -DarchetypeCatalog=internal -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=com.mushan -DartifactId=test -Dversion=1.0-SNAPSHOT -Dpackage=com.mushan
$ cd test
$ mvn archetype:generate -B -DarchetypeCatalog=internal -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=com.mushan -DartifactId=test-1 -Dversion=1.0-SNAPSHOT -Dpackage=com.mushan
```

运行到这一部时，新建maven提示出错：

```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-archetype-plugin:2.4:generate (default-cli) on project test: Unable to add module to the current project as it is not of packaging type 'pom' -> [Help 1]
```

说明在maven项目中执行`mvn archetype:generate`，是会检查当前目录是不是一个maven项目，如果他发现当前目录是一个maven项目，就会认为你在建立一个子模块，这时他还会检查当前maven项目的packaging的值是否为pom，如果不是则报错。因为只有packaging的值为pom的项目才能包含子模块。

所以我们修改一下test模块的pom，然后继续：

```
$ mvn archetype:generate -B -DarchetypeCatalog=internal -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=com.mushan -DartifactId=test-1 -Dversion=1.0-SNAPSHOT -Dpackage=com.mushan
$ mvn archetype:generate -B -DarchetypeCatalog=internal -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=com.mushan -DartifactId=test-2 -Dversion=1.0-SNAPSHOT -Dpackage=com.mushan
```

这时项目的目录结构是：

```
.
├── src
├── test-1
│   ├── src
│   └── pom.xml
├── test-2
│   ├── src
│   └── pom.xml
└── pom.xml
```

同时，查看test下的pom.xml，会发现多了一段：

```
<modules>
    <module>test-1</module>
    <module>test-2</module>
</modules>
```

就是这个modules配置，告知聚合模块，那些子模块被聚合进来了。需要注意的是，不要被迷惑了，这里的module配置不是指的是子模块的artifactId，而是子模块的**路径**！

因为maven新建项目时，目录的名字等于项目的artifactId。但是这个不是一个强规则，项目的目录名字是可以随意取的。你把test-1的目录改为test-11，然后同时修改module的值，会发现一切正常。

同时还需要说明的是，常规的聚合项目的结构是父子结构关系，但是这也不是必须的，子模块的位置可以是任意的，只要module指定好路径即可。一种比较常见的做法是平行目录结构，也就是子模块的目录和聚合模块的目录是平行的，这时，module的取值大概是这样的：

```
<modules>
    <module>../test-1</module>
    <module>../test-2</module>
</modules>
```

还有一个问题，聚合项目本身可以拥有代码么？我们可以编译试试：

```
$ mvn package
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO]
[INFO] test
[INFO] test-1
[INFO] test-2
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building test 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building test-1 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ test-1 ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/mazhibin/project/xxx/mvn/test/test-1/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ test-1 ---
[INFO] Nothing to compile - all classes are up to date
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ test-1 ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/mazhibin/project/xxx/mvn/test/test-1/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ test-1 ---
[INFO] Nothing to compile - all classes are up to date
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ test-1 ---
[INFO] Surefire report directory: /Users/mazhibin/project/xxx/mvn/test/test-1/target/surefire-reports

-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.mushan.AppTest
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.007 sec

Results :

Tests run: 1, Failures: 0, Errors: 0, Skipped: 0

[INFO]
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ test-1 ---
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building test-2 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ test-2 ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/mazhibin/project/xxx/mvn/test/test-2/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ test-2 ---
[INFO] Nothing to compile - all classes are up to date
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ test-2 ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/mazhibin/project/xxx/mvn/test/test-2/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ test-2 ---
[INFO] Nothing to compile - all classes are up to date
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ test-2 ---
[INFO] Surefire report directory: /Users/mazhibin/project/xxx/mvn/test/test-2/target/surefire-reports

-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.mushan.AppTest
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.009 sec

Results :

Tests run: 1, Failures: 0, Errors: 0, Skipped: 0

[INFO]
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ test-2 ---
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO]
[INFO] test ............................................... SUCCESS [  0.002 s]
[INFO] test-1 ............................................. SUCCESS [  1.784 s]
[INFO] test-2 ............................................. SUCCESS [  0.263 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.224 s
[INFO] Finished at: 2016-08-01T11:24:19+08:00
[INFO] Final Memory: 12M/309M
[INFO] ------------------------------------------------------------------------
```

执行完后，发现test-1和test-2中都生成了target目录，而test目录下没有，说明 **聚合项目不包含除了pom之外的文件，构建项目时不会编译聚合项目**

同时我们可以看到，构建聚合项目test的时候，maven说明了他的构建顺序：

```
[INFO] Reactor Build Order:
[INFO]
[INFO] test
[INFO] test-1
[INFO] test-2
```

这也就是聚合项目的作用所在了。

## 继承
聚合虽然解决了多模块构建的问题，但是没有解决另外一个问题，就是配置重复。一个大项目下的多个模块一般有许多一样的配置，有没有办法统一配置呢？有的，继承。

类似于OO中父类的属性可以被子类使用一样，父pom的属性也可以被子pom使用，这就是maven继承的思想。父模块也是一个普通的maven项目，他的作用是提供一个父pom，所以这个项目也不需要除了pom文件之外的文件。同时父pom的packaging的值也必须是'pom'。

同时，父模块也应该被聚合到聚合模块中。

我们可以新建一个test-1和test-2共享的父模块：

```
$ mvn archetype:generate -B -DarchetypeCatalog=internal -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=com.mushan -DartifactId=test-parent -Dversion=1.0-SNAPSHOT -Dpackage=com.mushan
```

修改test-parent的packaging为pom。然后修改test-1继承于test-parent：

```
<parent>
  <groupId>com.mushan</groupId>
  <artifactId>test-parent</artifactId>
  <version>1.0-SNAPSHOT</version>
</parent>
```

你在修改test-1的时候，应该发现了，test-1已经有parent这个属性了，而且配置的是test。为什么配置为聚合项目了呢？这个是maven默认在新建子模块的时候使用了混合聚合继承模式，这个我们之后再讲。

如何测试test-1是否继承成功了呢？我们可以在test-parent中添加一个依赖，然后看看test-1中是否继承了这个依赖。在test-parent的pom中添加：

```
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
    <version>1.7.13</version>
</dependency>
```

然后在test-1中执行：

```
$ mvn dependency:list

[ERROR]     Non-resolvable parent POM for com.mushan:test-1:1.0-SNAPSHOT: Could not find artifact com.mushan:test-parent:pom:1.0-SNAPSHOT in release  and 'parent.relativePath' points at wrong local POM @ line 5, column 11 -> [Help 2]
```

提示找不到test-parent。这是因为我们没有把test-parent安装到本地仓库中，所以找不到。那如果每次我修改test-parent，都要install一遍子模块中才能生效，会不会太麻烦了点。还好maven的parent配置是可以指定父模块的目录位置的：

```
<parent>
  <groupId>com.mushan</groupId>
  <artifactId>test-parent</artifactId>
  <version>1.0-SNAPSHOT</version>
  <relativePath>../test-parent/pom.xml</relativePath>
</parent>
```

在构建项目的时候，maven会先去relativePath的位置找，如果找不到，再去仓库中查找。

再执行`mvn dependency:list`，可以看到子模块使用了slf4j，说明继承了配置。

```
[INFO] The following files have been resolved:
[INFO]    junit:junit:jar:3.8.1:test
[INFO]    org.slf4j:slf4j-api:jar:1.7.13:compile
```

### 使用继承继续依赖管理
我们可以在父pom中定义所有子模块都需要使用到的依赖，这些配置会直接被继承到子模块中。那那些只会有部分子模块会使用到的依赖呢？这时候可以使用dependencyManagement这个属性。

dependencyManagement既能让子模块继承到父模块的依赖配置信息，又能保证子模块依赖使用的灵活性。dependencyManagement下的依赖不会被真的引入到项目中，但是能够约束dependencies下的依赖。

比如我们在test-parent中添加dependencyManagement配置

```
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.13</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

这个配置实际上不会引入任何依赖。但是子模块中可以这样配置：

```
<dependencies>
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
    </dependency>
</dependencies>
```

只需要指定groupId和artifactId，其他的依赖配置信息，子模块会到父模块的dependencyManagement中寻找。所以使用dependencyManagement，可以规范依赖的配置，而具体引入不引入，子模块可以自己选择。

## 混合聚合和继承
聚合和继承是两个概念，但是他们有相同点：

- 聚合模块和父模块的packaging都等于pom
- 聚合模块和父模块都没有除了pom.xml之外的其他内容

既然聚合模块和父模块的作用都是提供一个pom.xml，那一个模块能不能既是聚合模块也是父模块呢？完全可以，而且目前最佳实践就是这么做。

当使用mvn命令新建test-1模块时，maven在test的pom中添加了modules的配置，同时在test-1的pom中添加了parent的配置。这就是说test模块既是test-1的聚合模块，也是test-1的父模块，所以我们可以直接在test的pom中定义依赖等其他需要被继承的配置即可。

而且如实父模块就是聚合模块，可以不用指定relativePath属性，因为maven会自动找到上级目录的父模块。

## 总结

- 聚合模块和父模块只需要有pom.xml文件即可。不能有代码，不会进行编译
- 聚合模块中module的值是被聚合模块的目录位置
- 子模块中可以指定relativePath的值，来直接定位父模块的位置
- 可以在父模块中通过dependencyManagement规范依赖配置
- 最佳实践是结合聚合和继承，让一个项目既是聚合模块也是父模块，maven在新建项目时就是这么做的

## 参考资料
- 《Maven实战》