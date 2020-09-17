---
title: LinkedList源码分析
date: 2018-12-06 23:10:05
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

<a href="#1">一、LinkedList简介</a>
<a href="#2">二、成员分析</a>
<a href="#3">三、链表实现</a>
<a href="#4">四、双端队列实现</a>
<a href="#5">五、队列实现</a>
<a href="#6">六、栈实现</a>
<a href="#7">七、列表实现</a>
<a href="#8">八、迭代器、分割器</a>

## <a name="1">一、LinkedList简介</a>

**`java.util.LinkedList`** 是 **`java.util.List`** 接口实现，是一个 **链表** 数据结构的实现，直接继承自 **`java.util.AbstractSequentialList`** 抽象有序集合，是一个有序的 List，同时实现了 **`java.util.List`** 、 **`java.util.Deque`** 接口，也具备 **队列** 、 **双端队列** 的功能。同时，LinkedList 也具有 **栈** 的数据结构。因此 LinkedList 可以满足多种使用场景，是一个功能齐全的集合。

<!-- more -->

### 1.1 LinkedList 继承关系图

![LinkedList继承关系](/images/javase/linked-list-source-analysis/linkedlist1.png "LinkedList继承关系")

### 1.2 LinkedList 的特性：
 - 实现了 **双链表** 结构
 - 实现了 **Queue(队列)** 与 **Deque(双端队列)** 结构
 - 实现了 **Stack(栈)** 结构
 - 有序
 - 可重复
 - 线程不安全
 - 允许 **null** 值
 - 查询慢、增删快
 - 底层通过 **Node<E>** 实现

### 1.3 线程同步问题

由于 LinkedList 出于性能的考虑，并没有实现同步，因此在多线程环境下操作时，可能会引发线程安全问题。最好的解决办法是在创建时使用集合工具类 **`Collections.synchronizedList()`** 方法进行包装，以防止意外对列表的非同步访问。

```java
List list = Collections.synchronizedList(new LinkedList(...));
```

---

## <a name="2">二、成员分析</a>

### 2.1 成员变量

```java
// 集合大小
transient int size = 0;

/**
 * 指向第一个节点的指针
 * Invariant: (first == null && last == null) ||
 *            (first.prev == null && first.item != null)
 */
 transient Node<E> first;

/**
 * 指向最后一个节点的指针
 * Invariant: (first == null && last == null) ||
 *            (last.next == null && last.item != null)
 */
transient Node<E> last;
```

### 2.2 构造函数

遵循 **`java.util.Collection`** 规范。
```java
// 空参构造器
public LinkedList() {
}

/**
 * 参数类型为 Collection 的构造器。
 * 按照集合的迭代器返回的顺序，构造一个包含指定集合元素的列表。
 * @throws NullPointerException 如果指定的集合为空，引发空指针异常
 */
public LinkedList(Collection<? extends E> c) {
    // 调用空参构造器
    this();
    // 添加所有元素
    addAll(c);
}
```

---

## <a name="3">三、链表实现</a>

### 3.1 Node内部类

内部类 Node 就是实际的节点，用于存放实际元素的地方。
```java
// 内部类 Node 节点
private static class Node<E> {
    // 该节点存储的元素
    E item;
    // 前一个节点的引用
    Node<E> next;
    // 后一个节点的引用
    Node<E> prev;

    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```

### 3.2 连接方法

#### linkFirst(E) 方法：前

创建并连接第一个元素。
- 创建一个 Node 节点
- 将元素 E 放入其中
- 前节点设置为 null
- 后节点设置为 first 节点

```java
private void linkFirst(E e) {
    final Node<E> f = first;
    final Node<E> newNode = new Node<>(null, e, f);
    first = newNode;
    if (f == null)
        last = newNode;
    else
        f.prev = newNode;
    size++;
    modCount++;
}
```

#### linkLast(E) 方法：后

创建并连接最后一个元素。
- 创建一个 Node 节点
- 将元素 E 放入其中
- 前节点设置为 last 节点
- 后节点设置为 null

