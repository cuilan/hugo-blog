---
title: HashMap源码分析
date: 2019-09-03 17:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

**`java.util.HashMap`** 类继承了 **`java.util.AbstractMap`** 抽象类，实现了 **`java.util.Map`**、**`java.lang.Cloneable`**、**`java.io.Serializable`** 接口。

![HashMap继承关系](/images/javase/HashMap-source-analysis/HashMap1.png "HashMap继承关系")

<!-- more -->

<a href="#1">一、HashMap特点或规范</a>
<a href="#2">二、成员属性</a>
<a href="#3">三、构造器</a>
<a href="#4">四、内部类：Node，即：Map.Entry</a>
<a href="#5">五、继承自AbstractMap的方法</a>
<a href="#6">六、实现自Map接口的方法</a>
<a href="#7">**七、静态工具方法**</a>
<a href="#8">**八、其他主要方法**</a>
<a href="#9">九、迭代器</a>
<a href="/blog/2019/09/11/javase/HashMap-TreeNode/">**十、<font color="red">红</font><font color="black">黑</font>树**</a>

---

## <a name="1">一、HashMap特点或规范</a>

**HashMap** 是基于 **哈希表** 的 Map 接口实现。**无序** 且不保证顺序永远保持不变。

### 1.1 与Hashtable的区别

| HashMap | Hashtable |
| --- | --- |
| 不同步 | 同步 |
| 允许空键 | 不允许空键 |
| 允许空值 | 不允许空值 |

### 1.2 性能

- 通常情况下，**`hash(Object)`** 方法计算得出的哈希值都均匀的分布在 **哈希桶** 之间，这样可以保证 **`get(K)`** 和 **`put(K, V)`** 基本操作方法的性能为恒定时间。
- 对集合视图：**`keySet()`**，**`values()`**，**`entrySet()`** 的 **迭代时间**，与 HashMap实例的容量（桶的数量）加上其大小（K-V Node 的数量）成比例的时间。因此，如果迭代性能有较高要求，则不要将 初始容量设置得太高 或 负载因子设置得太低。
- 影响 HashMap 性能的两个因素：**初始容量** 和 **负载因子**。

### 1.3 容量capacity & 加载因子loadFactor

- **容量**：哈希表中的桶数，初始容量只是创建 HashMap 时的容量。
- **加载因子**：是一个比例值，即：已被分布的哈希桶数 / 容量；也可以描述为：**扩容操作之前允许哈希桶中已被分布的桶的数量**。

当 HashMap 中已被分布的桶数超过了 **加载因子 * 当前容量** 时，HashMap将被扩容至原来容量的两倍，并重新计算哈希值（即，重建内部数据结构）。

默认加载因子为：**0.75**，这个值在时间和空间成本之间提供了良好的权衡。
较高的值会减少空间开销，但会增加查找成本。在设置初始容量时，应考虑 Map 中的预期 Entry 数及加载因子，以避免多次扩容带来的性能损耗。
如果要将一个包含多个 Entry 的 Map 存储在 HashMap 中，应使用足够大的初始容量来创建，否则 HashMap 自身的扩容机制会多次进行扩容，严重影响性能。

### 1.4 HashMap的数据结构

##### 1.4.1 hash算法

HashMap 是通过对 key 进行 hash() 计算得出该节点（Node） 在 table 中的位置。详情：<a href="#hash">**hash(Object)方法**</a>。

##### 1.4.2 hash冲突及常见解决办法

当 HashMap 中节点过多时，不可避免的会出现 hash 冲突的问题，常见解决办法有两类：
- **开放定址法**：又有两种：
  - **线性探测**：当 hash 冲突时，查找下一个位置是否被占用，如果被占用则继续查找下一个位置，直到找到空位置。
    - 缺点：最坏的情况下，时间复杂度为：**O(N)**
  - **平方探测**：以平方大小查找下一个位置，假如：在2位置处发生冲突，则探测 (1^2)+1=3 位置处，如果3位置处也被占用，则探测 (2^2)+2=6 位置处，(3^2)+2=11 ...
    - 缺点：虽然效率有所提升，但会浪费空间；在哈希表未满的情况下，可能无法继续放入新元素。
- **链地址法**：HashMap 就采用了这种方式。
  - 这种方式的哈希表有一个**桶**的概念，即：**哈希桶**，每一个链表就是一个哈希桶，链表中存放节点 Node。当发生 hash 冲突时，放入当前链表的末尾。

