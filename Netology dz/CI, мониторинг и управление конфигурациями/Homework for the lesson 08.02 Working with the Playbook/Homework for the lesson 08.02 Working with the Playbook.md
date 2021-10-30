# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook. 
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

## Необязательная часть

1. Приготовьте дополнительный хост для установки logstash.
2. Пропишите данный хост в `prod.yml` в новую группу `logstash`.
3. Дополните playbook ещё одним play, который будет исполнять установку logstash только на выделенный для него хост.
4. Все переменные для нового play определите в отдельный файл `group_vars/logstash/vars.yml`.
5. Logstash конфиг должен конфигурироваться в части ссылки на elasticsearch (можно взять, например его IP из facts или определить через vars).
6. Дополните README.md, протестируйте playbook, выложите новую версию в github. В ответ предоставьте ссылку на репозиторий.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

## Начинаем выполнять:


ssh-keygen # генерим на хосте ssh , 3 enter

заходим в папку .ssh 

vim id_rsa.pub # копируем через vi ключ публичный и вставляем в файл на нужно агенте в папку 

vi authorized_keys  # вставили

ssh ansible@192.168.0.7 # проверяем заходит ли в ssh где ansible пользователь@IP_adress


Дальше пишем inventory файл

````
---
elasticsearch:
  hosts:
    ubuntu:
      ansible_connection: ssh
      ansible_user: ansible
      ansible_host: 192.168.0.7
kibana:
  hosts:
    ubuntu:
      ansible_connection: ssh
      ansible_user: ansible
      ansible_host: 192.168.0.7
````





````
---
- name: Install Java
  hosts: all
  tasks:
    - name: Set facts for Java 11 vars
      set_fact:
        java_home: "/opt/jdk/{{ java_jdk_version }}"
      tags: java
    - name: Upload .tar.gz file containing binaries from local storage
      copy:
        src: "{{ java_oracle_jdk_package }}"
        dest: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
      register: download_java_binaries
      until: download_java_binaries is succeeded
      tags: java
    - name: Ensure installation dir exists
      become: true
      file:
        state: directory
        path: "{{ java_home }}"
      tags: java
    - name: Extract java in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
        dest: "{{ java_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ java_home }}/bin/java"
      tags:
        - java
    - name: Export environment variables
      become: true
      template:
        src: jdk.sh.j2
        dest: /etc/profile.d/jdk.sh
      tags: java
- name: Install Elasticsearch
  hosts: elasticsearch
  become: true
  tasks:
    - name: Upload tar.gz Elasticsearch from remote URL
      get_url:
        url: "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        mode: 0755
        timeout: 60
        force: true
        validate_certs: false
      register: get_elastic
      until: get_elastic is succeeded
      tags: elastic
    - name: Create directrory for Elasticsearch
      file:
        state: directory
        path: "{{ elastic_home }}"
      tags: elastic
    - name: Extract Elasticsearch in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        dest: "{{ elastic_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ elastic_home }}/bin/elasticsearch"
      tags:
        - elastic
    - name: Set environment Elastic
      become: true
      template:
        src: templates/elk.sh.j2
        dest: /etc/profile.d/elk.sh
      tags: elastic
- name: Install Kibana
  hosts: kibana
  become: true
  tasks:
    - name: Upload .tar.gz file containing binaries from local storage
      copy:
        src: "{{ kibana_package }}"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
#        register: download_kibana_binaries
#        until: download_kibana_binaries is succeeded
      tags: kibana
    - name: Ensure installation dir exists
      become: true
      file:
        state: directory
        path: "{{ kibana_home }}"
      tags: kibana
    - name: Extract kibana in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ kibana_home }}/bin/kibana"
      tags:
        - skip_ansible_lint
        - kibana
    - name: Export environment variables
      become: true
      template:
        src: kibana.sh.j2
        dest: /etc/profile.d/kibana.sh
      tags: kibana
    - name: Recursively take ownership of a directory
      become: yes      
      file:
        path: "{{ kibana_home }}"
        state: directory
        recurse: yes
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
````

далее закидываем в папку files java

после заходим в папку group_vars создаем папку kibana

создаем файл vars.yml




kibana_version: "7.15.1"

kibana_home: "/opt/kibana/{{ kibana_version }}"

kibana_package: "kibana-7.15.1-linux-x86_64.tar.gz"

см. скрин “kibana.jpg”

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2008.02%20Working%20with%20the%20Playbook/kibana.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2008.02%20Working%20with%20the%20Playbook/kibana.jpg)

Далее заходим в папку файл и скачиваем tar.gz

