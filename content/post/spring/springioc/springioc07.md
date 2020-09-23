---
layout:     post 
title:      "BeanFactoryPostProcessors 后置处理器"
subtitle:   "SpringIOC源码分析四，invokeBeanFactoryPostProcessors方法，BeanFactoryPostProcessors，BeanDefinitionRegistryPostProcessor"
date:       2020-09-23
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

# invokeBeanFactoryPostProcessors 方法

`invokeBeanFactoryPostProcessors` 方法，调用各种后置处理器。

继承关系
* `BeanFactoryPostProcessors`
    * `BeanDefinitionRegistryPostProcessor`

## 获得 BeanFactoryPostProcessors

invokeBeanFactoryPostProcessors 方法中先获得 `BeanFactoryPostProcessors`

**注意**：`getBeanFactoryPostProcessors()` 获得是自定义的 BeanFactoryPostProcessors，即：没有添加 `@Component` 注解的 BeanFactoryPostProcessors，手动交给 Spring 管理的。

```java
PostProcessorRegistrationDelegate.invokeBeanFactoryPostProcessors(beanFactory, getBeanFactoryPostProcessors());
```

```java
// 手动添加 BeanFactoryPostProcessor，没有添加 @Component 注解
context.addBeanFactoryPostProcessor(new MyBeanDefinitionRegistryPostProcessor());
```

# 初始化存放 BeanFactoryPostProcessor 的集合