##### 1.4.3 <font color="red">红</font>黑树

当哈希表某一位置处的链表达到 8 个以上，并且哈希表的长度大于 64，该位置的链表会转换为一种 **平衡二叉树**：<a href="#10">**红黑树**</a>。

![HashMap数据结构](/images/javase/HashMap-source-analysis/HashMap-Tree.png "HashMap数据结构")

### 1.5 HashMap不同步

如果多个线程并发访问 **HashMap**，并且至少有一个线程在结构上进行了修改，则必须在外部进行同步。**结构修改** 是指 **添加**或 **删除** 一个或多个 **`Entry`** 的任何操作，仅修改 **`Entry`** 的值不是结构修改。这通常通过同步自然封装映射的某个对象来完成。

正确的同步方式：

**`Map m = Collections.synchronizedMap(new HashMap(...));`**

### 1.6 fail-fast快速失败机制

**HashMap** 的所有“集合视图方法”返回的迭代器都是 **_fail-fast_** 的：如果在创建迭代器之后的任何时候对 Map 进行结构修改，除了通过迭代器自己的 **`remove()`** 方法之外，迭代器将抛出 **`ConcurrentModificationException`** 异常。因此，在并发修改的情况下，迭代器可快速地失败。

---

## <a name="2">二、成员属性</a>

默认初始容量，必须是2的幂。
```java
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // 16
```

最大容量，2的30次幂。
```java
static final int MAXIMUM_CAPACITY = 1 << 30; // 1073741824
```

默认加载因子：0.75f。
```java
static final float DEFAULT_LOAD_FACTOR = 0.75f;
```

链表中 Entry 数大于8时，将转为 **<font color="red">红</font>黑树** 结构。
```java
static final int TREEIFY_THRESHOLD = 8;
```

**<font color="red">红</font>黑树** 转化为链表的长度临界值
```java
static final int UNTREEIFY_THRESHOLD = 6;
```

转化 **<font color="red">红</font>黑树** 的最小数组长度为64，数组长度太小不会转化红黑树。
```java
static final int MIN_TREEIFY_CAPACITY = 64;
```

HashMap 的基础数组结构，存放 Node 根节点。
```java
transient Node<K,V>[] table;
```

存放 HashMap 中全部 Entry 的 Set 集合
```java
transient Set<Map.Entry<K,V>> entrySet;
```

大小：HashMap 的 Entry 数量
```java
transient int size;
```

被修改或删除的总次数
```java
transient int modCount;
```

阈，临界值，当 HashMap 的大小达到临界值时，需要扩容
```java
int threshold;
```

加载因子
```java
final float loadFactor;
```

---

## <a name="3">三、构造器</a>

### 3.1 遵循Map接口的构造器规范

**`java.util.Map`** 接口的构造器规范，提供一个 **无参构造器**，一个 **参数类型为 Map** 的构造器。初始加载因子为默认值：0.75，其余值都为默认值。
```java
public HashMap() {
    this.loadFactor = DEFAULT_LOAD_FACTOR;
}
public HashMap(Map<? extends K, ? extends V> m) {
    this.loadFactor = DEFAULT_LOAD_FACTOR;
    // 批量放入
    putMapEntries(m, false);
}
```

### 3.2 HashMap自身构造器

支持指定 **初始容量**，加载因子为默认值：**0.75**
```java
public HashMap(int initialCapacity) {
    this(initialCapacity, DEFAULT_LOAD_FACTOR);
}
```

支持指定 **初始容量** 及 **加载因子**。
```java
public HashMap(int initialCapacity, float loadFactor) {
    // 初始容量不能小于 0
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " + initialCapacity);
    // 最大容量不能超过2的30次幂
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    // 加载因子必须大于0
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
    this.loadFactor = loadFactor;
    this.threshold = tableSizeFor(initialCapacity);
}
```

---

## <a name="4">四、内部类：Node，即：Map.Entry</a>

![HashMap.Node结构](/images/javase/HashMap-source-analysis/HashMap-Node.png "HashMap.Node结构")

