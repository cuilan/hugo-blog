---
layout:     post 
title:      "Spring容器初始化流程"
subtitle:   "SpringIOC源码分析五"
date:       2020-10-19
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

# Spring容器初始化流程

```java
// 父类构造器，实例化一个 BeanFactory -> DefaultListableBeanFactory
org.springframework.context.support.GenericApplicationContext#GenericApplicationContext()
	// 入口
	org.springframework.context.annotation.AnnotationConfigApplicationContext#AnnotationConfigApplicationContext()
		// 1. 实例化一个 AnnotatedBeanDefinitionReader 委托 AnnotationConfigUtils
		org.springframework.context.annotation.AnnotatedBeanDefinitionReader#AnnotatedBeanDefinitionReader()
			// 设置 AnnotationAwareOrderComparator 对象，提供依赖的排序功能
			// 设置 ContextAnnotationAutowireCandidateResolver 对象，提供延迟加载功能
			// 注册 ConfigurationClassPostProcessor 其实现了 BeanDefinitionRegistryPostProcessor 接口，提供配置类的处理功能
			// 注册 AutowiredAnnotationBeanPostProcessor 提供 Autowired 注解的处理功能
			// 注册 CommonAnnotationBeanPostProcessor 提供 JSR250 标准的通用注解处理器功能，Resource 注解
			// 注册 PersistenceAnnotationBeanPostProcessor 提供 JPA 相关支持
			// 注册 EventListenerMethodProcessor
			// 注册 DefaultEventListenerFactory
			org.springframework.context.annotation.AnnotationConfigUtils#registerAnnotationConfigProcessors()
				org.springframework.context.annotation.AnnotationConfigUtils#registerPostProcessor()
					// 往 beanDefinitionMap 中注册
					org.springframework.beans.factory.support.DefaultListableBeanFactory#registerBeanDefinition()
		// 2.实例化一个 ClassPath下BeanDefinition 的扫描器
		org.springframework.context.annotation.ClassPathBeanDefinitionScanner#ClassPathBeanDefinitionScanner()
		// 3.注册Bean
		org.springframework.context.annotation.AnnotationConfigApplicationContext#register()
		// 4.刷新容器，准备好 BeanFactory，以及 Bean 实例化
		org.springframework.context.support.AbstractApplicationContext#refresh()
			// Spring上下文容器刷新前的准备
			org.springframework.context.support.AbstractApplicationContext#prepareRefresh()
			// 获得 BeanFactory，DefaultListableBeanFactory
			org.springframework.context.support.AbstractApplicationContext#obtainFreshBeanFactory()
			// 配置 BeanFactory 的标准属性
			// 1).添加 ClassLoader
			// 2).添加 bean 表达式解析器，为了能让 beanFactory 解析 bean 表达式
			// 3).添加一个 BeanPostProcessor
			// 4).忽略一些 Aware 及子类
			// 5).注册一些特殊的依赖
			// 6).添加一个 BeanPostProcessor -> ApplicationListenerDetector
			org.springframework.context.support.AbstractApplicationContext#prepareBeanFactory()
			// 目前没有任何实现，允许子类对上下文 beanFactory 的后置处理
			org.springframework.context.support.AbstractApplicationContext#postProcessBeanFactory()
			// 调用 BeanFactoryPostProcessors，调用 BeanDefinitionRegistryPostProcessor
			org.springframework.context.support.AbstractApplicationContext#invokeBeanFactoryPostProcessors()
				// getBeanFactoryPostProcessors 获得自定义的 BeanFactoryPostProcessors，没有添加 @Component 注解
				org.springframework.context.support.AbstractApplicationContext#getBeanFactoryPostProcessors()
				// 调用给定的 BeanDefinitionRegistryPostProcessor
				org.springframework.context.support.PostProcessorRegistrationDelegate#invokeBeanFactoryPostProcessors()
					// 调用 postProcessBeanDefinitionRegistry 方法，子类的扩展
					org.springframework.context.annotation.ConfigurationClassPostProcessor#postProcessBeanDefinitionRegistry()
						// 处理配置的 BeanDefinitionRegistry
						org.springframework.context.annotation.ConfigurationClassPostProcessor#processConfigBeanDefinitions()
							// 判断是否是 Configuration 类，判断是否包含 Configuration 类
							// 如果有，则放入 configCandidates list 中，排序后再放入一个 candidates set 中
							org.springframework.context.annotation.ConfigurationClassUtils#checkConfigurationClassCandidate()
							// 扫描包
							org.springframework.context.annotation.ConfigurationClassParser#parse()
								org.springframework.context.annotation.ConfigurationClassParser#parse()
									org.springframework.context.annotation.ConfigurationClassParser#processConfigurationClass()
										// 1.处理内部类
										// 2.处理 @ComponentScans 和 @ComponentScan 注解的所有信息
										// 3.componentScanParser 真正的处理解析包扫描信息
										org.springframework.context.annotation.ConfigurationClassParser#doProcessConfigurationClass()
											// 解析 ComponentScan 配置信息
											org.springframework.context.annotation.ComponentScanAnnotationParser#parse()
												// 执行扫描
												org.springframework.context.annotation.ClassPathBeanDefinitionScanner#doScan()
													org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider#findCandidateComponents()
														org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider#scanCandidateComponents()
													// 执行注册 BeanDefinition
													org.springframework.context.annotation.ClassPathBeanDefinitionScanner#registerBeanDefinition()
														org.springframework.beans.factory.support.BeanDefinitionReaderUtils#registerBeanDefinition()
											// 处理 @Import 注解
											org.springframework.context.annotation.ConfigurationClassParser#processImports()
			// 注册 BeanPostProcessor，bean 的后置处理器
			org.springframework.context.support.AbstractApplicationContext#registerBeanPostProcessors()
			// 初始化消息源、国际化等，不重要
			org.springframework.context.support.AbstractApplicationContext#initMessageSource()
			// 初始化事件广播，不重要
			org.springframework.context.support.AbstractApplicationContext#initApplicationEventMulticaster()
			// 目前没有任何实现，供子类扩展
			org.springframework.context.support.AbstractApplicationContext#onRefresh()
			// 检查监听器并注册
			org.springframework.context.support.AbstractApplicationContext#registerListeners()
			// 完成 BeanFactory 中所有非延迟加载的 bean 的实例化
			org.springframework.context.support.AbstractApplicationContext#finishBeanFactoryInitialization()
				// 实例化所有的单例且非懒加载的 bean
				org.springframework.beans.factory.support.DefaultListableBeanFactory#preInstantiateSingletons()
					// 获得 bean
					org.springframework.beans.factory.support.AbstractBeanFactory#getBean()
						org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean()
							org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#createBean()
								// 创建 bean
								org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#doCreateBean()
									// 创建 bean 的实例
									org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#createBeanInstance()
										// 选择构造器：从后置处理器中选择构造器用以创建 bean 的实例
										org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#determineConstructorsFromBeanPostProcessors()
											// 返回候选的构造器，如果没有返回空，由后续的代码调用默认构造器去实例化
											org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor#determineCandidateConstructors()
										// 调用构造器实例化
										org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#autowireConstructor()
											org.springframework.beans.factory.support.ConstructorResolver#autowireConstructor()
										// 使用默认构造器去实例化
										org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#instantiateBean()
			org.springframework.context.support.AbstractApplicationContext#finishRefresh()
```

