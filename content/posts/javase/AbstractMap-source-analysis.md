---
title: AbstractMap源码分析
date: 2019-09-02 17:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JavaSE
---

**`java.util.AbstractMap`** 抽象类实现了 **`java.util.Map`** 接口。

![AbstractMap接口继承关系](/images/javase/AbstractMap-source-analysis/AbstractMap1.png "AbstractMap接口继承关系")

<!-- more -->

## 一、AbstractMap特点或规范

**AbstractMap** 抽象类提供了 **Map** 接口的基础实现，以最大限度地减少实现此接口所需的工作量。

### 1.1 实现不可修改的Map

要实现不可修改的 **Map**，子类只需要继承此类并实现 **`entrySet()`** 方法，该方法返回 **Map.Entry** 的 **set视图**。该set视图应该继承 **java.util.AbstractSet**，并实现抽象其方法。此set视图不应该支持 **`add()`**，**`remove()`** 方法，并且其迭代器不应支持 **`remove()`**方法。

### 1.2 实现可修改的Map

要实现可修改的 **Map**，子类必须另外覆盖此类的 **`put(K, V)`** 方法，否则会抛出 **UnsupportedOperationException** 异常，以及 **`entrySet().iterator()`** 返回的迭代器必须另外实现其 **`remove()`** 方法。

### 1.3 构造器规范

子类应该根据 **Map接口的构造器规范** 提供两个构造器：
- 无参构造器
- 参数为 Map 类型的构造器

---

## 二、成员变量

仅在第一次请求 **`keySet()`** 方法时初始化实例。

```java
transient Set<K> keySet;

public Set<K> keySet() {
    Set<K> ks = keySet; // 只读
    if (ks == null) {
        ks = new AbstractSet()<K> {...};
        keySet = ks;
    }
    return ks;
}
```

仅在第一次请求 **`values()`** 方法时初始化实例。

```java
transient Collection<V> values;

public Collection<V> values() {
    Collection<V> vals = values;
    if (vals == null) {
        vals = new AbstractCollection<V>() {...};
        values = vals;
    }
    return vals;
}
```

---

## 三、构造器

唯一构造器。

```java
protected AbstractMap() {
}
```

---

## 四、方法分析

### 4.1 AbstractMap的方法

**`SimpleEntry`** 和 **`SimpleImmutableEntry`** 的实用方法。比较是否相等，并检查空值。

```java
private static boolean eq(Object o1, Object o2) {
    return o1 == null ? o2 == null : o1.equals(o2);
}
```

### 4.2 Map接口的实现方法

#### 全局唯一抽象方法

返回此 Map 中包含的 Map.Entry 的 Set 视图。
如果在对集合进行迭代时不能修改 Map（除非通过迭代器自己的 **`remove()`** 操作，或者通过迭代器返回 Entry 上的 **`setValue(V)`** 操作）。
该 Set 视图支持删除元素，通过 **`Iterator.remove()`**，**`Set.remove(0`**，**`removeAll()`**，**`retainAll()`** 和 **`clear()`** 操作从 Map 中删除相应的 Entry，但不支持 `add()`或 `addAll()` 操作。

```java
public abstract Set<Entry<K,V>> entrySet();
```

#### 查询操作

```java
// 返回 Map 的大小
public int size() {
    return entrySet().size();
}
// Map 是否为空集
public boolean isEmpty() {
    return size() == 0;
}
// 是否包含值 value
public boolean containsValue(Object value) {
    Iterator<Entry<K, V>> i = entrySet().iterator();
    if (value == null) { // value 为空的情况
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            if (e.getValue() == null)
                return true;
        }
    } else { // value 不为空的情况
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            if (value.equals(e.getValue()))
                return true;
        }
    }
    return false;
}
// 是否包含 key
public boolean containsKey(Object key) {
    Iterator<Map.Entry<K, V>> i = entrySet().iterator();
    if (key == null) { // key 为空的情况
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            if (e.getKey() == null)
                return true;
        }
    } else { // key 不为空的情况
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            if (key.equals(e.getKey()))
                return true;
        }
    }
    return false;
}
// 根据 key 查询 value
public V get(Object key) {
    Iterator<Entry<K, V>> i = entrySet().iterator();
    if (key == null) { // key 为空的情况
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            if (e.getKey()==null)
                return e.getValue();
        }
    } else { // key 不为空的情况
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            if (key.equals(e.getKey()))
                return e.getValue();
        }
    }
    return null;
}
```

#### 修改操作

```java
// AbstractMap 抽象类不提供具体实现，实现可改变的 Map，需子类覆盖实现
public V put(K key, V value) {
    throw new UnsupportedOperationException();
}
// 根据 key 删除 value，并返回
public V remove(Object key) {
    Iterator<Entry<K, V>> i = entrySet().iterator();
    Entry<K, V> correctEntry = null;
    if (key == null) {
        while (correctEntry == null && i.hasNext()) {
            Entry<K, V> e = i.next();
            if (e.getKey() == null)
                correctEntry = e;
        }
    } else {
        while (correctEntry == null && i.hasNext()) {
            Entry<K, V> e = i.next();
            if (key.equals(e.getKey()))
                correctEntry = e;
        }
    }
    V oldValue = null;
    if (correctEntry != null) {
        oldValue = correctEntry.getValue();
        i.remove();
    }
    return oldValue;
}
```

