---
layout:     post 
title:      "refresh 方法后续方法，bean 的实例化"
subtitle:   "SpringIOC源码分析六，refresh 方法后续方法，完成 BeanFactory 中所有非延迟加载的 bean 的实例化"
date:       2020-10-19
image:      "/img/tag-bg.jpg"
tags:
- Java
- 源码
- SpringIOC
categories:
- SPRING
---

refresh 方法，至此，BeanFactory 初始化已完成。

# 一、registerBeanPostProcessors

注册 BeanPostProcessor，bean 的后置处理器。

---

# 二、initMessageSource

初始化消息源、国际化等，不重要。

---

# 三、initApplicationEventMulticaster

初始化事件广播，不重要。

---

# 四、onRefresh

目前没有任何实现，供子类扩展。

---

# 五、registerListeners

检查监听器并注册。

---

# 六、finishBeanFactoryInitialization

完成 BeanFactory 中所有非延迟加载的 bean 的实例化。

```java
// 实例化所有的单例且非懒加载的 bean
beanFactory.preInstantiateSingletons();
// 由子类实现
org.springframework.beans.factory.support.DefaultListableBeanFactory#preInstantiateSingletons
```

## preInstantiateSingletons 方法

实例化单例 bean。

```java
// 拿出全部 bean 的名称
List<String> beanNames = new ArrayList<>(this.beanDefinitionNames);

// 初始化所有非延时加载的单例 beans

for (String beanName : beanNames) {
	// 合并父 BeanDefinition
	RootBeanDefinition bd = getMergedLocalBeanDefinition(beanName);
	// 判断非抽象类、单例类、非懒加载
	if (!bd.isAbstract() && bd.isSingleton() && !bd.isLazyInit()) {
		// 如果是 FactoryBean 加上 &
		if (isFactoryBean(beanName)) {
			Object bean = getBean(FACTORY_BEAN_PREFIX + beanName);
			if (bean instanceof FactoryBean) {
				FactoryBean<?> factory = (FactoryBean<?>) bean;
				boolean isEagerInit;
				if (System.getSecurityManager() != null && factory instanceof SmartFactoryBean) {
					isEagerInit = AccessController.doPrivileged(
							(PrivilegedAction<Boolean>) ((SmartFactoryBean<?>) factory)::isEagerInit,
							getAccessControlContext());
				} else {
					isEagerInit = (factory instanceof SmartFactoryBean &&
							((SmartFactoryBean<?>) factory).isEagerInit());
				}
				if (isEagerInit) {
					getBean(beanName);
				}
			}
		} else {
			// 获得 bean
			getBean(beanName);
		}
	}
}
```

## doGetBean 方法

判断是否为 **`FactoryBean`** ，如果是，则进行转换并得到 beanName。

```java
// 传过来的 bean 名称可能是带有 &，这里进行转换
String beanName = transformedBeanName(name);
Object bean;
```

检查单例缓存中是否有手动添加的实例，这个方法在初始化的时候会调用，在 **`getBean`** 的时候也会调用，即，在 Spring 初始化的时候会先获取一下这个单例的实例，判断这个对象是否已经被实例化好了，大多数情况下该对象绝对为空，但懒加载的情况下，需要先获取一次。

```java
Object sharedInstance = getSingleton(beanName);
```

alreadyCreated 存储已被创建的 bean，解决循环依赖。

```java
if (!typeCheckOnly) {
	// 添加 beanName 到 alreadyCreated set 集合中，标记该 bean 已被创建
	markBeanAsCreated(beanName);
}
```

```java
RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);
checkMergedBeanDefinition(mbd, beanName, args);
// 确保当前 bean 说明依赖的 bean 优先被初始化
String[] dependsOn = mbd.getDependsOn();
```

```java
// 创建 bean 的实例
if (mbd.isSingleton()) {
	// 这里的 getSingleton 会创建 bean 的实例
	sharedInstance = getSingleton(beanName, () -> {
		try {
			// 这里执行真正的创建单例 bean 实例
			return createBean(beanName, mbd, args);
		} catch (BeansException ex) {
			// 从单例缓存中显式删除实例：
            // 创建过程可能急切地将其放置在该实例中，以实现循环引用解析。
            // 删除所有收到对 bean 的临时引用的 bean。
			destroySingleton(beanName);
			throw ex;
		}
	});
	bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
}
```

## createBean 方法

```java
// 创建 bean
Object beanInstance = doCreateBean(beanName, mbdToUse, args);
```

## doCreateBean 方法

```java
if (instanceWrapper == null) {
	// 创建 bean 的实例
	instanceWrapper = createBeanInstance(beanName, mbd, args);
}
```

## createBeanInstance 方法

```java
// 基于 xml 配置的 <bean factory-method="xxx">，配置的方法会被调用
if (mbd.getFactoryMethodName() != null) {
	return instantiateUsingFactoryMethod(beanName, mbd, args);
}

// Shortcut 快捷方式，用以再次快速创建 bean
// 是否已解析
boolean resolved = false;
// 是否需要自动装配
boolean autowireNecessary = false;
if (args == null) {
	synchronized (mbd.constructorArgumentLock) {
		if (mbd.resolvedConstructorOrFactoryMethod != null) {
			resolved = true;
			// 如果已经解析了构造方法的参数，则必须通过一个带参数的构造方法采实例化
			autowireNecessary = mbd.constructorArgumentsResolved;
		}
	}
}
// 如果已经解析过，并且需要自动注入
if (resolved) {
	if (autowireNecessary) {
		return autowireConstructor(beanName, mbd, null, null);
	} else {
		return instantiateBean(beanName, mbd);
	}
}

// 由后置处理器来决定返回哪些构造方法
// 这里的 ctors 如果为空，则调用下面的默认构造器去实例化 bean
Constructor<?>[] ctors = determineConstructorsFromBeanPostProcessors(beanClass, beanName);
if (ctors != null || mbd.getResolvedAutowireMode() == AUTOWIRE_CONSTRUCTOR ||
		mbd.hasConstructorArgumentValues() || !ObjectUtils.isEmpty(args)) {
	// 自动装配构造器
	return autowireConstructor(beanName, mbd, ctors, args);
}

ctors = mbd.getPreferredConstructors();
if (ctors != null) {
	return autowireConstructor(beanName, mbd, ctors, null);
}
// 使用默认构造器去实例化
return instantiateBean(beanName, mbd);
```

---

# 七、finishRefresh

最后一步

* 清除资源缓存
* 初始化生命周期的处理器
* 发布事件
