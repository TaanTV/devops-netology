## Задание 1

Найдите команду для выдачи статуса БД и приведите в ответе из ее вывода версию сервера БД.

см. скрин "Версия бд.jpg"
```
Server version:		8.0.25 MySQL Community Server - GPL
```

Приведите в ответе количество записей с price > 300.

````
select * from orders WHERE price > 300;
SELECT COUNT(*) FROM orders WHERE price > 300;
````



## Задание 2


Создайте пользователя test в БД c паролем test-pass, используя:
````
REATE USER 'test'@'%' IDENTIFIED BY 'test-pass'
ATTRIBUTE '{"Family": "Pretty", "name": "James"}';
ALTER USER 'test'@'%' PASSWORD EXPIRE INTERVAL 180 DAY 
FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2;

ALTER USER 'test'@'%'
WITH
	MAX_QUERIES_PER_HOUR 100;

GRANT Alter ON test_db.* TO 'test'@'%';
````
  

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю test и приведите в ответе к задаче.

см. скрин "INFORMATION_SCHEMA.USER_ATTRIBUTES Домашнее задание к занятию 6.3. MySQL.jpg"

````
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES
WHERE USER = 'test' AND HOST = '%'
````

## Задача 3

Установите профилирование SET profiling = 1. Изучите вывод профилирования команд SHOW PROFILES;.

Исследуйте, какой engine используется в таблице БД test_db и приведите в ответе.

````
SET profiling = 1
SHOW PROFILES;
````

см. скрин "profiling_Домашнее_задание_к_занятию_6_3_MySQL.jpg"

````
show engines;
````
см. скрин "show_engines_default_Домашнее_задание_к_занятию_6_3_MySQL.jpg"

Измените engine и приведите время выполнения и запрос на изменения из профайлера в ответе:

на MyISAM

см. скрин "смена_движка_на_MYISAM_Домашнее_задание_к_занятию_6_3_MySQL.jpg"

````
ALTER TABLE orders ENGINE = MYISAM;
````

на InnoDB

см. "скрин смена_движка_на_InnoDB_Домашнее_задание_к_занятию_6_3_MySQL.jgp"
````
ALTER TABLE orders ENGINE = InnoDB;
````

## Задача 4

innodb_flush_log_at_trx_commit = 0                          # IO speed is more important than data safety

innodb_file_per_table = 1                                   # the data is stored in different files with the .ibd extension

innodb_log_buffer_size = 1M                                 # The size of the buffer into which transactions are placed in an uncommitted state

innodb_buffer_pool_size = 3G                                # The size of the buffer for caching data and indexes

innodb_log_file_size = 100M                                 # Operation log file size

````
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL



innodb_flush_log_at_trx_commit = 0                          # IO speed is more important than data safety

innodb_file_per_table = 1                                   # the data is stored in different files with the .ibd extension

innodb_log_buffer_size = 1M                                 # The size of the buffer into which transactions are placed in an uncommitted state

innodb_buffer_pool_size = 3G                                # The size of the buffer for caching data and indexes

innodb_log_file_size = 100M                                 # Operation log file size



# Custom config should go here
!includedir /etc/mysql/conf.d/
````