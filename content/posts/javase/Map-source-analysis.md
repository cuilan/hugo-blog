---
title: Map接口源码分析
date: 2019-08-21 15:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JavaSE
---

**`java.util.Map`** 接口是双列集合的顶级接口。

## 一、Map特点或规范

- 双列集合，由 **key** 映射 **value** 的对象。
- **Map** 不能包含重复的 **key**，且每个 **key** 只能映射一个 **value**。
- **Map** 接口提供了三个集合的视图，**key集合**、**value集合**、**Entry<K, V>集合。
- **Map** 的顺序定义为 **集合视图** 的迭代器返回其元素的顺序。
- 有序性
  - **`java.util.TreeMap`** 类有序
  - 其他，如 **`java.util.HashMap`** 类无序

<!-- more -->

### 1.1 构造器规范

所有 Map 实现类都应该提供两个“标准”构造函数，Map 接口无法强制子类执行此规范（因为接口不能包含构造函数），但JDK中的所有 Map 实现都符合要求：
- **无参构造器**，用于创建一个空 **Map**。
- **参数类型为 Map 的构造器**，它创建一个具有相同键值的新映射映射作为其论点。

### 1.2 key/value限制

某些 Map 实现类对可能包含的 key 和 value 有限制。如，某些实现禁止空 key 和空 value，有些实现类对键的类型有限制。如果插入不合格的 key 或 value 会引发异常，通常是 **`NullPointerException`** 或 **`ClassCastException`**。

---

## 二、Map.Entry接口

**Map.Entry** 类映射实体，即：key-value 键值对。**`Map.entrySet()`** 方法可以返回 Map 的实体集合视图，即：**`Set<Map.Entry<K, V>>`**。

```java
interface Entry<K, V> {

    // 返回当前实体的 key
    K getKey();

    // 返回当前实体的 value
    V getValue();

    // 设置当前实体的 value
    V setValue(V value);

    // 比较当前实体与 o 是否一致
    boolean equals(Object o);

    // 获得当前实体的哈希值
    int hashCode();

    /**
     * 返回一个比较器，用于在 key 上按自然顺序比较 Map.Entry。
     * 返回的比较器是可序列化的，并在将条目与null键进行比较时抛出 NullPointerException。
     */
    public static <K extends Comparable<? super K>, V> Comparator<Map.Entry<K,V>> comparingByKey() {
        return (Comparator<Map.Entry<K, V>> & Serializable)
            (c1, c2) -> c1.getKey().compareTo(c2.getKey());
    }

    /**
     * 返回一个比较器，用于在 value 上按自然顺序比较 Map.Entry。
     * 返回的比较器是可序列化的，并在将条目与空值进行比较时抛出 NullPointerException。
     */
    public static <K, V extends Comparable<? super V>> Comparator<Map.Entry<K,V>> comparingByValue() {
        return (Comparator<Map.Entry<K, V>> & Serializable)
            (c1, c2) -> c1.getValue().compareTo(c2.getValue());
    }

    // 返回一个比较器，使用给定的 Comparator 按 key 比较 Map.Entry。
    public static <K, V> Comparator<Map.Entry<K, V>> comparingByKey(Comparator<? super K> cmp) {
        Objects.requireNonNull(cmp);
        return (Comparator<Map.Entry<K, V>> & Serializable)
            (c1, c2) -> cmp.compare(c1.getKey(), c2.getKey());
    }

    // 返回一个比较器，使用给定的 Comparator 按 value 将比较 Map.Entry。
    public static <K, V> Comparator<Map.Entry<K, V>> comparingByValue(Comparator<? super V> cmp) {
        Objects.requireNonNull(cmp);
        return (Comparator<Map.Entry<K, V>> & Serializable)
            (c1, c2) -> cmp.compare(c1.getValue(), c2.getValue());
    }
}
```

---

## 三、方法描述

### 3.1 查询方法