dmitry@dmitry-VirtualBox:~/08-ansible-02-playbook/playbook/files$ curl –O https://artifacts.elastic.co/downloads/kibana/kibana-7.15.1-linux-x86_64.tar.gz #Одна строчка
далее заходим в плейбук site.yml

дописываем плейбук kibana чтобы он брал из папки files 
kibana 7.15.1 как указано в groups_vars
````
- name: Install Kibana
  hosts: kibana
  become: true
  tasks:
    - name: Upload .tar.gz file containing binaries from local storage
      copy:
        src: "{{ kibana_package }}"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
#        register: download_kibana_binaries
#        until: download_kibana_binaries is succeeded
      tags: kibana
    - name: Ensure installation dir exists
      become: true
      file:
        state: directory
        path: "{{ kibana_home }}"
      tags: kibana
    - name: Extract kibana in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ kibana_home }}/bin/kibana"
      tags:
        - skip_ansible_lint
        - kibana
    - name: Export environment variables
      become: true
      template:
        src: kibana.sh.j2
        dest: /etc/profile.d/kibana.sh
      tags: kibana
    - name: Recursively take ownership of a directory
      become: yes      
      file:
        path: "{{ kibana_home }}"
        state: directory
        recurse: yes
````

см. скрин “kibana playbook.jpg”

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2008.02%20Working%20with%20the%20Playbook/kibana%20playbook.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2008.02%20Working%20with%20the%20Playbook/kibana%20playbook.jpg)

````
---
- name: Install Java
  hosts: all
  tasks:
    - name: Set facts for Java 11 vars
      set_fact:
        java_home: "/opt/jdk/{{ java_jdk_version }}"
      tags: java
    - name: Upload .tar.gz file containing binaries from local storage
      copy:
        src: "{{ java_oracle_jdk_package }}"
        dest: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
      register: download_java_binaries
      until: download_java_binaries is succeeded
      tags: java
    - name: Ensure installation dir exists
      become: true
      file:
        state: directory
        path: "{{ java_home }}"
      tags: java
    - name: Extract java in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
        dest: "{{ java_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ java_home }}/bin/java"
      tags:
        - java
    - name: Export environment variables
      become: true
      template:
        src: jdk.sh.j2
        dest: /etc/profile.d/jdk.sh
      tags: java
- name: Install Elasticsearch
  hosts: elasticsearch
  become: true
  tasks:
    - name: Upload tar.gz Elasticsearch from remote URL
      get_url:
        url: "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        mode: 0755
        timeout: 60
        force: true
        validate_certs: false
      register: get_elastic
      until: get_elastic is succeeded
      tags: elastic
    - name: Create directrory for Elasticsearch
      file:
        state: directory
        path: "{{ elastic_home }}"
      tags: elastic
    - name: Extract Elasticsearch in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        dest: "{{ elastic_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ elastic_home }}/bin/elasticsearch"
      tags:
        - elastic
    - name: Set environment Elastic
      become: true
      template:
        src: templates/elk.sh.j2
        dest: /etc/profile.d/elk.sh
      tags: elastic
- name: Install Kibana
  hosts: kibana
  become: true
  tasks:
    - name: Upload .tar.gz file containing binaries from local storage
      copy:
        src: "{{ kibana_package }}"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
#        register: download_kibana_binaries
#        until: download_kibana_binaries is succeeded
      tags: kibana
    - name: Ensure installation dir exists
      become: true
      file:
        state: directory
        path: "{{ kibana_home }}"
      tags: kibana
    - name: Extract kibana in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ kibana_home }}/bin/kibana"
      tags:
        - skip_ansible_lint
        - kibana
    - name: Export environment variables
      become: true
      template:
        src: kibana.sh.j2
        dest: /etc/profile.d/kibana.sh
      tags: kibana
    - name: Recursively take ownership of a directory
      become: yes      
      file:
        path: "{{ kibana_home }}"
        state: directory
        recurse: yes
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
````

заходим в teamplates и создаем файл kibana.sh.j2
dmitry@dmitry-VirtualBox:~/08-ansible-02-playbook/playbook/templates$ touch kibana.sh.j2

добавляем переменную PATH
````
# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
#!/usr/bin/env bash

export KIBANA_HOME={{ kibana_home }}
export PATH=$PATH:$KIBANA_HOME/bin
````

Запускаем плейбук
dmitry@dmitry-VirtualBox:~/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml

## Ответ !!!
см. скрин “final playbook.jpg”

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2008.02%20Working%20with%20the%20Playbook/final%20playbook.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2008.02%20Working%20with%20the%20Playbook/final%20playbook.jpg)



