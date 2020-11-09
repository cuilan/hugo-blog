---
layout:     post 
title:      "六、Explain关键字详解"
subtitle:   "Explain关键字"
date:       2020-11-02
tags:
- 中间件
- MySQL
categories:
- 中间件
---

# Explain关键字

| 列名 | 描述 |
| :--- | :--- |
| id | 在一个大的查询语句中每个SELECT关键字都对应一个唯一的id |
| select_type | SELECT关键字对应的那个查询的类型 |
| table | 表名 |
| partitions | 匹配的分区信息 |
| **type** | 针对单表的访问方法 |
| **possible_keys** | 可能用到的索引 |
| **key** | 实际使用的索引 |
| **key_len** | 实际使用的索引长度 |
| ref | 当使用索引列等值查询时，与索引列进行等值匹配的对象信息 |
| rows | 预估的需要读取的记录条数 |
| filtered | 某个表经过搜索条件过滤后剩余记录条数的百分比 |
| **Extra** | 一些额外的信息 |

---

# 各字段详解

## id

查询语句中每出现一个`SELECT` 关键字，MySQL 就会为它分配一个唯一的id值。这个id值就是 EXPLAIN 语句的第一个列。
对于连接查询来说，一个 SELECT 关键字后边的 FROM 子句中可以跟随多个表，所以在连接查询的执行计划中，每个表都会对应一条记录，但是这些记录的id值都是相同的。

## select_type

每一个 SELECT 关键字代表的小查询都定义了一个称之为 `select_type` 的属性，意思是我们只要知道了某个小查询的 select_type 属性，就知道了这个小查询在整个大查询中扮演了一个什么角色。

### 1. SIMPLE

查询语句中不包含 `UNION` 或者 子查询 的查询都算作是 `SIMPLE` 类型。
连接查询也是 `SIMPLE` 类型。

### 2. PRIMARY

对于包含 `UNION`、`UNION ALL` 或者 **子查询** 的大查询来说，它是由几个小查询组成的，其中最左边的那个查询的 `select_type` 值就是 `PRIMARY`。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a IN (SELECT a FROM t2) OR c = 1;

+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
|  1 | PRIMARY     | t1    | NULL       | ALL   | NULL          | NULL    | NULL    | NULL |    8 |   100.00 | Using where |
|  2 | SUBQUERY    | t2    | NULL       | index | PRIMARY       | PRIMARY | 4       | NULL |    3 |   100.00 | Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)
```

从结果中可以看到，最左边的小查询 `select * from t1` 对应的是执行计划中的第一条记录，它的 `select_type` 值就是 `PRIMARY`。

### 3. UNION

对于包含 `UNION` 或者 `UNION ALL` 的大查询来说，它是由几个小查询组成的，其中除了最左边的那个小查询以外，其余的小查询的 `select_type` 值就是 `UNION`。

```sql
mysql> EXPLAIN SELECT a FROM t1 UNION SELECT a FROM t2;
+----+--------------+------------+------------+-------+---------------+---------+---------+------+------+----------+-----------------+
| id | select_type  | table      | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra           |
+----+--------------+------------+------------+-------+---------------+---------+---------+------+------+----------+-----------------+
|  1 | PRIMARY      | t1         | NULL       | index | NULL          | idx_bcd | 15      | NULL |    8 |   100.00 | Using index     |
|  2 | UNION        | t2         | NULL       | index | NULL          | PRIMARY | 4       | NULL |    3 |   100.00 | Using index     |
|NULL| UNION RESULT | <union1,2> | NULL       | ALL   | NULL          | NULL    | NULL    | NULL | NULL |     NULL | Using temporary |
+----+--------------+------------+------------+-------+---------------+---------+---------+------+------+----------+-----------------+
3 rows in set, 1 warning (0.00 sec)
```

### 4. UNION RESULT

MySQL选择使用 **临时表** 来完成 `UNION` 查询的 **去重** 工作，针对该临时表的查询的 `select_type` 就是 `UNION RESULT`。见上边 **UNION** 例子。

### 5. SUBQUERY

**非相关子查询**，`select_type` 为 `SUBQUERY` 的子查询由于会被 **物化**，所以只需要执行一遍。见上边 **PRIMARY** 中的例子。

### 6. DEPENDENT SUBQUERY 独立子查询

**相关子查询**，`select_type` 为 `DEPENDENT SUBQUERY` 的查询可能会被执行多次。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a IN (SELECT a FROM t2 WHERE t1.a = t2.a) OR c =1;
+----+--------------------+-------+------------+--------+---------------+---------+---------+--------------+------+----------+--------------------------+
| id | select_type        | table | partitions | type   | possible_keys | key     | key_len | ref          | rows | filtered | Extra                    |
+----+--------------------+-------+------------+--------+---------------+---------+---------+--------------+------+----------+--------------------------+
|  1 | PRIMARY            | t1    | NULL       | ALL    | NULL          | NULL    | NULL    | NULL         |    8 |   100.00 | Using where              |
|  2 | DEPENDENT SUBQUERY | t2    | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | zy_test.t1.a |    1 |   100.00 | Using where; Using index |
+----+--------------------+-------+------------+--------+---------------+---------+---------+--------------+------+----------+--------------------------+
2 rows in set, 2 warnings (0.00 sec)
```

