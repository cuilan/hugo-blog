---
title: AbstractQueue源码分析
date: 2019-08-21 11:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JavaSE
---

**`java.util.AbstractQueue`** 类继承自 **`java.util.AbstractCollection`** 抽象类，实现了 **`java.util.Queue`** 接口。

![AbstractQueue继承关系](/images/javase/AbstractQueue-source-analysis/AbstractQueue1.png "AbstractQueue继承关系")

<!-- more -->

## 一、AbstractQueue特点或规范

**AbstractQueue** 类提供 **队列Queue** 操作的基础实现。此类不允许 **`null`** 元素。

如果操作没有找到元素，则会抛出异常，而不会返回 **`false`** 或 **`null`**。
- **`add(E)`** 依赖 **`offer(E)`**
- **`remove()`** 依赖 **`poll()`**
- **`element()`** 依赖 **`peek()`**

继承此类的 **队列Queue** 实现必须实现的方法：
- **`Queue.offer(E)`** 方法，且不允许插入 **`null`** 元素
- **`Queue.peek()`**
- **`Queue.poll()`**
- **`Collection.size()`**
- **`Collection.iterator()`**

如果无法满足特定要求，可继承 **`AbstractCollection`**。

---

## 二、构造器

唯一构造器，由子类实现提供 **Collection** 规范中的两个构造器。
```java
protected AbstractQueue() {
}
```

---

## 三、方法分析

### 3.1 继承自 AbstractCollection 的方法

#### add(E) 方法
将指定的元素插入此队列，如果插入成功，则返回 **`true`**，否则抛出 **`IllegalStateException`** 异常。
```java
public boolean add(E e) {
    if (offer(e))
        return true;
    else
        throw new IllegalStateException("Queue full");
}
```

#### addAll(Collection) 方法

将指定集合中的所有元素添加到当前队列中。此实现迭代指定的集合，并依次将迭代器返回的每个元素添加到当前队列中。
```java
public boolean addAll(Collection<? extends E> c) {
    if (c == null)
        throw new NullPointerException();
    if (c == this)
        throw new IllegalArgumentException();
    boolean modified = false;
    for (E e : c)
        if (add(e))
            modified = true;
    return modified;
}
```

#### clear() 方法

删除队列中的所有元素。重复调用 **`poll()`** 方法直到返回 **`null`**。
```java
public void clear() {
    while (poll() != null)
        ;
}
```

### 3.2 继承自 AbstractQueue 的方法

#### element() 方法

删除并返回此队列的头元素。此方法与 **`peek()`** 的不同之处仅在于，如果此队列为空，则抛出异常。
```java
public E element() {
    E x = peek();
    if (x != null)
        return x;
    else
        throw new NoSuchElementException();
}
```

#### remove() 方法

删除并返回此队列的头元素。此方法与 **`poll()`** 的不同之处仅在于，如果此队列为空，则抛出异常。
```java
public E remove() {
    E x = poll();
    if (x != null)
        return x;
    else
        throw new NoSuchElementException();
}
```
