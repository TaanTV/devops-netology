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