```java
void linkLast(E e) {
    final Node<E> l = last;
    final Node<E> newNode = new Node<>(l, e, null);
    last = newNode;
    if (l == null)
        first = newNode;
    else
        l.next = newNode;
    size++;
    modCount++;
}
```

#### linkBefore(E, Node) 方法：中

在**节点前（非空）**插入一个元素。
- 获取 succ 节点的前节点
- 创建一个 Node 节点，并放入元素 E
- 连接前节点和后节点
- 判断前节点不为空，并将前节点的 next 节点设置为当前节点

```java
void linkBefore(E e, Node<E> succ) {
    // assert succ != null;
    final Node<E> pred = succ.prev;
    final Node<E> newNode = new Node<>(pred, e, succ);
    succ.prev = newNode;
    if (pred == null)
        first = newNode;
    else
        pred.next = newNode;
    size++;
    modCount++;
}
```

### 3.3 删除节点方法

#### unlinkFirst(Node) 方法：前

删除并返回链表的第一个的节点（非空）。
- 获取 f 节点的元素并返回
- 获取 f 节点的 next 节点
- 将 next 节点设置为 first 节点
- 将 next 节点的前节点设置为 null

```java
private E unlinkFirst(Node<E> f) {
    // 元素 f 是第一个，并且 f 不为空
    // assert f == first && f != null;
    final E element = f.item;
    final Node<E> next = f.next;
    f.item = null;
    f.next = null; // help GC，GC垃圾自动回收
    first = next;
    if (next == null)
        last = null;
    else
        next.prev = null;
    size--;
    modCount++;
    return element;
}
```

#### unlinkLast(Node) 方法：后

删除并返回链表的最后一个节点（非空）。
- 获取 l 节点的元素并返回
- 获取 l 节点的 prev 节点
- 将 prev 节点设置为 last 节点
- 将 prev 节点的后节点设置为 null

```java
private E unlinkLast(Node<E> l) {
    // 元素 l 是最后一个，并且 l 不为空
    // assert l == last && l != null;
    final E element = l.item;
    final Node<E> prev = l.prev;
    l.item = null;
    l.prev = null; // help GC，GC垃圾自动回收
    last = prev;
    if (prev == null)
        first = null;
    else
        prev.next = null;
    size--;
    modCount++;
    return element;
}
```

#### unlink(Node) 方法：中

删除并返回链表中的一个节点（非空）。
- 获取 x 节点的元素并返回
- 获取 x 节点的 prev、next 节点
- 将 prev、next 链接

```java
E unlink(Node<E> x) {
    // 元素 x 不为空
    // assert x != null;
    final E element = x.item;
    final Node<E> next = x.next;
    final Node<E> prev = x.prev;
    if (prev == null) {
        first = next;
    } else {
        prev.next = next;
        x.prev = null;
    }
    if (next == null) {
        last = prev;
    } else {
        next.prev = prev;
        x.next = null;
    }
    x.item = null;
    size--;
    modCount++;
    return element;
}
```

---

## <a name="4">四、双端队列实现</a>

### 4.1 获取

#### getFirst() 方法：头

获取并返回第一个元素，如果为空抛出异常。
```java
public E getFirst() {
    final Node<E> f = first;
    if (f == null)
        throw new NoSuchElementException();
    return f.item;
}
```

#### getLast() 方法：尾

获取并返回最后一个元素，如果为空抛出异常。
```java
public E getLast() {
    final Node<E> l = last;
    if (l == null)
        throw new NoSuchElementException();
    return l.item;
}
```

#### peekFirst() 方法：头

获取并返回第一个元素，如果为空则返回 null。
```java
public E peekFirst() {
    final Node<E> f = first;
    return (f == null) ? null : f.item;
}
```

#### peekLast() 方法：尾

获取并返回最后一个元素，如果为空则返回 null。
```java
public E peekLast() {
    final Node<E> l = last;
    return (l == null) ? null : l.item;
}
```

### 4.2 删除

#### removeFirst() 方法：头

删除并返回第一个元素，如果为空抛出异常。
```java
public E removeFirst() {
    final Node<E> f = first;
    if (f == null)
        throw new NoSuchElementException();
    return unlinkFirst(f);
}
```

