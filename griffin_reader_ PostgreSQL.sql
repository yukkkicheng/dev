/*
 Navicat Premium Data Transfer

 Source Server         : dev
 Source Server Type    : MySQL
 Source Server Version : 80018 (8.0.18-baidu-rds-1.0.0.1)
 Source Host           : 10.27.139.199:8306
 Source Schema         : griffin_reader_kingbase

 Target Server Type    : Kingbase
 Target Server Version : N/A
 File Encoding         : N/A

 Date: 12/31/2024 10:47:00
*/

-- MySQL中，设置字符集为utf8mb4，确保数据库操作使用UTF-8编码
-- 在 PostgreSQL 中，字符集通常在数据库创建时指定，且客户端编码在连接配置中设置
-- PostgreSQL从9.1版本开始，其内置的UTF8编码就已经是完整的四字节UTF-8编码了
CREATE DATABASE test WITH ENCODING 'UTF8';

-- ----------------------------------------------------
-- Table 1 structure for t_auto_read_task_conf
-- ----------------------------------------------------
DROP TABLE IF EXISTS t_auto_read_task_conf; 
CREATE TABLE t_auto_read_task_conf(
  id SERIAL PRIMARY KEY,
  business_type VARCHAR(64) NOT NULL,
  doc_status INT NOT NULL,
  trigger_service_name VARCHAR(64) NOT NULL,
  param TEXT,
  enable INT NOT NULL, 
  create_time DATETIME NOT NULL,
  update_time DATETIME NOT NULL,
  griffin_reader_id VARCHAR(64) DEFAULT NULL
); -- ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
----------------------------- COMMENTS -----------------------------
COMMENT ON TABLE t_auto_read_task_conf IS '自动阅读任务配置表';
COMMENT ON COLUMN t_auto_read_task_conf.id IS '自增主键';
COMMENT ON COLUMN t_auto_read_task_conf.business_type IS '业务类型';
COMMENT ON COLUMN t_auto_read_task_conf.doc_status IS '文档监听状态';
COMMENT ON COLUMN t_auto_read_task_conf.trigger_service_name IS '触发技能名称';
COMMENT ON COLUMN t_auto_read_task_conf.param IS '参数配置';
COMMENT ON COLUMN t_auto_read_task_conf.enable IS '启用状态 0:启用 1:禁用';
COMMENT ON COLUMN t_auto_read_task_conf.create_time IS '创建时间';
COMMENT ON COLUMN t_auto_read_task_conf.update_time IS '更新时间';
------------------------------- 索引 -------------------------------
CREATE INDEX business_type_key ON t_auto_read_task_conf USING btree(business_type);

-- ----------------------------------------------------
-- Table 2 structure for t_debug_info
-- ----------------------------------------------------
DROP TABLE IF EXISTS t_debug_info;
-- 创建序列，并设置其起始值
CREATE SEQUENCE seq_debug_info
START WITH 105
INCREMENT BY 1;
-- 创建表并使用序列
CREATE TABLE t_debug_info (
  id INT DEFAULT nextval('seq_debug_info') PRIMARY KEY,
  task_id VARCHAR(64) NOT NULL,
  doc_id VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  create_time DATETIME NOT NULL
); -- ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
----------------------------- COMMENTS -----------------------------
COMMENT ON TABLE t_debug_info IS '调试信息表';
COMMENT ON COLUMN t_debug_info.id IS '自增主键';
COMMENT ON COLUMN t_debug_info.task_id IS '主键';
COMMENT ON COLUMN t_debug_info.doc_id IS '文档ID';
COMMENT ON COLUMN t_debug_info.title IS '标题';
COMMENT ON COLUMN t_debug_info.content IS '标题内容';
COMMENT ON COLUMN t_debug_info.create_time IS '创建时间';
------------------------------- 索引 -------------------------------
CREATE INDEX task_id_key ON t_debug_info USING btree(task_id);

