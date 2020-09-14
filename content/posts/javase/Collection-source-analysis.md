---
title: Collection接口源码分析
date: 2019-07-15 11:02:00
tags:
- Java
- 源码
- 集合框架
categories:
- JavaSE
---

**`java.util.Collection`** 接口是单列集合层次结构中的 **根接口**。集合表示 **一组对象**，称为其 **元素**。其有些子类集合允许重复元素，有些其他集合则不允许。有些是有序的，有些是无序的。JDK中 **`Collection`** 不提供此接口的任何直接实现：它提供了更具体的子接口（如Set和List）的实现。此接口通常用于更抽象的传递集合，并在需要最大通用性的情况下对其进行操作。

如：
```java
Collection<?> c = new ArrayList();
Collection<?> c = new HashSet();
```

<!-- more -->

## 一、Collection接口规范

Collection接口定义了一系列子类实现规范：

1、**可重复**、**无序**的集合（可能包含重复元素的无序集合）应直接实现此接口。

2、所 有通用Collection实现类（通常 **通过其子接口间接实现Collection**）应提供 **两个“标准”构造函数**：
 - 一个无参构造函数，用它来创建一个空集合。
 - 一个为子类类型的，参数为 Collection 的构造函数，使用与其参数相同的元素来创建新集合，允许用户复制任何集合，从而生成所需实现类型的等效集合。

Collection 接口无法强制执行此规范（因为接口不能包含构造函数），但Java平台库中的所有通用 Collection 实现都符合此规范。

---

## 二、方法描述

#### size()方法

返回当前集合中的元素数量。如果此集合包含元素数量大于 **`Integer.MAX_VALUE`** 个元素，则返回 **`Integer.MAX_VALUE`**。
```java
int size();
```

#### isEmpty()方法

如果当前 **`Collection`** 不包含任何元素，则返回 **`true`**。
```java
boolean isEmpty();
```

#### contains()方法、containsAll(Collection<?> c)方法

如果当前集合包含指定元素，则返回 **`true`**。当且仅当此集合包含至少一个元素 e 时才返回 **`true`**。`(o == null ? e == null : o.equals(e))`
```java
boolean contains(Object o);
```

如果当前集合包含指定 Collection 中的所有元素，则返回 **`true`**。
```java
boolean containsAll(Collection<?> c);
```

#### iterator()方法

继承自父类 **`java.lang.Iterable`**，返回一个当前集合的迭代器。
```java
Iterator<E> iterator();
```

#### toArray()方法、toArray(T[] a)方法

返回一个包含此集合中所有元素的数组。如果此集合是有序的，则此方法会以相同的顺序返回元素。返回的数组是线程安全的，因为当前集合不会保留对它的引用。此方法充当基于数组和基于集合的桥梁。
```java
Object[] toArray();

/**
 * 支持返回指定的类型 T
 */
<T> T[] toArray(T[] a);
```

#### 添加方法

**添加单个元素**：如果因添加了该元素后，集合发生改变则返回 **`true`**，如果此集合不允许重复并且已包含指定的元素，则返回 **`false`**。部分子类实现可限制添加元素的范围，如某些集合会拒绝添加 **`null`** 元素。
```java
boolean add(E e);
```

**添加集合**：将指定且非空的集合中的所有元素添加到当前集合中。
```java
boolean addAll(Collection<? extends E> c);
```

#### 删除方法

**删除单个元素**：从当前集合中移除指定元素的单个实例（如果存在）。如果当前集合中包含一个或多个此类元素，则删除元素 e **`(o == null ? e == null : o.equals(e))`**。如果当前集合包含指定的元素，则删除后返回 **`true`**。
```java
boolean remove(Object o);
```

**删除集合**：将指定的集合中的所有元素从当前集合中删除。
```java
boolean removeAll(Collection<?> c);
```

**删除满足特定条件的元素**：条件非空。
```java
default boolean removeIf(Predicate<? super E> filter) {
    Objects.requireNonNull(filter);
    boolean removed = false;
    final Iterator<E> each = iterator();
    while (each.hasNext()) {
        if (filter.test(each.next())) {
            each.remove();
            removed = true;
        }
    }
    return removed;
}
```

#### retainAll(Collection<?> c)方法

仅保留当前集合中包含在指定集合中的元素。换句话说，从当前集合中删除未包含在指定集合中的所有元素。
```java
boolean retainAll(Collection<?> c);
```

#### clear()方法

从当前集合中删除所有元素。执行后当前集合将为空。
```java
void clear();
```

#### equals(Object o)、hashCode()方法

**equals**：将指定对象与此集合进行比较。

Collection 接口没有为 `Object.equals()` 方法提供实现，当创建一个实现 Collection 接口的集合时（非 Set、List 实现类），建议不要覆盖 `Object.equals()` 方法，`Object.equals()` 方法提供了**“引用比较”**的实现，除非子类需要实现**“值比较”**，如 List、Set这样的实现类。

实现 equals 方法需要遵循 `Object.equals()` 方法的契约声明，即：**equals对称性**，**`a.equals(b) 当且仅当 b.equals(a)`**。

非实现 List、Set 接口的 Collection 实现类，**equals 方法判断两个集合的引用是否一致（引用比较），必须返回 false**。
实现了 List、Set 接口的 Collection 实现类，**equals 方法判断的是集合中值是否完全一致（值比较），即：两个不同的集合，只要集合中的值一致，则返回 true**。
```java
boolean equals(Object o);
```

**hashCode**：返回当前集合的哈希值。

Collection 接口没有为 `Object.hashCode()` 方法提供实现，但应注意，任何覆盖 `Object.equals()` 方法的实现类也必须覆盖 `Object.hashCode()` 方法以满足 `Object.hashCode()` 方法的常规协定。

即：**`c1.equals(c2)`** 意味着 **`c1.hashCode() == c2.hashCode`**。
```java
int hashCode();
```

---

## 三、JDK1.8新增方法

#### spliterator()方法

获得当前集合的 **分割迭代器**，返回 **`java.util.Spliterators`** 类提供的 **`IteratorSpliterator`** 并行分割迭代器。
```java
default Stream<E> stream() {
    return StreamSupport.stream(spliterator(), false);
}
```

#### stream()方法

返回当前集合的串行流对象。
```java
default Stream<E> stream() {
    return StreamSupport.stream(spliterator(), false);
}
```

#### parallelStream()方法

与 `stream()` 方法类似，支持并行处理。
```java
default Stream<E> parallelStream() {
    return StreamSupport.stream(spliterator(), true);
}
```





