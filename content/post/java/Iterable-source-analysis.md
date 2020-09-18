---
title: Iterable接口源码分析
date: 2019-07-12 10:18:22
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

实现此接口的对象成为“for-each loop”语句的目标，即具有可迭代功能。

**Iterable** 接口在 **`java.lang`** 包下，**`java.util.Collection`** 接口实现了此接口，因此 **`Collection`** 及其子类都可以使用迭代器。

# 一、方法描述

## iterator()方法

返回 **T** 类型元素的迭代器。见：<a href="#Iterator">Iterator</a>
```java
Iterator<T> iterator();
```

<!-- more -->

## forEach()方法

对Iterable的每个元素执行给定操作，直到处理完所有元素或操作抛出异常为止。
```java
default void forEach(Consumer<? super T> action) {
    // 验证非空
    Objects.requireNonNull(action);
    for (T t : this) {
        action.accept(t);
    }
}
```

## spliterator()方法

分割迭代器，通常由实现此接口的子类覆盖默认实现。默认实现的拆分能力较差，子类的具体实现一般性能良好，有特定的具体实现优化。
```java
default Spliterator<T> spliterator() {
    return Spliterators.spliteratorUnknownSize(iterator(), 0);
}
```

---

# 二、Iterator迭代器

集合框架的迭代器父接口。由子类提供具体实现。

**`java.util.Iterator`** 接口的定义取代了 **Java Collections Framework** 中的 **`java.util.Enumeration`**。 迭代器在两个方面与枚举不同：

- 迭代器允许调用者在迭代期间使用定义良好的语义从底层集合中删除元素。
- 方法名称已得到改进。

## hasNext()方法

如果迭代具有更多元素，则返回true。
```java
boolean hasNext();
```

## next()方法

返回迭代中的下一个元素。
```java
E next();
```

## remove()方法

从当前集合中移除迭代器返回的最后一个元素（即此时 next() 返回的元素）。
```java
default void remove() {
    throw new UnsupportedOperationException("remove");
}
```

## forEachRemaining(Consumer<? super E> action)方法

对满足指定条件的剩余元素进行迭代。
```java
default void forEachRemaining(Consumer<? super E> action) {
    Objects.requireNonNull(action);
    while (hasNext())
        action.accept(next());
}
```



