```java
static class Node<K,V> implements Map.Entry<K,V> {
    // 存储 key 的 hash 值
    final int hash;
    // 存储 key
    final K key;
    // 存储 value
    V value;
    // 存储链表的下一个 Node，可以为 null
    Node<K,V> next;

    // 构造方法
    Node(int hash, K key, V value, Node<K,V> next) {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }

    public final K getKey() { return key; }
    public final V getValue() { return value; }
    public final String toString() { return key + "=" + value; }
    public final int hashCode() {
        return Objects.hashCode(key) ^ Objects.hashCode(value);
    }
    // 设置 newValue 并返回 oldValue
    public final V setValue(V newValue) {
        V oldValue = value;
        value = newValue;
        return oldValue;
    }
    public final boolean equals(Object o) {
        if (o == this) { return true; }
        if (o instanceof Map.Entry) {
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;
            // key/value 都相等才返回 true
            if (Objects.equals(key, e.getKey()) && Objects.equals(value, e.getValue())) {
                return true;
            }
        }
        return false;
    }
}
```

---

## <a name="5">五、继承自AbstractMap的方法</a>

### 5.1 基础操作

对 HashMap 的基础操作，依赖于 **`hash() / getNode() / putVal() / putMapEntries() / removeNode()`** 方法。

```java
// 返回 HashMap 的大小
public int size() { return size; }
// 是否为空
public boolean isEmpty() { return size == 0; }
// 根据 key 获取元素
public V get(Object key) {
    Node<K,V> e; // 根据 key 的 hash 从 table 中查找
    return (e = getNode(hash(key), key)) == null ? null : e.value;
}
// 是否包含此 key
public boolean containsKey(Object key) {
    return getNode(hash(key), key) != null;
}
// 放入 K-V 对，依赖 hash(K) 方法
public V put(K key, V value) {
    return putVal(hash(key), key, value, false, true);
}
// 批量放入，依赖于 putMapEntries() 方法
public void putAll(Map<? extends K, ? extends V> m) {
    putMapEntries(m, true);
}
// 删除，依赖于removeNode() 方法
public V remove(Object key) {
    Node<K,V> e;
    return (e = removeNode(hash(key), key, null, false, true)) == null ? null : e.value;
}
// 清空 HashMap，时间复杂度 O(n)
public void clear() {
    Node<K,V>[] tab;
    modCount++;
    if ((tab = table) != null && size > 0) {
        size = 0;
        for (int i = 0; i < tab.length; ++i)
            tab[i] = null;
    }
}
// 是否包含 value，时间复杂度 O(m * n)
public boolean containsValue(Object value) {
    Node<K,V>[] tab; V v;
    if ((tab = table) != null && size > 0) {
        for (int i = 0; i < tab.length; ++i) {
            for (Node<K,V> e = tab[i]; e != null; e = e.next) {
                if ((v = e.value) == value ||
                    (value != null && value.equals(v)))
                    return true;
            }
        }
    }
    return false;
}
@Override
public Object clone() {
    HashMap<K,V> result;
    try {
        result = (HashMap<K,V>)super.clone();
    } catch (CloneNotSupportedException e) {
        throw new InternalError(e);
    }
    result.reinitialize();
    result.putMapEntries(this, false);
    return result;
}
```

### 5.2 转换为单列集合视图

```java
// 返回 HashMap.KeySet
public Set<K> keySet() {
    Set<K> ks;
    return (ks = keySet) == null ? (keySet = new KeySet()) : ks;
}
// 返回 HashMap.Values
public Collection<V> values() {
    Collection<V> vs;
    return (vs = values) == null ? (values = new Values()) : vs;
}
// 返回 HashMap.EntrySet
public Set<Map.Entry<K,V>> entrySet() {
    Set<Map.Entry<K,V>> es;
    return (es = entrySet) == null ? (entrySet = new EntrySet()) : es;
}
```

---

## <a name="6">六、实现自Map接口的方法</a>

### 6.1 覆盖扩展自 JDK8 Map 的默认方法。

```java
// 返回指定 key 的 value，如果不包含 key 的映射，则返回 defaultValue
public V getOrDefault(Object key, V defaultValue) {}
// 如果 value 不存在才放入
public V putIfAbsent(K key, V value) {}
// 删除并返回是否删除成功
public boolean remove(Object key, Object value) {}
// 如果 oldValue 与 HashMap 中的值完全一致，才进行替换
public boolean replace(K key, V oldValue, V newValue) {}
// 无论新旧值是否一致，只要旧值不为空，就进行替换
public V replace(K key, V value) {}
// 循环并执行给定 lambda (K, V) -> void
public void forEach(BiConsumer<? super K, ? super V> action) {}
// 对每一个 Node 执行给定 lambda，并将结果替换 (K, V) -> V
public void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {}
```

