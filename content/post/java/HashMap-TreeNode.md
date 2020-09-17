---
title: HashMap.TreeNode类源码分析
date: 2019-09-11 17:00:00
tags:
- Java
- 源码
- 集合框架
categories:
- JAVA
---

继承关系：

- **`java.util.Map.Entry`** Map 接口中的顶层实体接口。
  - **`java.util.HashMap.Node`** HashMap 中的单向链表节点。
    - **`java.util.LinkedHashMap.Entry`** LinkedHashMap 中的双向链表节点。
	  - **`java.util.HashMap.TreeNode`** HashMap 中的红黑树节点。

![TreeNode继承关系](/images/javase/HashMap-TreeNode/TreeNode1.png "TreeNode继承关系")

<!-- more -->

---

## 一、HashMap节点内部类

HashMap 中节点内部类有两种实现：
- 链表节点：**`HashMap.Node`**
- 红黑树节点：**`HashMap.TreeNode`**

有关 HashMap 数据结构、方法分析、哈希冲突 及 链表实现等，见：<a href="/blog/2019/09/03/javase/HashMap-source-analysis/">**HashMap源码分析**</a>。

---

## 二、链表-红黑树 相互转换的方法

### treeifyBin(Node, int) 方法

转换为红黑树结构：根据 hash 值计算待转换的链表在 哈希表(**`table`**) 的位置，如果否满足转换为红黑树的条件，就进行转换。

**执行过程分析：**
- 哈希表（数组）是否已初始化：
  - 未初始化，调用 **`resize()`** 进行初始化。
  - 或已初始化，判断哈希表的长度是否小于 64：
    - 小于 64，不考虑使用红黑树结构，调用 **`resize()`** 重新计算大小。
	- 大于等于 64，转换为红黑树结构。

```java
final void treeifyBin(Node<K,V>[] tab, int hash) {
    int n, index; Node<K,V> e;
    // 如果哈希表 tab 没有初始化，或长度小于最小 64，则 resize()
    if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY) { resize(); }
    // 根据 hash 计算哈希表的位置，并将该位置的链表转换为红黑树
    else if ((e = tab[index = (n - 1) & hash]) != null) {
        TreeNode<K,V> hd = null;
        TreeNode<K,V> tl = null;
        do {
            // 将链表节点替换为红黑树节点
            TreeNode<K,V> p = replacementTreeNode(e, null);
            if (tl == null)
                hd = p;
            else {
                p.prev = tl;
                tl.next = p;
            }
            tl = p;
        } while ((e = e.next) != null);
        if ((tab[index] = hd) != null)
            hd.treeify(tab); // 转换为红黑树
    }
}
```

### newTreeNode(int, K, V, Node) 方法

创建一个新的树节点。
```java
TreeNode<K,V> newTreeNode(int hash, K key, V value, Node<K,V> next) {
    return new TreeNode<>(hash, key, value, next);
}
```

### replacementNode(Node, Node) 方法

将树节点转换为链表节点。
```java
Node<K,V> replacementNode(Node<K,V> p, Node<K,V> next) {
    return new Node<>(p.hash, p.key, p.value, next);
}
```

### replacementTreeNode(Node, Node) 方法

将链表节点转换为树节点。
```java
TreeNode<K,V> replacementTreeNode(Node<K,V> p, Node<K,V> next) {
    return new TreeNode<>(p.hash, p.key, p.value, next);
}
```

---

## 三、二叉树 - <font color="red">红</font>黑树

### 3.1 二叉树

**二叉树** 又叫二叉排序树、二叉查找树。
性能：
- 在完全二叉树的情况下，时间复杂度为：**O(logn)**。
- 在极端情况下，二叉树实际上会变成链表结构，每次操作都将遍历链表，时间复杂度为：**O(n)**。

![二叉树](/images/javase/HashMap-TreeNode/BTree.png "二叉树")

二叉树的缺陷就在于不能实现**自平衡**。

### 3.2 红黑树

红黑树是一种 **自平衡二叉查找树**，它满足 **五条规则**：

- 每个节点必须是红色或黑色；
- 根节点必须是黑色；
- 每个叶子节点都是黑色的空节点；
- 如果节点是红色，则它的子节点必须是黑色（反之不一定）；
- 从根节点到叶节点或空子节点的每条路径，必须包含相同数目的黑色节点（即：**相同的黑色高度**）。

![红黑树](/images/javase/HashMap-TreeNode/RBTree.png "红黑树")

红黑树是通过 **变色、<a href="#left">左旋</a>、<a href="#right">右旋</a>** 来保持自平衡的。

---

## 四、TreeNode实现代码

### 4.1 成员属性

