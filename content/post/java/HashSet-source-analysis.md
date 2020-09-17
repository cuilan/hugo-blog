---
title: HashSet源码分析
date: 2019-08-19 10:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.HashSet`** 类继承自 **`java.util.AbstractSet`** 抽象类，实现了 **`java.util.Set`**、**`java.lang.Cloneable`**、**`java.io.Serializable`** 接口。

![HashSet继承关系](/images/javase/HashSet-source-analysis/HashSet1.png "HashSet继承关系")

<!-- more -->

## 一、HashSet特点或规范

**HashSet** 类是 **Set** 接口的实现类，底层由 **`java.util.HashMap`** 实现。
- 无序，不保证集合的迭代顺序
- 允许 **`null`** 元素。

### 1.1 性能

- 该类的基本操作（**`add(E)`**、**`remove(Object)`**、**`contains(Object)`**、**`size()`**）时间性能较高，时间复杂度为 **O(1)**，前提是 **Hash** 必须正确分布。
- 迭代此集合需要的时间与 HashSet 实例的大小（元素数量）加上后备 HashMap 实例的“容量”（桶数）之和成比例。因此，如果迭代性能很重要，则不要将初始容量设置得太高（或负载因子太低）。

### 1.2 线程不安全

注意，HashSet 线程不安全。如果多个线程同时访问，并且至少有一个线程修改了该 Set，则必须在外部进行同步。最好在创建完成时添加同步，以防止对 Set 的意外不同步访问：

```java
Set s = Collections.synchronizedSet(new HashSet(...));
```

注意：线程并发访问，可能引发 **ConcurrentModificationException** 异常。

---

## 二、成员变量

**HashSet** 底层由 **HashMap** 实现，由此来保证不可重复性。
```java
private transient HashMap<E,Object> map;

// 关联 HashMap 中的 Object 虚拟值
private static final Object PRESENT = new Object();
```

---

## 三、构造器

### 空参构造器（遵循 Collection 接口规范）

使用 HashMap 实例，默认初始容量为 **16 **，默认加载因子为：**0.75**。
```java
public HashSet() {
    map = new HashMap<>();
}
```

### 参数为 Collection 类型的构造器（遵循 Collection 接口规范）

使用 HashMap 实例，初始容量为：集合的 **size / 0.75 + 1倍**，默认加载因子为：**0.75**。
```java
public HashSet(Collection<? extends E> c) {
    map = new HashMap<>(Math.max((int) (c.size()/.75f) + 1, 16));
    addAll(c);
}
```

### 指定初始容量和加载因子的构造器

构造一个空的 HashSet，使用 HashMap 实例，可指定 **初始容量** 和 **加载因子**。
```java
public HashSet(int initialCapacity, float loadFactor) {
    map = new HashMap<>(initialCapacity, loadFactor);
}
```

### 仅指定初始容量的构造器

构造一个空的 HashSet，使用 HashMap 实例，仅支持指定 **初始容量**，加载因子默认为：**0.75**。
```java
public HashSet(int initialCapacity) {
    map = new HashMap<>(initialCapacity);
}
```

### 有序 HashSet 构造器

构造一个空的 LinkedHashSet，包访问权限，仅由子类 **`java.util.LinkedHashSet`** 使用。使用 LinkedHashMap 实例，可指定 **初始容量** 和 **加载因子**，**dummy** 参数仅作为标志位，用于区分其他构造器。
```java
HashSet(int initialCapacity, float loadFactor, boolean dummy) {
    map = new LinkedHashMap<>(initialCapacity, loadFactor);
}
```

---

## 四、实现方法

### 4.1 继承自AbstractCollection的方法

```java
// 获取迭代器，迭代器返回的元素无序
public Iterator<E> iterator() {
    return map.keySet().iterator();
}

// 返回 set 的大小
public int size() {
    return map.size();
}

// 当前 set 是否为空
public boolean isEmpty() {
    return map.isEmpty();
}

// 当前 set 是否包含元素 o
public boolean contains(Object o) {
    return map.containsKey(o);
}

// 添加元素 e，并返回是否添加成功
public boolean add(E e) {
    return map.put(e, PRESENT) == null;
}

// 删除元素 o，并返回是否删除成功
public boolean remove(Object o) {
    return map.remove(o) == PRESENT;
}

// 清空 set 中的全部元素
public void clear() {
    map.clear();
}
```

### 4.2 其他方法

```java
public Object clone() {
    try {
        HashSet<E> newSet = (HashSet<E>) super.clone();
        newSet.map = (HashMap<E, Object>) map.clone();
        return newSet;
    } catch (CloneNotSupportedException e) {
        throw new InternalError(e);
    }
}
```

```java
private void writeObject(java.io.ObjectOutputStream s)
    throws java.io.IOException {
    // Write out any hidden serialization magic
    s.defaultWriteObject();
    // Write out HashMap capacity and load factor
    s.writeInt(map.capacity());
    s.writeFloat(map.loadFactor());
    // Write out size
    s.writeInt(map.size());
    // Write out all elements in the proper order.
    for (E e : map.keySet())
        s.writeObject(e);
}
```

```java
private void readObject(java.io.ObjectInputStream s)
    throws java.io.IOException, ClassNotFoundException {
    // Read in any hidden serialization magic
    s.defaultReadObject();
    // Read capacity and verify non-negative.
    int capacity = s.readInt();
    if (capacity < 0) {
        throw new InvalidObjectException("Illegal capacity: " +
                                         capacity);
    }
    // Read load factor and verify positive and non NaN.
    float loadFactor = s.readFloat();
    if (loadFactor <= 0 || Float.isNaN(loadFactor)) {
        throw new InvalidObjectException("Illegal load factor: " +
                                         loadFactor);
    }
    // Read size and verify non-negative.
    int size = s.readInt();
    if (size < 0) {
        throw new InvalidObjectException("Illegal size: " +
                                         size);
    }
    // Set the capacity according to the size and load factor ensuring that
    // the HashMap is at least 25% full but clamping to maximum capacity.
    capacity = (int) Math.min(size * Math.min(1 / loadFactor, 4.0f),
            HashMap.MAXIMUM_CAPACITY);
    // Create backing HashMap
    map = (((HashSet<?>)this) instanceof LinkedHashSet ?
           new LinkedHashMap<E,Object>(capacity, loadFactor) :
           new HashMap<E,Object>(capacity, loadFactor));
    // Read in all elements in the proper order.
    for (int i=0; i<size; i++) {
        @SuppressWarnings("unchecked")
            E e = (E) s.readObject();
        map.put(e, PRESENT);
    }
}
```

```java
public Spliterator<E> spliterator() {
    return new HashMap.KeySpliterator<E,Object>(map, 0, -1, 0, 0);
}
```