#### removeLast() 方法：尾

删除并返回最后一个元素，如果为空抛出异常。
```java
public E removeLast() {
    final Node<E> l = last;
    if (l == null)
        throw new NoSuchElementException();
    return unlinkLast(l);
}
```

#### pollFirst() 方法：头

删除并返回第一个元素，如果为空则返回 null。
```java
public E pollFirst() {
    final Node<E> f = first;
    return (f == null) ? null : unlinkFirst(f);
}
```

#### pollLast() 方法：尾

删除并返回最后一个元素，如果为空则返回 null。
```java
public E pollLast() {
    final Node<E> l = last;
    return (l == null) ? null : unlinkLast(l);
}
```

#### removeFirstOccurrence(Object) 方法

从头至尾（**正序**）删除第一次出现的元素 Object，依赖 **`remove(Object)`** 方法。
```java
public boolean removeFirstOccurrence(Object o) {
    return remove(o);
}
```

#### removeLastOccurrence(Object) 方法

从尾至头（**倒序**）删除第一次出现的元素 Object，依赖 **`unlink(Node)`** 方法。
```java
public boolean removeLastOccurrence(Object o) {
    if (o == null) { // 非 null 元素
        // 从 last 节点开始，向前循环迭代
        for (Node<E> x = last; x != null; x = x.prev) {
            if (x.item == null) {
                unlink(x);
                return true;
            }
        }
    } else { // null 元素
        for (Node<E> x = last; x != null; x = x.prev) {
            if (o.equals(x.item)) {
                unlink(x);
                return true;
            }
        }
    }
    return false;
}
```

### 4.3 添加

#### addFirst(E) 方法：头

在头部添加一个元素 E。
```java
public void addFirst(E e) {
    // 链接第一个元素
    linkFirst(e);
}
```

#### addLast(E) 方法：尾

在尾部添加一个元素 E。
```java
public void addLast(E e) {
    // 链接最后一个元素
    linkLast(e);
}
```

#### offerFirst(E) 方法：头

在头部添加一个元素 E，并返回是否添加成功。
```java
public boolean offerFirst(E e) {
    addFirst(e);
    return true;
}
```

#### offerLast(E) 方法：尾

在尾部添加一个元素 E，并返回是否添加成功。
```java
public boolean offerLast(E e) {
    addLast(e);
    return true;
}
```

### 4.4 倒序迭代

#### descendingIterator() 方法

```java
public Iterator<E> descendingIterator() {
    return new DescendingIterator();
}
```

---

## <a name="5">五、队列实现</a>

### 5.1 获取

#### element() 方法

获取头元素，如果为空抛出异常。
```java
public E element() {
    return getFirst();
}
```

#### peek() 方法

获取头元素，如果为空则返回 null。
```java
public E peek() {
    final Node<E> f = first;
    return (f == null) ? null : f.item;
}
```

### 5.2 删除

#### remove() 方法

删除头元素，如果为空抛出异常。
```java
public E remove() {
    return removeFirst();
}
```

#### poll() 方法

删除头元素，如果为空则返回 null。
```java
public E poll() {
    final Node<E> f = first;
    return (f == null) ? null : unlinkFirst(f);
}
```

### 5.3 添加

#### offer(E) 方法

在末尾添加一个元素 E，依赖 **`add(E)`** 方法。
```java
public boolean offer(E e) {
    return add(e);
}
```

#### add(E) 方法

在末尾添加一个元素 E。
```java
public boolean add(E e) {
    linkLast(e);
    return true;
}
```

---

## <a name="6">六、栈实现</a>

#### push(E) 方法

将元素 E 压入栈顶，即：将元素 E 添加至栈的头部。
```java
public void push(E e) {
    addFirst(e);
}
```

#### pop() 方法

弹出栈顶元素，即：删除并返回栈的第一个元素。
```java
public E pop() {
    return removeFirst();
}
```

---

## <a name="7">七、列表实现</a>

### 7.1 元素操作

