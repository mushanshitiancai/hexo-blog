---
title: Spring笔记-Spring Security学习
date: 2017-06-09 17:09:36
categories: [Java,Spring]
tags: [java,spring]
---

问题：
- Spring Security是干嘛的？
- Spring Security如何配置？
- Spring Security如何设置需要被保护的URL？
- Spring Security如何设置获取用户角色信息的策略？
- Spring Security如何自定义登录页面？
- Spring Security如何自定义退出页面？
- Spring Security如何设置权限验证失败后的处理？

## Spring Security是干嘛的？

Spring Security是一个能够为基于Spring的企业应用系统提供声明式的安全访问控制解决方案的安全框架。它提供了一组可以在Spring应用上下文中配置的Bean，充分利用了Spring IoC，DI（控制反转Inversion of Control ,DI:Dependency Injection 依赖注入）和AOP（面向切面编程）功能，为应用系统提供声明式的安全访问控制功能，减少了为企业系统安全控制编写大量重复代码的工作。

我的理解是，我们在需要验证用户权限时，从零开始的做法是我们从cookie/session中提取用户信息，如果没有，那么提示错误或者让用户去登录，如果用户已经登录，我们就通过用户id去数据库查询用户的角色/权限信息，然后判断是否可以执行。而Spring Security就是提取了这些操作共性加高度可配置的安全中间件。使用Spring Security我们不需要完全手写这些功能，只需要配置策略即可。对于需要定制的地方，通过自定义扩展配置搞定。

## Spring Security如何配置？

