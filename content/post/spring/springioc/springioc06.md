---
layout:     post 
title:      "refresh方法-刷新前的准备工作"
subtitle:   "SpringIOC源码分析三，refresh方法"
date:       2020-09-21
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

# refresh() 方法

```java
public void refresh() throws BeansException, IllegalStateException {
	synchronized (this.startupShutdownMonitor) {
		// Spring 上下文容器刷新前的准备
		prepareRefresh();

		// 获得BeanFactory，DefaultListableBeanFactory
		ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

		// 准备BeanFactory，设置属性、添加BeanPostProcessor、注册依赖、忽略依赖接口
		prepareBeanFactory(beanFactory);

		try {
			// 目前没有任何实现，允许子类对上下文 beanFactory 的后置处理
		    postProcessBeanFactory(beanFactory);

		    // 调用 BeanFactoryPostProcessors，调用 BeanDefinitionRegistryPostProcessor
		    invokeBeanFactoryPostProcessors(beanFactory);

		    // 至此，BeanFactory 初始化完成

		    // 注册 BeanPostProcessor，bean 的后置处理器
		    registerBeanPostProcessors(beanFactory);

		    // 初始化消息源、国际化等，不重要
	    	initMessageSource();

		    // 初始化事件广播，不重要
		    initApplicationEventMulticaster();

		    // 目前没有任何实现，供子类扩展
		    onRefresh();

		    // 检查监听器并注册
		    registerListeners();

		    // 完成 BeanFactory 中所有非延迟加载的 bean 的实例化
		    finishBeanFactoryInitialization(beanFactory);

			finishRefresh();
		} catch (BeansException ex) {
			destroyBeans();
			cancelRefresh(ex);
			throw ex;
		} finally {
			resetCommonCaches();
		}
	}
}
```

# prepareRefresh

Spring 上下文容器刷新前的准备
* 设置启动时间
* 是否激活标志位
* 初始化属性源配置

# 获得 BeanFactory

获得 BeanFactory，`DefaultListableBeanFactory`

## 创建 BeanFactory

`refreshBeanFactory()`

```java
// 创建 BeanFactory
DefaultListableBeanFactory beanFactory = createBeanFactory();

// createBeanFactory() 方法
return new DefaultListableBeanFactory(getInternalParentBeanFactory());
```

## 获得 BeanFactory

```java
DefaultListableBeanFactory beanFactory = this.beanFactory;
return beanFactory;
```

# prepareBeanFactory(beanFactory)

准备 BeanFactory，设置属性、添加 `BeanPostProcessor`、注册依赖、忽略依赖接口

1. 添加 ClassLoader
2. 添加 bean 表达式解析器，为了能让 beanFactory 解析 bean 表达式
3. 添加一个 BeanPostProcessor
4. 忽略一些 Aware 及子类
5. 注册一些特殊的依赖，替换依赖
6. 添加一个 BeanPostProcessor -> ApplicationListenerDetector

```java
protected void prepareBeanFactory(ConfigurableListableBeanFactory beanFactory) {
	// 1.添加 ClassLoader
	// Tell the internal bean factory to use the context's class loader etc.
	beanFactory.setBeanClassLoader(getClassLoader());
	// 2.添加 bean 表达式解析器，为了能让 beanFactory 解析 bean 表达式
	beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
	// 对象与 String 类型的转换 -> ref="dao"
	beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));
	// Configure the bean factory with context callbacks.
	// 3.添加一个 BeanPostProcessor
	beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
	// 4.忽略一些 Aware 及子类
	beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
	beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
	beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
	beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
	beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
	beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);
	// 5.注册一些特殊的依赖，替换依赖
	// BeanFactory interface not registered as resolvable type in a plain factory.
	// MessageSource registered (and found for autowiring) as a bean.
	beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
	beanFactory.registerResolvableDependency(ResourceLoader.class, this);
	beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
	beanFactory.registerResolvableDependency(ApplicationContext.class, this);
	// 6.添加一个 BeanPostProcessor -> ApplicationListenerDetector
	// Register early post-processor for detecting inner beans as ApplicationListeners.
	beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(this));
	// Detect a LoadTimeWeaver and prepare for weaving, if found.
	if (beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
		beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
		// Set a temporary ClassLoader for type matching.
		beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
	}
	// Register default environment beans.
	if (!beanFactory.containsLocalBean(ENVIRONMENT_BEAN_NAME)) {
		beanFactory.registerSingleton(ENVIRONMENT_BEAN_NAME, getEnvironment());
	}
	if (!beanFactory.containsLocalBean(SYSTEM_PROPERTIES_BEAN_NAME)) {
		beanFactory.registerSingleton(SYSTEM_PROPERTIES_BEAN_NAME, getEnvironment().getSystemProperties());
	}
	if (!beanFactory.containsLocalBean(SYSTEM_ENVIRONMENT_BEAN_NAME)) {
		beanFactory.registerSingleton(SYSTEM_ENVIRONMENT_BEAN_NAME, getEnvironment().getSystemEnvironment());
	}
}
```

# postProcessBeanFactory(beanFactory)

目前没有任何实现，允许子类对上下文 beanFactory 的后置处理
