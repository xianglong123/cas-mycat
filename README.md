## 分片规则 - 按id自增分片
    1、scheme.xml <table name="TB_TEST" primaryKey="id" dataNode="dn1,dn2,dn3" rule="auto-sharding-long" />
       设置rule为auto-sharding-long
    
    2、查看rule.xml表中规则
    	<tableRule name="auto-sharding-long">
    		<rule>
    			<columns>id</columns>
    			<algorithm>rang-long</algorithm>
    		</rule>
    	</tableRule>
    	
    	<function name="rang-long"
    		class="io.mycat.route.function.AutoPartitionByLong">
    		<property name="mapFile">autopartition-long.txt</property>
    	</function>
    	
    	查看	autopartition-long.txt规则
    
    3、[root@iZ2zei01n7f2wre8skwlipZ conf]# cat autopartition-long.txt 
      # range start-end ,data node index
      # K=1000,M=10000.
      0-500M=0
      500M-1000M=1
      1000M-1500M=2
      
      解释：0-500M的id在表0，500M-1000M在表1，1000M-1500M在表2

## server.xml中密码加密
    执行命令：java -cp Mycat-server-1.6.7.1-release.jar io.mycat.util.DecryptUtil 0:xianglong:123456
         GO0bnFVWrAuFgr1JMuMZkvfDNyTpoiGU7n/Wlsa151CirHQnANVk3NzE3FErx8v6pAcO0ctX3xFecmSr+976QA==
         
     将密码粘贴在rule.xml的password处。并新增usingDecrypt为1 ==》 是否启动加密：yes
     
     	<user name="xianglong" defaultAccount="true">
     		<property name="password">h+PqhcJESzF+85+Osof1C3GA5+RcV0pom4ZuzSwO6yRyNUqkjvXnmA/ySxQLX77oyOIK3HVDVjccrSpGZYa7Gw==</property>
     		<property name="schemas">ITCAST</property>
     		<property name="usingDecrypt">1</property>
     		
## 权限设置
                <privileges check="true">  是否检查权限，false后面就无效了
                        <schema name="ITCAST" dml="0110" >  0000 分别代表增删改查权限
                                <table name="TB_TEST" dml="0000"></table> 就近原则，越靠近表的权限，优先级越高
                        </schema>
                </privileges>  

## firewall 标签
    firewall 标签用来定义防火墙：firewall下whitehost标签用来定义IP白名单，blacklist用来定义 SQL黑名单。
    
```xml
<firewall>
    <!--白名单配置-->
    <whitehost>
        <host user="root" host="127.0.0.1"></host>
    </whitehost>
    <!--黑名单配置-->
    <blacklist check="true">
        <property name="selectAllow">true</property>
    </blacklist>
</firewall>
```

### 摸分区
    <table name="tb_log" primaryKey="id" dataNode="dn1,dn2,dn3" rule="mod-long" />
    mod-long:根据指定队列%实例数选择存放数据的实例
```xml
	<tableRule name="mod-long">
		<rule>
			<columns>id</columns>
			<algorithm>mod-long</algorithm>
		</rule>
	</tableRule>

	<function name="mod-long" class="io.mycat.route.function.PartitionByMod">
		<!-- how many data nodes -->
		<property name="count">3</property> 
	</function>
```

### 范围分区
    <table name="tb_log" primaryKey="id" dataNode="dn1,dn2,dn3" rule="auto-sharding-long" />
    auto-sharding-long：根据指定columns的数值选择存放的实例
```xml
	<tableRule name="auto-sharding-long">
		<rule>
			<columns>id</columns>
			<algorithm>rang-long</algorithm>
		</rule>
	</tableRule>

	<function name="rang-long"
		class="io.mycat.route.function.AutoPartitionByLong">
		<property name="mapFile">autopartition-long.txt</property>
		<property name="defaultNode">0</property> # 要是找不到计算出来的实例，默认第0个
	</function>
```
    # range start-end ,data node index
    # K=1000,M=10000.
    0-500M=0
    500M-1000M=1
    1000M-1500M=2
  
### 枚举分区
	<table name="tb_user" primaryKey="id" dataNode="dn1,dn2,dn3" rule="sharding-by-enum-status" />
    sharding-by-enum-status：根据枚举的值选择存放的实例
```xml
	<tableRule name="sharding-by-enum-status">
		<rule>
			<columns>status</columns>
			<algorithm>hash-int</algorithm>
		</rule>
	</tableRule>

	<function name="hash-int"
		class="io.mycat.route.function.PartitionByFileMap">
		<property name="mapFile">partition-hash-int.txt</property>
		<property name="type">0</property> #字段的类型
		<property name="defaultNode">0</property>
	</function>
```
    cat partition-hash-int.txt
    1=0
    2=1
    3=2
   
