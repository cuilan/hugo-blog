---
title: Dictionary抽象类源码分析
date: 2019-09-17 16:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

## 一、Dictionary特点或规范

Dictionary 抽象类形式上等同于一个接口，其全部方法都是抽象方法。它是 Hashtable 的父类，它将 键 映射到 值。每个键和每个值都是一个对象。在任何一个 Dictionary 对象中，每个键最多与一个值相关联。给定一个 Dictionary 和一个键，可以查找关联的元素。任何非 null 对象都可以用作键和值。通常，此类的实现应使用 **`equals()`** 方法来确定两个键是否相同。

<font color="red">注意</font>：此类已过时。

<!-- more -->

---

## 二、构造器

唯一空参构造器。

```java
public Dictionary() {
}
```

---

## 三、方法描述

```java
abstract public int size();
abstract public boolean isEmpty();
abstract public Enumeration<K> keys();
abstract public Enumeration<V> elements();
abstract public V get(Object key);
abstract public V put(K key, V value);
abstract public V remove(Object key);
```