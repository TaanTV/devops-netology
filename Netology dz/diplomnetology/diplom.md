# смотрим наш конфиг лист
````
last@last-VirtualBox:~/yandex-cli$ yc config list
````

# экспортируем наш токен
````
last@last-VirtualBox:~/yandex-cli$ export YC_TOKEN=77XXXXXXXX
````

*===================================================*

# Создание облачной инфраструктуры

### создаем workspace stage

````
last@last-VirtualBox:~/yandex-cli$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
````

### создаем workspace prod
````
last@last-VirtualBox:~/yandex-cli$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
````
### переходит на workspace stage
````
last@last-VirtualBox:~/yandex-cli$ terraform workspace select stage
````
### workspace list
````
last@last-VirtualBox:~/yandex-cli$ terraform workspace list
  default
  prod
* stage
````

### [main](https://github.com/TaanTV/devops-netology/blob/main/Netology%20dz/diplomnetology/main.tf)
main 
````
terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

locals {
  folder_id = "b1gaegtiiea77v9culb9"
  cloud_id  = "b1gsfpkg218ub8pa1o4q"
}


provider "yandex" {
  cloud_id  = "local.cloud_id"
  folder_id = local.folder_id
  zone      = "ru-central1-a"
}

##---------------------------------------------------------
# VPC # https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network

resource "yandex_vpc_network" "network" {
  name = "netology"

}

#---------------------------------------------------------
# subnet public-subnet # https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  description    = "NAT instance"
  network_id     = yandex_vpc_network.network.id
}

# --------------------------------------------------------
# create NAT public

resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public-subnet.id
    nat        = true
    ip_address = "192.168.10.254"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


#---------------------------------------------------------
# subnet private-subnet # https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet

resource "yandex_vpc_subnet" "private-subnet" { # private-subnet ***
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id # * nat-private
}

#---------------------------------------------------------
# Bucket object storage # https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket

// Создание сервис аккаунта # Create SA
resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "netology-account"
}

#-----------------------------------------------
#  S3 bucket  https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket

// Назначение роли ## Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = local.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

//  Создание статического ключа доступа ## Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создание Bucket ## Use keys to create bucket
resource "yandex_storage_bucket" "my-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "taan"
  acl        = "private" # default value, just in case we specify
}

#-----------------------------------------------
#  Bastion

/*

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20 # Guaranteed share of vCPU
    memory        = 2
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "stage") ? true : false
  }


  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

*/

#-----------------------------------------------
#  master node

resource "yandex_compute_instance" "master-node" {
  name        = "master-node"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores = 4
    #  core_fraction = 20 # Guaranteed share of vCPU
    memory = 4
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "[prod]") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true # no bastion
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#-----------------------------------------------
#  master node 1

resource "yandex_compute_instance" "master-node-1" {
  name        = "master-node-1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores = 4
    #  core_fraction = 20 # Guaranteed share of vCPU
    memory = 4
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "[prod]") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true # no bastion
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#-----------------------------------------------
#  master node

resource "yandex_compute_instance" "master-node-2" {
  name        = "master-node-2"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores = 4
    #  core_fraction = 20 # Guaranteed share of vCPU
    memory = 4
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "[prod]") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true # no bastion
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#-----------------------------------------------
#  worker node

resource "yandex_compute_instance" "worker-node" {
  name        = "worker-node"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores = 4
    #  core_fraction = 20 # Guaranteed share of vCPU
    memory = 4

  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "prod") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true # no bastion
    #  nat       = false ## bastion
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#-----------------------------------------------
#  worker node 1

