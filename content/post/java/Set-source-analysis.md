---
title: Set接口源码分析
date: 2019-07-18 15:55:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.Set`** 接口直接继承自 **`java.util.Collection`** 接口。

![Set接口继承关系](/images/javase/Set-source-analysis/Set1.png "Set接口继承关系")

<!-- more -->

## 一、Set接口特点或规范

- **不包含重复元素**。至多一个 **`null`** 元素。数学意义的集合。

- 全部方法都继承自 **`java.util.Collection`** 接口。

- 子类实现必须创建一个不包含重复元素的构造函数。

- 子类实现必须对 **`equals()`** 和 **`hashCode()`** 方法重写，对 Set 进行 **“值比较”**。

- 某些子类实现对其包含的元素有限制。如：
 - 某些实现禁止 **`null`** 元素
 - 某些实现对其元素的类型有限制

## 二、继承自 Collection 的方法

详细方法描述，见：<a href="/blog/2019/07/15/javase/Collection-source-analysis/">**`java.util.Collection`**</a> 接口。

```java
int size();
boolean isEmpty();
boolean contains(Object o);
Iterator<E> iterator();
Object[] toArray();
<T> T[] toArray(T[] a);

// 修改操作
boolean add(E e);
boolean remove(Object o);

// 批量操作
boolean containsAll(Collection<?> c);
boolean addAll(Collection<? extends E> c);
boolean retainAll(Collection<?> c);
boolean removeAll(Collection<?> c);
void clear();

// equals、hashCode
boolean equals(Object o);
int hashCode();

@Override
default Spliterator<E> spliterator() {
    // 返回一个不可重复的分割迭代器
    return Spliterators.spliterator(this, Spliterator.DISTINCT);
}
```

























































