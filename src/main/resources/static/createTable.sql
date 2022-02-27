create database db1;
create database db2;
create database db3;

use db1;
create table TB_TEST
(
    id int null,
    title varchar(32) null
);


use db2;
create table TB_TEST
(
    id int null,
    title varchar(32) null
);


use db3;
create table TB_TEST
(
    id int null,
    title varchar(32) null
);


--- 测试
insert into TB_TEST (id, title) values (1, 'good2');
insert into TB_TEST (id, title) values (2, 'good2');
insert into TB_TEST (id, title) values (3, 'good2');
insert into TB_TEST (id, title) values (5000000, 'good2');
insert into TB_TEST (id, title) values (5000001, 'good2');
insert into TB_TEST (id, title) values (10000001, 'good2');

--

select * from TB_TEST;