---
title: ArrayList源码分析
date: 2018-11-15 22:26:53
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

ArrayList应该算是日常开发中使用最多的List实现类。

## 一、ArrayList 的特性

- 有序
- 可重复
- 线程不安全
- 允许插入 **null** 值
- 查询快、增删慢
- 底层通过 **Object[]** 数组实现

<!-- more -->

## 二、ArrayList继承关系

**`java.util.ArrayList`** 继承 **`java.util.AbstractList`**，实现了 **`java.util.List`**、**`java.util.RandomAccess`**、 **`java.io.Serializable`** 接口。

![ArrayList继承关系](/images/javase/array-list-source-analysis/array-list.png "ArrayList继承关系")

---

## 三、成员变量

```java
// 序列化版本id
private static final long serialVersionUID = 8683452581122892189L;

// 默认初始容量
private static final int DEFAULT_CAPACITY = 10;

// 用于空实例的共享空数组实例
private static final Object[] EMPTY_ELEMENTDATA = {};

// 用于默认大小的空实例的共享空数组实例。
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

// 存储 ArrayList 元素的数组缓冲区
transient Object[] elementData;

// ArrayList 的大小
private int size;

// ArrayList 最大容量
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
```

---

## 四、构造器

遵循 **`java.util.Collection`** 构造器规范，提供：
- 一个空参构造器
- 参数为 Collection 的构造器
- 定义初始容量的构造器。

每个 ArrayList 实例都有一个  **_capacity_** （容量）。容量是用于存储在 ArrayList 中元素的数组的大小。它的大小始终大于或等于 ArrayList  的大小（size）。在调用 ArrayList 的构造方法时，可指定初始化容量大小，如果不指定则默认容量为10。
```java
// 无参构造器
public ArrayList() {
    // 默认初始容量
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

// 初始容量的构造器
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    }
}

// 参数为 Collection 的构造器
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // 替换为空集合
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```

---

## 五、实现方法

### 5.1 capacity（容量）

#### ensureCapacity(int)方法

在应用程序中可以人为增加 ArrayList 实例的容量，在添加大量元素之前可使用 **_ensureCapacity()_** 方法进行扩容。优点是可以减少重新分配容量的次数，大大提高初始化速度。
```java
public void ensureCapacity(int minCapacity) {
    int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA) ? 0 : DEFAULT_CAPACITY;
    if (minCapacity > minExpand) {
        ensureExplicitCapacity(minCapacity);
    }
    grow(minCapacity);
}

// 最终调用增长方法
private void grow(int minCapacity) {
    int oldCapacity = elementData.length;
    // 新容量 = 旧容量 + 二分之一旧容量
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    // 扩容量大于新容量(旧容量的1.5倍)时才会按照扩容量进行调整，否则还是按照1.5倍容量进行调节
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```

在扩容值很大的情况下使用  **_ensureCapacity()_**  方法可大大提高效率，但在扩容值较小时，其扩容耗时与正常情况下的默认调整容量所耗时几乎相差无几，所以只有在需要大量插入元素时，调用此方法进行扩容才会有显著的性能提升。

#### trimToSize()方法

与 ArrayList 容量相关的方法还有 **_trimToSize()_** ，该方法的作用是将 ArrayList 的容量压缩为实际大小，从而使空间的利用率最大化，源码如下：

```java
public void trimToSize() {
    // 记录操作次数自增
    modCount++;
    if (size < elementData.length) {
        elementData = (size == 0) ? EMPTY_ELEMENTDATA : Arrays.copyOf(elementData, size);
    }
}
```

### 5.2 常用方法

#### size()方法

返回当前实例的大小。

#### isEmpty()方法

判断当前实例是否为空。

#### contains(Object o)方法

判断当前实例中是否包含  **o**  对象。

#### indexOf(Object o)方法

用于获取对象 o 第一次出现的索引位置，源码如下：

```java
public int indexOf(Object o) {
    // 如果接收对象为null，则返回实例中的第一个null位置的索引 
    if (o == null) {
        for (int i = 0; i < size; i++)
            if (elementData[i]==null)
                return i;
    } else {
        for (int i = 0; i < size; i++)
            if (o.equals(elementData[i]))
                return i;
    }
    // 如果不包含该对象，则返回-1，表明该对象在ArrayList实例的-1位置
    return -1;
}
```

#### lastIndexOf(Object o)方法

