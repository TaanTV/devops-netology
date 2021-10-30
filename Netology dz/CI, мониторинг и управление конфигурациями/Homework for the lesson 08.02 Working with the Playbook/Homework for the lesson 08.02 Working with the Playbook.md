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

см. скрин “final playbook.jpg”