resource "yandex_compute_instance" "worker-node-1" {
  name        = "worker-node-1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores = 4
    #    core_fraction = 20 # Guaranteed share of vCPU
    memory = 4
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "prod") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true # no bastion
    #  nat       = false ## bastion
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
/*
#-----------------------------------------------
#  worker node 2

resource "yandex_compute_instance" "worker-node-2" {
  name        = "worker-node-2"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores = 4
    #  core_fraction = 20 # Guaranteed share of vCPU
    memory = 4
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "prod") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true # no bastion
    #  nat       = false ## bastion
  }

  metadata = {
    user-data = file("./bootstrap.sh")
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
*/
````
*===================================================*
# Создание Kubernetes кластера

### git clone kubespray
````
last@last-VirtualBox:~/yandex-cli$ git clone https://github.com/kubernetes-sigs/kubespray.git
````

### переходим в папку kubespray
````
last@last-VirtualBox:~/yandex-cli$ cd kubespray/
````

### смотрим файлики ls
````
last@last-VirtualBox:~/yandex-cli/kubespray$ ls
ansible.cfg          _config.yml      extra_playbooks    library   OWNERS_ALIASES             requirements-2.10.txt  requirements.txt  SECURITY_CONTACTS  upgrade-cluster.yml
ansible_version.yml  contrib          facts.yml          LICENSE   README.md                  requirements-2.11.txt  reset.yml         setup.cfg          Vagrantfile
cluster.yml          CONTRIBUTING.md  index.html         logo      recover-control-plane.yml  requirements-2.12.txt  roles             setup.py
CNAME                Dockerfile       inventory          Makefile  RELEASE.md                 requirements-2.9.txt   scale.yml         test-infra
code-of-conduct.md   docs             legacy_groups.yml  OWNERS    remove-node.yml            requirements-2.9.yml   scripts           tests
````
### устанавливаем зависимости pip3 
````
last@last-VirtualBox:~/yandex-cli/kubespray$ sudo pip3 install -r requirements.txt
````
### Копирование примера в папку с вашей конфигурацией
````
cp -rfp inventory/sample inventory/mycluster # Копирование примера в папку с вашей конфигурацией
````


### наш inventory kubespray 

````
 ## Configure 'ip' variable to bind kubernetes services on a
# ## different ip than the default iface
# ## We should set etcd_member_name for etcd cluster. The node that is not a etcd member do not need to set the value, or can set the empty string value.
[all]
node1 ansible_host=51.250.65.198 ansible_connection=ssh ansible_user=ubuntu
node2 ansible_host=51.250.69.77 ansible_connection=ssh ansible_user=ubuntu
node3 ansible_host=51.250.70.80 ansible_connection=ssh ansible_user=ubuntu
node4 ansible_host=51.250.87.135 ansible_connection=ssh ansible_user=ubuntu
node5 ansible_host=51.250.78.99 ansible_connection=ssh ansible_user=ubuntu
# node6 ansible_host=95.54.0.17  # ip=10.3.0.6 etcd_member_name=etcd6

# ## configure a bastion host if your nodes are not directly reachable
# [bastion]
# bastion ansible_host=31.163.237.177 ansible_user=some_user

[kube_control_plane]
node1
node2
node3

[etcd]
node1
node2
node3

[kube_node]
# node2
# node3
node4
node5
# node6

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
````

### разливаем наш плейбук kubespray
````
ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b -v -e ansible_user=ubuntu
````

*===================================================*
# Создание тестового приложения

### Gitlab пайплайн 

````
image: docker:20.10.5
services:
  - docker:20.10.5-dind
stages:
  - build
  - deploy

before_script:
  - echo $CI_REGISTRY_USER
  - echo $CI_COMMIT_REF_NAME
  - docker login --username dmitrykraska --password $DOCKER_PASSWORD
  
build:
  stage: build
  script:
    - docker login --username dmitrykraska --password $DOCKER_PASSWORD    
    - docker build -t dmitrykraska/diplomnetology:latest .
    - docker push dmitrykraska/diplomnetology:latest  
# except:
  only:
    - main