### 7. DEVIED 提取表

```sql
mysql> EXPLAIN SELECT * FROM (SELECT a, count(*) FROM t2 GROUP BY a) AS devied_table;
+----+-------------+------------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type | table      | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+-------------+------------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
|  1 | PRIMARY     | <derived2> | NULL       | ALL   | NULL          | NULL    | NULL    | NULL |    3 |   100.00 | NULL        |
|  2 | DERIVED     | t2         | NULL       | index | PRIMARY       | PRIMARY | 4       | NULL |    3 |   100.00 | Using index |
+----+-------------+------------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)
```

从执行计划中可以看出，id 为 2 的记录就代表子查询的执行方式，它的 `select_type`是 `DERIVED`，说明该子查询是以 **物化** 的方式执行的。
id 为 1 的记录代表外层查询，注意：它的 `table` 列显示的是，表示该查询是针对将 **派生表物化** 之后的表进行查询的。

### 8. MATERIALIZED 物化表

当查询优化器在执行包含子查询的语句时，选择将子查询物化之后与外层查询进行连接查询时，该子查询对应的 `select_type` 属性就是 `MATERIALIZED`。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a IN(SELECT c FROM t2 WHERE b =1);
+----+--------------+-------------+------------+--------+---------------+---------+---------+---------------+------+----------+-------------+
| id | select_type  | table       | partitions | type   | possible_keys | key     | key_len | ref           | rows | filtered | Extra       |
+----+--------------+-------------+------------+--------+---------------+---------+---------+---------------+------+----------+-------------+
|  1 | SIMPLE       | <subquery2> | NULL       | ALL    | NULL          | NULL    | NULL    | NULL          | NULL |   100.00 | Using where |
|  1 | SIMPLE       | t1          | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | <subquery2>.c |    1 |   100.00 | NULL        |
|  2 | MATERIALIZED | t2          | NULL       | ALL    | NULL          | NULL    | NULL    | NULL          |    3 |    33.33 | Using where |
+----+--------------+-------------+------------+--------+---------------+---------+---------+---------------+------+----------+-------------+
3 rows in set, 1 warning (0.00 sec)
```

## table

查询表名。

## partitions

匹配的分区信息。

## type

针对单表的访问方法。

### 1. system

当表中只有一条记录并且该表使用的存储引擎的统计数据是精确的，比如 `MyISAM`、`Memory` 存储引擎，那么对该表的访问方法就是 `system`。

```sql
mysql> CREATE TABLE test(i int) Engine=MyISAM;
Query OK, 0 rows affected (0.01 sec)

mysql> INSERT INTO test VALUES(1);
Query OK, 1 row affected (0.01 sec)

mysql> EXPLAIN SELECT * FROM test;
+----+-------------+-------+------------+--------+---------------+------+---------+------+------+----------+-------+
| id | select_type | table | partitions | type   | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
+----+-------------+-------+------------+--------+---------------+------+---------+------+------+----------+-------+
|  1 | SIMPLE      | test  | NULL       | system | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+--------+---------------+------+---------+------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
```

### 2. const

当根据主键或者唯一二级索引列与常数进行等值匹配时，对单表的访问方法就是 `const`。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a = 1;
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | t1    | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
```

### 3. eq_ref

在连接查询时，如果被驱动表是通过主键或者唯一二级索引列等值匹配的方式进行访问的（如果该主键或者唯一二级索引是联合索引的话，所有的索引列都必须进行等值比较），
则对该被驱动表的访问方法就是 `eq_ref`。

