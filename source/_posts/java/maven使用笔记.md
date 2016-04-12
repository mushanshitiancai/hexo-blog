---
title: maven使用笔记
date: 2016-04-11 20:16:19
tags: java
---

maven是Java世界中必回的一个工程管理工具。

<!-- more -->

## 安装

## 约定优于配置
maven使用约定优于配置，他提供了一套默认的项目结构：

```
project-dir             // 项目根目录，存放pom.xml和所有其他目录
├── pom.xml             // Project Object Model
└── src
    ├── main
    │   ├── java        // 项目Java源代码
    │   └── resources   // 项目资源，比如property文件
    └── test
        └── java        // 项目的测试代码
        └── resources   // 测试用的资源
```

## 新建工程

    $ mvn archetype:generate

不带其他参数，maven就会进入交互建立工程模式。

第一次运行，maven会下载很多依赖。然后会列出一个项目原型列表，有很多，我看到的有1500多条。maven默认的选择是766，也就是`maven-archetype-quickstart`。接下来会让你选择哪一个版本的原型，默认选择的是最新版本，回车即可。

接下来需要输入`groupId`,`artifactId`,`version`,`package`,只要是提供了默认选项的，都可以直接按回车返回。

> GroupID是项目组织唯一的标识符，实际对应JAVA的包的结构，是main目录里java的目录结构。
> ArtifactID就是项目的唯一的标识符，实际对应项目的名称，就是项目根目录的名称。
> 一般GroupID就是填com.mushan.test这样子。
> 
> -- [maven GroupID和ArtifactID填什么](http://zhidao.baidu.com/link?url=wCZVG9JcHwP-nYaUK4izNdcYSeSGA5-dd99_K2nOsPSTvA6o6M1-oSJFHKC4P-szB1YC1vEN5Ei1AUAAuprIG_)

```
Define value for property 'groupId': : com.mushan
Define value for property 'artifactId': : mvn-test
Define value for property 'version':  1.0-SNAPSHOT: :
Define value for property 'package':  com.mushan: :
Confirm properties configuration:
groupId: com.mushan
artifactId: mvn-test
version: 1.0-SNAPSHOT
package: com.mushan
```

建立后的目录工程为：

```
.
├── pom.xml
└── src
    ├── main
    │   └── java
    │       └── com
    │           └── mushan
    │               └── App.java
    └── test
        └── java
            └── com
                └── mushan
                    └── AppTest.java
```

`maven-archetype-quickstart`在App.java中写好了hello world的代码。

### 直接指定选项
也可以直接在命令中指定选项：

    $ mvn archetype:generate -B -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.1 -DgroupId=com.company -DartifactId=project -Dversion=1.0-SNAPSHOT -Dpackage=com.company.project

这里的`-B`选项，是批量模式也就是不进行互动的意思：

    -B,--batch-mode                        Run in non-interactive (batch)

### 过滤列表
默认会列出所有的项目原型，选择麻烦，可以进行过滤，格式是：[groupId:]artifactId：

    $ mvn archetype:generate -Dfilter=org.apache:struts

或者是在交互模式下过滤：

    $ mvn archetype:generate
    
    ...

    Choose a number or apply filter (format: [groupId:]artifactId, case sensitive contains): org.apache:struts

比如我们想要看maven官方的工程原型可以使用`org.apache.maven.archetypes:`过滤。

## 运行工程

    $ mvn package

执行后，工程目录下多出一个`target`目录。编译后的jar文件在这目录中，编译的class文件在`target/classes/`中。

让我执行这个hello world：

    $ java -cp target/mvn-test-1.0-SNAPSHOT.jar com.mushan.App

## POM(Project Object Model)
项目对象模型。从名字可以看得出来，maven践行了Java世界中的一切皆对象的设计，在项目管理上也使用了面对对象的设计。

看一下我刚刚建立的工程的pom文件：

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.mushan</groupId>
  <artifactId>mvn-test</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>jar</packaging>

  <name>mvn-test</name>
  <url>http://maven.apache.org</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```

POM文件的根节点是`project`。`modelVersion`指定了pom的版本。

`groupId`, `artifactId`, `packaging`, `version`这四个属性被称之为`maven坐标`，他唯一确定一个项目。在maven中，我们使用项目坐标来指定依赖的第三方项目，父项目，插件。一般可以这么写：

    groupId:artifactId:packaging:version

我们的项目就是

    com.mushan:mvn-test:jar:1.0-SNAPSHOT

小工程可能体现不出来项目对象模型中'对象'的这一层设计。在大的项目中，会分为很多小项目，他们都属于一个父项目，所以就可以继承同一个POM。在这个POM中指定这个大项目通用的配置。

所有的POM都默认继承于一个Super-POM，也就是mvn内置的一个POM，其指定了'约定优于配置'中的约定，也就是之前提到的默认项目结构。

如果你想要看一下实际的，包含了继承信息的POM，可以这么看：

    $ mvn help:effective-pom

## 生命周期
生命周期指的是项目的一个构建过程。maven提供了一套默认的生命周期，以及其绑定的插件目标：

```
process-resources 阶段：resources:resources
compile 阶段：compiler:compile
process-classes 阶段：(默认无目标)
process-test-resources 阶段：resources:testResources
test-compile 阶段：compiler:testCompile
test 阶段：surefire:test
prepare-package 阶段：(默认无目标)
package 阶段：jar:jar
```

## 安装依赖

```
<dependencies> 
  <dependency> 
    <groupId>junit</groupId> 
    <artifactId>junit</artifactId> 
    <version>3.8.1</version> 
    <scope>test</scope> 
  </dependency> 
</dependencies> 
```

## 安装项目到本地库

    $ mvn install

这样你就可以在你自己的项目中使用安装的项目了。


## 参考资料
- [Apache Maven 入门篇 ( 上 )](http://www.oracle.com/technetwork/cn/community/java/apache-maven-getting-started-1-406235-zhs.html)
- [Apache Maven 入门篇 ( 下 )](http://www.oracle.com/technetwork/cn/community/java/apache-maven-getting-started-2-405568-zhs.html)