-- ----------------------------------------------------
-- Table 3 structure for t_document_type
-- ----------------------------------------------------
DROP TABLE IF EXISTS t_document_type;
-- 创建序列，并设置其起始值
CREATE SEQUENCE seq_document_type
START WITH 1206
INCREMENT BY 1;
-- 创建表并使用序列
CREATE TABLE t_document_type (
  id BIGINT DEFAULT nextval('seq_document_type') PRIMARY KEY,
  document_type_id VARCHAR(64) NOT NULL,
  griffin_reader_id VARCHAR(64) NOT NULL,
  document_type_name VARCHAR(255) NOT NULL, 
  color INT DEFAULT NULL,
  conf TEXT,
  pid VARCHAR(64) DEFAULT NULL,
  collection_id VARCHAR(64) DEFAULT NULL,
  security_code VARCHAR(255) DEFAULT NULL,
  knowledge_id VARCHAR(64) DEFAULT NULL,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- ON UPDATE CURRENT_TIMESTAMP
  user_name VARCHAR(64) NOT NULL,
  user_id VARCHAR(64) NOT NULL,
  category VARCHAR(255) DEFAULT NULL,
  description TEXT,
  is_enable INT DEFAULT 0
); -- ENGINE=InnoDB AUTO_INCREMENT=1206 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
----------------------------- COMMENTS -----------------------------
COMMENT ON TABLE t_document_type IS '文档类型表';
COMMENT ON COLUMN t_document_type.id IS '自增主键';
COMMENT ON COLUMN t_document_type.document_type_id IS '主键';
COMMENT ON COLUMN t_document_type.griffin_reader_id IS 'griffin_reader 主键';
COMMENT ON COLUMN t_document_type.document_type_name IS '文档类型';
COMMENT ON COLUMN t_document_type.color IS '标签颜色 取随机数/9，取余';
COMMENT ON COLUMN t_document_type.conf IS '文档集配置';
COMMENT ON COLUMN t_document_type.pid IS '父id';
COMMENT ON COLUMN t_document_type.collection_id IS '文档集id';
COMMENT ON COLUMN t_document_type.security_code IS '安全码，删除时需要';
COMMENT ON COLUMN t_document_type.knowledge_id IS '知识库id';
COMMENT ON COLUMN t_document_type.create_time IS '创建时间';
COMMENT ON COLUMN t_document_type.user_name IS '更新操作用户';
COMMENT ON COLUMN t_document_type.user_id IS '更新操作用户id';
COMMENT ON COLUMN t_document_type.category IS '分类';
COMMENT ON COLUMN t_document_type.description IS '类型说明';
COMMENT ON COLUMN t_document_type.is_enable IS '启停 0：启用 1：停用';
------------------------------- 索引 -------------------------------
CREATE UNIQUE INDEX document_key ON t_document_type USING btree(griffin_reader_id, document_type_name);
COMMENT ON INDEX document_key IS '唯一索引';

-- ----------------------------------------------------
-- Table 4 structure for t_griffin_reader
-- ----------------------------------------------------
DROP TABLE IF EXISTS t_griffin_reader;
-- 创建序列，并设置其起始值
CREATE SEQUENCE seq_griffin_reader
START WITH 149
INCREMENT BY 1;
-- 创建表并使用序列
CREATE TABLE t_griffin_reader (
  id BIGINT DEFAULT nextval('seq_griffin_reader') PRIMARY KEY,
  griffin_reader_id VARCHAR(64) NOT NULL,
  namespace_id VARCHAR(64) NOT NULL,
  document_type VARCHAR(255) NOT NULL,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- ON UPDATE CURRENT_TIMESTAMP
  user_name VARCHAR(64) NOT NULL, 
  user_id VARCHAR(64) NOT NULL,
  knowledge_id VARCHAR(64) DEFAULT NULL
); -- ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
----------------------------- COMMENTS -----------------------------
COMMENT ON TABLE t_griffin_reader IS 'reader基本信息表';
COMMENT ON COLUMN t_griffin_reader.id IS '自增id';
COMMENT ON COLUMN t_griffin_reader.griffin_reader_id IS '分布式id';
COMMENT ON COLUMN t_griffin_reader.namespace_id IS '空间 id';
COMMENT ON COLUMN t_griffin_reader.document_type IS '文档类型: 通用文档,自定义文档';
COMMENT ON COLUMN t_griffin_reader.create_time IS '记录创建时间';
COMMENT ON COLUMN t_griffin_reader.update_time IS '记录变更时间';
COMMENT ON COLUMN t_griffin_reader.user_name IS '操作用户';
COMMENT ON COLUMN t_griffin_reader.user_id IS '操作用户id';
COMMENT ON COLUMN t_griffin_reader.knowledge_id IS '知识库id';
------------------------------- 索引 -------------------------------
CREATE UNIQUE INDEX uni_t_griffin_reader ON t_griffin_reader USING btree(griffin_reader_id);