build&deploy:
  stage: deploy
  script:
    - docker login --username dmitrykraska --password $DOCKER_PASSWORD
    - docker build -t dmitrykraska/diplomnetology:$CI_COMMIT_REF_NAME .
    - docker push dmitrykraska/diplomnetology:$CI_COMMIT_REF_NAME
  only:
    - tags
````

### app-deployment.yml

````
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  labels:
    app: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: dmitrykraska/diplomnetology:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          name: http
````

### app-service.yml

````
apiVersion: v1
kind: Service
metadata:
  labels:
    app: my-app
  name: nginx-my
  namespace: default
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: http
    nodePort: 32000
  selector:
    app: my-app
````

*===================================================*
# Подготовка kubernetes к работе

### залетаем на наш мастер по ssh
````
last@last-VirtualBox:~$ ssh ubuntu@51.250.65.198
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Mon Jun 13 09:20:37 2022 from 94.51.222.183
````
### закидываем .kube конфиг  [гайд](https://itisgood.ru/2020/08/11/oshibka-kubernetes-the-connection-to-the-server-localhost-8080-was-refused/)

````
ubuntu@node1:~$ mkdir -p $HOME/.kube
````

````
ubuntu@node1:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
cp: overwrite '/home/ubuntu/.kube/config'? yes
````

````
ubuntu@node1:~$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
````

*===================================================*
# Подготовка системы мониторинга для нашего приложения

### качаем helm
````
ubuntu@node1:~$ wget https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
--2022-06-13 09:33:23--  https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
Resolving get.helm.sh (get.helm.sh)... 152.199.21.175, 2606:2800:233:1cb7:261b:1f9c:2074:3c
Connecting to get.helm.sh (get.helm.sh)|152.199.21.175|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 13626774 (13M) [application/x-tar]
Saving to: ‘helm-v3.8.0-linux-amd64.tar.gz’

helm-v3.8.0-linux-amd64.tar.gz                     100%[===============================================================================================================>]  13.00M  58.5MB/s    in 0.2s    

2022-06-13 09:33:24 (58.5 MB/s) - ‘helm-v3.8.0-linux-amd64.tar.gz’ saved [13626774/13626774]
````
### ставим helm

````
ubuntu@node1:~$ tar -zxvf helm-v3.8.0-linux-amd64.tar.gz
linux-amd64/
linux-amd64/helm
linux-amd64/LICENSE
linux-amd64/README.md
````

````
ubuntu@node1:~$ sudo mv linux-amd64/helm /usr/local/bin/helm
````
### чтобы ошибки не вылетала нужно было изменить права :
### sudo chown $(id -u):$(id -g) $HOME/.kube/config
````
ubuntu@node1:~$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ubuntu/.kube/config
"prometheus-community" has been added to your repositories
````

### ставим стабильный прометеус, теста ради в --namespace default
````
ubuntu@node1:~$ helm install --namespace default stable prometheus-community/kube-prometheus-stack
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ubuntu/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ubuntu/.kube/config
NAME: stable
LAST DEPLOYED: Mon Jun 13 09:35:02 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=stable"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
````

### редактируем файлик svc stable-grafana
````
ubuntu@node1:~$ kubectl edit svc stable-grafana
service/stable-grafana edited
````

### должен выглядеть вот так (selector заменяем по гайду см. шаги [гайд](https://itsecforu.ru/2021/04/12/%E2%98%B8%EF%B8%8F-%D0%BA%D0%B0%D0%BA-%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C-prometheus-%D0%B8-grafana-%D0%BD%D0%B0-kubernetes-%D1%81-%D0%BF%D0%BE%D0%BC%D0%BE%D1%89%D1%8C%D1%8E-h/))

````
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: stable
    meta.helm.sh/release-namespace: default
  creationTimestamp: "2022-06-13T10:14:52Z"
  labels:
    app.kubernetes.io/instance: stable
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: grafana
    app.kubernetes.io/version: 8.5.3
    helm.sh/chart: grafana-6.29.6
  name: stable-grafana
  namespace: default
  resourceVersion: "14630"
  uid: f7e72a81-aaf0-4834-a702-408a61acbe40
