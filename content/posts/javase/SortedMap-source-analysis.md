---
title: SortedMap接口源码分析
date: 2019-08-27 23:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JavaSE
---

**`java.util.SortedMap`** 接口直接继承自 **`java.util.Map`** 接口。

![SortedMap接口继承关系](/images/javase/SortedMap-source-analysis/SortedMap1.png "SortedMap接口继承关系")

<!-- more -->

## 一、SortedMap特点或规范

- **SortedMap** 在 **Map** 的基础上进一步提供其 key 的总排序。
- **SortedMap** 默认是根据其 key 的 **自然顺序** 排序的，或者根据 **SortedMap** 在创建时提供的比较器进行排序。
- **SortedMap** 的集合视图：**`entrySet()`**，**`keySet()`**、**`values()`** ，在迭代这些视图时会按照顺序返回。
- **SortedMap** 在 **Map** 的基础上提供了几个额外的方法扩展排序相关功能。

### 1.1 可比较性规范

插入到 **SortedMap** 中的所有 key 必须实现 **Comparable** 接口。此外，子类实现所有的 **key** 必须是 **可相互比较的**，即：**`k1.compareTo(k2)`** 或 **`comparator.compare(k1, k2)`**，违反此规范将导致函数调用抛出 **ClassCastException**。

<font color="red">注意</font>：如果 **SortedMap** 要正确实现 **Map** 接口，则由 **SortedMap** 维护的排序（无论是否提供显式比较器）必须与 **`equals()`** 方法一致。这是因为 Map 接口是根据 equals() 方法定义的，但是有序映射使用 compareTo（或compare）方法执行所有 key 的比较，因此从 SortedMap 的角度来看，equals() 方法认为相等的两个键是相等的。

**TreeMap** 比较特别，它的排序与 equals() 不一致。

### 1.2 构造器规范

所有 **SortedMap** 实现类都应该提供 **四个“标准”构造函数**。由于接口无法指定构造函数，所以无法强制子类实现此规范。

- **无参构造器**：根据 key 的自然顺序创建一个空的 **SortedMap**。
- **参数为 Comparator 类型的构造器**：根据指定的比较器创建一个空的 **SortedMap**。
- **参数为 Map 类型的构造器**：它创建一个具有与其参数 Map 相同的 key-value 映射的新 Map，并根据 key 的自然顺序进行排序。
- **参数为 SortedMap 类型的构造器**：它创建一个具有与其参数 SortedMap 相同的 key-value 映射的新 SortedMap，并与其参数 SortedMap 相同的顺序进行排序。

<font color="red">注意</font>：有几种方法返回 **key 的有限范围 subMap**。这样的 subMap 是半开放的，即：包含头不包含尾。

---

## 二、方法描述

### 2.1 SortedMap中的方法

#### comparator() 方法

返回用于对此 SortedMap 中的 key 的比较器，如果此 SortedMap 使用其 key 的自然顺序，则返回 **`null`**。
```java
Comparator<? super K> comparator();
```

#### subMap(K, K) 方法

返回此 SortedMap 的部分视图，其 key 的范围从 fromKey（包括）到 toKey（不包括），如果 fromKey 和 toKey 相等，则返回的 Map 为空。
```java
SortedMap<K,V> subMap(K fromKey, K toKey);
```

#### headMap(K) 方法

返回此 SortedMap 的部分视图，其 key 的范围严格小于 toKey。
```java
SortedMap<K,V> headMap(K toKey);
```

#### tailMap(K) 方法

返回此 SortedMap 的部分视图，其 key 的范围大于等于 fromKey。
```java
SortedMap<K,V> tailMap(K fromKey);
```

#### firstKey() 方法

返回此 SortedMap 中第一个（最低）key。
```java
K firstKey();
```

#### lastKey() 方法

返回此 SortedMap 中最后一个（最高）key。
```java
K lastKey();
```

### 2.2 继承自Map的方法

```java
// 返回所有 key 的集合
Set<K> keySet();
// 返回所有 value 的集合
Collection<V> values();
// 返回所有 Entry 的集合
Set<Map.Entry<K, V>> entrySet();
```