```java
// 继承 LinkedHashMap.Entry
static final class TreeNode<K,V> extends LinkedHashMap.Entry<K,V> {
    TreeNode<K,V> parent; // 链接父节点
    TreeNode<K,V> left; // 链接左节点
    TreeNode<K,V> right; // 链接右节点
    TreeNode<K,V> prev; // 链接前一个节点，转换为链表时需要
    boolean red; // 红黑树颜色
}
```

### 4.2 构造器

```java
TreeNode(int hash, K key, V val, Node<K,V> next) {
    super(hash, key, val, next);
}
```

### 4.3 核心方法分析

#### root() 根节点

根节点，其父节点 parent 必须为空。
```java
final TreeNode<K,V> root() {
    for (TreeNode<K,V> r = this, p;;) {
        if ((p = r.parent) == null)
            return r;
        r = p;
    }
}
```

#### <a name="left">rotateLeft() 左旋</a>

![左旋](/images/javase/HashMap-TreeNode/RotateLeft.png "左旋")

**执行过程分析：**
- p 节点不能为空，且 p 的右节点不为空，并将 p 的右节点赋值给 r。
- 如果 r 的左节点(rl) 不为空，赋值给 p 的右节点。
- 将 p 的父节点(pp) 赋值给 r 的父节点，并判断 pp 是否为空：
  - 如果 pp 不为空，则将作为 r 的父节点。
  - 如果 pp 为空，说明 r 已经是根节点，按照规则根节点一定是黑色。
- 判断 p 节点是 pp 节点的左节点还是右节点，并赋值。
- 将 p 变更为 r 的左节点。

```java
static <K,V> TreeNode<K,V> rotateLeft(TreeNode<K,V> root, TreeNode<K,V> p) {
    TreeNode<K,V> r, pp, rl;
    if (p != null && (r = p.right) != null) {

        // 判断 r 的左节点是否为空
        if ((rl = p.right = r.left) != null)
            rl.parent = p;

        // 是否为根节点，是否需要变色
        if ((pp = r.parent = p.parent) == null)
            (root = r).red = false;

        // 判断 p 是 pp 的左节点还是右节点
        else if (pp.left == p)
            pp.left = r; // 左节点
        else
            pp.right = r; // 右节点

        // 将 p 变更为 r 的左节点
        r.left = p;
        p.parent = r;
    }
    return root;
}
```

#### <a name="right">rotateRight() 右旋</a>

![右旋](/images/javase/HashMap-TreeNode/RotateRight.png "右旋")

**执行过程分析：**
- p 节点不能为空，且 p 的左节点不为空，并将 p 的左节点赋值给 l。
- 如果 l 的右节点(lr) 不为空，赋值给 p 的左节点。
- 将 p 的父节点(pp) 赋值给 l 的父节点，并判断 pp 是否为空：
  - 如果 pp 不为空，则将作为 l 的父节点。
  - 如果 pp 为空，说明 l 已经是根节点，按照规则根节点一定是黑色。
- 判断 p 节点是 pp 节点的左节点还是右节点，并赋值。
- 将 p 变更为 l 的右节点。

```java
static <K,V> TreeNode<K,V> rotateRight(TreeNode<K,V> root, TreeNode<K,V> p) {
    TreeNode<K,V> l, pp, lr;
    if (p != null && (l = p.left) != null) {

        // 判断 l 的右节点是否为空
        if ((lr = p.left = l.right) != null)
            lr.parent = p;

        // 是否为根节点，是否需要变色
        if ((pp = l.parent = p.parent) == null)
            (root = l).red = false;

        // 判断 p 是 pp 的左节点还是右节点
        else if (pp.right == p)
            pp.right = l;
        else
            pp.left = l;

        // 将 p 变更为 l 的右节点
        l.right = p;
        p.parent = l;
    }
    return root;
}
```

#### getTreeNode() & find() 查找

从树中查找元素，广度优先搜索。

```java
final TreeNode<K,V> getTreeNode(int h, Object k) {
    return ((parent != null) ? root() : this).find(h, k, null);
}

final TreeNode<K,V> find(int h, Object k, Class<?> kc) {
    TreeNode<K,V> p = this;
    do {
        int ph, dir; K pk;
        TreeNode<K,V> pl = p.left, pr = p.right, q;
        if ((ph = p.hash) > h)
            p = pl; // p.hash 大于 h，说明该节点在 p 的左边
        else if (ph < h)
            p = pr; // p.hash 小于 h，说明该节点在 p 的右边
        else if ((pk = p.key) == k || (k != null && k.equals(pk)))
            return p;  // p.hash 等于 h，说明该节点就是 p 节点
        else if (pl == null)
            p = pr;
        else if (pr == null)
            p = pl;
        else if ((kc != null ||
                  (kc = comparableClassFor(k)) != null) &&
                 (dir = compareComparables(kc, k, pk)) != 0)
            p = (dir < 0) ? pl : pr;
        else if ((q = pr.find(h, k, kc)) != null)
            return q;
        else
            p = pl;
    } while (p != null);
    return null;
}
```