spec:
  allocateLoadBalancerNodePorts: true
  clusterIP: 10.233.37.243
  clusterIPs:
  - 10.233.37.243
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: http-web
    nodePort: 30993
    port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app.kubernetes.io/instance: stable
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: LoadBalancer
status:
  loadBalancer: {}
````

### ищем наш LoadBalancer 

````
ubuntu@node1:~$ kubectl get service
NAME                                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP      None            <none>        9093/TCP,9094/TCP,9094/UDP   6m7s
kubernetes                                ClusterIP      10.233.0.1      <none>        443/TCP                      86m
nginx-my                                  NodePort       10.233.58.177   <none>        80:32000/TCP                 50m
prometheus-operated                       ClusterIP      None            <none>        9090/TCP                     6m7s
stable-grafana                            LoadBalancer   10.233.37.243   <pending>     80:30993/TCP                 6m17s
stable-kube-prometheus-sta-alertmanager   ClusterIP      10.233.0.69     <none>        9093/TCP                     6m17s
stable-kube-prometheus-sta-operator       ClusterIP      10.233.21.163   <none>        443/TCP                      6m17s
stable-kube-prometheus-sta-prometheus     ClusterIP      10.233.5.209    <none>        9090/TCP                     6m17s
stable-kube-state-metrics                 ClusterIP      10.233.48.88    <none>        8080/TCP                     6m17s
stable-prometheus-node-exporter           ClusterIP      10.233.9.90     <none>        9100/TCP                     6m17s
````
### залетаем в браузере на него LoadBalancer 
````
stable-grafana                            LoadBalancer   10.233.37.243
````
### удивляемся что тут доступ не admin/admin, а
````
UserName: admin
Password: prom-operator
````

### создаем dashboard с метриками берем для теста
````
100 - node_filesystem_avail_bytes{fstype!='tmpfs'} / node_filesystem_size_bytes * 100 # занятое место в процентах
````

````
node_memory_MemFree_bytes / node_memory_MemTotal_bytes * 100 #  Количество свободной оперативной памяти
````

````
100 - avg(irate(node_cpu_seconds_total{mode="idle"}[1m])) without (cpu) * 100 # сколько времени мой процессор отдыхает
````

*===================================================*
#Установка и настройка CI/CD

### запускаем наше приложение и сервис (см. выше или [https://gitlab.com/devopstaan/diplomnetology](https://gitlab.com/devopstaan/diplomnetology))
````
ubuntu@node1:~$ kubectl apply -f app-deployment.yml 
deployment.apps/my-deployment created
ubuntu@node1:~$ kubectl apply -f app-service.yml 
service/nginx-my created
````


### curl -i http://51.250.65.198:32000
````
ubuntu@node1:~$ curl -i http://51.250.65.198:32000/
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Mon, 13 Jun 2022 10:28:17 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Expires: Mon, 13 Jun 2022 10:28:16 GMT
Cache-Control: no-cache
````


### смотрим все сервисы 
````
ubuntu@node1:~$ kubectl get all

NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-stable-kube-prometheus-sta-alertmanager-0   2/2     Running   0          14m
pod/my-deployment-67b5b69967-8fhxt                           1/1     Running   0          58m
pod/my-deployment-67b5b69967-thlsr                           1/1     Running   0          58m
pod/prometheus-stable-kube-prometheus-sta-prometheus-0       2/2     Running   0          14m
pod/stable-grafana-599dff57ff-tqqr5                          3/3     Running   0          14m
pod/stable-kube-prometheus-sta-operator-7fc6f9f59d-r9v2d     1/1     Running   0          14m
pod/stable-kube-state-metrics-76c4564574-b5vrj               1/1     Running   0          14m
pod/stable-prometheus-node-exporter-6tblp                    1/1     Running   0          14m
pod/stable-prometheus-node-exporter-8vtqx                    1/1     Running   0          14m
pod/stable-prometheus-node-exporter-ctnpw                    1/1     Running   0          14m
pod/stable-prometheus-node-exporter-f6p92                    1/1     Running   0          14m
pod/stable-prometheus-node-exporter-q8vr9                    1/1     Running   0          14m

