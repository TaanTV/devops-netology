# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

### Ответ:

dmitry@dmitry-VirtualBox:~$ kubectl get po # смотрим сколько у нас подов

dmitry@dmitry-VirtualBox:~$ kubectl get deployment # посмотреть сколько deployment

dmitry@dmitry-VirtualBox:~$ kubectl scale --replicas=2 deployment/hello-node
#   kubectl scale сделай мне 2 реплики --replicas=2 deployment/hello-node


dmitry@dmitry-VirtualBox:~$ kubectl get deployment

````
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           3d20h
````

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20get%20deployment%2012.2%20%D0%9A%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D1%8B%20%D0%B4%D0%BB%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%8B%20%D1%81%20Kubernetes.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20get%20deployment%2012.2%20%D0%9A%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D1%8B%20%D0%B4%D0%BB%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%8B%20%D1%81%20Kubernetes.jpg)



## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)


### Ответ:

dmitry@dmitry-VirtualBox:~$ kubectl create serviceaccount netology-user # создать пользователя

Вывод: ##serviceaccount/netology-user created

kubectl create rolebinding log-viewer --clusterrole=view --serviceaccount=default:netology-user --namespace=default
# создаем роль


dmitry@dmitry-VirtualBox:~$ kubectl get serviceaccounts/netology-user -o yaml
вывести в Yaml формате  полный дамп объекта служебной учетной записи serviceaccounts/netology-user

````
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-01-28T10:29:22Z"
  name: netology-user
  namespace: default
  resourceVersion: "998"
  uid: cb7be10a-53b1-4442-a271-3906fedde41c
secrets:
- name: netology-user-token-sxsgd
````

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20get%20serviceaccounts%20netology-user%20-o%20yaml.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20get%20serviceaccounts%20netology-user%20-o%20yaml.jpg)

dmitry@dmitry-VirtualBox:~$ kubectl describe secret/netology-user-token-sxsgd #посмотреть токен
````
Name:         netology-user-token-sxsgd
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: netology-user
              kubernetes.io/service-account.uid: cb7be10a-53b1-4442-a271-3906fedde41c

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IkJlMEhSQVNNR0VZcV9uTmhqS2R6RVYzSnJNNUQwcURNZl91R1hyOC1rU0kifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im5ldG9sb2d5LXVzZXItdG9rZW4tc3hzZ2QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibmV0b2xvZ3ktdXNlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImNiN2JlMTBhLTUzYjEtNDQ0Mi1hMjcxLTM5MDZmZWRkZTQxYyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0Om5ldG9sb2d5LXVzZXIifQ.S8bxB56h1VGw5t3gcncI50XTdt5N0bFRsOOouxgKa-UclLWGqRULxmJbep8nTnJ74PNnX_wQFchjKu0qlqJtKh4r4_OIU5puic6RM7TFtOvvPvWKei4o0wWh64WqTJF_stnN3WL_8Rd2ti53PRtEdXlk2wU4yt_46bbyGnZnPFJSbzq3Giev4Khxxw3ZgVOoi2vcxLD8ksDmpldYIM_Mzm9qFBbEkQ-YOtyCoCc887_rpC4VAf2VtBBtL40PzkTwPMy7lEs8A4Dqn83smchDfwrG0ItwQ5EisvrxUkEnJe9Oi8SBmjN5JoPWx6v0FzsAJDivMC1xZQc09q5YB8abNg
ca.crt:     1111 bytes
namespace:  7 bytes
````
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20describe%20secret%20netology-user-token-sxsgd.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20describe%20secret%20netology-user-token-sxsgd.jpg)

kubectl config set-credentials netology-user --token eyJhbGciOiJSUzI … # Добавляем пользователя с токеном в конфиг set-credentials  (вставляем токен с secret/netology-user/token-sxsgd.jpg)

dmitry@dmitry-VirtualBox:~$ kubectl config set-context minikube --user netology-user # настраиваем set-context на работу с новым пользователем.

dmitry@dmitry-VirtualBox:~$ kubectl config use-context minikube # перешли на контекст netology-user
Switched to context "minikube". 

dmitry@dmitry-VirtualBox:~$ kubectl config use-context minikube # перешли на контекст netology-user
Switched to context "minikube". 
````
dmitry@dmitry-VirtualBox:~$ kubectl get po 
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-d42b2   1/1     Running   0          33m
hello-node-6b89d599b9-kgx75   1/1     Running   0          28m
````

# проверяем все ли на месте и где бы напакостить

dmitry@dmitry-VirtualBox:~$ kubectl delete pods/hello-node-6b89d599b9-d42b2 #пытаемся удалить свой под 
Error from server (Forbidden): pods "hello-node-6b89d599b9-d42b2" is forbidden: User "system:serviceaccount:default:netology-user" cannot delete resource "pods" in API group "" in the namespace "default"
## Перевод:
Ошибка сервера (запрещено): модули "hello-node-6b89d599b9-d42b2" запрещены: пользователь "system:serviceaccount:default:netology-user" не может удалить ресурсы "pods" в группе API "" в пространстве имен "default"

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20delete%20pod.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/kubectl%20delete%20pod.jpg)


dmitry@dmitry-VirtualBox:~$ kubectl config set-context minikube --user minikube # возвращаемся на  set-context minikube  --user minikube

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/back%20minikube.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.2%20Commands%20for%20working%20with%20Kubernetes/back%20minikube.jpg)



### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---



## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

---

dmitry@dmitry-VirtualBox:~$ kubectl scale --replicas=5 deployment/hello-node # увеличить количество реплик до 5, как в 1 задании.
deployment.apps/hello-node scaled
dmitry@dmitry-VirtualBox:~$ kubectl get po
````
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-7wfns   1/1     Running   0          13s
hello-node-6b89d599b9-d42b2   1/1     Running   0          55m
hello-node-6b89d599b9-jkm4f   1/1     Running   0          13s
hello-node-6b89d599b9-kgx75   1/1     Running   0          51m
hello-node-6b89d599b9-sxkkz   1/1     Running   0          13s
````