### 范围求摸分区
    <table name="tb_stu" primaryKey="id" dataNode="dn1,dn2,dn3" rule="auto-sharding-rang-mod" />
    auto-sharding-rang-mod:先范围分区，再求摸分区

```xml
	<tableRule name="auto-sharding-rang-mod">
		<rule>
			<columns>id</columns>
			<algorithm>rang-mod</algorithm>
		</rule>
	</tableRule>

	<function name="rang-mod" class="io.mycat.route.function.PartitionByRangeMod">
        	<property name="mapFile">partition-range-mod.txt</property>
	</function>    
```
    cat partition-range-mod.txt
    # range start-end ,data node group size
    0-500M=1
    500M1-2000M=2

### 固定分片hash
    <table name="tb_brand" primaryKey="id" dataNode="dn1,dn2,dn3" rule="sharding-by-long-hash" />
    sharding-by-long-hash ：根据后10位二进制数据和1024取摸。扩展差八成生产也很少用。
```xml
	<tableRule name="sharding-by-long-hash">
		<rule>
			<columns>id</columns>
			<algorithm>func1</algorithm>
		</rule>
	</tableRule>

	<function name="func1" class="io.mycat.route.function.PartitionByLong">
		<property name="partitionCount">2,1</property>
		<property name="partitionLength">256,512</property>
	</function>
```

### 取模范围分区
    <table name="tb_mod_range" primaryKey="id" dataNode="dn1,dn2,dn3" rule="sharding-by-pattern" />
    sharding-by-pattern: 取模之后的数据，在哪个范围决定存储在哪个实例中
```xml
	<tableRule name="sharding-by-pattern">
		<rule>
			<columns>id</columns>
			<algorithm>sharding-by-pattern</algorithm>
		</rule>
	</tableRule>

	<function name="sharding-by-pattern" class="io.mycat.route.function.PartitionByPattern">
		<property name="mapFile">partition-pattern.txt</property>
		<property name="defaultNode">0</property>
		<property name="patternValue">96</property>
	</function>

```
    cat partition-pattern.txt
    0-32=0
    33-64=1
    65-96=2

### 字符串hash求摸范围分区
    <table name="tb_u" primaryKey="username" dataNode="dn1,dn2,dn3" rule="sharding-by-prefixpattern" />
    sharding-by-prefixpattern：取字符串前N位，取ASCII码值相加，然后取摸
```xml
	<tableRule name="sharding-by-prefixpattern">
		<rule>
			<columns>username</columns>
			<algorithm>sharding-by-prefixpattern</algorithm>
		</rule>
	</tableRule>

	<function name="sharding-by-prefixpattern" class="io.mycat.route.function.PartitionByPrefixPattern">
		<property name="mapFile">partition-prefixpattern.txt</property>
		<property name="prefixLength">5</property>
		<property name="patternValue">96</property>
	</function>
```    
    cat partition-prefixpattern.txt
    0-32=0
    33-64=1
    65-96=2    

### 应用指定算法
    由运行阶段由应用自主决定路由到哪个分片，直接根据字符子穿（必须是数字）计算分区号，配置如下；
    <table name="tb_app" primaryKey="id" dataNode="dn1,dn2,dn3" rule="sharding-by-substring" />
```xml
	<tableRule name="sharding-by-substring">
		<rule>
			<columns>id</columns>
			<algorithm>sharding-by-substring</algorithm>
		</rule>
	</tableRule>
	<function name="sharding-by-substring" class="io.mycat.route.function.PartitionDirectBySubString">
		<property name="startIndex">0</property> 开始的索引
		<property name="size">2</property>       截取的字段长度
		<property name="partitionCount">3</property> 总共由多少实例
		<property name="defaultPartition">0</property> 找不到走哪台
	</function>

```

### 字符串hash解析算法
    <table name="tb_strhash" primaryKey="name" dataNode="dn1,dn2" rule="sharding-by-stringhash" />
```xml
	<tableRule name="sharding-by-stringhash">
		<rule>
			<columns>name</columns>
			<algorithm>sharding-by-stringhash</algorithm>
		</rule>
	</tableRule>
	<function name="sharding-by-stringhash" class="io.mycat.route.function.PartitionByString">
		<property name="partitionLength">512</property>
		<property name="partitionCount">2</property>
		<property name="hashSlice">0:2</property>
	</function>
```

### 一致性hash算法
    一致性hash算法有效解决了分布式数据的扩展问题
 
 
 