#### 批量操作

```java
// 依赖 put(K, V) 方法，需要子类覆盖实现
public void putAll(Map<? extends K, ? extends V> m) {
    for (Map.Entry<? extends K, ? extends V> e : m.entrySet())
        put(e.getKey(), e.getValue());
}
// 清空当前 Map
public void clear() {
    entrySet().clear();
}
```

#### 转为单列集合视图

```java
// 仅在第一次请求时，创建一个 AbstractSet 实现类初始化 keySet
public Set<K> keySet() {
    Set<K> ks = keySet;
    if (ks == null) {
        ks = new AbstractSet<K>() {...};
        keySet = ks;
    }
    return ks;
}
// 仅在第一次请求时，创建一个 AbstractCollection 实现类初始化 values
public Collection<V> values() {
    Collection<V> vals = values;
    if (vals == null) {
        vals = new AbstractCollection<V>() {...};
        values = vals;
    }
    return vals;
}
```

#### 比较和哈希

**`equals()`** 方法将每一项 Entry 都进行对比

**时间复杂度** 体现在循环次数：**O(mn) = m(当前Map元素数) 乘 n(被比较的Map元素数)**

```java
// Map.Entry 的每一项都参与比较
public boolean equals(Object o) {
    if (o == this) { return true; } // 引用相同
    if (!(o instanceof Map)) { return false; } // 类型不同
    Map<?, ?> m = (Map<?, ?>) o;
    if (m.size() != size()) { return false; } // 大小不同
    try {
        Iterator<Entry<K, V>> i = entrySet().iterator();
        while (i.hasNext()) {
            Entry<K, V> e = i.next();
            K key = e.getKey();
            V value = e.getValue();
            if (value == null) {
                if (!(m.get(key) == null && m.containsKey(key)))
                    return false;
            } else {
                if (!value.equals(m.get(key)))
                    return false;
            }
        }
    } catch (ClassCastException unused) {
        return false;
    } catch (NullPointerException unused) {
        return false;
    }
    return true;
}
// Map.Entry 的每一项都参与计算
public int hashCode() {
    int h = 0;
    Iterator<Entry<K, V>> i = entrySet().iterator();
    while (i.hasNext()) { h += i.next().hashCode(); }
    return h;
}
```

### 4.3 继承自Object的方法

```java
public String toString() {
    Iterator<Entry<K, V>> i = entrySet().iterator();
    if (!i.hasNext()) { return "{}"; }
    StringBuilder sb = new StringBuilder();
    sb.append('{');
    for (;;) {
        Entry<K, V> e = i.next();
        K key = e.getKey();
        V value = e.getValue();
        sb.append(key == this ? "(this Map)" : key);
        sb.append('=');
        sb.append(value == this ? "(this Map)" : value);
        if (!i.hasNext()) { return sb.append('}').toString(); }
        sb.append(',').append(' ');
    }
}
// 此克隆方法为浅克隆，仅克隆对象本身，并没有克隆其中的 Entry
protected Object clone() throws CloneNotSupportedException {
    AbstractMap<?, ?> result = (AbstractMap<?, ?>)super.clone();
    result.keySet = null;
    result.values = null;
    return result;
}
```

---

## 五、Entry实现（内部类）

### 5.1 SimpleEntry

```java
public static class SimpleEntry<K,V> implements Entry<K,V>, java.io.Serializable {
    private static final long serialVersionUID = -8499721149061103585L;
    private final K key;
    private V value;

    // 构造器
    public SimpleEntry(K key, V value) {
        this.key = key;
        this.value = value;
    }
    public SimpleEntry(Entry<? extends K, ? extends V> entry) {
        this.key = entry.getKey();
        this.value = entry.getValue();
    }

    public K getKey() { return key; }
    public V getValue() { return value; }
    public V setValue(V value) {
        V oldValue = this.value;
        this.value = value;
        return oldValue;
    }
    public boolean equals(Object o) {
        if (!(o instanceof Map.Entry)) { return false; }
        Map.Entry<?,?> e = (Map.Entry<?,?>)o;
        return eq(key, e.getKey()) && eq(value, e.getValue());
    }
    public int hashCode() {
        return (key == null ? 0 : key.hashCode()) ^ (value == null ? 0 : value.hashCode());
    }
    public String toString() { return key + "=" + value; }
}
```

### 5.2 SimpleImmutableEntry

不可变 Entry 实现类，不支持 setValue(V) 方法。

```java
public static class SimpleImmutableEntry<K,V> implements Entry<K,V>, java.io.Serializable {
    ......
    // 唯一与 SimpleEntry 不同的就是不支持修改 value
    public V setValue(V value) {
        throw new UnsupportedOperationException();
    }
    ......
}
```
