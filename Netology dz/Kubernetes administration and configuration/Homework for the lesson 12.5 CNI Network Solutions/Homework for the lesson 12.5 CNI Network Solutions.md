# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 

* установка производится через ansible/kubespray;
  
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

## Ответ:


````
kubespraycloud@kubespraycloud-VirtualBox:~$ kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-x4ssl   1/1     Running   0          141m
````
# открываем порт
````
kubespraycloud@kubespraycloud-VirtualBox:~$ kubectl expose deployment hello-node --type=LoadBalancer --port=8080
````
# выводим сервисы
````
kubespraycloud@kubespraycloud-VirtualBox:~$ kubectl get services
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.96.198.84   <pending>     8080:32760/TCP   140m
kubernetes   ClusterIP      10.96.0.1      <none>        443/TCP          23h
````
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.5%20CNI%20Network%20Solutions/hello%20world.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.5%20CNI%20Network%20Solutions/hello%20world.jpg)

## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 

* установить утилиту calicoctl;
  
* получить 3 вышеописанных типа в консоли.


установка по гайду

https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart


````
master@node1:~$ kubectl get nodes -o wide
NAME    STATUS   ROLES                  AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
node1   Ready    control-plane,master   11m     v1.23.4   192.168.0.35   <none>        Ubuntu 20.04.3 LTS   5.4.0-96-generic   containerd://1.5.9
node2   Ready    <none>                 9m48s   v1.23.3   192.168.0.24   <none>        Ubuntu 20.04.3 LTS   5.4.0-96-generic   containerd://1.5.9
````
# вывести node
````
master@node1:~$ calicoctl get node
NAME    
node1   
node2   
````

# вывести ippool
````
master@node1:~$ calicoctl get ippool
NAME           CIDR             SELECTOR   
default-pool   10.233.64.0/18   all()      
````

# вывести profile
````
master@node1:~$ calicoctl get profile
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
kns.tigera-operator                                  
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-kube-controllers              
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       
ksa.tigera-operator.default                          
ksa.tigera-operator.tigera-operator                  
````

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.5%20CNI%20Network%20Solutions/calico.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.5%20CNI%20Network%20Solutions/calico.jpg)
![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.5%20CNI%20Network%20Solutions/calico%202.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/Kubernetes%20administration%20and%20configuration/Homework%20for%20the%20lesson%2012.5%20CNI%20Network%20Solutions/calico%202.jpg)