**lambda表达式计算操作的方法**

具体说明以下方法的作用，测试数据：
```java
Map<Integer, String> map = new HashMap<>();
map.put(1, "a");
map.put(2, "b");
map.put(3, "c");
```

#### computeIfAbsent()

如果 key 存在，则不进行计算，输出旧值。
如果 key 不存在，否则根据 key 计算新值，设置并返回。
```java
public V computeIfAbsent(K key, Function<? super K, ? extends V> mappingFunction) {}
map.computeIfAbsent(3, key -> key.toString()); // 结果为：c
map.computeIfAbsent(4, key -> key.toString()); // 结果为：4
```

#### computeIfPresent()

如果 key 存在，则根据 key/value 计算新的值，设置并返回，如果计算结果为 null，则删除 Node。
如果 key 不存在，不进行计算。
```java
public V computeIfPresent(K key, BiFunction<? super K, ? super V, ? extends V> remappingFunction) {}
map.computeIfPresent(3, (key, value) -> key + value); // 结果为：3c
map.computeIfPresent(4, (key, value) -> key + value); // 无结果
map.computeIfPresent(2, (key, value) -> null); // 将 key 为2的 Node 删除
```

#### compute()

**`compute()`** 方法是 **`computeIfAbsent()`** 和 **`computeIfPresent()`** 方法的合体。
无论 key 是否存在，都根据 key/value 计算新值，如果计算结果为 null，则删除 Node。
```java
public V compute(K key, BiFunction<? super K, ? super V, ? extends V> remappingFunction) {}
map.compute(3, (k, v) -> k + v); // 结果为：3c
map.compute(4, (k, v) -> k + v); // 结果为：4null
map.compute(2, (k, v) -> null); // 将 key 为2的 Node 删除
```

#### merge()

无论 key 是否存在，都根据 **旧值** 与 **新值** 进行计算，设置并返回计算结果，如果计算结果为 null，则删除 Node。
```java
public V merge(K key, V value, BiFunction<? super V, ? super V, ? extends V> remappingFunction) {}
map.merge(3, "ccc", (oldV, newV) -> oldV + newV); // 结果为：cccc
map.merge(4, "ddd", (oldV, newV) -> oldV + newV); // 结果为：ddd
map.merge(2, "bbb", (oldV, newV) -> null); // 将 key 为2的 Node 删除
```

---

## <a name="7">七、HashMap静态工具方法</a>

### <a name="hash">7.1 hash(Object) 方法</a>

对 key 计算 hashCode 计算，int 类型的 hashCode 占 32 位，**`h >>> 16`** 将 hashCode 右移16位，再与 hashCode 进行异或运算。
```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}

// getNode(int hash, Object key) 方法
n = tab.length
tab[(n - 1) & hash]
```

**原因**：高16位与低16位进行异或运算，可以将高位上的变化体现到低位上，以此来避免 hash 碰撞，同时又保证了性能。**`getNode()`** 方法根据 **table 的最后一个索引值**与 **hash** 进行 **与运算**，将结果作为数组的索引进行取值。

```java
// 假设 table.length = 16
0000 0000 0000 0000 0000 0000 0001 0000       // 16

1111 1111 1111 1111 0000 1010 0011 1010       // 假设 h = hashCode
0000 0000 0000 0000 1111 1111 1111 1111       // h >>> 16 右移16位
1111 1111 1111 1111 1111 0101 1100 0101       // hash = h ^ (h >>> 16)

0000 0000 0000 0000 0000 0000 0000 1111       // n - 1 = 15
1111 1111 1111 1111 1111 0101 1100 0101       // (n - 1) & hash
0000 0000 0000 0000 0000 0000 0000 0101       // 计算结果为：101 -> 5
```

只有最低的4位参与了计算，**该 key 在 table 的 tab[5] 位置**。

### 7.2 tableSizeFor(int) 方法

此方法保证返回值是大于等于给定参数 cap 最小的2的幂次方的数值。具体算法是分别进行多次 **右移**，每次进行 **或等运算**。

```java
static final int tableSizeFor(int cap) {
    int n = cap - 1;
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16;
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```

假如，给定的初始化容量是10：

