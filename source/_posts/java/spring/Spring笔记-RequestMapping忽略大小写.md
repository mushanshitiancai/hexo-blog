---
title: Spring笔记-RequestMapping忽略大小写
date: 2017-04-12 15:50:39
categories: [Java,Spring]
tags: [java,spring]
---

```xml
<mvc:annotation-driven>
    <mvc:path-matching path-matcher="pathMatcher"/>
</mvc:annotation-driven>

<bean id="pathMatcher" class="org.springframework.util.AntPathMatcher">
    <property name="caseSensitive" value="false"/>
</bean>
```

[Spring Framework Reference Documentation](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#websocket-stomp-destination-separator)