返回 Map 中 key-value 映射的数量。如果 Map 中包含元素多于 **`Integer.MAX_VALUE`**，则返回 **`Integer.MAX_VALUE`**。
```java
int size();
```

如果 Map 不包含 key-value 映射，则返回 **`true`**。
```java
boolean isEmpty();
```

如果 Map 包含指定 key 的映射，则返回 **`true`**，即：**`key == null ? k == null : key.equals(k)`**。
```java
boolean containsKey(Object key);
```
如果 Map 将一个或多个 key 映射到指定 value，则返回 **`true`**，即：**`value == null ? v == null : value.equals(v)`**。
```java
boolean containsValue(Object value);
```

返回指定 key 映射的 value，如果 Map 不包含 key 的映射，则返回 **`null`**，如果此 Map 允许空值，则返回值 **`null`** 不一定表示 Map 不包含该 key 的映射，Map 也可能将 key 明确映射为 **`null`**，**`containsKey()`** 方法可用于区分这两种情况。
```java
V get(Object key);
```

### 3.2 修改操作

将指定的 value 与 Map 中的指定 key 相关联。如果 Map 先前包含 key 的映射，则指定的 value 将替换旧 value。返回之前与 key 相关联的 value，如果之前没有关联，则返回 **`null`**。
```java
V put(K key, V value);
```

如果存在该 key，则从 Map 中移除 key 的映射。
返回删除之前与 key 关联的 value，如果 Map 不包含该 key 的映射，则返回 **`null`**。
```java
V remove(Object key);
```

### 3.3 批量操作

将指定 Map 中的所有实体复制到此 Map 中。
```java
void putAll(Map<? extends K, ? extends V> m);
```

将当前 Map 中所有实体删除。
```java
void clear();
```

### 3.4 视图

返回 Map 中包含的 key 的 Set 视图。
```java
Set<K> keySet();
```

返回 Map 中包含的 value 的 Collection 视图。
```java
Collection<V> values();
```

返回 Map 中包含的 Entry 实体的 Set 视图。
```java
Set<Map.Entry<K, V>> entrySet();
```

### 3.5 equals、hashCode

将指定对象与此 Map 进行相等性比较。如果给定对象也是一个 Map，并且两个 Map 指向同一个 Map，则返回 **`true`**。
这可确保equals方法在Map接口的不同实现中正常工作。
```java
boolean equals(Object o);
```

返回 Map 的哈希值。Map 的哈希值的定义为 Map 的 **`entrySet()`** 视图中每个条目的哈希值的总和。
```java
int hashCode();
```

### 3.6 默认方法

返回指定 key 映射到的 value，如果此 Map 不包含 key 的映射，则返回 defaultValue。
```java
default V getOrDefault(Object key, V defaultValue) {
    V v;
    return (((v = get(key)) != null) || containsKey(key))
        ? v
        : defaultValue;
}
```

对此 Map 中的每个条目执行给定操作，直到处理完所有条目或操作引发异常。
```java
default void forEach(BiConsumer<? super K, ? super V> action) {
    Objects.requireNonNull(action);
    for (Map.Entry<K, V> entry : entrySet()) {
        K k;
        V v;
        try {
            k = entry.getKey();
            v = entry.getValue();
        } catch(IllegalStateException ise) {
            // this usually means the entry is no longer in the map.
            throw new ConcurrentModificationException(ise);
        }
        action.accept(k, v);
    }
}
```

将每个条目的值替换为在该条目上调用给定函数的结果，直到所有条目都已处理或函数抛出异常。函数抛出的异常将转发给调用者。
```java
default void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
    Objects.requireNonNull(function);
    for (Map.Entry<K, V> entry : entrySet()) {
        K k;
        V v;
        try {
            k = entry.getKey();
            v = entry.getValue();
        } catch(IllegalStateException ise) {
            // this usually means the entry is no longer in the map.
            throw new ConcurrentModificationException(ise);
        }
        // ise thrown from function is not a cme.
        v = function.apply(k, v);
        try {
            entry.setValue(v);
        } catch(IllegalStateException ise) {
            // this usually means the entry is no longer in the map.
            throw new ConcurrentModificationException(ise);
        }
    }
}
```

