---
layout:     post 
title:      "AnnotationConfigApplicationContext启动入口"
subtitle:   "SpringIOC源码分析一，AnnotationConfigApplicationContext启动入口，BeanFactory"
date:       2020-09-19
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

# 一、AnnotationConfigApplicationContext 入口

依赖于 Spring5.X 版本，目前大多数项目已放弃基于 XML 配置的方式，所以本文基于 **JavaConfig** 注解配置的方式理解 Spring 上下文启动的流程。

```java
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(Config.class);
// 或
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
```

# 二、AnnotationConfigApplicationContext 构造方法

无论通过哪种方式最终都会调用默认构造器。

```java
public AnnotationConfigApplicationContext(Class<?>... componentClasses) {
	// 先调用当前类的构造器，初始化BeanDefinition的读取器、扫描器
	this();
	// 注册配置类，本身也作为一个BeanDefinition被注册
	register(componentClasses);
	// 刷新方法
	refresh();
}
```

**默认构造器**，优先调用父类 `GenericApplicationContext` 的构造器。

```java
public AnnotationConfigApplicationContext() {
	// 优先调用父类的构造器，GenericApplicationContext，初始化BeanFactory
	// 初始化被注解的BeanDefinition读取器
	this.reader = new AnnotatedBeanDefinitionReader(this);
	// 初始化ClassPath下BeanDefinition的扫描器
	// 这里的 scanner 仅仅是提供给程序员外部调用的，Spring 内部扫描包使用的是下面方法中的 scanner
	// org.springframework.context.annotation.ComponentScanAnnotationParser#parse
	this.scanner = new ClassPathBeanDefinitionScanner(this);
}
```

```java
public GenericApplicationContext() {
	this.beanFactory = new DefaultListableBeanFactory();
}
```

AnnotationConfigApplicationContext 默认构造器中做了两件事：
  * 初始化 `AnnotatedBeanDefinitionReader` BeanDefinition读取器
  * 初始化 `ClassPathBeanDefinitionScanner` 仅供程序员外部调用，并不是 Spring 内部扫描包的类

## 2.1 初始化 AnnotatedBeanDefinitionReader

### 为 BeanFactory 注册后置处理器

实例化一个 AnnotatedBeanDefinitionReader 委托 AnnotationConfigUtils，
registerAnnotationConfigProcessors 方法很重要，在这个方法中为容器注册一系列内部的 BeanPostProcessor 后置处理器（6个）。

* **ConfigurationClassPostProcessor**: 提供 Java 配置类处理能力。
* **AutowiredAnnotationBeanPostProcessor**: 提供 Autowired 注解的Bean后置处理器功能。
* **CommonAnnotationBeanPostProcessor**: 提供 JSR250 标准的通用注解处理器功能，Resource 注解，@@PostConstruct，@PreDestroy 等。
* **PersistenceAnnotationBeanPostProcessor**: 提供 JPA 相关支持。
* **DefaultEventListenerFactory**
* **EventListenerMethodProcessor**

