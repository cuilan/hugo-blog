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

# 一、invokeBeanFactoryPostProcessors 方法

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

---

# 二、执行处理 BeanFactoryPostProcessor

## 1. 判断 beanFactory 是否为 BeanDefinitionRegistry 类型

当前 `beanFactory` 类型为 **`DefaultListableBeanFactory`**。

如果是 `BeanDefinitionRegistry` 类型，则继续判断是否为 `BeanDefinitionRegistryPostProcessor` 子类型，并且循环优先处理 `BeanDefinitionRegistryPostProcessor` 类型。

```java
// 判断
if (beanFactory instanceof BeanDefinitionRegistry) {
    // 强转类型
    BeanDefinitionRegistry registry = (BeanDefinitionRegistry) beanFactory;

    // 存放标准 BeanFactoryPostProcessor 实现类集合
    List<BeanFactoryPostProcessor> regularPostProcessors = new ArrayList<>();

    // 存放 BeanDefinitionRegistryPostProcessor 实现类集合
    List<BeanDefinitionRegistryPostProcessor> registryProcessors = new ArrayList<>();

    // 循环处理
    for (BeanFactoryPostProcessor postProcessor : beanFactoryPostProcessors) {
		// 优先处理 BeanDefinitionRegistryPostProcessor
		if (postProcessor instanceof BeanDefinitionRegistryPostProcessor) {
            // 强转为 BeanDefinitionRegistryPostProcessor 类型
			BeanDefinitionRegistryPostProcessor registryProcessor = (BeanDefinitionRegistryPostProcessor) postProcessor;
			
            // 处理实现
            registryProcessor.postProcessBeanDefinitionRegistry(registry);
			
            // 处理完成后添加至 registryProcessors 集合中
            registryProcessors.add(registryProcessor);
		} else {
            // BeanFactoryPostProcessor 类型，则添加至 regularPostProcessors 集合中
			regularPostProcessors.add(postProcessor);
		}
	}

    // 省略后续代码
    ......
}
```

## 2. 处理 BeanDefinitionRegistryPostProcessor

**`ConfigurationClassPostProcessor # postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry)`** 方法。

### 1). 初始化 config bean 的容器集合

```java
// 配置的 Bean
List<BeanDefinitionHolder> configCandidates = new ArrayList<>();
// 获取容器中注册的所有 Bean 的名字
String[] candidateNames = registry.getBeanDefinitionNames();

// 包含初始化时放入的6个内部 Bean
for (String beanName : candidateNames) {
	BeanDefinition beanDef = registry.getBeanDefinition(beanName);
	// 判断是否包含 CONFIGURATION_CLASS_ATTRIBUTE 属性，如果有说明已处理
	if (beanDef.getAttribute(ConfigurationClassUtils.CONFIGURATION_CLASS_ATTRIBUTE) != null) {
		if (logger.isDebugEnabled()) {
			// 已处理日志
			logger.debug("Bean definition has already been processed as a configuration class: " + beanDef);
		}
	}
	// 判断是否是 Configuration 类，判断是否包含 Configuration 类
	else if (ConfigurationClassUtils.checkConfigurationClassCandidate(beanDef, this.metadataReaderFactory)) {
		// 如果有，添加入容器
		configCandidates.add(new BeanDefinitionHolder(beanDef, beanName));
	}
}

// 如果没有找到 @Configuration 注解的类，则返回
// Return immediately if no @Configuration classes were found
if (configCandidates.isEmpty()) {
	return;
}

// 排序
// Sort by previously determined @Order value, if applicable
configCandidates.sort((bd1, bd2) -> {
	int i1 = ConfigurationClassUtils.getOrder(bd1.getBeanDefinition());
	int i2 = ConfigurationClassUtils.getOrder(bd2.getBeanDefinition());
	return Integer.compare(i1, i2);
});
```

### 2). 生成 bean 的名称

也可以实现 **`BeanNameGenerator`** 接口，自定义 bean 的名称生成规则。