-- ----------------------------------------------------
-- Table 5 structure for t_read_task
-- ----------------------------------------------------
DROP TABLE IF EXISTS t_read_task;
-- 创建序列，并设置其起始值
CREATE SEQUENCE seq_read_task
START WITH 111
INCREMENT BY 1;
-- 创建表并使用序列
CREATE TABLE t_read_task (
  id INT DEFAULT nextval('seq_read_task') PRIMARY KEY,
  task_id VARCHAR(255) NOT NULL,
  doc_id VARCHAR(255) NOT NULL,
  doc_name VARCHAR(255) NOT NULL,
  business_type VARCHAR(255) NOT NULL,
  skill VARCHAR(255) NOT NULL,
  skill_alias VARCHAR(255) NOT NULL,
  skill_id VARCHAR(255) NOT NULL,
  origin VARCHAR(255) DEFAULT NULL,
  task_status VARCHAR(255) NOT NULL,
  info TEXT,
  user_id VARCHAR(255) NOT NULL,
  user_name VARCHAR(255) NOT NULL,
  task_progress DOUBLE PRECISION DEFAULT NULL,
  task_duration BIGINT DEFAULT NULL,
  task_stage VARCHAR(16) DEFAULT NULL,
  task_failed_stage VARCHAR(255) DEFAULT NULL,
  prompt_md5 VARCHAR(255) DEFAULT NULL,
  collection_id VARCHAR(64) NOT NULL,
  request TEXT,
  create_time DATETIME NOT NULL,
  update_time DATETIME NOT NULL,
  pre_doc_index_update_time DATETIME DEFAULT NULL
); -- ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
----------------------------- COMMENTS -----------------------------
COMMENT ON TABLE t_read_task IS '阅读任务表';
COMMENT ON COLUMN t_read_task.id IS '自增主键';
COMMENT ON COLUMN t_read_task.task_id IS '主键';
COMMENT ON COLUMN t_read_task.doc_id IS '文档ID';
COMMENT ON COLUMN t_read_task.doc_name IS '文档名称';
COMMENT ON COLUMN t_read_task.business_type IS '文档类型';
COMMENT ON COLUMN t_read_task.skill IS '技能名称';
COMMENT ON COLUMN t_read_task.skill_alias IS '技能别名';
COMMENT ON COLUMN t_read_task.skill_id IS '技能ID';
COMMENT ON COLUMN t_read_task.origin IS '操作来源';
COMMENT ON COLUMN t_read_task.task_status IS '文档阅读状态';
COMMENT ON COLUMN t_read_task.info IS '记录错误信息';
COMMENT ON COLUMN t_read_task.user_id IS '操作人ID';
COMMENT ON COLUMN t_read_task.user_name IS '操作人名称';
COMMENT ON COLUMN t_read_task.task_progress IS '阅读进度';
COMMENT ON COLUMN t_read_task.task_duration IS '任务耗时';
COMMENT ON COLUMN t_read_task.task_stage IS '任务阶段';
COMMENT ON COLUMN t_read_task.task_failed_stage IS '任务失败阶段';
COMMENT ON COLUMN t_read_task.prompt_md5 IS '用到的prompt的MD5';
COMMENT ON COLUMN t_read_task.collection_id IS '文档集ID';
COMMENT ON COLUMN t_read_task.request IS '请求内容';
COMMENT ON COLUMN t_read_task.create_time IS '创建时间';
COMMENT ON COLUMN t_read_task.update_time IS '更新时间';
COMMENT ON COLUMN t_read_task.pre_doc_index_update_time IS '上次文档索引更新时间';
------------------------------- 索引 -------------------------------
CREATE UNIQUE INDEX uni_t_read_task ON t_read_task USING btree(task_id);
CREATE INDEX task_key ON t_read_task USING btree(doc_id, skill, task_status, create_time);

-- ----------------------------------------------------
-- Table 6 structure for t_skill_conf
-- ----------------------------------------------------
DROP TABLE IF EXISTS t_skill_conf;
-- 创建序列，并设置其起始值
CREATE SEQUENCE seq_skill_conf
START WITH 701
INCREMENT BY 1;
-- 创建表并使用序列
CREATE TABLE t_skill_conf (
  id BIGINT DEFAULT nextval('seq_skill_conf') PRIMARY KEY,
  skill_id VARCHAR(255) NOT NULL,
  griffin_reader_id VARCHAR(64) NOT NULL,
  document_type VARCHAR(255) NOT NULL,
  skill VARCHAR(255) NOT NULL,
  skill_alias VARCHAR(255) NOT NULL,
  skill_desc TEXT,
  is_enable INT NOT NULL,
  skill_conf TEXT NOT NULL,
  params TEXT,
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- ON UPDATE CURRENT_TIMESTAMP
  update_user_name VARCHAR(64) NOT NULL,
  update_user_id VARCHAR(64) NOT NULL
); -- ENGINE=InnoDB AUTO_INCREMENT=701 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
----------------------------- COMMENTS -----------------------------
COMMENT ON TABLE t_skill_conf IS '技能配置表';
COMMENT ON COLUMN t_skill_conf.id IS '自增主键';
COMMENT ON COLUMN t_skill_conf.skill_id IS '主键';
COMMENT ON COLUMN t_skill_conf.griffin_reader_id IS 'griffin_reader 主键';
COMMENT ON COLUMN t_skill_conf.document_type IS '文档类型';
COMMENT ON COLUMN t_skill_conf.skill IS '技能';
COMMENT ON COLUMN t_skill_conf.skill_alias IS '技能别名';
COMMENT ON COLUMN t_skill_conf.skill_desc IS '技能描述';
COMMENT ON COLUMN t_skill_conf.is_enable IS '启停 0：启用 1：停用';
COMMENT ON COLUMN t_skill_conf.skill_conf IS '技能配置';
COMMENT ON COLUMN t_skill_conf.params IS '技能参数';
COMMENT ON COLUMN t_skill_conf.create_time IS '创建时间';
COMMENT ON COLUMN t_skill_conf.update_time IS '修改时间';
COMMENT ON COLUMN t_skill_conf.update_user_name IS '更新操作用户';
COMMENT ON COLUMN t_skill_conf.update_user_id IS '更新操作用户id';
------------------------------- 索引 -------------------------------
CREATE UNIQUE INDEX uni_t_skill_conf ON t_skill_conf USING btree(skill_id);
CREATE INDEX skill_key ON t_skill_conf USING btree(griffin_reader_id, document_type, update_time);