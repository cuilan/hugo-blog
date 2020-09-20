---
layout:     post 
title:      "代理模式Proxy"
subtitle:   "设计模式，JDK静态代理，JDK动态代理，SpringAOP基于代理模式实现的原理"
date:       2020-09-18
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

# 一. 什么是代理

代理的名词：
* 目标对象：被代理对象
* 代理对象：增强后的代理对象

# 二. Java实现代理的两种方式

## 1. 静态代理

### 1) 继承
代理对象继承目标对象，需要重写要增强的方法，缺点：产生的类过多。

### 2) 聚合
代理对象实现与目标对象相同的接口，代理对象中需要包含一个目标对象，缺点：同样会产生类，只是比继承的方式少一点。

## 2. 动态代理

### 1) 自定义动态代理

#### (1) 实现步骤：
* a) 通过目标对象的接口反射获取接口信息，并生成一个源文件：$Proxy.java
* b) 通过第三方编译技术，动态编译产生类文件：$Proxy.class
* c) 通过ClassLoader（URLClassLoader）技术，将产生的代理类加载到JVM中
* d) 最后通过反射获得这个类的实例对象

#### (2) 缺点：
* a) 需要生成中间文件
* b) 需要动态编译class
* c) 需要URLClassLoader操作
* d) IO操作的性能消耗过高

### 2) JDK动态代理

#### 1) 源码流程分析：

![](/images/spring/springioc/springioc03/1.png)

### 3) CGLIB代理
