# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

git clone https://github.com/kubernetes-sigs/kubespray # клонируем себе репозиторий

sudo pip3 install -r requirements.txt # sudo pip3 install -r requirements.txt # Установка зависимостей

cp -rfp inventory/sample inventory/mycluster # Копирование примера в папку с вашей конфигурацией

### заполяем инвентори:

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.4%20Deploying%20a%20cluster%20on%20your%20own%20servers%2C%20lesson%202/inventory.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.4%20Deploying%20a%20cluster%20on%20your%20own%20servers%2C%20lesson%202/inventory.jpg)

ansible-playbook -i kubespray/inventory/mycluster/inventory.ini kubespray/cluster.yml --ask-pass -b --ask-become-pass # заускаем playbook

Вывод:

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.4%20Deploying%20a%20cluster%20on%20your%20own%20servers%2C%20lesson%202/playbook2.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.4%20Deploying%20a%20cluster%20on%20your%20own%20servers%2C%20lesson%202/playbook2.jpg)


![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.4%20Deploying%20a%20cluster%20on%20your%20own%20servers%2C%20lesson%202/kubectl%20et%20nodes.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.4%20Deploying%20a%20cluster%20on%20your%20own%20servers%2C%20lesson%202/kubectl%20et%20nodes.jpg)