```sql
mysql> EXPLAIN SELECT * FROM t1 JOIN t2 ON t1.a = t2.a;
+----+-------------+-------+------------+--------+---------------+---------+---------+--------------+------+----------+-------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref          | rows | filtered | Extra |
+----+-------------+-------+------------+--------+---------------+---------+---------+--------------+------+----------+-------+
|  1 | SIMPLE      | t2    | NULL       | ALL    | PRIMARY       | NULL    | NULL    | NULL         |    3 |   100.00 | NULL  |
|  1 | SIMPLE      | t1    | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | zy_test.t2.a |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+--------+---------------+---------+---------+--------------+------+----------+-------+
2 rows in set, 1 warning (0.00 sec)
```

### 4. ref

当通过普通的二级索引列与常量进行等值匹配时来查询某个表，那么对该表的访问方法就可能是 `ref`。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE b = 1;
+----+-------------+-------+------------+------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | t1    | NULL       | ref  | idx_bcd       | idx_bcd | 5       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+---------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)
```

### 5. ref_or_null

当对普通二级索引进行等值匹配查询，该索引列的值也可以是NULL值时，那么对该表的访问方法就可能是 `ref_or_null`。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE b = 1 OR b IS NULL;
+----+-------------+-------+------------+-------------+---------------+---------+---------+-------+------+----------+-----------------------+
| id | select_type | table | partitions | type        | possible_keys | key     | key_len | ref   | rows | filtered | Extra                 |
+----+-------------+-------+------------+-------------+---------------+---------+---------+-------+------+----------+-----------------------+
|  1 | SIMPLE      | t1    | NULL       | ref_or_null | idx_bcd       | idx_bcd | 5       | const |    2 |   100.00 | Using index condition |
+----+-------------+-------+------------+-------------+---------------+---------+---------+-------+------+----------+-----------------------+
1 row in set, 1 warning (0.00 sec)
```

### 6. index_merge

索引合并。
```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a = 1 OR b = 1;
+----+-------------+-------+------------+-------------+-----------------+-----------------+---------+------+------+----------+------------------------------------------------+
| id | select_type | table | partitions | type        | possible_keys   | key             | key_len | ref  | rows | filtered | Extra                                          |
+----+-------------+-------+------------+-------------+-----------------+-----------------+---------+------+------+----------+------------------------------------------------+
|  1 | SIMPLE      | t1    | NULL       | index_merge | PRIMARY,idx_bcd | idx_bcd,PRIMARY | 5,4     | NULL |    2 |   100.00 | Using sort_union(idx_bcd,PRIMARY); Using where |
+----+-------------+-------+------------+-------------+-----------------+-----------------+---------+------+------+----------+------------------------------------------------+
1 row in set, 1 warning (0.00 sec)
```

### 7. unique_subquery

如果查询优化器决定将 `IN` 子查询转换为 `EXISTS` 子查询，而且子查询可以使用到主键进行等值匹配的话，那么该子查询执行计划的 `type` 列的值就是 `unique_subquery`。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE c IN (SELECT a FROM t2 WHERE t1.c = t2.c) OR a = 1;
+----+--------------------+-------+------------+-----------------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type        | table | partitions | type            | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+--------------------+-------+------------+-----------------+---------------+---------+---------+------+------+----------+-------------+
|  1 | PRIMARY            | t1    | NULL       | ALL             | PRIMARY       | NULL    | NULL    | NULL |    8 |   100.00 | Using where |
|  2 | DEPENDENT SUBQUERY | t2    | NULL       | unique_subquery | PRIMARY       | PRIMARY | 4       | func |    1 |    33.33 | Using where |
+----+--------------------+-------+------------+-----------------+---------------+---------+---------+------+------+----------+-------------+
2 rows in set, 2 warnings (0.00 sec)
```

### 8. index_subquery

`index_subquery` 与 `unique_subquery` 类似，只不过访问子查询中的表时使用的是 **普通索引**。

### 9. range

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a > 1;
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | t1    | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL |    7 |   100.00 | Using where |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
```

### 10. index

当可以使用覆盖索引，但需要扫描全部的索引记录时，该表的访问方法就是 `index`。
```sql
mysql> EXPLAIN SELECT b FROM t1;
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | t1    | NULL       | index | NULL          | idx_bcd | 15      | NULL |    8 |   100.00 | Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.01 sec)
```