### mysql 自带分区
    水平分区Partition有以下几种模式
    Range（范围） – 这种模式允许DBA将数据划分不同范围。例如DBA可以将一个表通过年份划分成三个分区，80年代（1980’s）的数据，90年代（1990’s）的数据以及任何在2000年（包括2000年）后的数据。
    Hash（哈希） – 这中模式允许DBA通过对表的一个或多个列的Hash Key进行计算，最后通过这个Hash码不同数值对应的数据区域进行分区，。例如DBA可以建立一个对表主键进行分区的表。
    Key（键值） – 上面Hash模式的一种延伸，这里的Hash Key是MySQL系统产生的。
    List（预定义列表） – 这种模式允许系统通过DBA定义的列表的值所对应的行数据进行分割。例如：DBA建立了一个横跨三个分区的表，分别根据2004年2005年和2006年值所对应的数据。
    Composite（复合模式） - 很神秘吧，哈哈，其实是以上模式的组合使用而已，就不解释了。举例：在初始化已经进行了Range范围分区的表上，我们可以对其中一个分区再进行hash哈希分区。

```sql
PARTITION BY RANGE (YEAR(createtime))
(PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
PARTITION p2018 VALUES LESS THAN MAXVALUE ENGINE = InnoDB
);


select YEAR('2017-01-01');

insert into message_all (id, createtime) values (1, DATE_SUB(NOW(), INTERVAL 6 YEAR ));
insert into message_all (id, createtime) values (2, DATE_SUB(NOW(), INTERVAL 7 YEAR ));
insert into message_all (id, createtime) values (3, DATE_SUB(NOW(), INTERVAL 8 YEAR ));
insert into message_all (id, createtime) values (4, DATE_SUB(NOW(), INTERVAL 6 YEAR ));
insert into message_all (id, createtime) values (5, DATE_SUB(NOW(), INTERVAL 6 YEAR ));
insert into message_all (id, createtime) values (6, DATE_SUB(NOW(), INTERVAL 6 YEAR ));
insert into message_all (id, createtime) values (7, DATE_SUB(NOW(), INTERVAL 6 YEAR ));
insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL 6 YEAR ));

insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL 1 YEAR ));
insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL 2 YEAR ));
insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL 3 YEAR ));
insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL 4 YEAR ));
insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL 5 YEAR ));

insert into message_all (id, createtime) values (8, DATE_SUB(NOW(), INTERVAL -5 YEAR ));

select DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');
select DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');
select DATE_SUB(NOW(), INTERVAL 6.3 YEAR);
select DATE_SUB(NOW(), INTERVAL 4 YEAR);


select * from message_all where createtime < DATE_SUB(NOW(), INTERVAL 4 YEAR ) and createtime > '2016-02-19 19:52:25';
explain select * from message_all where createtime < DATE_SUB(NOW(), INTERVAL 4 YEAR ) and createtime > '2016-02-19 19:52:25';


-- 删除分区
ALTER TABLE message_all DROP PARTITION p2018;

-- 清空分区数据
ALTER TABLE message_all TRUNCATE PARTITION p2017;

-- 新增分区
ALTER TABLE message_all ADD PARTITION
    (
    PARTITION p2020 VALUES LESS THAN (2020),
    PARTITION p2021 VALUES LESS THAN (2021),
    PARTITION p2022 VALUES LESS THAN (2022)
    );

-- 重定义（可实现：分区拆分、合并、重命名）
ALTER TABLE message_all REORGANIZE PARTITION p201601,p201602,p201603,p201604 INTO
    (
    PARTITION p2016012 VALUES less than(TO_DAYS('2016-03-01')),
    PARTITION p2016034 VALUES less than(TO_DAYS('2016-05-01'))
    );

-- 修改分区规则
ALTER TABLE message_all PARTITION BY RANGE (to_days(createtime))
    (
    PARTITION p2015 VALUES LESS THAN (to_days('2016-01-01')),
    PARTITION p2016 VALUES LESS THAN (to_days('2017-01-01')),
    PARTITION p2017 VALUES LESS THAN (to_days('2018-01-01')),
    PARTITION p2018 VALUES LESS THAN MAXVALUE
    );
-- https://blog.csdn.net/pete_lee/article/details/59113885

-- 检查/查看你的分区
SHOW TABLE STATUS LIKE 'message_all';

SELECT * FROM information_schema.partitions WHERE table_name='message_all';

SHOW CREATE TABLE message_all;


-- 指定分区查
SELECT * FROM message_all PARTITION (p2020)


```


