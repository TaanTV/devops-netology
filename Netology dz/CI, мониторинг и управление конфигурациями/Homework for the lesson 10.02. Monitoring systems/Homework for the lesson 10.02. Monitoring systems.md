### 1. Опишите основные плюсы и минусы pull и push систем мониторинга.

Ответ:
### pull - это когда центральный сервер мониторинга ходит к агентам и через какой-то заданный инженером период выгружает данные.

+ Нам легче контролировать подлинность данных потому что мы можем опрашивать допустим с разных машин у нас, мы можем опрашивать разные агенты. Условно с 1 машины мы опрашиваем первые 4 агента на хостах и еще 2 там на хостах. Т.е. мы контролируем откуда и где мы забираем данные.

+ Так же мы можем настроить систему TLS, если нам нужно чтобы все было по паролям , по доступам, т.е. мы можем все это в PULL модели настроить.

+ Упрощенная отладка получения данных с агентов  

 у того же самого Prometheus агенты отдают httml страничку определенного формата. Соответственно мы простым Curl можем протестировать работает ли наш агент. Все ли он нам данные отдает.

### push -модель подразумевает отправку данных с агентов (рабочих машин, с которых собираем мониторинг) в систему мониторинга,  

+ возможность испольование протокола UDP

протокол UDP менее затратный протокол передачи данных, соответственно мы можем эти метрики гораздо быстрее собирать и гораздо быстрее  обрабатывать и у нас получается производительность и наблюдаемость системы гораздо выше- но это не всегда надежно. 

+ Упрощение репликации данных в разные системы мониторинга  
или их резервные копии (мы можем отпралять данные на разные машины)
  
+ Более гибкая настройка отправки пакетов данных с метриками  
(на каждом клиенте задается объем данных и частоту отправки) 



### 2. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

Prometheus push/pull

TICK push

Zabbix  push/pull

VictoriaMetrics

Nagios

### 3. Склонируйте себе репозиторий и запустите TICK-стэк, используя технологии docker и docker-compose.

В виде решения на это упражнение приведите выводы команд с вашего компьютера (виртуальной машины):

- curl http://localhost:8086/ping
- curl http://localhost:8888
- curl http://localhost:9092/kapacitor/v1/ping
А также скриншот веб-интерфейса ПО chronograf (http://localhost:8888).

````
dmitry@dmitry-VirtualBox:~/TICK$ docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                                                                                                                             NAMES
d0e89cc53a6a   chrono_config        "/entrypoint.sh chro…"   18 minutes ago   Up 18 minutes   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                                                                         tick_chronograf_1
f772986c8c87   kapacitor            "/entrypoint.sh kapa…"   18 minutes ago   Up 18 minutes   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp                                                                                         tick_kapacitor_1
98c3a2ec6796   telegraf             "/entrypoint.sh tele…"   18 minutes ago   Up 18 minutes   8092/udp, 8125/udp, 8094/tcp                                                                                                      tick_telegraf_1
657c16ac4b36   tick_documentation   "/documentation/docu…"   18 minutes ago   Up 18 minutes   0.0.0.0:3010->3000/tcp, :::3010->3000/tcp                                                                                         tick_documentation_1
6655ddb35787   influxdb             "/entrypoint.sh infl…"   18 minutes ago   Up 18 minutes   0.0.0.0:8082->8082/tcp, :::8082->8082/tcp, 0.0.0.0:8086->8086/tcp, :::8086->8086/tcp, 0.0.0.0:8089->8089/udp, :::8089->8089/udp   tick_influxdb_1
dmitry@dmitry-VirtualBox:~/TICK$ ls
chronograf  docker-compose.yml  documentation  images  influxdb  kapacitor  LICENSE  README.md  sandbox  sandbox.bat  telegraf
dmitry@dmitry-VirtualBox:~/TICK$ curl -v http://localhost:8086/ping
*   Trying 127.0.0.1:8086...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /ping HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 204 No Content
< Content-Type: application/json
< Request-Id: 234b8800-1d07-11ec-8166-0242ac120002
< X-Influxdb-Build: OSS
< X-Influxdb-Version: 1.8.9
< X-Request-Id: 234b8800-1d07-11ec-8166-0242ac120002
< Date: Fri, 24 Sep 2021 07:15:03 GMT
< 
* Connection #0 to host localhost left intact
dmitry@dmitry-VirtualBox:~/TICK$ curl -v http://localhost:8888
*   Trying 127.0.0.1:8888...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8888 (#0)
> GET / HTTP/1.1
> Host: localhost:8888
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Accept-Ranges: bytes
< Cache-Control: public, max-age=3600
< Content-Length: 336
< Content-Security-Policy: script-src 'self'; object-src 'self'
< Content-Type: text/html; charset=utf-8
< Etag: "33628162924"
< Last-Modified: Mon, 28 Jun 2021 16:29:24 GMT
< Vary: Accept-Encoding
< X-Chronograf-Version: 1.9.0
< X-Content-Type-Options: nosniff
< X-Frame-Options: SAMEORIGIN
< X-Xss-Protection: 1; mode=block
< Date: Fri, 24 Sep 2021 07:21:45 GMT
< 
* Connection #0 to host localhost left intact
<!DOCTYPE html><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title><link rel="icon shortcut" href="/favicon.fa749080.ico"><link rel="stylesheet" href="/src.d80ed715.css"></head><body> <div id="react-root" data-basepath=""></div> <script src="/src.c278d833.js"></script> </body></html>dmitry@dmitry-VirtualBox:~/TICK$ 
dmitry@dmitry-VirtualBox:~/TICK$ curl -v http://localhost:9092/kapacitor/v1/ping
*   Trying 127.0.0.1:9092...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9092 (#0)
> GET /kapacitor/v1/ping HTTP/1.1
> Host: localhost:9092
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 204 No Content
< Content-Type: application/json; charset=utf-8
< Request-Id: 1c8a0c4c-1d08-11ec-81da-000000000000
< X-Kapacitor-Version: 1.6.1
< Date: Fri, 24 Sep 2021 07:22:01 GMT
< 
* Connection #0 to host localhost left intact

````

### 4. Перейдите в веб-интерфейс Chronograf (http://localhost:8888) и откройте вкладку Data explorer.

Нажмите на кнопку Add a query

Изучите вывод интерфейса и выберите БД telegraf.autogen

В measurments выберите mem->host->telegraf_container_id , а в fields выберите used_percent. Внизу появится график утилизации оперативной памяти в контейнере telegraf.

Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.

Для выполнения задания приведите скриншот с отображением метрик утилизации места на диске (disk->host->telegraf_container_id) из веб-интерфейса.

Ответ:



