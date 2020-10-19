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

# 一、注册 BeanPostProcessor，bean 的后置处理器

# 二、初始化消息源、国际化等，不重要

# 三、初始化事件广播，不重要

# 四、目前没有任何实现，供子类扩展

# 五、检查监听器并注册

# 六、完成 BeanFactory 中所有非延迟加载的 bean 的实例化

# 七、finishRefresh() 完成