```java
// 得到 Spring 默认的 BeanNameGenerator 名称生成器
// Detect any custom bean name generation strategy supplied through the enclosing application context
SingletonBeanRegistry sbr = null;
if (registry instanceof SingletonBeanRegistry) {
	sbr = (SingletonBeanRegistry) registry;
	if (!this.localBeanNameGeneratorSet) {
		BeanNameGenerator generator = (BeanNameGenerator) sbr.getSingleton(
				AnnotationConfigUtils.CONFIGURATION_BEAN_NAME_GENERATOR);
		if (generator != null) {
			this.componentScanBeanNameGenerator = generator;
			this.importBeanNameGenerator = generator;
		}
	}
}
```

### 3). 封装为 ConfigurationClassParser

将当前 registry 后置处理器封装为 **`ConfigurationClassParser`**。
```java
// 解析每一个 @Configuration 类
ConfigurationClassParser parser = new ConfigurationClassParser(
		this.metadataReaderFactory, this.problemReporter, this.environment,
		this.resourceLoader, this.componentScanBeanNameGenerator, registry);
```

### 4). 扫描包并解析配置类

找到普通 BeanDefinition 和 ConfigurationClass。

```java
// 定义两个是为了去重
Set<BeanDefinitionHolder> candidates = new LinkedHashSet<>(configCandidates);
Set<ConfigurationClass> alreadyParsed = new HashSet<>(configCandidates.size());
do {
	// 扫描包
	parser.parse(candidates);
	......
	// 加载 configClasses 中的 BeanDefinition
	this.reader.loadBeanDefinitions(configClasses);
	alreadyParsed.addAll(configClasses);
	......
}
while (!candidates.isEmpty());
```

**`doProcessConfigurationClass`** 方法中解析并处理 **`@ComponentScans`** 和 **`@ComponentScan`** 注解，**`@Imports`** 注解，**`@Bean`** 注解的方法。
调用链：

```java
org.springframework.context.annotation.ConfigurationClassParser#parse
	org.springframework.context.annotation.ConfigurationClassParser#processConfigurationClass
		org.springframework.context.annotation.ConfigurationClassParser#doProcessConfigurationClass


		// 处理 @ComponentScans 和 @ComponentScan 注解的所有信息
		// Process any @ComponentScan annotations
		Set<AnnotationAttributes> componentScans = AnnotationConfigUtils.attributesForRepeatable(
				sourceClass.getMetadata(), ComponentScans.class, ComponentScan.class);
		if (!componentScans.isEmpty() &&
				!this.conditionEvaluator.shouldSkip(sourceClass.getMetadata(), ConfigurationPhase.REGISTER_BEAN)) {
			for (AnnotationAttributes componentScan : componentScans) {
				// componentScanParser 真正的处理解析包扫描信息
				// The config class is annotated with @ComponentScan -> perform the scan immediately
				Set<BeanDefinitionHolder> scannedBeanDefinitions =
						this.componentScanParser.parse(componentScan, sourceClass.getMetadata().getClassName());
				// Check the set of scanned definitions for any further config classes and parse recursively if needed
				for (BeanDefinitionHolder holder : scannedBeanDefinitions) {
					BeanDefinition bdCand = holder.getBeanDefinition().getOriginatingBeanDefinition();
					if (bdCand == null) {
						bdCand = holder.getBeanDefinition();
					}
					if (ConfigurationClassUtils.checkConfigurationClassCandidate(bdCand, this.metadataReaderFactory)) {
						parse(bdCand.getBeanClassName(), holder.getBeanName());
					}
				}
			}
		}
		// ************************************************************************************
		// 以上代码是扫描普通类 -> @Component 注解的类，并且已经放入 BeanDefinitionMap 中
		// ************************************************************************************

		// 处理 @Imports 注解
		// Process any @Import annotations
		processImports(configClass, sourceClass, getImports(sourceClass), filter, true);

		......

		// ASM 反射获取所有加了 @Bean 注解的方法，表示是一个被 Spring 管理的 Bean
		// Process individual @Bean methods
		Set<MethodMetadata> beanMethods = retrieveBeanMethodMetadata(sourceClass);
		for (MethodMetadata methodMetadata : beanMethods) {
			configClass.addBeanMethod(new BeanMethod(methodMetadata, configClass));
		}
		......
```