用于获取对象 o 最后一次出现的索引位置，与 indexOf() 方法相似，只是在内部倒序 for 循环而已。

#### get(int index)方法

获取某一位置的元素，内部调用默认权限的 elementData(int index) 方法，其本质上是对数组的随机访问。

```java
public E get(int index) {
    // 边界检查，防止数组越界
    rangeCheck(index);
    return elementData(index);
}

E elementData(int index) {
    return (E) elementData[index];
}
```

#### set(int index, E element)方法

是替换该实例某一位置的值，返回被替换的值。

```java
public E set(int index, E element) {
    rangeCheck(index);
    E oldValue = elementData(index);
    elementData[index] = element;
    return oldValue;
}
```

#### add(E e)方法

添加元素至该实例：

```java
public boolean add(E e) {
    // 先进行扩容，只扩容一个位置
    ensureCapacityInternal(size + 1);
    // 将该元素防止在 ArrayList 的末尾位置
    elementData[size++] = e;
    return true;
}
```

#### add(int index, E element)方法

```java
public void add(int index, E element) {
    // 为添加操作进行边界检查
    rangeCheckForAdd(index);
    // 先进行扩容，只扩容一个位置
    ensureCapacityInternal(size + 1);
    // 参数：待复制的数组，从待复制的数组的第几个开始，目标数组，从第几个开始进行复制，复制的长度
    // 源数组index位置之前的元素保持不变，空出一个元素的位置，后面的元素进行复制
    System.arraycopy(elementData, index, elementData, index + 1, size - index);
    elementData[index] = element;
    size++;
}
```

#### remove(int index)方法

移除某一位置的元素：
```java
public E remove(int index) {
    // 边界检查
    rangeCheck(index);
    // 操作数自增
    modCount++;
    E oldValue = elementData(index);
    // 要移动的长度
    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index, numMoved);
    // 将该位置至为null，待GC进行回收
    elementData[--size] = null; // clear to let GC do its work
    return oldValue;
}
```

#### remove(Object o)方法

移除该 ArrayList 中的某一元素，如果该元素不存在则该实例保持不变，如果存在则移除该元素，且之后的元素依次前移一位，直到该实例中不包含此元素时执行完毕。

#### clear()方法

清空该实例中的全部元素，并将 size 修改为0。
```java
public void clear() {
    modCount++;
    for (int i = 0; i < size; i++)
        elementData[i] = null;
    size = 0;
}
```

#### addAll(Collection<? extends E> c)、addAll(int index, Collection<? extends E> c)是重载方法

作用是一次性添加多个元素，本质是求 **合集**。
```java
public boolean addAll(Collection<? extends E> c) {
    // 转为对象数组
    Object[] a = c.toArray();
    int numNew = a.length;
	// 扩容并增加修改次数
    ensureCapacityInternal(size + numNew);  // Increments modCount
	// 复制数组
    System.arraycopy(a, 0, elementData, size, numNew);
    size += numNew;
    return numNew != 0;
}

// 指定位置插入全部
public boolean addAll(int index, Collection<? extends E> c) {
    // 检查边界
	rangeCheckForAdd(index);
    Object[] a = c.toArray();
    int numNew = a.length;
    ensureCapacityInternal(size + numNew);  // Increments modCount
    // 计算移动位置
    int numMoved = size - index;
    if (numMoved > 0)
        System.arraycopy(elementData, index, elementData, index + numNew, numMoved);
    System.arraycopy(a, 0, elementData, index, numNew);
    size += numNew;
    return numNew != 0;
}
```

#### removeAll(Collection<?> c)方法

删除子集合中全部元素（如果包含），本质是求 **差集**。
```java
public boolean removeAll(Collection<?> c) {
    // 非空检查
    Objects.requireNonNull(c);
	// 批量删除操作，是否删除补集
	// 此处中不删除补集
	// 设集合A[1,2,3,4,5]，集合B[2,3]，B在A中的补集为：[1,4,5]
	// A.batchRemove(B, false)的结果为：C[1,4,5]
    return batchRemove(c, false);
}
```

#### retainAll(Collection<?> c)方法

获取子集合与当前集合共同包含的元素，本质是求 **交集**。
```java
public boolean retainAll(Collection<?> c) {
    // 非空检查
    Objects.requireNonNull(c);
	// 批量删除操作，是否删除补集
	// 此处中删除补集
	// 设集合A[1,2,3,4,5]，集合B[2,3]，B在A中的补集为：[1,4,5]
	// A.batchRemove(B, true)的结果为：C[2,3]
    return batchRemove(c, true);
}
```

