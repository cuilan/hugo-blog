---
title: AbstractSet源码分析
date: 2019-08-16 12:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.AbstractSet`** 抽象类继承自 **`java.util.AbstractCollection`** 抽象类，实现了 **`java.util.Set`** 接口。

![AbstractSet继承关系](/images/javase/AbstractSet-source-analysis/AbstractSet1.png "AbstractSet继承关系")

# 一、AbstractSet特点或规范

**AbstractSet** 类提供了 **Set** 接口的基础实现，以最大限度地减少实现 **Set** 接口所需的工作量。
- 子类通过此类实现集合 与 通过实现 **AbstractCollection** 类实现集合的过程相同，但必须遵循 **Set** 接口的规范。
- AbstractSet 类不会覆盖 AbstractCollection 类中的任何实现。
- 只是添加了 **`equals()`** 和 **`hashCode()`** 的实现。

# 二、构造器

唯一构造器。
```java
protected AbstractSet() {
}
```

# 三、实现方法

## equals(Object) 方法

将指定对象与当前 Set 进行比较。
- 如果指定对象也是一个集合，且与当前 Set 引用相同则返回 **`true`**。
- 两个集合具有相同的大小，并且指定集合的每个成员都包含在此集合中，则返回 **`true`**。

```java
public boolean equals(Object o) {
    if (o == this)
        return true;
    if (!(o instanceof Set))
        return false;
    Collection<?> c = (Collection<?>) o;
    if (c.size() != size())
        return false;
    try {
        return containsAll(c);
    } catch (ClassCastException unused)   {
        return false;
    } catch (NullPointerException unused) {
        return false;
    }
}
```

## hashCode() 方法

返回此 Set 的哈希值。Set 的哈希值是集合中所有元素的哈希值的 **总和**，其中空元素的哈希值为 **0**。

```java
public int hashCode() {
    int h = 0;
    Iterator<E> i = iterator();
    while (i.hasNext()) {
        E obj = i.next();
        if (obj != null)
            h += obj.hashCode();
    }
    return h;
}
```

## removeAll(Collection) 方法

从当前集合中删除指定集合中的所有元素。

**注意**，如果迭代器方法返回的迭代器未实现 **`remove()`** 方法，则此实现将抛出 **`UnsupportedOperationException`** 异常。

```java
public boolean removeAll(Collection<?> c) {
    Objects.requireNonNull(c);
    boolean modified = false;
    if (size() > c.size()) {
        for (Iterator<?> i = c.iterator(); i.hasNext(); )
            modified |= remove(i.next());
    } else {
        for (Iterator<?> i = iterator(); i.hasNext(); ) {
            if (c.contains(i.next())) {
                i.remove();
                modified = true;
            }
        }
    }
    return modified;
}
```