### 11. all

全表扫描。

## possible_key 和 key

`possible_keys` 列表示在某个查询语句中，对某个表执行单表查询时可能用到的索引有哪些。

`key` 列表示实际用到的索引有哪些。

不过有一点比较特别，就是在使用 `index` 访问方法来查询某个表时，`possible_keys` 列是空的，而 `key` 列展示的是实际使用到的索引。

> possible_keys 列中的值并不是越多越好，可能使用的索引越多，查询优化器计算查询成本时就得花费更长时间，所以如果可以的话，尽量删除那些用不到的索引。

## key_len

`key_len` 列表示当优化器决定使用某个索引执行查询时，该索引记录的最大长度，它是由这三个部分构成的：
* 对于使用固定长度类型的索引列来说，它实际占用的存储空间的最大长度就是该固定值，对于指定字符集的变长类型的索引列来说，比如某个索引列的类型是 `VARCHAR(100)`，使用的字符集是 `utf8`，那么该列实际占用的最大存储空间就是 **100 × 3 = 300** 个字节。
* 如果该索引列可以存储 `NULL` 值，则 `key_len` 比不可以存储 `NULL` 值时多1个字节。
* 对于变长字段来说，都会有2个字节的空间来存储该变长列的实际长度。

## ref

当使用索引列等值匹配的条件去执行查询时，也就是在访问方法是 `const`、`eq_ref`、`ref`、`ref_or_null`、`unique_subquery`、`index_subquery` 其中之一时，`ref` 列展示的就是与索引列作等值匹配的东西是什么，比如只是一个常数或者是某个列。

## rows

如果查询优化器决定使用全表扫描的方式对某个表执行查询时，执行计划的 `rows` 列就代表预计需要扫描的行数，如果使用索引来执行查询时，执行计划的 `rows` 列就代表预计扫描的索引记录行数。

## filered

代表查询优化器预测在这扫描的记录中，有多少条记录满足其余的搜索条件。

```sql
mysql> EXPLAIN SELECT * FROM t1 WHERE a > 1 AND b = 1;
+----+-------------+-------+------------+------+-----------------+---------+---------+-------+------+----------+-----------------------+
| id | select_type | table | partitions | type | possible_keys   | key     | key_len | ref   | rows | filtered | Extra                 |
+----+-------------+-------+------------+------+-----------------+---------+---------+-------+------+----------+-----------------------+
|  1 | SIMPLE      | t1    | NULL       | ref  | PRIMARY,idx_bcd | idx_bcd | 5       | const |    1 |    87.50 | Using index condition |
+----+-------------+-------+------------+------+-----------------+---------+---------+-------+------+----------+-----------------------+
1 row in set, 1 warning (0.00 sec)
```

从执行计划的 `key` 列中可以看出来，该查询使用 `PRIMARY` 索引来执行查询，从 `rows` 列可以看出满足 `a > 1` 的记录有 1 条。
执行计划的 `filtered` 列就代表查询优化器预测在这 1 条记录中，有多少条记录满足其余的搜索条件，也就是 `b = 1` 这个条件的百分比。此处 `filtered` 列的值是 **87.50**，
说明查询优化器预测在 1 条记录中有 **87.50%** 的记录满足 `b = 1` 这个条件。

对于单表查询来说，这个 `filtered` 列的值没什么意义，我们更关注在连接查询中驱动表对应的执行计划记录的 `filtered` 值。

## Extra

Extra 列是用来说明一些额外信息的，我们可以通过这些额外信息来更准确的理解 MySQL 到底将如何执行给定的查询语句。

## No tables used

当查询语句的没有FROM子句时将会提示该额外信息。

## Impossible WHERE

查询语句的 `WHERE` 子句永远为 `FALSE` 时将会提示该额外信息。

## No matching min/max row

当查询列表处有 `MIN` 或者 `MAX` 聚集函数，但是并没有符合 `WHERE` 子句中的搜索条件的记录时，将会提示该额外信息。

## Using index

当查询列表以及搜索条件中只包含属于某个索引的列，也就是在可以使用索引覆盖的情况下，在 `Extra` 列将会提示该额外信息。

## Using index condition

有些搜索条件中虽然出现了索引列，但却不能使用到索引(在MySQL 5.6版本后加入的新特性)。

## Using where

当使用全表扫描来执行对某个表的查询，并且该语句的 `WHERE` 子句中有针对该表的搜索条件时，在 Extra 列中会提示上述额外信息。

