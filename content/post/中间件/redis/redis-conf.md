---
layout:     post 
title:      "Redis配置文件详解"
subtitle:   "Redis、redis.conf"
description: "Redis各模块功能，及配置参数详解"
date:       2020-12-01
tags:
- 中间件
- Redis
categories:
- 中间件
---

# redis.conf配置文件

```bash
# Redis configuration file example.

# 启动时指定配置文件
# ./redis-server /path/to/redis.conf

################################## NETWORK 网络 ####################################

# 绑定主机地址
bind 127.0.0.1

# 保护模式，默认开启
protected-mode yes

# 监听端口号，默认为6379，设置为0，则不监听任何端口
port 6379

# TCP 监听的最大容纳数量，默认511
Linux需要修改 /proc/sys/net/core/somaxconn 对应的值
tcp-backlog 511

# 制定 Unix socket 的路径
# unixsocket /tmp/redis.sock
# unixsocketperm 700

# 当客户端闲置多少秒后关闭连接，0代表关闭该功能
timeout 0

# TCP keepalive 心跳包
# Redis 3.2.1 之后版本推荐设置为300秒
tcp-keepalive 300

################################# GENERAL 通用 #####################################

# Redis默认不是以守护进程的方式运行的，yes启动守护进程
daemonize no

# 监控管理守护进程，no、upstart、systemd、no，默认no
supervised no

# Redis以守护进程方式运行时，Redis默认会把pid写入 /var/run/redis.pid 文件，
pidfile /var/run/redis_6379.pid

# 定义日志级别
# debug     适用于开发或测试阶段
# verbose   日志数量少于debug
# notice    适用于生产环境，默认级别
# warning   仅仅一些重要的消息被记录
loglevel notice

# 指定日志文件的位置
logfile ""

# 是否把日志记录到系统日志，默认no
# syslog-enabled no

# 设置 syslog 的 identity
# syslog-ident redis

# 设置 syslog 的 facility，必须是 USER 或者是 LOCAL0-LOCAL7 之间的值
# syslog-facility local0

# 设置数据库的数量
databases 16

# 控制台展示redis logo
always-show-logo yes

################################ SNAPSHOTTING 快照  ################################
#
# 保存数据到磁盘：
# Save the DB on disk:
#
#   格式：save <seconds> <changes>
#   根据给定的时间间隔和写入次数将数据保存到磁盘
#
#   下面的例子的意思是：
#     900 秒后如果至少有 1 个 key 的值变化，则保存
#     300 秒后如果至少有 10 个 key 的值变化，则保存
#     60  秒后如果至少有 10000 个 key 的值变化，则保存
#
#   注意：注释掉所有的 save 可停用保存功能。也可以直接一个空字符串来实现停用：
#   save ""
save 900 1
save 300 10
save 60 10000

# 持久化失败后, 是否继续工作
stop-writes-on-bgsave-error yes

# dump.rdb 文件是否使用 LZF 压缩，默认为 yes
rdbcompression yes

# 是否校验rdb文件
rdbchecksum yes

# 设置 dump 的文件名称
dbfilename dump.rdb

# RDB 文件是否删除同步锁
# 仅在同时禁用 AOF 和 RDB 的实例中起作用，否则将被完全忽略。
rdb-del-sync-files no

# 制定 rdb 存放目录，上面的 dbfilename 只指定了文件名。这个配置项必须是目录，而不能是文件名。
dir ./

################################# REPLICATION 从复制节点 #################################

# 从节点配置
# Redis 5.0 以前的版本使用 slaveof 配置从节点
# slaveof <masterip> <masterport>
#
# Redis 5.0 以后的版本建议使用此配置
# replicaof <masterip> <masterport>

# 如果主节点配置了认证，需要添加用户名、密码
# masteruser <username>
# masterauth <master-password>

# 从节点是否可以相应客户端请求，默认：yes
replica-serve-stale-data yes

# 从节点只读
replica-read-only yes

# 是否使用无盘复制
repl-diskless-sync no
repl-diskless-sync-delay 5

# RDB无盘加载
# "disabled"    - 不要使用无盘负载（首先将rdb文件存储到磁盘）
# "on-empty-db" - 仅在完全安全时才使用无盘加载
# "swapdb"      - 解析时在RAM中保留当前数据库内容的副本直接从套接字获取数据
repl-diskless-load disabled

# 主节点每隔一段固定的时间向从节点发送一个PING命令
# repl-ping-replica-period 10

# 复制超时时间，单位：秒
# repl-timeout 60

# 是否禁用 TCP_NODELAY 网络延迟，no不禁用，yes禁用
repl-disable-tcp-nodelay no

# 复制积累缓冲区大小
# repl-backlog-size 1mb

# 主服务器与从服务器断开多长时间，释放缓冲区，单位：秒，0表示从不释放积压
# repl-backlog-ttl 3600

# 从服务器晋升为主服务器的优先级，取值：0~100，值越小优先级越高，默认100
replica-priority 100

# 最小3个可写的从节点，默认0，禁用此功能
# min-replicas-to-write 3
# 最小从节点的最大延迟为10秒
# min-replicas-max-lag 10

# 从节点对外暴露ip
# replica-announce-ip 5.5.5.5
# 从节点对外暴露端口
# replica-announce-port 1234

################################## SECURITY 安全 ###################################

# 设置密码，默认无
# requirepass 123456

############################ MEMORY MANAGEMENT 内存管理 ##############################

# 最大内存限制
# maxmemory <bytes>

# 最大内存策略：如果达到内存限制了，Redis如何选择删除key。
#
# volatile-lru    -> 根据 LRU 算法删除设置过期时间的key
# allkeys-lru     -> 根据 LRU 算法删除任何key
# volatile-lfu    -> 根据 LFU 算法删除设置过期时间的key
# allkeys-lfu     -> 根据 LFU 算法删除任何key
# volatile-random -> 随机移除设置过过期时间的key
# allkeys-random  -> 随机移除任何key
# volatile-ttl    -> 移除即将过期的key(minor TTL)
# noeviction      -> 不移除任何key，只返回一个写错误（默认）
#
# maxmemory-policy noeviction

# 删除时 Redis 会检查 5 个key然后取最旧的那个。
# 默认值为5，数字越大结果越精确，但会消耗更多CPU。
# maxmemory-samples 5

# 从节点忽略最大内存限制
# replica-ignore-maxmemory yes

############################## APPEND ONLY MODE ###############################

# 是否开启 AOF 模式，默认no
appendonly no

# AOF 文件名
appendfilename "appendonly.aof"

# 同步策略，数据刷入磁盘的频率：
#     no: 不要立刻刷，只有在操作系统需要刷的时候再刷。比较快。
#     always: 每次写操作都立刻写入到aof文件。慢，但是最安全。
#     everysec: 每秒写一次。折中方案。
#
# appendfsync always
appendfsync everysec
# appendfsync no

# AOF 重写期间是否同步
no-appendfsync-on-rewrite no

# 自动重写AOF文件配置，达到64mb的100%触发重写。
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# 加载 AOF 文件时出错，是否依然启动，并发送日志通知。
aof-load-truncated yes

# RDB AOF 混合持久化
aof-use-rdb-preamble yes

################################ LUA SCRIPTING  ###############################

# LUA 脚本最大执行时间
lua-time-limit 5000

################################ REDIS CLUSTER 集群  ###############################

# 开启Redis集群功能
# cluster-enabled yes

# Redis自动生成的集群配置文件名，不能重复
# cluster-config-file nodes-6379.conf

# 集群节点超时毫秒数。超时的节点将被视为不可用状态。
# cluster-node-timeout 15000

# 集群选举新master策略：
#   (node-timeout * cluster-replica-validity-factor) + repl-ping-replica-period
# 
# cluster-replica-validity-factor 10

# cluster-migration-barrier 1

# 默认情况下 Redis 集群只要发现有一个 hash slot 未被覆盖（没有可用的节点为其提供服务）则会停止提供查询服务。 
# 因此当集群发生部分故障（比如部分的 hash slot 未被覆盖），则会导致整个集群都无法工作。
# 当所有的 slots 再次被覆盖后，集群会自动恢复到可用状态。
# 如果希望在集群发生故障时可用的部分依然可以提供查询服务，可设置为 no
# cluster-require-full-coverage yes

# master是否进行故障转移，yes不会自动进行故障转移
# cluster-replica-no-failover no

# 当集群节点数达不到最小值时，是否允许客户端读操作
# cluster-allow-reads-when-down no

################################## SLOW LOG 慢查询日志 ###################################

# 慢查询日志，记录超过多少微秒的查询命令。
# 1000000等于1秒，设置为0则记录所有命令。
slowlog-log-slower-than 10000

# 记录大小，可通过SLOWLOG RESET命令重置
slowlog-max-len 128
```






