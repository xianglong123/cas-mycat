create database partition_db_1;
create database partition_db_2;
create database partition_db_3;


-- 范围分区
create table if not exists tb_log
(
    id bigint not null comment 'ID'
    primary key,
    operateuser varchar(200) null comment '姓名',
    operation int(2) null comment '1:insert|2:delete|3:update|4:select'
    );

insert into tb_log (id, operateuser, operation) values (1, 'Tomcat1', 4);
insert into tb_log (id, operateuser, operation) values (5000000, 'Tomcat1', 4);
insert into tb_log (id, operateuser, operation) values (5000001, 'Tomcat1', 4);
insert into tb_log (id, operateuser, operation) values (10000000, 'Tomcat1', 4);
insert into tb_log (id, operateuser, operation) values (10000001, 'Tomcat1', 4);
insert into tb_log (id, operateuser, operation) values (15000000, 'Tomcat1', 4);
insert into tb_log (id, operateuser, operation) values (15000001, 'Tomcat1', 4);

-- 枚举分区
create table tb_user
(
    id bigint not null comment 'ID',
    username varchar(200) null comment '姓名',
    status int(2) default 1 null comment '1:未启用 2：已启用 3：已关闭',
    constraint tb_user_pk
        primary key (id)
);

insert into tb_user (id, username, status) values (1, 'Tom', 1);
insert into tb_user (id, username, status) values (2, 'Cat', 2);
insert into tb_user (id, username, status) values (3, 'Coco', 3);
insert into tb_user (id, username, status) values (4, 'Lily', 1);
insert into tb_user (id, username, status) values (5, 'Rose', 2);
insert into tb_user (id, username, status) values (6, 'Jim', 3);

-- 范围求摸分区
create table tb_stu
(
    id bigint not null comment 'ID',
    username varchar(200) null comment '姓名',
    status int(2) default 1 null comment '1:未启用 2：已启用 3：已关闭',
    constraint tb_stu_pk
        primary key (id)
);

insert into tb_stu (id, username, status) values (1, 'Jim', 1);
insert into tb_stu (id, username, status) values (2, 'Cat', 2);
insert into tb_stu (id, username, status) values (3, 'Rose', 3);
insert into tb_stu (id, username, status) values (4, 'Coco', 2);
insert into tb_stu (id, username, status) values (5, 'Lily1', 1);
insert into tb_stu (id, username, status) values (5000001, 'Lily1', 1);
insert into tb_stu (id, username, status) values (5000002, 'Lily1', 1);
insert into tb_stu (id, username, status) values (5000003, 'Lily1', 1);
insert into tb_stu (id, username, status) values (5000004, 'Lily1', 1);

-- 固定分片hash
create table tb_brand
(
    id bigint not null comment 'ID',
    name varchar(200) null comment '姓名',
    firstChar char(1) null comment '首字母',
    constraint tb_brand_pk
        primary key (id)
);

insert into tb_brand (id, name, firstChar) values (529, '529', 'B');
insert into tb_brand (id, name, firstChar) values (1203, '1203', 'J');
insert into tb_brand (id, name, firstChar) values (1205, '1205', 'S');
insert into tb_brand (id, name, firstChar) values (1719, '1719', 'L');

-- 取模范围分区
create table tb_mod_range
(
    id bigint not null comment 'ID',
    name varchar(200) null comment '姓名',
    constraint tb_mod_range_pk
        primary key (id)
);

insert into tb_mod_range (id, name) values (1, 'Test1');
insert into tb_mod_range (id, name) values (2, 'Test1');
insert into tb_mod_range (id, name) values (3, 'Test1');
insert into tb_mod_range (id, name) values (4, 'Test1');
insert into tb_mod_range (id, name) values (5, 'Test1');

insert into tb_mod_range (id, name) values (33, 'Test1');
insert into tb_mod_range (id, name) values (34, 'Test1');
insert into tb_mod_range (id, name) values (35, 'Test1');
insert into tb_mod_range (id, name) values (36, 'Test1');

insert into tb_mod_range (id, name) values (91, 'Test1');
insert into tb_mod_range (id, name) values (98, 'Test1');

-- 字符串hash求摸分区
create table tb_u
(
    username varchar(200) not null comment '用户名',
    age int(11) default 0 comment '年龄',
    constraint tb_u_pk
        primary key (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

insert into tb_u (username, age) values ('Test100001', 18);
insert into tb_u (username, age) values ('Test200001', 19);
insert into tb_u (username, age) values ('Test300001', 20);
insert into tb_u (username, age) values ('Test400001', 21);
insert into tb_u (username, age) values ('Test500001', 22);


-- 应用指定算法分区
create table tb_app
(
    id varchar(10) not null comment 'ID',
    name varchar(200) default NULL comment '名称',
    constraint tb_app_pk
        primary key (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

insert into tb_app (id, name) values ('00-00001', 'Testx00001');
insert into tb_app (id, name) values ('00-00002', 'Test100001');
insert into tb_app (id, name) values ('01-00001', 'Test200001');
insert into tb_app (id, name) values ('01-00002', 'Test300001');
insert into tb_app (id, name) values ('02-00001', 'Test400001');
insert into tb_app (id, name) values ('02-00002', 'Test500001');

-- 字符串hash解析算法
create table tb_strhash
(
    name varchar(20) NOT NULL comment '名称',
    content varchar(100)  NULL comment '内容',
    constraint tb_app_pk
        primary key (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

insert into tb_strhash (name, content) values ('T1001', UUID());
insert into tb_strhash (name, content) values ('ROSE', UUID());
insert into tb_strhash (name, content) values ('JERRY', UUID());
insert into tb_strhash (name, content) values ('CRISTINA', UUID());
insert into tb_strhash (name, content) values ('TOMCAT', UUID());

-- 一致性hash算法
create table tb_order
(
    id int(11) primary key,
    money int(11),
    content varchar(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;