```java
// 是否包含元素 o
public boolean contains(Object o) { return indexOf(o) != -1; }

// 返回列表的大小
public int size() { return size; }

// 删除指定元素
public boolean remove(Object o) {
    if (o == null) {
        for (Node<E> x = first; x != null; x = x.next) {
            if (x.item == null) {
                unlink(x);
                return true;
            }
        }
    } else {
        for (Node<E> x = first; x != null; x = x.next) {
            if (o.equals(x.item)) {
                unlink(x);
                return true;
            }
        }
    }
    return false;
}

// 添加集合，默认添加至末尾
public boolean addAll(Collection<? extends E> c) { return addAll(size, c); }

// 将集合添加到指定位置之后
public boolean addAll(int index, Collection<? extends E> c) {
    checkPositionIndex(index);
    Object[] a = c.toArray();
    int numNew = a.length;
    if (numNew == 0)
        return false;
    Node<E> pred, succ;
    if (index == size) {
        succ = null;
        pred = last;
    } else {
        succ = node(index);
        pred = succ.prev;
    }
    for (Object o : a) {
        @SuppressWarnings("unchecked") E e = (E) o;
        Node<E> newNode = new Node<>(pred, e, null);
        if (pred == null)
            first = newNode;
        else
            pred.next = newNode;
        pred = newNode;
    }
    if (succ == null) {
        last = pred;
    } else {
        pred.next = succ;
        succ.prev = pred;
    }
    size += numNew;
    modCount++;
    return true;
}

// 清除所有节点及连接，使 GC 回收效率更高
public void clear() {
    for (Node<E> x = first; x != null; ) {
        Node<E> next = x.next;
        x.item = null;
        x.next = null;
        x.prev = null;
        x = next;
    }
    first = last = null;
    size = 0;
    modCount++;
}
```

### 7.2 索引操作

```java
public E get(int index) {
    checkElementIndex(index);
    return node(index).item;
}

public E set(int index, E element) {
    checkElementIndex(index);
    Node<E> x = node(index);
    E oldVal = x.item;
    x.item = element;
    return oldVal;
}

public void add(int index, E element) {
    checkPositionIndex(index);
    if (index == size)
        linkLast(element);
    else
        linkBefore(element, node(index));
}

public E remove(int index) {
    checkElementIndex(index);
    return unlink(node(index));
}

private boolean isElementIndex(int index) {
    return index >= 0 && index < size;
}

private boolean isPositionIndex(int index) {
    return index >= 0 && index <= size;
}

private String outOfBoundsMsg(int index) {
    return "Index: "+index+", Size: "+size;
}
private void checkElementIndex(int index) {
    if (!isElementIndex(index))
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}
private void checkPositionIndex(int index) {
    if (!isPositionIndex(index))
        throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

Node<E> node(int index) {
    // assert isElementIndex(index);
    if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    } else {
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}
```

### 7.3 元素搜索操作

#### indexOf(Object) 方法

返回此列表中第一次出现的指定元素的索引，如果此列表不包含该元素，则返回-1。
```java
public int indexOf(Object o) {
    int index = 0;
    if (o == null) {
        for (Node<E> x = first; x != null; x = x.next) {
            if (x.item == null)
                return index;
            index++;
        }
    } else {
        for (Node<E> x = first; x != null; x = x.next) {
            if (o.equals(x.item))
                return index;
            index++;
        }
    }
    return -1;
}
```

#### lastIndexOf(Object) 方法

返回此列表中指定元素最后一次出现的索引，如果此列表不包含该元素，则返回-1。
```java
public int lastIndexOf(Object o) {
    int index = size;
    if (o == null) {
        for (Node<E> x = last; x != null; x = x.prev) {
            index--;
            if (x.item == null)
                return index;
        }
    } else {
        for (Node<E> x = last; x != null; x = x.prev) {
            index--;
            if (o.equals(x.item))
                return index;
        }
    }
    return -1;
}
```

---

## <a name="8">八、迭代器、分割器</a>

### ListItr

略。

### DescendingIterator

略。

### LLSpliterator

略。
