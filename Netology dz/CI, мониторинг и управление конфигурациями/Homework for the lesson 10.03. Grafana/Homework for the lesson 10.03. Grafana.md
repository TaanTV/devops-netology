ставим prometheus по этим гайдам: 

https://github.com/Einsteinish/Docker-Compose-Prometheus-and-Grafana офф 

https://blog.unixhost.pro/2021/02/ustanovka-prometheus-grafana/ не офф


для себя скрин поднятых контейнеров
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.03.%20Grafana/%D1%81%D1%82%D0%B0%D0%B2%D0%B8%D0%BC%20%D0%B2%20%D1%80%D1%83%D1%87%D0%BD%D1%83%D1%8E.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.03.%20Grafana/%D1%81%D1%82%D0%B0%D0%B2%D0%B8%D0%BC%20%D0%B2%20%D1%80%D1%83%D1%87%D0%BD%D1%83%D1%8E.jpg)

# Домашнее задание к занятию "10.03. Grafana"

## Задание повышенной сложности

**В части задания 1** не используйте директорию [help](./help) для сборки проекта, самостоятельно разверните grafana, где в 
роли источника данных будет выступать prometheus, а сборщиком данных node-exporter:
- grafana
- prometheus-server
- prometheus node-exporter

За дополнительными материалами, вы можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию приведите также все конфигурации/скрипты/манифесты, которые вы 
использовали в процессе решения задания.

**В части задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например Telegram или Email
и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

## Обязательные задания

### Задание 1
Используя директорию [help](./help) внутри данного домашнего задания - запустите связку prometheus-grafana.

Зайдите в веб-интерфейс графана, используя авторизационные данные, указанные в манифесте docker-compose.

Подключите поднятый вами prometheus как источник данных.

Решение домашнего задания - скриншот веб-интерфейса grafana со списком подключенных Datasource.

## Задание 2
Изучите самостоятельно ресурсы:
- [https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.03.%20Grafana/%D1%81%D1%82%D0%B0%D0%B2%D0%B8%D0%BC%20%D0%B2%20%D1%80%D1%83%D1%87%D0%BD%D1%83%D1%8E.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.03.%20Grafana/%D1%81%D1%82%D0%B0%D0%B2%D0%B8%D0%BC%20%D0%B2%20%D1%80%D1%83%D1%87%D0%BD%D1%83%D1%8E.jpg)
- [understanding prometheus cpu metrics](https://www.robustperception.io/understanding-machine-cpu-usage)

Создайте Dashboard и в ней создайте следующие Panels:
- Утилизация CPU для nodeexporter (в процентах, 100-idle)
- CPULA 1/5/15
- Количество свободной оперативной памяти
- Количество места на файловой системе

Для решения данного ДЗ приведите promql запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

## Ответ:

### 1) Утилизация CPU для nodeexporter (в процентах, 100-idle)
avg(rate(node_cpu_seconds_total {mode = "idle"}[15s])) * 100

 [пример](http://example.com/ "Необязательная подсказка")

### 2) CPULA 1/5/15



100 - avg(irate(node_cpu_seconds_total{mode="idle"}[1m])) without (cpu) * 100 # сколько времени мой процессор отдыхает

100 - avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) without (cpu) * 100 #

100 - avg(irate(node_cpu_seconds_total{mode="idle"}[15m])) without (cpu) * 100 #

sum (irate(node_cpu_seconds_total[5m])) without (mode) # средняя загрузка процессора

[пример](http://example.com/ "Необязательная подсказка")
### 3) Количество свободной оперативной памяти

node_memory_MemFree_bytes / node_memory_MemTotal_bytes * 100

 [пример](http://example.com/ "Необязательная подсказка")
### 4) Количество места на файловой системе

node_filesystem_avail_bytes / node_filesystem_size_bytes * 100  # свободное место в процентах

100 - node_filesystem_avail_bytes{fstype!='tmpfs'} / node_filesystem_size_bytes * 100 # занятое место в процентах

 [пример](http://example.com/ "Необязательная подсказка")



## Задание 3
Создайте для каждой Dashboard подходящее правило alert (можно обратиться к первой лекции в блоке "Мониторинг").

Для решения ДЗ - приведите скриншот вашей итоговой Dashboard.

 [пример](http://example.com/ "Необязательная подсказка")

## Задание 4
Сохраните ваш Dashboard.

Для этого перейдите в настройки Dashboard, выберите в боковом меню "JSON MODEL".

Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.

В решении задания - приведите листинг этого файла.