---

## 六、迭代器

#### iterator()方法

返回一个实现 **Iterator<E>** 接口的迭代器 **Itr**，可以对集合中的元素进行操作。
```java
public Iterator<E> iterator() {
    return new Itr();
}

private class Itr implements Iterator<E> {}
```

#### listIterator()方法

返回一个继承 **Itr** 内部类，并实现了 **ListIterator<E>** 接口的迭代器 **ListItr**。
```java
public ListIterator<E> listIterator(int index) {
    if (index < 0 || index > size)
        throw new IndexOutOfBoundsException("Index: "+index);
    // 构造一个指定位置索引的迭代器
    return new ListItr(index);
}

public ListIterator<E> listIterator() {
    // 构造一个以0为索引的迭代器
    return new ListItr(0);
}

// 源码中注释为优化版本的迭代器
// An optimized version of AbstractList.ListItr
private class ListItr extends Itr implements ListIterator<E> {}
```

### Itr 迭代器与 ListItr 迭代器比较

 - ListItr 迭代器有 add() 方法，可以向集合中添加元素，Itr 迭代器无法添加。

 - ListItr 迭代器与 Itr 迭代器都有 hasNext() 和 next() 方法，可实现向后迭代。但 ListItr 迭代器有 hasPrevious() 和 previous() 方法，可实现逆向（向前）迭代。Itr 迭代器无法逆向迭代。

 - ListItr 迭代器可以定位当前的索引位置，nextIndex() 和 previousIndex() 可获取后一位与前一位的索引。Itr 迭代器无此功能。

 - ListItr 迭代器与 Itr 迭代器都可删除对象，但 ListItr 迭代器可实现对象的修改，set() 方法可以实现。Itr 迭代器仅支持遍历，不支持修改操作。因为 ListItr 迭代器的这些功能，可以实现对 LinkedList 等 List 数据结构进行操作。

## 七、JDK1.8新增方法

#### forEach() 方法

 **_forEach(Consumer<? super E> action)_**  方法用于迭代集合， forEach 方法是一个覆写方法，继承关系：

 - **Iterable**
	- **Collection**
		- **AbstractCollection**
			- **AbstractList**
				- **ArrayList**

Iterable 接口中的默认方法 forEach()，本质上是获得一个 iterator 迭代器，然后执行迭代。

```java
// Iterable接口中的默认方法
default void forEach(Consumer<? super T> action) {
    Objects.requireNonNull(action);
    // 增强forEach循环实现，Iterator迭代器实现
	for (T t : this) {
        action.accept(t);
    }
}

// ArrayList中的forEach方法
@Override
public void forEach(Consumer<? super E> action) {
    Objects.requireNonNull(action);
    final int expectedModCount = modCount;
    @SuppressWarnings("unchecked")
    final E[] elementData = (E[]) this.elementData;
    final int size = this.size;
    // 普通for循环实现
	for (int i=0; modCount == expectedModCount && i < size; i++) {
        action.accept(elementData[i]);
    }
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
}
```

增强 forEach 循环是 JDK1.5 之后的新语法，本质上是一种 Java 语言的语法糖，等同于 iterator 的方式。

```java
// 语法
for (Object obj : list) {
    ......
}

// 等同于
for (Iterator i=list.iterator(); i.hasNext(); ) {
    i.next();
}
```

**ArrayList** 还实现了 **RandomAccess** 接口，通过索引随机访问，由此可见 ArrayList 中的 forEach() 方法运行速度要比增强 forEach 循环快一些。

#### sort() 方法

在JDK1.7及之前的版本中，是通过 **Collections.sort()** 方法实现。

```java
public static <T extends Comparable<? super T>> void sort(List<T> list) {
    list.sort(null);
}
public static <T> void sort(List<T> list, Comparator<? super T> c) {
    list.sort(c);
}
```

在JDK1.8之后，新增了 **sort()** 方法，内部排序通过 **TimSort(混合排序)** 算法实现。

```java
public void sort(Comparator<? super E> c) {
    // final记录排序前的modCount值
    final int expectedModCount = modCount;
	// 调用Arrays排序方法，TimSort实现
    Arrays.sort((E[]) elementData, 0, size, c);
	// 判断排序后的modCount与排序前是否相等，防止并发操作导致线程安全问题
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
    modCount++;
}
```
