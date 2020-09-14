---
title: AbstractSequentialList源码分析
date: 2019-08-09 12:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JavaSE
---

**`java.util.AbstractSequentialList`** 抽象类继承自 **`java.util.AbstractList`** 抽象类。

![AbstractSequentialList继承关系](/images/javase/AbstractSequentialList-source-analysis/AbstractSequentialList1.png "AbstractSequentialList继承关系")

<!-- more -->

## 一、AbstractSequentialList特点或规范

- 此类以最大限度地减少实现一个 **“顺序访问”** 数据存储（如：**链表**）所需的工作量。
- 如需 **随机访问** 数据（如：**数组**），应**优先**使用 AbstractList 而不是此类。

### 实现此类需要实现的方法

最简实现此类，只需要提供 **`listIterator(int)`** 和 **`size()`** 方法的实现。

### 随机访问

此类与 AbstractList 类相反，它在 **列表迭代器** 上实现了 “随机访问” 的方法：**`get(int index)`**，**`set(int index, E element)`**，**`add(int index, E element)`** 和 **`remove(int index)`**。

### 可修改性规范

- 如果子类实现是**不可修改的列表**，只需要实现 **`ListIterator`** 的 **`hasNext()`**，**`next()`**，**`hasPrevious()`**，**`previous()`** 和 **`index()`** 方法。
- 如果子类实现需要**可修改的列表**，还应该实现 **`ListIterator`** 的 **`set()`** 方法。
- 如果子类实现需要**可变大小的列表**，还应该实现 **`ListIterator`** 的 **`remove()`** 和 **`add()`** 方法。

### 构造器规范

子类实现应根据 **`java.util.Collection`** 接口规范中的建议，提供：
- 无参构造器
- 参数类型为 **Collection** 构造器

---

## 二、构造器

唯一构造器，**`protected`** 权限。
```java
protected AbstractSequentialList() {
}
```

---

## 三、继承自 AbstractList 方法

### 3.1 实现方法

#### get(int) 方法

索引随机访问：首先获取指向索引元素的列表迭代器（使用 **`listIterator(index)`**），然后使用 **`ListIterator.next()`** 方法获取元素并返回。
```java
public E get(int index) {
    try {
        return listIterator(index).next();
    } catch (NoSuchElementException exc) {
        throw new IndexOutOfBoundsException("Index: "+index);
    }
}
```

#### set(int, E) 方法

修改列表：使用指定元素替换当前列表中指定位置的元素。
首先获取指向索引元素的列表迭代器（使用 **`listIterator(index)`**），然后使用 **`ListIterator.next()`** 方法获取当前元素，并调用 **`ListIterator.set(E)`** 方法将其替换。

**注意**：如果列表迭代器未实现 **`set(E)`** 方法，则将抛出 **`UnsupportedOperationException`** 异常。
```java
public E set(int index, E element) {
    try {
        ListIterator<E> e = listIterator(index);
        E oldVal = e.next();
        e.set(element);
        return oldVal;
    } catch (NoSuchElementException exc) {
        throw new IndexOutOfBoundsException("Index: "+index);
    }
}
```

#### add(int, E) 方法

大小可变：将指定元素插入到当前列表中指定位置，并将当前位置的元素（如果有）和任何后续元素向右移动（将其添加到其索引中）。
首先获取指向索引元素的列表迭代器（使用 **`listIterator(index)`**），然后使用 **`ListIterator.add()`** 方法插入指定的元素。

**注意**：如果列表迭代器未实现 **`add(E)`** 方法，则将抛出 **`UnsupportedOperationException`** 异常。
```java
public void add(int index, E element) {
    try {
        listIterator(index).add(element);
    } catch (NoSuchElementException exc) {
        throw new IndexOutOfBoundsException("Index: "+index);
    }
}
```

#### remove(int) 方法


删除此列表中指定位置的元素，并返回该元素。
将任何后续元素向左移位（从索引中减去一个）。
首先获取指向索引元素的列表迭代器（使用 **`listIterator(index)`**），然后使用 **`ListIterator.remove()`** 方法删除该元素。

**注意**：如果列表迭代器未实现 **`remove()`** 方法，则将抛出 **`UnsupportedOperationException`** 异常。
```java
public E remove(int index) {
    try {
        ListIterator<E> e = listIterator(index);
        E outCast = e.next();
        e.remove();
        return outCast;
    } catch (NoSuchElementException exc) {
        throw new IndexOutOfBoundsException("Index: "+index);
    }
}
```

#### addAll(int, Collection<? extends E>) 方法

将指定集合中所有元素插入到指定位置的当前列表中。将当前位置的元素（如果有）和任何后续元素向右移动（增加其索引）。
新元素将按照指定集合的​​迭代器返回的顺序出现在此列表中。

**注意**：如果列表迭代器未实现 **`add(E)`** 方法，则将抛出 **`UnsupportedOperationException`** 异常。
```java
public boolean addAll(int index, Collection<? extends E> c) {
    try {
        boolean modified = false;
        ListIterator<E> e1 = listIterator(index);
        Iterator<? extends E> e2 = c.iterator();
        while (e2.hasNext()) {
            e1.add(e2.next());
            modified = true;
        }
        return modified;
    } catch (NoSuchElementException exc) {
        throw new IndexOutOfBoundsException("Index: "+index);
    }
}
```

#### iterator() 方法

返回当前集合的 **`ListIterator`** 列表迭代器，依赖子类实现。
```java
public Iterator<E> iterator() {
    return listIterator();
}
```

### 3.2 抽象方法

#### listIterator(int) 方法

获取当前列表的 **`ListIterator`** 列表迭代器，此方法依赖子类实现。
```java
public abstract ListIterator<E> listIterator(int index);
```
