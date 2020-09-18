---
title: NavigableSet接口源码分析
date: 2019-08-01 18:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.NavigableSet`** 接口直接继承自 **`java.util.SortedSet`** 接口。

![NavigableSet接口继承关系](/images/javase/NavigableSet-source-analysis/NavigableSet1.png "NavigableSet接口继承关系")

# 一、NavigableSet接口特点或规范

- **`java.util.NavigableSet`** 接口在 **`java.util.SortedSet`** 基础上增加了导航功能，使用导航方法扩展的 SortedSet 报告给定搜索目标的最接近匹配。
- **`lower()`**，**`floor()`**，**`ceiling()`** 和 **`higher()`** 方法返回元素分别小于，小于或等于，大于或等于，大于给定元素，如果没有这样的元素则返回 **`null`**。
- 此接口还定义了 **`pollFirst()`** 和 **`pollLast()`** 方法，返回并删除最低和最高元素（如果存在），否则返回 **`null`**。
- 任何 NavigableSet 实现类的的子集都必须实现 NavigableSet 接口。

---

# 二、方法描述

## lower(E)方法

返回当前 Set 中**小于**指定元素的**最大元素**，如果没有这样的元素，则返回 **`null`**。
```java
E lower(E e);
```

## floor(E)方法

返回当前 Set 中**小于或等于**指定元素的**最大元素**，如果没有这样的元素，则返回 **`null`**。
```java
E floor(E e);
```

## ceiling(E)方法

返回当前 Set 中**大于或等于**指定元素的**最小元素**，如果没有这样的元素，则返回 **`null`**。
```java
E ceiling(E e);
```

## higher(E)方法

返回当前 Set 中**大于**指定元素的**最小元素**，如果没有这样的元素，则返回 **`null`**。
```java
E higher(E e);
```

## pollFirst()方法

检索并删除**第一个（最低）**元素，如果没有这样的元素，则返回 **`null`**。
```java
E pollFirst();
```

## pollLast()方法

检索并删除**最后一个（最高）**元素，如果没有这样的元素，则返回 **`null`**。
```java
E pollLast();
```

## iterator()方法

以**升序**返回当前 Set 中元素的迭代器。
```java
Iterator<E> iterator();
```

## descendingSet()方法

- 返回当前 Set 中元素的**降序**视图。
- 对当前 Set 的修改将反映在降序集中。
- 此方法返回的 Set 的顺序等同于 **`Collections.reverseOrder(comparator())`。
- 表达式：**`s.descendingSet().descendingSet()`** 返回 s 的视图等效于 s。

```java
NavigableSet<E> descendingSet();
```

## descendingIterator()方法

以**降序**返回当前 Set 中元素的迭代器。等效于 **`descendingSet().iterator()`**。
```java
Iterator<E> descendingIterator();
```

---

# 三、继承自 SortedSet 的方法

## subSet()方法

返回当前 Set 的部分视图，其元素范围从 **fromElement** 到 **toElement**；**fromInclusive**：是否包含头；**toInclusive**：是否包含尾。
```java
// 等效于 subSet(fromElement, true, toElement, false)
SortedSet<E> subSet(E fromElement, E toElement);

NavigableSet<E> subSet(E fromElement, boolean fromInclusive, E toElement, boolean toInclusive);
```

## headSet()方法

返回当前 Set 的部分视图，其元素范围从 Set 起始至 **toElement**；**inclusive**：是否包含尾，即：控制是否包含元素 toElement 元素。
```java
// 等效于 headSet(toElement, false)
SortedSet<E> headSet(E toElement);

NavigableSet<E> headSet(E toElement, boolean inclusive);
```

## tailSet()方法

返回当前 Set 的部分视图，其元素范围从 **fromElement** 至 Set 结尾；**inclusive**：是否包含头，即：控制是否包含元素 fromElement 元素。
```java
// 等效于 tailSet(fromElement, true)
SortedSet<E> tailSet(E fromElement);

NavigableSet<E> tailSet(E fromElement, boolean inclusive);
```
