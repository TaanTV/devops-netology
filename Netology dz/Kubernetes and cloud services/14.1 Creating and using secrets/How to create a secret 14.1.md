 Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать секрет?

```
openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
```

### Как просмотреть список секретов?

```
kubectl get secrets
kubectl get secret
```

### Как просмотреть секрет?

```
kubectl get secret domain-cert
kubectl describe secret domain-cert
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get secret domain-cert -o yaml
kubectl get secret domain-cert -o json
```

### Как выгрузить секрет и сохранить его в файл?

```
kubectl get secrets -o json > secrets.json
kubectl get secret domain-cert -o yaml > domain-cert.yml
```

### Как удалить секрет?

```
kubectl delete secret domain-cert
```

### Как загрузить секрет из файла?

```
kubectl apply -f domain-cert.yml
```


### Ответ:

Как создать секрет?

````
last@last-VirtualBox:~/14.1$ openssl genrsa -out cert.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
..........++++
...............................++++
e is 65537 (0x010001)
last@last-VirtualBox:~/14.1$ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
> -subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
last@last-VirtualBox:~/14.1$ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key
secret/domain-cert created

````
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/How%20to%20create%20a%20secret%2014.1%20Creating%20and%20using%20secrets%20.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/How%20to%20create%20a%20secret%2014.1%20Creating%20and%20using%20secrets%20.jpg)
Как просмотреть список секретов?
````
last@last-VirtualBox:~/14.1$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-pwmrq   kubernetes.io/service-account-token   3      15m
domain-cert           kubernetes.io/tls                     2      15s
````


````
last@last-VirtualBox:~/14.1$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-pwmrq   kubernetes.io/service-account-token   3      19m
domain-cert           kubernetes.io/tls                     2      4m18s

````
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/How%20to%20view%20the%20list%20of%20secrets%2014.1%20Creating%20and%20using%20secrets%20.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/How%20to%20view%20the%20list%20of%20secrets%2014.1%20Creating%20and%20using%20secrets%20.jpg)
Как просмотреть секрет?
````
ast@last-VirtualBox:~/14.1$ kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      27s

last@last-VirtualBox:~/14.1$ kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
````

Как получить информацию в формате YAML и/или JSON?

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/How%20to%20view%20the%20list%20of%20secrets%2014.1%20Creating%20and%20using%20secrets%20.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/How%20to%20view%20the%20list%20of%20secrets%2014.1%20Creating%20and%20using%20secrets%20.jpg)

в yaml
````
kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBD...UlRJRklDQVRFLS0tLS0K
    
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkF...VZLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2022-04-02T12:00:27Z"
  name: domain-cert
  namespace: default
  resourceVersion: "1089"
  uid: 773aa9b6-b8fc-4332-b766-fc23de9baa15
type: kubernetes.io/tls
````
в json
````
ubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "LS0tLS1CRUdJTiB...tRU5EIENFUlRJRklDQVRFLS0tLS0K",
        
        "tls.key": "LS0tLS1CRUdJT...EUgS0VZLS0tLS0K"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-04-02T12:00:27Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "1089",
        "uid": "773aa9b6-b8fc-4332-b766-fc23de9baa15"
    },
    "type": "kubernetes.io/tls"
}
````

Как выгрузить секрет и сохранить его в файл?

````
last@last-VirtualBox:~/14.1$ kubectl get secrets -o json > secrets.json
last@last-VirtualBox:~/14.1$ kubectl get secret domain-cert -o yaml > domain-cert.yml
````

проверяем как выгрузились
````
last@last-VirtualBox:~/14.1$ ls
cert.crt  cert.key  domain-cert.yml  secrets.json
````
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/%D0%9A%D0%B0%D0%BA%20%D0%B2%D1%8B%D0%B3%D1%80%D1%83%D0%B7%D0%B8%D1%82%D1%8C%20%D1%81%D0%B5%D0%BA%D1%80%D0%B5%D1%82%20%D0%B8%20%D1%81%D0%BE%D1%85%D1%80%D0%B0%D0%BD%D0%B8%D1%82%D1%8C%20%D0%B5%D0%B3%D0%BE%20%D0%B2%20%D1%84%D0%B0%D0%B9%D0%BB.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/%D0%9A%D0%B0%D0%BA%20%D0%B2%D1%8B%D0%B3%D1%80%D1%83%D0%B7%D0%B8%D1%82%D1%8C%20%D1%81%D0%B5%D0%BA%D1%80%D0%B5%D1%82%20%D0%B8%20%D1%81%D0%BE%D1%85%D1%80%D0%B0%D0%BD%D0%B8%D1%82%D1%8C%20%D0%B5%D0%B3%D0%BE%20%D0%B2%20%D1%84%D0%B0%D0%B9%D0%BB.jpg)
Как удалить секрет?
````
last@last-VirtualBox:~/14.1$ kubectl delete secret domain-cert
secret "domain-cert" deleted
````

Как загрузить секрет из файла?
````
last@last-VirtualBox:~/14.1$ kubectl apply -f domain-cert.yml
secret/domain-cert created
````
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/finally%20upload%20the%20secret%20to%20JSON.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20and%20cloud%20services/14.1%20Creating%20and%20using%20secrets/finally%20upload%20the%20secret%20to%20JSON.jpg)