如果指定的 key 尚未与 value 关联或映射为 null，则将其与给定 value 关联并返回 null，否则返回当前 value。默认实现不保证此方法的同步或原子性属性。提供原子性保证的任何实现都必须覆盖此方法并记录其并发属性。
```java
default V putIfAbsent(K key, V value) {
    V v = get(key);
    if (v == null) {
        v = put(key, value);
    }
    return v;
}
```

仅当指定 key 映射到指定 value 时才删除该条目。
```java
default boolean remove(Object key, Object value) {
    Object curValue = get(key);
    if (!Objects.equals(curValue, value) ||
        (curValue == null && !containsKey(key))) {
        return false;
    }
    remove(key);
    return true;
}
```

仅当指定 key 映射到指定 value 时才替换指定 key 的条目。
```java
default boolean replace(K key, V oldValue, V newValue) {
    Object curValue = get(key);
    if (!Objects.equals(curValue, oldValue) ||
        (curValue == null && !containsKey(key))) {
        return false;
    }
    put(key, newValue);
    return true;
}
```

仅当指定 key 映射到某个 value 时才替换该条目。
```java
default V replace(K key, V value) {
    V curValue;
    if (((curValue = get(key)) != null) || containsKey(key)) {
        curValue = put(key, value);
    }
    return curValue;
}
```

如果指定的 key 尚未与 value 关联或映射为 null，则尝试使用给定的映射函数计算其值，并将其输入此映射，除非为 null。
```java
default V computeIfAbsent(K key,
        Function<? super K, ? extends V> mappingFunction) {
    Objects.requireNonNull(mappingFunction);
    V v;
    if ((v = get(key)) == null) {
        V newValue;
        if ((newValue = mappingFunction.apply(key)) != null) {
            put(key, newValue);
            return newValue;
        }
    }
    return v;
}
```

如果指定 key 的 value 存在且为非 null，则尝试在给定 key 及其当前映射 value 的情况下计算新映射。如果函数返回 null，则删除映射。如果函数本身抛出异常，则重新抛出异常，并保持当前映射不变。
```java
default V computeIfPresent(K key,
        BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
    Objects.requireNonNull(remappingFunction);
    V oldValue;
    if ((oldValue = get(key)) != null) {
        V newValue = remappingFunction.apply(key, oldValue);
        if (newValue != null) {
            put(key, newValue);
            return newValue;
        } else {
            remove(key);
            return null;
        }
    } else {
        return null;
    }
}
```

尝试计算指定 key 及其当前映射 value 的映射，如果没有当前映射，则为 null。
```java
default V compute(K key,
        BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
    Objects.requireNonNull(remappingFunction);
    V oldValue = get(key);
    V newValue = remappingFunction.apply(key, oldValue);
    if (newValue == null) {
        // delete mapping
        if (oldValue != null || containsKey(key)) {
            // something to remove
            remove(key);
            return null;
        } else {
            // nothing to do. Leave things as they were.
            return null;
        }
    } else {
        // add or replace old mapping
        put(key, newValue);
        return newValue;
    }
}
```

如果指定的 key 尚未与 value 关联或与 null 关联，则将其与给定的非空值关联。否则，将相关 value 替换为给定重映射函数的结果，或者如果结果为 null 则删除。
```java
default V merge(K key, V value,
        BiFunction<? super V, ? super V, ? extends V> remappingFunction) {
    Objects.requireNonNull(remappingFunction);
    Objects.requireNonNull(value);
    V oldValue = get(key);
    V newValue = (oldValue == null) ? value :
               remappingFunction.apply(oldValue, value);
    if(newValue == null) {
        remove(key);
    } else {
        put(key, newValue);
    }
    return newValue;
}
```
