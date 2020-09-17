---
title: SortedSet接口源码分析
date: 2019-07-30 23:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.SortedSet`** 接口直接继承自 **`java.util.Set`** 接口。

![SortedSet接口继承关系](/images/javase/SortedSet-source-analysis/SortedSet1.png "SortedSet接口继承关系")

<!-- more -->

## 一、SortedSet接口特点或规范

### 实现规范

- 在 **`java.util.Set`** 基础上进一步提供其元素的总排序。元素按照 **自然顺序** 排序，或通过创建时提供的 **比较器排序**。
- 迭代器将按 **升序** 顺序遍历集合。提供了几个额外的操作以利用订购。 （此接口是SortedMap的集合模拟。）
- 插入到 SortedSet 中的所有元素必须实现 **`java.lang.Comparable`** 接口（或指定的比较器）。
- 所有元素必须可相互比较，即：**`e1.compareTo(e2)`**（或 **`comparator.compare(e1, e2)`**）。
- **注意**，如果 SortedSet 要正确实现 Set 接口，则由 SortedSet 维护的排序（无论是否提供显式比较器）必须与 **equals()** 方法一致。

因为 Set 接口的不可重复性依赖于 **`equals()`** 方法，而 SortedSet 使用 **`compareTo()`** 方法进行所有元素的比较，

### 构造器规范

所有 **`SortedSet`** 的实现类应提供 **四个“标准”构造器**：

1. **无参构造器**，它根据元素的**自然顺序**创建一个**空**的 SortedSet。（Collection规范）
2. 参数为 **`Collection`** 类型的构造器，它创建一个新的 SortedSet，其元素类型与 Collection 参数中的元素类型相同，并根据元素的**自然顺序**进行排序。（Collection规范）
3. 参数为 **`Comparator`** 类型的构造器，它创建一个根据**指定比较器排序**的**空**的 SortedSet。
4. 参数为 **`SortedSet`** 类型的构造器，它创建一个新的 SortedSet，其具有与输入的 SortedSet 相同的元素和相同的顺序。

由于接口不能包含构造函数，因此无法强制执行此规范。

---

## 二、方法描述

#### comparator()方法

获取当前 **`Set`** 对其元素进行排序的比较器，如果当前 Set 的元素排序为自然顺序，则返回 **`null`**。
```java
Comparator<? super E> comparator();
```

#### subSet(E, E)方法

返回当前 Set 的子集视图，其元素范围从 **fromElement**（包含）到 **toElement**（不包含）。如果fromElement和toElement相等，则返回的集合为空。
```java
SortedSet<E> subSet(E fromElement, E toElement);
```

#### headSet(E)方法

返回当前 Set 的子集视图，其元素范围从 Set 第一个元素到 **toElement**（不包含）。
```java
SortedSet<E> headSet(E toElement);
```

#### tailSet(E)方法

返回当前 Set 的子集视图，其元素范围从 **fromElement**（包含）到 Set 最后一个元素（包含）。
```java
SortedSet<E> tailSet(E fromElement);
```

#### first()方法

返回当前 Set 中的第一个（最低）元素。
```java
E first();
```

#### last()方法

返回当前 Set 中的最后一个（最高）元素。
```java
E last();
```

#### spliterator()方法

在此有序集中的元素上创建Spliterator。
- **`Spliterator.DISTINCT`**
- **`Spliterator.SORTED`**
- **`Spliterator.ORDERED`**

如果 **`SortedSet`** 的比较器为 **`null`**，则 Spliterator 的比较器必须为 **`null`**。
否则，Spliterator 的比较器必须与分类组的比较器相同或强加相同的总排序。
```java
@Override
default Spliterator<E> spliterator() {
    return new Spliterators.IteratorSpliterator<E>(
            this, Spliterator.DISTINCT | Spliterator.SORTED | Spliterator.ORDERED) {
        @Override
        public Comparator<? super E> getComparator() {
            return SortedSet.this.comparator();
        }
    };
}
```