#### putTreeVal() & balanceInsertion()

**`putTreeVal()`**：插入新树节点，通过比较决定放置在左节点还是右节点，**同时维护了链表的结构**。

**`balanceInsertion()`**：平衡树的结构，**变色**、**左旋** 或 **右旋**。

```java
static <K,V> TreeNode<K,V> balanceInsertion(TreeNode<K,V> root, TreeNode<K,V> x) {
    x.red = true;
    for (TreeNode<K,V> xp, xpp, xppl, xppr;;) {
        if ((xp = x.parent) == null) {
            x.red = false;
            return x;
        }
        else if (!xp.red || (xpp = xp.parent) == null)
            return root;
        if (xp == (xppl = xpp.left)) {
            if ((xppr = xpp.right) != null && xppr.red) {
                xppr.red = false;
                xp.red = false;
                xpp.red = true;
                x = xpp;
            }
            else {
                if (x == xp.right) {
                    root = rotateLeft(root, x = xp);
                    xpp = (xp = x.parent) == null ? null : xp.parent;
                }
                if (xp != null) {
                    xp.red = false;
                    if (xpp != null) {
                        xpp.red = true;
                        root = rotateRight(root, xpp);
                    }
                }
            }
        }
        else {
            if (xppl != null && xppl.red) {
                xppl.red = false;
                xp.red = false;
                xpp.red = true;
                x = xpp;
            }
            else {
                if (x == xp.left) {
                    root = rotateRight(root, x = xp);
                    xpp = (xp = x.parent) == null ? null : xp.parent;
                }
                if (xp != null) {
                    xp.red = false;
                    if (xpp != null) {
                        xpp.red = true;
                        root = rotateLeft(root, xpp);
                    }
                }
            }
        }
    }
}
```

#### removeTreeNode() & balanceDeletion()

**`removeTreeNode()`**：删除节点，**同时维护了链表的结构**。

**`balanceDeletion()`**：平衡树的结构，**变色**、**左旋** 或 **右旋**。

```java
static <K,V> TreeNode<K,V> balanceDeletion(TreeNode<K,V> root,
                                           TreeNode<K,V> x) {
    for (TreeNode<K,V> xp, xpl, xpr;;)  {
        if (x == null || x == root)
            return root;
        else if ((xp = x.parent) == null) {
            x.red = false;
            return x;
        }
        else if (x.red) {
            x.red = false;
            return root;
        }
        else if ((xpl = xp.left) == x) {
            if ((xpr = xp.right) != null && xpr.red) {
                xpr.red = false;
                xp.red = true;
                root = rotateLeft(root, xp);
                xpr = (xp = x.parent) == null ? null : xp.right;
            }
            if (xpr == null)
                x = xp;
            else {
                TreeNode<K,V> sl = xpr.left, sr = xpr.right;
                if ((sr == null || !sr.red) &&
                    (sl == null || !sl.red)) {
                    xpr.red = true;
                    x = xp;
                }
                else {
                    if (sr == null || !sr.red) {
                        if (sl != null)
                            sl.red = false;
                        xpr.red = true;
                        root = rotateRight(root, xpr);
                        xpr = (xp = x.parent) == null ?
                            null : xp.right;
                    }
                    if (xpr != null) {
                        xpr.red = (xp == null) ? false : xp.red;
                        if ((sr = xpr.right) != null)
                            sr.red = false;
                    }
                    if (xp != null) {
                        xp.red = false;
                        root = rotateLeft(root, xp);
                    }
                    x = root;
                }
            }
        }
        else { // symmetric
            if (xpl != null && xpl.red) {
                xpl.red = false;
                xp.red = true;
                root = rotateRight(root, xp);
                xpl = (xp = x.parent) == null ? null : xp.left;
            }
            if (xpl == null)
                x = xp;
            else {
                TreeNode<K,V> sl = xpl.left, sr = xpl.right;
                if ((sl == null || !sl.red) &&
                    (sr == null || !sr.red)) {
                    xpl.red = true;
                    x = xp;
                }
                else {
                    if (sl == null || !sl.red) {
                        if (sr != null)
                            sr.red = false;
                        xpl.red = true;
                        root = rotateLeft(root, xpl);
                        xpl = (xp = x.parent) == null ?
                            null : xp.left;
                    }
                    if (xpl != null) {
                        xpl.red = (xp == null) ? false : xp.red;
                        if ((sl = xpl.left) != null)
                            sl.red = false;
                    }
                    if (xp != null) {
                        xp.red = false;
                        root = rotateRight(root, xp);
                    }
                    x = root;
                }
            }
        }
    }
}
```

#### treeify() & untreeify()

**`treeify()`**：由链表结构转换为红黑树结构。

**`untreeify()`**：由红黑树结构转换为链表结构。
