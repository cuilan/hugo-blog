---
layout:     post 
title:      "AOP&切面表达式"
subtitle:   "AOP概念，SpringAOP对AspecJ的支持，环绕通知"
date:       2020-09-18
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

# 一. 什么是AOP？

AOP（Aspect Oriented Programming）面向切面编程，是相对OOP而言的，AOP关注的是切面，是程序的横切点通用性问题，不会对主业务造成影响，是对传统OOP编程的补充扩展，以非侵入的方式对程序进行增强补充，实现业务与通用性问题的解耦，如记录日志、事务管理，性能监控等。

# 二. AOP概念
## 1. 术语

* Aspect：切面
* Join point：连接点，在SpringAOP中，连接点始终代表方法的执行
* Advice：通知
* Pointcut：切点（连接点的集合），SpringAOP默认使用AspectJ切入表达式
* Introduction：类型间声明
* Target object：目标对象
* AOP proxy：代理对象
* Weaving：织入

## 2. 通知类型

* 前置通知
* 后置通知
* 环绕通知

# 三. SpringAOP对AspectJ的支持

## 1. 启用@AspectJ支持

![](/images/spring/springioc/springioc02/1.png)
![](/images/spring/springioc/springioc02/2.png)

## 2. 声明切点

### i. execution：最细粒度匹配

```java
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern?.name-pattern(param-pattern) throws throws-pattern?)
```
* a) modifiers-pattern?：访问控制权限，可以省略
* b) ret-type-pattern：返回值类型，通常为：*
* c) declaring-type-pattern：类型，全包名，可以省略
* d) name-pattern：方法名称
* e) param-pattern：参数类型及名称
* f) throws-pattern?：异常类型，可以省略

### ii. within：较粗粒度匹配，仅能实现到包和接口、类级别
```java
within(declaring-type-pattern?.name-pattern)
```

### iii. args：匹配指定参数
```java
args(param-pattern)
```

### iv. this：匹配代理对象
```java
this(param-pattern)
```
SpringAOP默认使用的是JDK的Proxy代理（基于聚合接口实现），proxyTargetClass默认为false，表示不使用CGLIB代理目标类，所以使用this匹配到的是代理对象，无法为目标对象实现增强功能。改为true则使用CGLIB代理（动态代理），此时this匹配的才是被代理对象。

![](/images/spring/springioc/springioc02/3.png)

### v. target：匹配被代理对象
```java
target(param-pattern)
```

目标对象无论使用什么代理都可以匹配到。

### vi. @target：匹配带有XXX注解的目标类
### vii. @args：匹配带有XXX注解的参数
### viii. @within：匹配带有XXX注解的类，支持表达式，效果等同于@target
### ix. @annotation：匹配所有带有XXX注解的类、方法等

# 四. 环绕通知
## 1. 声明环绕通知：
```java
@Around("execution(* cn.cuilan.*.*(..))")
```

## 2. ProceedingJoinPoint与JoinPoint

* JoinPoint是切入点对象，ProceedingJoinPoint是可继续执行的切入点对象
* ProceedingJoinPoint继承自JoinPoint