### 5). 处理 @Imports 注解，processImports 方法

处理 @Imports 注解，分别判断导入的类型：

* **普通类**
* **ImportSelector**
* **ImportBeanDefinitionRegistrar**

```java
// 处理前的检查，是否循环导入，是否循环调用等
if (checkForCircularImports && isChainedImportOnStack(configClass)) {
	this.problemReporter.error(new CircularImportProblem(configClass, this.importStack));
} else {
	this.importStack.push(configClass);
	try {
		// 循环处理
		for (SourceClass candidate : importCandidates) {
			// 处理 ImportSelector.class
			if (candidate.isAssignable(ImportSelector.class)) {
				// Candidate class is an ImportSelector -> delegate to it to determine imports
				Class<?> candidateClass = candidate.loadClass();
				ImportSelector selector = ParserStrategyUtils.instantiateClass(candidateClass, ImportSelector.class,
						this.environment, this.resourceLoader, this.registry);
				Predicate<String> selectorFilter = selector.getExclusionFilter();
				if (selectorFilter != null) {
					exclusionFilter = exclusionFilter.or(selectorFilter);
				}
				if (selector instanceof DeferredImportSelector) {
					this.deferredImportSelectorHandler.handle(configClass, (DeferredImportSelector) selector);
				} else {
					// 拿到 ImportSelector -> selectImports 方法中返回的类名称
					String[] importClassNames = selector.selectImports(currentSourceClass.getMetadata());
					Collection<SourceClass> importSourceClasses = asSourceClasses(importClassNames, exclusionFilter);
					// 得到待导入的类，递归调用本方法处理
					processImports(configClass, currentSourceClass, importSourceClasses, exclusionFilter, false);
				}
			}
			// 处理 ImportBeanDefinitionRegistrar.class
			else if (candidate.isAssignable(ImportBeanDefinitionRegistrar.class)) {
				// Candidate class is an ImportBeanDefinitionRegistrar ->
				// delegate to it to register additional bean definitions
				Class<?> candidateClass = candidate.loadClass();
				ImportBeanDefinitionRegistrar registrar =
						ParserStrategyUtils.instantiateClass(candidateClass, ImportBeanDefinitionRegistrar.class,
								this.environment, this.resourceLoader, this.registry);
				configClass.addImportBeanDefinitionRegistrar(registrar, currentSourceClass.getMetadata());
			}
			// 处理普通配置类
			else {
				// 如果是一个普通配置类，则加入 importStack 后，再调用 processConfigurationClass 进行后置处理
				// processConfigurationClass 里面会将当前 configClass 类放入 configurationClasses 中
				// configurationClasses 是一个 Map，会在后续拿出来解析为 BeanDefinition 继而注册
				// Candidate class not an ImportSelector or ImportBeanDefinitionRegistrar ->
				// process it as an @Configuration class
				this.importStack.registerImport(
						currentSourceClass.getMetadata(), candidate.getMetadata().getClassName());
				// 这里递归调用
				processConfigurationClass(candidate.asConfigClass(configClass), exclusionFilter);
			}
		}
	} catch () { ...... }
}
```

---

## 3. invokeBeanFactoryPostProcessors 后续处理

解析完 PostProcessors 后，继续调用所有的 BeanDefinitionRegistryPostProcessor 实现，直到不再出现为止。

```java
// 定义一个 List<BeanDefinitionRegistryPostProcessor> 存放 Spring 的 BeanDefinitionRegistryPostProcessor
// 也就是 ConfigurationClassPostProcessor
List<BeanDefinitionRegistryPostProcessor> currentRegistryProcessors = new ArrayList<>();

// 排序 BeanDefinitionRegistryPostProcessor
sortPostProcessors(currentRegistryProcessors, beanFactory);
// 合并
registryProcessors.addAll(currentRegistryProcessors);

// ********************************************************************************
// 调用给定的 BeanDefinitionRegistryPostProcessor -> ConfigurationClassPostProcessor
invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
// ********************************************************************************
currentRegistryProcessors.clear();
```