参考[Spring笔记-Spring配置 | 木杉的博客](http://mushanshitiancai.github.io/2017/06/07/java/spring/Spring%E7%AC%94%E8%AE%B0-Spring%E9%85%8D%E7%BD%AE/)，引入Spring Security，我们需要添加新的`WebApplicationInitializer`实现，Spring Security提供了`AbstractSecurityWebApplicationInitializer`抽象类，我们直接继承即可。这个Initializer中初始化了Spring Security一些相关配置。

配置的结构图如下：

![](/img/java/spring/security-config.png)

配置代码：

```java
public class MyWebApplicationInitializer implements WebApplicationInitializer{
    public void onStartup(ServletContext servletContext) throws ServletException {
        ServletRegistration.Dynamic registration = servletContext.addServlet("test", new DispatcherServlet());
        registration.setLoadOnStartup(1);
        registration.addMapping("/*");
        registration.setInitParameter("contextClass", "org.springframework.web.context.support.AnnotationConfigWebApplicationContext");
        registration.setInitParameter("contextConfigLocation", "WebSecurityConfig");
    }
}
```

```java
public class SecurityWebApplicationInitializer extends AbstractSecurityWebApplicationInitializer {
}
```

```java
@Configuration
public class AppConfig {

    @Bean
    public TestServlet testServlet(){
        return new TestServlet();
    }
}
```

```java
@EnableWebSecurity
@Import(AppConfig.class)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Bean
    public UserDetailsService userDetailsService() {
        InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
        manager.createUser(User.withUsername("user").password("password").roles("USER").build());
        return manager;
    }
}
```

这个Security配置只配置了用户获取策略。但是他做了很多的事情：

- 使你的应用的所有URL都需要授权才可访问
- 为你生成了一个登陆表单
- 允许使用user/password这个账号来通过based authentication进行授权
- 允许用户登出
- 防止CSRF攻击
- 防止Session Fixation
- 整合安全相关Header
- 结合Servlet API方法

## Spring Security如何设置需要被保护的URL？

上面的简单配置，默认会让所有的URL都需要授权。那我们如何自定义呢？

`WebSecurityConfigurerAdapter`中指定了默认配置：

```java
protected void configure(HttpSecurity http) throws Exception {
	logger.debug("Using default configure(HttpSecurity). If subclassed this will potentially override subclass configure(HttpSecurity).");

	http
		.authorizeRequests()
			.anyRequest().authenticated()
			.and()
		.formLogin().and()
		.httpBasic();
}
```

其中`anyRequest()`指定了所有的URL都需要授权。同时`formLogin()`指定生成默认登录页面，`httpBasic()`指定用based authentication来进行授权登录。

我们可以覆盖这个方法来指定我们需要的配置。

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http.authorizeRequests().antMatchers("/test/**").authenticated()
            .and().formLogin()
            .and().httpBasic();
}
```

这里我们指定`/test/**`下的URL才需要授权。这里使用ant风格的url匹配，你也可以使用`regexMatchers()`方法来使用正则风格的匹配模式。

## Spring Security如何设置获取用户角色信息的策略？

上面的例子中，我们使用最简单的方式从内存中获取用户信息，这个用于演示还可以，但是实际中应该没有应用会这么做。Spring Security支持从多种地方获取用户信息，比如内存，数据库，LDAP等。

大部分场景我们从数据库中读取用户信息，看下例子：

```java
@Autowired
private DataSource dataSource;

@Autowired
public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
	auth
		.jdbcAuthentication()
			.dataSource(dataSource)
			.withDefaultSchema()
			.withUser("user").password("password").roles("USER").and()
			.withUser("admin").password("password").roles("USER", "ADMIN");
}
```

## Spring Security如何自定义登录页面？

```java
protected void configure(HttpSecurity http) throws Exception {
	http
		.authorizeRequests()
			.anyRequest().authenticated()
			.and()
		.formLogin()
			.loginPage("/login")
			.permitAll();
}
```

`formLogin()`指定登录配置，使用`loginPage("/login")`指定登录页面URL，注意对于登录页面一定要设置`permitAll()`否则未登录的用户就进不了登录页面了。

自定义的登录页面可以是这样的：

```html
<c:url value="/login" var="loginUrl"/>
<form action="${loginUrl}" method="post">       1
	<c:if test="${param.error != null}">        2
		<p>
			Invalid username and password.
		</p>
	</c:if>
	<c:if test="${param.logout != null}">       3
		<p>
			You have been logged out.
		</p>
	</c:if>
	<p>
		<label for="username">Username</label>
		<input type="text" id="username" name="username"/>	4
	</p>
	<p>
		<label for="password">Password</label>
		<input type="password" id="password" name="password"/>	5
	</p>
	<input type="hidden"                        6
		name="${_csrf.parameterName}"
		value="${_csrf.token}"/>
	<button type="submit" class="btn">Log in</button>
</form>
```

## Spring Security如何自定义退出页面？

```java
protected void configure(HttpSecurity http) throws Exception {
	http
		.logout()                                                                
			.logoutUrl("/my/logout")                                                 
			.logoutSuccessUrl("/my/index")                                           
			.logoutSuccessHandler(logoutSuccessHandler)                              
			.invalidateHttpSession(true)                                             
			.addLogoutHandler(logoutHandler)                                         
			.deleteCookies(cookieNamesToClear)                                       
			.and()
		...
}
```

- `logoutUrl("/my/logout")`指定登出的URL
- `logoutSuccessUrl("/my/index")`指定登出成功时转到的URL
- `logoutSuccessHandler(logoutSuccessHandler)`指定登出成功时，触发的处理器
- `invalidateHttpSession(true)`指定登出时是否清理session

## Spring Security如何设置权限验证失败后的处理？

验证权限失败有两种场景：
- 用户未登录
- 用户登录了但是没有对应的权限

对于第一种情况，Spring Security默认会跳转到登录页面，如果没有登录页面，则会抛出403页面。我们可以指定`AuthenticationEntryPoint`，也就是登录入口。比如对于RESTful应用，用户如果没有登录，是不会跳转到登录页面的，而是直接提示未授权。对于这种场景，我们可以自定义登录入口，把登录入口设置为错误提示即可：

```java
@Component( "restAuthenticationEntryPoint" )
public class RestAuthenticationEntryPoint
  implements AuthenticationEntryPoint{
 
   @Override
   public void commence(
     HttpServletRequest request,
     HttpServletResponse response, 
     AuthenticationException authException) throws IOException {
  
      response.sendError( HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized" );
   }
}
```

在Security Config中设置授权入口为自定义的错误提示：

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http.authorizeRequests()
            .antMatchers("/test/**").authenticated()
            .antMatchers("/admin/**").hasRole("ADMIN")
            .and().formLogin()
            .and().exceptionHandling().authenticationEntryPoint(restAuthenticationEntryPoint);
}
```

对于“用户登录了但是没有对应的权限”这种情况，默认会返回access deny界面，这个界面也是可以定制的，可以直接指定错误信息页面：

```java
.and().exceptionHandling().accessDeniedPage("/deny");
```

或者指定一个处理器：

```java
.and().exceptionHandling().accessDeniedHandler(new AccessDeniedHandler() {
        public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
            // do something
        }
```

## 参考资料
- [Spring Security Reference](http://docs.spring.io/spring-security/site/docs/4.2.2.RELEASE/reference/htmlsingle/)
- [Spring Security for a REST API | Baeldung](http://www.baeldung.com/securing-a-restful-web-service-with-spring-security)
