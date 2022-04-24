# создаем workspace stage

````
last@last-VirtualBox:~/yandex-cli$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
````

# создаем workspace prod
````
last@last-VirtualBox:~/yandex-cli$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
````
# переходит на workspace stage
````
last@last-VirtualBox:~/yandex-cli$ terraform workspace select stage
````
# workspace list
````
last@last-VirtualBox:~/yandex-cli$ terraform workspace list
  default
  prod
* stage
````



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


### Запускаем плейбук
````
ansible-playbook -i /kubespray/inventory/mycluster/inventory.ini cluster.yml -b -v -e ansible_user=ubuntu
````


### ini файлик такой inventory 
````
# ## different ip than the default iface
# ## We should set etcd_member_name for etcd cluster. The node that is not a etcd member do not need to set the value, or can set the empty string value.
[all]
node1 ansible_host=51.250.7.201 ansible_connection=ssh ansible_user=ubuntu
node2 ansible_host=51.250.1.128 ansible_connection=ssh ansible_user=ubuntu
#node3 ansible_host=192.168.0.9 ansible_connection=ssh ansible_user=worker2
#node4 ansible_host=192.168.0.10  ansible_connection=ssh ansible_user=worker3
# node5 ansible_host=95.54.0.16  # ip=10.3.0.5 etcd_member_name=etcd5
# node6 ansible_host=95.54.0.17  # ip=10.3.0.6 etcd_member_name=etcd6

# ## configure a bastion host if your nodes are not directly reachable
# [bastion]
# bastion ansible_host=31.163.237.177 ansible_user=some_user

[kube_control_plane]
node1
# node2
# node3

[etcd]
node1
# node2
# node3

[kube_node]
node2
#node3
#node4
# node5
# node6

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
````


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
  name      = "account"
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
    cores         = 2
    core_fraction = 20 # Guaranteed share of vCPU
    memory        = 2
  }

  # Interrupting machine ## прерываемая машина
  scheduling_policy {
    preemptible = (terraform.workspace == "[prod]") ? true : false
  }

  boot_disk {
    initialize_params {
      image_id = "fd8anitv6eua45627i0e"
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
    cores         = 2
    core_fraction = 20 # Guaranteed share of vCPU
    memory        = 2
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
````

# inventory

````
# ## Configure 'ip' variable to bind kubernetes services on a
# ## different ip than the default iface
# ## We should set etcd_member_name for etcd cluster. The node that is not a etcd member do not need to set the value, or can set the empty string value.
[all]
node1 ansible_host=51.250.7.201 ansible_connection=ssh ansible_user=ubuntu
node2 ansible_host=51.250.1.128 ansible_connection=ssh ansible_user=ubuntu
#node3 ansible_host=192.168.0.9 ansible_connection=ssh ansible_user=worker2
#node4 ansible_host=192.168.0.10  ansible_connection=ssh ansible_user=worker3
# node5 ansible_host=95.54.0.16  # ip=10.3.0.5 etcd_member_name=etcd5
# node6 ansible_host=95.54.0.17  # ip=10.3.0.6 etcd_member_name=etcd6

# ## configure a bastion host if your nodes are not directly reachable
# [bastion]
# bastion ansible_host=31.163.237.177 ansible_user=some_user

[kube_control_plane]
node1
# node2
# node3

[etcd]
node1
# node2
# node3

[kube_node]
node2
#node3
#node4
# node5
# node6

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
````