```java
public static Set<BeanDefinitionHolder> registerAnnotationConfigProcessors(
		BeanDefinitionRegistry registry, @Nullable Object source) {
	DefaultListableBeanFactory beanFactory = unwrapDefaultListableBeanFactory(registry);
	if (beanFactory != null) {
		// AnnotationAwareOrderComparator 的主要功能是解析 @Order 注解和 @Priority
		if (!(beanFactory.getDependencyComparator() instanceof AnnotationAwareOrderComparator)) {
			beanFactory.setDependencyComparator(AnnotationAwareOrderComparator.INSTANCE);
		}
		// ContextAnnotationAutowireCandidateResolver 提供处理延迟加载的功能
		if (!(beanFactory.getAutowireCandidateResolver() instanceof ContextAnnotationAutowireCandidateResolver)) {
			beanFactory.setAutowireCandidateResolver(new ContextAnnotationAutowireCandidateResolver());
		}
	}
	// BeanDefinitionHolder 是对beanName和BeanDefinition的封装
	Set<BeanDefinitionHolder> beanDefs = new LinkedHashSet<>(8);
	// ConfigurationClassPostProcessor 的类型是 BeanDefinitionRegistryPostProcessor
	// BeanDefinitionRegistryPostProcessor 是 BeanFactoryPostProcessor 的子接口
	if (!registry.containsBeanDefinition(CONFIGURATION_ANNOTATION_PROCESSOR_BEAN_NAME)) {
		RootBeanDefinition def = new RootBeanDefinition(ConfigurationClassPostProcessor.class);
		def.setSource(source);
		beanDefs.add(registerPostProcessor(registry, def, CONFIGURATION_ANNOTATION_PROCESSOR_BEAN_NAME));
	}
	// AutowiredAnnotationBeanPostProcessor 提供 Autowired 注解的Bean后置处理器功能
	if (!registry.containsBeanDefinition(AUTOWIRED_ANNOTATION_PROCESSOR_BEAN_NAME)) {
		RootBeanDefinition def = new RootBeanDefinition(AutowiredAnnotationBeanPostProcessor.class);
		def.setSource(source);
		beanDefs.add(registerPostProcessor(registry, def, AUTOWIRED_ANNOTATION_PROCESSOR_BEAN_NAME));
	}
	// CommonAnnotationBeanPostProcessor 提供 JSR250 标准的通用注解处理器功能，Resource 注解
	// Check for JSR-250 support, and if present add the CommonAnnotationBeanPostProcessor.
	if (jsr250Present && !registry.containsBeanDefinition(COMMON_ANNOTATION_PROCESSOR_BEAN_NAME)) {
		RootBeanDefinition def = new RootBeanDefinition(CommonAnnotationBeanPostProcessor.class);
		def.setSource(source);
		beanDefs.add(registerPostProcessor(registry, def, COMMON_ANNOTATION_PROCESSOR_BEAN_NAME));
	}
	// PersistenceAnnotationBeanPostProcessor 提供 JPA 相关支持
	// Check for JPA support, and if present add the PersistenceAnnotationBeanPostProcessor.
	if (jpaPresent && !registry.containsBeanDefinition(PERSISTENCE_ANNOTATION_PROCESSOR_BEAN_NAME)) {
		RootBeanDefinition def = new RootBeanDefinition();
		try {
			def.setBeanClass(ClassUtils.forName(PERSISTENCE_ANNOTATION_PROCESSOR_CLASS_NAME,
					AnnotationConfigUtils.class.getClassLoader()));
		} catch (ClassNotFoundException ex) {
			throw new IllegalStateException(
					"Cannot load optional framework class: " + PERSISTENCE_ANNOTATION_PROCESSOR_CLASS_NAME, ex);
		}
		def.setSource(source);
		beanDefs.add(registerPostProcessor(registry, def, PERSISTENCE_ANNOTATION_PROCESSOR_BEAN_NAME));
	}
	if (!registry.containsBeanDefinition(EVENT_LISTENER_PROCESSOR_BEAN_NAME)) {
		RootBeanDefinition def = new RootBeanDefinition(EventListenerMethodProcessor.class);
		def.setSource(source);
		beanDefs.add(registerPostProcessor(registry, def, EVENT_LISTENER_PROCESSOR_BEAN_NAME));
	}
	if (!registry.containsBeanDefinition(EVENT_LISTENER_FACTORY_BEAN_NAME)) {
		RootBeanDefinition def = new RootBeanDefinition(DefaultEventListenerFactory.class);
		def.setSource(source);
		beanDefs.add(registerPostProcessor(registry, def, EVENT_LISTENER_FACTORY_BEAN_NAME));
	}
	return beanDefs;
}
```

### BeanPostProcessor 后置处理器

BeanPostProcessor 是 Spring 框架的一个扩展点（不止一个，5个扩展点），通过实现 BeanPostProcessor 接口，
程序员可以干预 Bean 的实例化的过程，从而减轻了 BeanFactory 的负担，这个接口可以设置多个，会形成一个列表，然后依次执行。
比如，AOP 就是在 Bean 实例化后期将切面逻辑织入 Bean 实例中的，AOP 也正是通过 BeanPostProcessor 和 IOC 容器建立联系的
（由 Spring 提供的默认的 PostProcessor，Spring 提供了很多默认的 PostProcessor 的实现类）。

BeanPostProcessor 常用实现类：
1. ApplicationContextAwareProcessor
2. InitDestroyAnnotationBeanPostProcessor
3. InstantiationAwareBeanPostProcessor
4. CommonAnnotationBeanPostProcessor
5. AutowiredAnnotationBeanPostProcessor
6. RequiredAnnotationBeanPostProcessor
7. BeanValidationPostProcessor
8. AbstractAutoProxyCreator
9. BeanFactoryPostProcessor
10. ConfigurableListableBeanFactory

## 2.2 初始化 ClassPathBeanDefinitionScanner

初始化ClassPath下BeanDefinition的扫描器，这里的 scanner 仅仅是提供给程序员外部调用的，Spring 内部扫描包使用的是下面方法中的 scanner

**org.springframework.context.annotation.ComponentScanAnnotationParser#parse()**