NAME                                              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                     ClusterIP      None            <none>        9093/TCP,9094/TCP,9094/UDP   14m
service/kubernetes                                ClusterIP      10.233.0.1      <none>        443/TCP                      95m
service/nginx-my                                  NodePort       10.233.58.177   <none>        80:32000/TCP                 58m
service/prometheus-operated                       ClusterIP      None            <none>        9090/TCP                     14m
service/stable-grafana                            LoadBalancer   10.233.37.243   <pending>     80:30993/TCP                 14m
service/stable-kube-prometheus-sta-alertmanager   ClusterIP      10.233.0.69     <none>        9093/TCP                     14m
service/stable-kube-prometheus-sta-operator       ClusterIP      10.233.21.163   <none>        443/TCP                      14m
service/stable-kube-prometheus-sta-prometheus     ClusterIP      10.233.5.209    <none>        9090/TCP                     14m
service/stable-kube-state-metrics                 ClusterIP      10.233.48.88    <none>        8080/TCP                     14m
service/stable-prometheus-node-exporter           ClusterIP      10.233.9.90     <none>        9100/TCP                     14m

NAME                                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/stable-prometheus-node-exporter   5         5         5       5            5           <none>          14m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-deployment                         2/2     2            2           58m
deployment.apps/stable-grafana                        1/1     1            1           14m
deployment.apps/stable-kube-prometheus-sta-operator   1/1     1            1           14m
deployment.apps/stable-kube-state-metrics             1/1     1            1           14m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/my-deployment-67b5b69967                         2         2         2       58m
replicaset.apps/stable-grafana-599dff57ff                        1         1         1       14m
replicaset.apps/stable-kube-prometheus-sta-operator-7fc6f9f59d   1         1         1       14m
replicaset.apps/stable-kube-state-metrics-76c4564574             1         1         1       14m

NAME                                                                    READY   AGE
statefulset.apps/alertmanager-stable-kube-prometheus-sta-alertmanager   1/1     14m
statefulset.apps/prometheus-stable-kube-prometheus-sta-prometheus       1/1     14m
````

Ответ:

### Доступ к образу

[доступ к образу nginx](http://51.250.65.198:32000/)

### рабочее приложение
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/nginx%20up.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/nginx%20up.jpg)


### gitlab repo
[https://gitlab.com/devopstaan/diplomnetology/-/tree/main](https://gitlab.com/devopstaan/diplomnetology/-/tree/main)

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/gitlab%20pipelines.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/gitlab%20pipelines.jpg)
### dockerhub образ нашего nginx

[https://hub.docker.com/repository/docker/dmitrykraska/diplomnetology](https://hub.docker.com/repository/docker/dmitrykraska/diplomnetology)
### YC
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/yandex%20cloud%20all.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/yandex%20cloud%20all.jpg)

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/yandex%20cloud%20VM.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/yandex%20cloud%20VM.jpg)

### Dashboard grafana
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/dashboard.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/diplomnetology/dashboard.jpg)

[gitlab репо](https://gitlab.com/devopstaan/diplomnetology)


*==================*
# Ссылки чтобы вспомнить как решал проблемы:

### вспомогательные ссылки по закидыванию config в папку /.kubeconfig (треб. для работы kubectl после разлива кластера через kubespray)

[https://itisgood.ru/2020/08/11/oshibka-kubernetes-the-connection-to-the-server-localhost-8080-was-refused/](https://itisgood.ru/2020/08/11/oshibka-kubernetes-the-connection-to-the-server-localhost-8080-was-refused/)

### установка Prometheus через helm

[https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