## Using join buffer(Block Nested Loop)

在连接查询执行过程中，当被驱动表不能有效的利用索引加快访问速度，MySQL一般会为其分配一块名叫 `join buffer` 的内存块来加快查询速度。

## Using filesort

很多情况下排序操作无法使用到索引，只能在内存中(记录较少的时候)或者磁盘中(记录较多的时候)进行排序，
这种在内存中或者磁盘上进行排序的方式统称为 **文件排序(英文名:filesort)**。
如果某个查询需要使用文件排序的方式执行查询，就会在执行计划的 Extra 列中显示 `Using filesort` 提示。

## Using temporary

在许多查询的执行过程中，MySQL 可能会借助 **临时表** 来完成一些功能，比如 **去重**、**排序** 之类的，
比如在执行许多包含 `DISTINCT`、`GROUP BY`、`UNION` 等子句的查询过程中，如果不能有效利用索引来完成查询，
MySQL 很有可能寻求通过建立内部的临时表来执行查询。如果查询中使用到了内部的临时表，在执行计划的 Extra 列将会显示 `Using temporary` 提示。

## Start temporary、End temporary

查询优化器会优先尝试将 `IN` 子查询转换成 semi-join，而semi-join又有好多种执行策略，当执行策略为 `DuplicateWeedout` 时，
也就是通过建立临时表来实现为外层查询中的记录进行去重操作时，驱动表查询执行计划的 Extra 列将显示 `Start temporary` 提示，
被驱动表查询执行计划的 Extra 列将显示 `End temporary` 提示。

## FirstMatch(表名)

在将 `IN` 子查询转为 semi-join 时，如果采用的是 `FirstMatch` 执行策略，则在被驱动表执行计划的 Extra 列就是显示 `FirstMatch(tbl_name)` 提示。

---

# 总结

## 性能按 type 排序

**system > const > eq_ref > ref > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL**

## 性能按 Extra 排序

* `Using index` : 用了覆盖索引
* `Using index condition` : 用了条件索引(索引下推)
* `Using where` : 从索引查出来数据后继续用 `where` 条件过滤
* `Using join buffer(Block Nested Loop)` : join 的时候利用了 join buffer(优化策略:去除外连接、增 大join buffer大小)
* `Using filesort` : 用了文件排序，排序的时候没有用到索引
* `Using temporary` : 用了临时表(优化策略:增加条件以减少结果集、增加索引，思路就是要么减少待排序的数量，要么就提前排好序)
* `Start temporary`, `End temporary` : 子查询的时候，可以优化成半连接，但是使用的是通过临时表来去重
* `FirstMatch(tbl_name)` : 子查询的时候，可以优化成半连接，但是使用的是直接进行数据比较来去重

## 常见优化手段

1. SQL语句中 `IN` 包含的值不应过多，不能超过200个，200个以内查询优化器计算成本时比较精准，超过200个是估算的成本，另外建议能用 `between` 就不要用 `in`，这样就可以使用 `range` 索引了。
2. `SELECT` 语句务必指明字段名称: `SELECT *` 增加很多不必要的消耗(cpu、io、内存、网络带宽);
增加了使用覆盖索引的可能性;当表结构发生改变时，前断也需要更新。所以要求直接在select后面接上字段名。
3. 当只需要一条数据的时候，使用 `LIMIT 1`。
4. 排序时注意是否能用到索引。
5. 使用 `OR` 时如果没有用到索引，可以改为 `UNION ALL` 或者 `UNION`。
6. 如果 `IN` 不能用到索引，可以改成 `EXISTS` 看是否能用到索引。
7. 使用合理的分页方式以提高分页的效率。
8. 不建议使用 `%` 前缀模糊查询。
9. 避免在 `WHERE` 子句中对字段进行表达式操作。
10. 避免隐式类型转换。
11. 对于联合索引来说，要遵守最左前缀法则。
12. 必要时可以使用 `force index` 来强制查询走某个索引。
13. 对于联合索引来说，如果存在范围查询，比如 `between`、`>`、`<` 等条件时，会造成后面的索引字段失效。
14. 尽量使用 `INNER JOIN`，避免 `LEFT JOIN`，让查询优化器来自动选择小表作为驱动表。
15. 必要时刻可以使用 `straight_join` 来指定驱动表，前提条件是本身是 `INNER JOIN`。