```java
0000 1010      // cap = 10
0000 1001      // n = 10 - 1 = 9

0000 1001      // 9
0000 0100      // 第一次右移1位
0000 1101      // 或等运算，结果13

0000 1101      // 13
0000 0011      // 第二次右移2位
0000 1111      // 或等运算，结果15

0000 1111      // 15
0000 0000      // 第三次右移4位
0000 1111      // 或等运算，结果15

0000 1111      // 15
0000 0000      // 第四次右移8位
0000 1111      // 或等运算，结果15

0000 1111      // 15
0000 0000      // 第五次右移16位
0000 1111      // 或等运算，结果15

0001 0000      // 最后结果 n = n + 1 = 16
```

---

## <a name="8">八、其他主要方法</a>

#### putMapEntries(Map, boolean)

```java
// 批量放入
final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
    int s = m.size();
    if (s > 0) {
        if (table == null) {
            // size / loadFactor + 1.0f
            float ft = ((float)s / loadFactor) + 1.0F;
            int t = ((ft < (float)MAXIMUM_CAPACITY) ? (int)ft : MAXIMUM_CAPACITY);
            if (t > threshold)
                threshold = tableSizeFor(t);
        } else if (s > threshold) {
            resize();
        }
        for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {
            K key = e.getKey();
            V value = e.getValue();
            putVal(hash(key), key, value, false, evict);
        }
    }
}
```

#### getNode(int, Object)

**执行过程分析：**

根据 **`(tab.length - 1) & hash`** 计算出元素在 table 中的索引位置，优先判断第一个：
  - 如果第一个是要找的元素，返回该元素。
  - 如果第一个不是要找的元素，则判断该节点是链表结构，还是树型结构：
    - 如果是树型结构，根据 hash、key查找。
	- 如果是链表结构，循环迭代 netx 节点，直到找到该元素。

```java
final Node<K,V> getNode(int hash, Object key) {
    Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (first = tab[(n - 1) & hash]) != null) {
        if (first.hash == hash && // 优先返回第一个元素
            ((k = first.key) == key || (key != null && key.equals(k))))
            return first;
        if ((e = first.next) != null) {
            if (first instanceof TreeNode) // 树型结构
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);
            do {
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    return e;
            } while ((e = e.next) != null); // 链表结构
        }
    }
    return null;
}
```

#### putVal(int, K, V, boolean, boolean) 方法

**执行过程分析：**
1. 先判断 table 是否为空，如果为空，进行扩容。
2. 根据 **`(tab.length - 1) & hash`** 计算出元素在 table 中的索引，并判断是否为空：
  - 第一个节点为空，说明该 hash 桶下没有任何节点，直接放入即可。
  - 第一个节点不为空：
    - 当前节点与该位置的第一个节点的 hash 值一致，key 也相同，已存在。
	- 判断该位置的结构：
	  - 树型结构：调用 **`putTreeVal()`** 放入。
	  - 链表结构：将该节点放入第一个节点的 next 位置，并检查是否需要转化为树型结构。
3. 自增修改次数、size 大小，并判断 size 是否大于当前临界值，即：是否需要扩容。

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict) {
    Node<K,V>[] tab;
    Node<K,V> p;
    int n, i;
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length; // table 为空，扩容
    if ((p = tab[i = (n - 1) & hash]) == null) // table[i] 为空，则放置第一个元素
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        if (p.hash == hash && ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    if (++size > threshold) { resize(); }
    afterNodeInsertion(evict);
    return null;
}
```

#### resize() 方法

**执行过程分析：**
1. 先判断旧容量是否大于 0：
  - 如果旧容量大于 0，说明 table 已初始化，继续判断：
    - 如果旧容量大于等于最大容量限制，将临界值 **`threshold`** 设置为 **`Integer.MAX_VALUE`**。
	- 如果将容量扩容 2 倍后小于最大容量限制，且旧容量大于等于初始容量 16，则扩容旧临界值为原来的 2 倍。
  - 如果旧容量不大于 0，说明 table 未初始化，继续判断：
    - 如果旧临界值大于 0，将旧临界值赋值给新容量，**HashMap** 初始化时，临界值为16。
	- 否则就初始化默认参数。
2. 再次校验新临界值是否为 0，如果为 0，**初始化临界值**。
3. 创建一个新 Node 数组，并循环复制全部节点：
  - 如果循环中的当前位置只有一个节点，则直接赋值。
  - 如果循环中的当前位置是红黑树，调用 **`split()`** 方法。
  - 如果循环中的当前位置是链表，则复制并重新计算 hash 值。

```java
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    // oldCap 大于 0，table 已存在
    if (oldCap > 0) {
        if (oldCap >= MAXIMUM_CAPACITY) {
            // 如果oldCap 大于 MAXIMUM_CAPACITY，将 threshold 设置为 Integer.MAX_VALUE
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            // 先将 oldCap 设置为原来的两倍
            // 判断 oldCap 是否小于 MAXIMUM_CAPACITY，且大于等于默认值
            // threshold 是原来的两倍
            newThr = oldThr << 1;
    }
    else if (oldThr > 0)
        // 如果 oldThr 大于 0，将 newCap 设置为 oldThr
        newCap = oldThr;
    else {
        // 默认初始化，cap为16，threshold为12  
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }

    if (newThr == 0) {
        // newThr 为 0，newThr = newCap * 0.75
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }

    threshold = newThr;
    // 创建一个新 Node 数组
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        // 循环复制全部节点
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)
                    // 此位置只有一个节点，直接赋值
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)
                    // 如果此位置是红黑树
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

