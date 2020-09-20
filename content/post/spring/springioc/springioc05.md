---
layout:     post 
title:      "Spring注册Bean的流程"
subtitle:   "SpringIOC源码分析二，Spring注册Bean的流程，register方法"
date:       2020-09-20
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

![Spring注册Bean的流程](/images/spring/springioc/springioc05/1.png "Spring注册Bean的流程")

# 一、register方法

## 使用

register 方法既可以注册普通 Bean，也可以将一个 JavaConfig 配置类作为 Bean 来注册。

```java
// 注册普遍Bean
context.register(Test.class);

public AnnotationConfigApplicationContext(Class<?>... componentClasses) {
	// 先调用当前类的构造器，初始化BeanDefinition的读取器、扫描器
	this();
	// 注册配置类，本身也作为一个BeanDefinition被注册
	register(componentClasses);
	// 刷新方法
	refresh();
}
```

## 准备BeanDefinition



```java
private <T> void doRegisterBean(Class<T> beanClass, @Nullable String name,
								@Nullable Class<? extends Annotation>[] qualifiers, @Nullable Supplier<T> supplier,
								@Nullable BeanDefinitionCustomizer[] customizers) {

    // 创建注解生成的BeanDefinition
	AnnotatedGenericBeanDefinition abd = new AnnotatedGenericBeanDefinition(beanClass);
	// 判断是否需要跳过注册
	if (this.conditionEvaluator.shouldSkip(abd.getMetadata())) {
		return;
	}

	abd.setInstanceSupplier(supplier);
	ScopeMetadata scopeMetadata = this.scopeMetadataResolver.resolveScopeMetadata(abd);
	// 设置Scope，单例或原型
	abd.setScope(scopeMetadata.getScopeName());
	// 生成bean的名称，BeanNameGenerator接口，自定义Bean名称生成策略可以实现该接口
	String beanName = (name != null ? name : this.beanNameGenerator.generateBeanName(abd, this.registry));

    // 注解配置静态工具类，处理通用BeanDefinition的注解
	AnnotationConfigUtils.processCommonDefinitionAnnotations(abd);
	if (qualifiers != null) {
		for (Class<? extends Annotation> qualifier : qualifiers) {
			if (Primary.class == qualifier) {
				abd.setPrimary(true);
			} else if (Lazy.class == qualifier) {
				abd.setLazyInit(true);
			} else {
				abd.addQualifier(new AutowireCandidateQualifier(qualifier));
			}
		}
	}
	if (customizers != null) {
		for (BeanDefinitionCustomizer customizer : customizers) {
			customizer.customize(abd);
		}
	}

	// 将BeanDefinition对象、bean名称，封装成BeanDefinitionHolder对象
	BeanDefinitionHolder definitionHolder = new BeanDefinitionHolder(abd, beanName);
	// 应用作用域代理模式
	definitionHolder = AnnotationConfigUtils.applyScopedProxyMode(scopeMetadata, definitionHolder, this.registry);
	// 注册BeanDefinition，this.registry = GenericApplicationContext
	BeanDefinitionReaderUtils.registerBeanDefinition(definitionHolder, this.registry);
}
```


