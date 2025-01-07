# 中化-初始化sql兼容Kingbase问题分析
注意⚠️: SQL 文档的制作和执行应当明确以目标数据库类型，即 Kingbase 为主

## 1.SET NAMES utf8mb4：查阅资料中
这行代码的作用是设置MySQL数据库连接的字符编码为 utf8mb4。
注意：设置了连接字符集，但数据库和表的字符集也需要相应配置为 utf8mb4，以确保存储和检索数据时编码的一致性

🛑问题点：如何在Kingbase数据库中实现？还在查阅资料中
utf8.utf8mb4主要是表情之类的

## 2. 禁用外键检查：已经解决；确认是否用到外键？确认reader中
在进行表结构操作（如删除和创建表）时，禁用外键检查可以避免因外键约束而导致的操作失败。
MySQL中：
```sql
-- 关闭外键约束检查
SET FOREIGN_KEY_CHECKS = 0;
-- 开启外键约束检查
SET FOREIGN_KEY_CHECKS = 1;
```

Kingbase中没有这种全局配置关闭外键约束检查的配置，只能手动去关闭每一张表：
```sql
-- 关闭外键约束检查
ALTER TABLE 表名 DISABLE TRIGGER ALL;
-- 开启外键约束检查
ALTER TABLE 表名 ENABLE TRIGGER ALL;
```

## 3. SET utf8mb4 COLLATE utf8mb4_general_ci：初步查阅资料后，目前仍就没有找到解决方案
MySQL中有些字段用到了“SET utf8mb4 COLLATE utf8mb4_general_ci”。但是在Kingbase数据库，我这边查出来他这边没办法在建表格的时候实现指定排序顺序并大小写不敏感这功能，大部分情况下都是在查询语句中来实现。
* utf8mb4：用于定义存储文本数据时使用的编码方式。utf8mb4 是 utf8 的超集，能够存储更多的 Unicode 字符，特别是那些需要四字节存储的字符（如一些表情符号）。
* utf8mb4_general_ci：这是一个排序规则，用于定义在比较和排序字符串时应该如何处理字符。_general_ci 则表示这是一种不区分大小写的排序规则，并且是一种“通用”的排序方式，**不考虑特定语言或地区的特殊排序需求**。
```sql
CREATE TABLE `t_auto_read_task_conf` (
    `business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '业务类型'
);
```

## 4. 表结束后 ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci：还在查阅资料
疑问点：
1. 为什么表格结束后还需要用到“CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci”，那和单个字段指明有什么区别呢？
    * **CHARSET=utf8mb4**: 设置表的默认字符集为utf8mb4。
    * **COLLATE=utf8mb4_general_ci**: 指定表的默认排序规则为utf8mb4_general_ci。
2. **ENGINE=InnoDB**：指定表的存储引擎为InnoDB。Kingbase数据库通常不需要（也不允许）像MySQL那样由用户显式指定存储引擎。Kingbase的存储机制是内置的，用户无需关心。
```sql
CREATE TABLE `t_auto_read_task_conf` (
    ...
); ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

## 5. ON UPDATE CURRENT_TIMESTAMP
**ON UPDATE CURRENT_TIMESTAMP**: 在记录更新时，该字段会自动更新为当前时间戳。在KingbaseES中，直接支持ON UPDATE CURRENT_TIMESTAMP这种语法的情况可能较少。
* 使用触发器（Trigger）: 创建一个触发器，在记录更新时自动设置create_time字段为当前时间戳。这种方法比较灵活，但也需要额外的维护工作。如果您选择使用触发器来实现自动更新功能，需要编写相应的触发器函数和触发器定义，并将其应用到表上。
* 应用层处理（倾向于这个）: 另一种方法是在应用层（即应用程序代码中）处理更新时间戳的逻辑。每次更新记录时，由应用程序显式地设置create_time字段为当前时间。

Table 3 t_document_type: 
```sql
CREATE TABLE t_document_type (
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间'
)
```

Table 4 t_griffin_reader: 
```sql
CREATE TABLE t_griffin_reader (
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间'
)
```

Table 6 t_skill_conf: 
```sql
CREATE TABLE t_skill_conf (
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间'
)
```

## 6. uni索引在table 4中已经使用过
```sql
TEST=# CREATE UNIQUE INDEX uni ON t_read_task USING btree(task_id);
ERROR:  relation "uni" already exists
```

Table 4 t_griffin_reader中：
```sql
CREATE TABLE t_griffin_reader (
    UNIQUE KEY `uni` (`griffin_reader_id`) USING BTREE
)

CREATE UNIQUE INDEX uni ON t_griffin_reader USING btree(griffin_reader_id);
```

Table 5 t_read_task中：<br>
解决方法为：**把 uni-> uni_key**
```sql
CREATE TABLE t_read_task (
    UNIQUE KEY `uni` (`task_id`) USING BTREE
)

CREATE UNIQUE INDEX uni ON t_read_task USING btree(task_id); 
```










id<br>
varchar(64) -> VARCHAR(64);<br>
int(11) -> 