#### removeNode(int, Object, Object, boolean, boolean) 方法

核心删除方法，其他 remove 方法都依赖于此方法。
**执行过程分析：**
1. 首先执行的前提是 table 已初始化，且不为空。
2. 根据 hash 值计算出的位置，确定该位置处是一个节点，红黑树还是链表，并查找。
3. 删除，判断该位置的类型，执行不同的删除方式。

```java
final Node<K,V> removeNode(int hash, Object key, Object value,
                           boolean matchValue, boolean movable) {
    Node<K,V>[] tab; Node<K,V> p; int n, index;
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (p = tab[index = (n - 1) & hash]) != null) {
        Node<K,V> node = null, e; K k; V v;
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            // 如果 hash 与 key 都相同，说明此位置处只有一个元素
            node = p;
        else if ((e = p.next) != null) {
            if (p instanceof TreeNode)
                // 此位置处是一个红黑树
                node = ((TreeNode<K,V>)p).getTreeNode(hash, key);
            else {
                // 此位置处是一个链表，遍历并找到 Node
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key ||
                         (key != null && key.equals(k)))) {
                        node = e;
                        break;
                    }
                    p = e;
                } while ((e = e.next) != null);
            }
        }

        if (node != null && (!matchValue || (v = node.value) == value ||
                             (value != null && value.equals(v)))) {
            if (node instanceof TreeNode)
                ((TreeNode<K,V>)node).removeTreeNode(this, tab, movable);
            else if (node == p)
                tab[index] = node.next;
            else
                p.next = node.next;
            ++modCount;
            --size;
            afterNodeRemoval(node);
            return node;
        }
    }
    return null;
}
```

---

## <a name="9">九、迭代器</a>

**`keySet()`**，**`values()`**，**`entrySet()`** 三个视图方法中的迭代器都为 **`HashIterator`** 抽象类的实例。

```java
abstract class HashIterator {
    Node<K,V> next;        // 链接下一个 Node
    Node<K,V> current;     // 当前 Node
    int expectedModCount;  // 记录操作数，防止并发修改
    int index;             // 当前 Hash 值
    HashIterator() {
        expectedModCount = modCount;
        Node<K,V>[] t = table;
        current = next = null;
        index = 0;
        if (t != null && size > 0) { // 在构造时
            do {} while (index < t.length && (next = t[index++]) == null);
        }
    }
    public final boolean hasNext() { return next != null; }
    final Node<K,V> nextNode() {
        Node<K,V>[] t;
        Node<K,V> e = next;
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
        if (e == null)
            throw new NoSuchElementException();
        if ((next = (current = e).next) == null && (t = table) != null) {
            do {} while (index < t.length && (next = t[index++]) == null);
        }
        return e;
    }
    public final void remove() {
        Node<K,V> p = current;
        if (p == null)
            throw new IllegalStateException();
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
        current = null;
        K key = p.key;
        removeNode(hash(key), key, null, false, false);
        expectedModCount = modCount;
    }
}
```

```java
// key 的迭代器
final class KeyIterator extends HashIterator implements Iterator<K> {
    public final K next() { return nextNode().key; }
}
// value 的迭代器
final class ValueIterator extends HashIterator implements Iterator<V> {
    public final V next() { return nextNode().value; }
}
// node 的迭代器
final class EntryIterator extends HashIterator implements Iterator<Map.Entry<K,V>> {
    public final Map.Entry<K,V> next() { return nextNode(); }
}
```
