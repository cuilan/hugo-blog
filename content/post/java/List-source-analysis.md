---
title: List接口源码分析
date: 2019-07-17 15:34:00
image: "/img/contact-bg.jpg"
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.List`** 接口直接继承自 **`java.util.Collection`** 接口，在 Collection 接口的功能之上添加了 List 功能特有的接口规范。

![List接口继承关系](/images/javase/List-source-analysis/List1.png "List接口继承关系")

# 一、List接口特点

- **有序**集合。
- 该接口的子类实现可以精确控制列表中每个元素的插入位置，可以通过索引访问元素，并搜索列表中的元素。
- 与 Set 集合不同，通常允许重复元素，且允许 **`null`** 元素， **`null`** 元素也可重复。
- List 接口提供了一个特殊的迭代器：**`java.util.ListIterator`**，它允许元素**插入**和**替换**，以及 **`java.util.Iterator`** 接口提供的常规操作之外的**双向访问**。
- 还提供了一种从列表的指定位置开始的迭代器：**`listIterator(int index)`**。

---

# 二、继承自 Collection 的方法

详细方法描述，见：[**java.util.Collection**](/post/java/collection-source-analysis/) 接口。

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
boolean removeAll(Collection<?> c);
boolean retainAll(Collection<?> c);
void clear();

// equals、hashCode
boolean equals(Object o);
int hashCode();

@Override
default Spliterator<E> spliterator() {
    // 返回一个有序分割迭代器
    return Spliterators.spliterator(this, Spliterator.ORDERED);
}
```

---

# 三、List接口方法描述

## 3.1 添加方法

List 接口包含 **四种添加方法**：

- 继承自 Collection 接口的
  - **添加单个元素至末尾**
  - **添加整个集合元素至末尾**
- 以及 List 接口提供的
  - **在指定位置插入单个元素**
  - **在指定位置插入整个集合**

### add(int index, E element)方法

将指定元素插入当前列表中的指定位置，并将当前位置的元素（如果有）和之后的元素向右移动（增加其索引）。
```java
void add(int index, E element);
```

### addAll(int index, Collection c)方法

将指定集合中的所有元素插入到当前列表的指定位置。并将当前位置的元素（如果有）和之后的元素向右移动（增加其索引）。
```java
boolean addAll(int index, Collection<? extends E> c);
```

## 3.2 索引相关操作

### get(int index)方法

返回此列表中指定位置的元素。
```java
E get(int index);
```

### set()方法

将指定位置的元素替换为指定的元素。
```java
E set(int index, E element);
```

### remove()

删除此列表中指定位置的元素。并将之后的元素向左移位（索引减一）。返回从列表中删除的元素。
```java
E remove(int index);
```

### indexOf(Object o)方法

返回此列表中第一次出现的指定元素的索引，如果当前列表不包含该元素，则返回-1。
即：返回**最低索引**。
```java
int indexOf(Object o);
```

### lastIndexOf(Object o)方法

返回此列表中最后一次出现的指定元素的索引，如果当前列表不包含该元素，则返回-1。
即：返回**最高索引**。
```java
int lastIndexOf(Object o);
```

## 3.3 其他操作

### replaceAll()方法

替换列表中所有满足条件的元素。
```java
default void replaceAll(UnaryOperator<E> operator) {
    Objects.requireNonNull(operator);
    final ListIterator<E> li = this.listIterator();
    while (li.hasNext()) {
        li.set(operator.apply(li.next()));
    }
}
```

### sort()方法

根据指定的比较器的顺序对当前列表进行排序。

如果指定的比较器为 **`null`**，则当前列表中的所有元素都必须实现 **`Comparable`** 接口，并且应使用元素的自然顺序。列表必须是可修改的，但无需调整大小。
```java
default void sort(Comparator<? super E> c) {
    Object[] a = this.toArray();
    Arrays.sort(a, (Comparator) c);
    ListIterator<E> i = this.listIterator();
    for (Object e : a) {
        i.next();
        i.set((E) e);
    }
}
```

### subList()方法

返回从起始索引（包含）至结束索引（不包含）的子列表。即：包含头不包含尾。
如果开始索引与结束索引相等，则返回空列表。
```java
List<E> subList(int fromIndex, int toIndex);
```

### listIterator()方法

返回当前列表中元素的 **`ListIterator`** 列表迭代器。
```java
ListIterator<E> listIterator();
```

### listIterator(int index)方法

从指定索引位置开始，返回当前列表中元素的 **`ListIterator`** 列表迭代器。
```java
ListIterator<E> listIterator(int index);
```

---

# 四、ListIterator迭代器

**`java.util.ListIterator`** 继承自 **`java.util.Iterator`** 接口，可实现从双端迭代。该迭代器允许在迭代期间对列表进行修改。

**`ListIterator`** 没有当前元素，它的迭代光标位置是位于元素之间的，长度为 n 的列表的迭代器具有 n+1 个可能的索引位置，如下：
```java
列表元素：  Element(0)   Element(1)   Element(2)   ... Element(n-1)
索引位置: ^            ^            ^            ^                  ^
```

需要注意：**`remove()`** 方法和 **`set(Object)`** 方法没有根据光标位置进行操作；它们是对 **`next()`** 方法或 **`previous()`** 方法调用后返回的最后一个光标进行操作。

## hasNext()方法

如果当前列表迭代器从前向后遍历列表时还有下一个元素，则返回 **`true`**。
```java
boolean hasNext();
```

## next()方法

返回当前列表中的下一个元素并向前移动光标位置。
```java
E next();
```

## hasPrevious()方法

如果当前列表迭代器从后向前遍历列表时还有下一个元素，则返回 **`true`**。
```java
boolean hasPrevious();
```

## previous()方法

返回当前列表中的上一个元素并向后移动光标位置。
```java
E previous();
```

## nextIndex()方法
返回下一个元素的索引。
```java
int nextIndex();
```

## previousIndex()方法

返回上一个元素的索引。
```java
int previousIndex();
```

## remove()方法

从当前列表中删除 **`next()`** 或 **`previous()`** 返回的最后一个元素。
此方法只能在每次调用下一次或上一次时进行一次。
只有在最后一次调用 **`next()`** 或 **`previous()`** 之后没有调用 **`add(E)`** 时才能进行此操作。
```java
void remove();
```

## set(E e)方法

用指定的元素替换 **`next()`** 或 **`previous()`** 返回的最后一个元素。
只有在最后一次调用 **`next()`** 或 **`previous()`** 之后才调用 **`remove()`** 和 **`add(E)`**时，才能进行此调用。
```java
void set(E e);
```

## add(E e)方法

将指定的元素插入当前列表。
元素将紧接在 **`next()`** 返回的元素之前插入（如果有），并且在 **`previous()`** 返回的元素之后插入（如果有）。
如果当前列表中不包含任何元素，则新元素将成为列表中的唯一元素。
```java
void add(E e);
```
