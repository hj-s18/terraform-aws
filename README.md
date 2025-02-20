# Basic
```
[ec2-user@ip-10-0-1-172 hj]$ kubectl get nodes -o wide
NAME                                            STATUS   ROLES    AGE   VERSION               INTERNAL-IP   EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-10-0-3-117.ap-northeast-2.compute.internal   Ready    <none>   17h   v1.31.5-eks-5d632ec   10.0.3.117    <none>        Amazon Linux 2   5.10.233-224.894.amzn2.x86_64   containerd://1.7.25
ip-10-0-4-148.ap-northeast-2.compute.internal   Ready    <none>   17h   v1.31.5-eks-5d632ec   10.0.4.148    <none>        Amazon Linux 2   5.10.233-224.894.amzn2.x86_64   containerd://1.7.25

[ec2-user@ip-10-0-1-172 hj]$ kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   17h   <none>

[ec2-user@ip-10-0-1-172 hj]$ ls
deployment.yaml  nginx.yaml  svc-cip.yaml  svc-lb.yaml  svc-np.yaml
[ec2-user@ip-10-0-1-172 hj]$ kubectl apply -f deployment.yaml
deployment.apps/nginx created

[ec2-user@ip-10-0-1-172 hj]$ kubectl get deployment -o wide
NAME        READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS       IMAGES        SELECTOR
nginx       3/3     3            3           9s     nginxpod         nginx         app=nginxpod

[ec2-user@ip-10-0-1-172 hj]$ kubectl get deployment -o wide --show-labels
NAME        READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS       IMAGES       SELECTOR       LABELS
nginx       3/3     3            3           4m48s   nginxpod         nginx        app=nginxpod   <none>

[ec2-user@ip-10-0-1-172 hj]$ kubectl describe deployment nginx
Name:                   nginx
Namespace:              default
CreationTimestamp:      Thu, 20 Feb 2025 01:45:13 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginxpod
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginxpod
  Containers:
   nginxpod:
    Image:         nginx
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-7998648bbc (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  19m   deployment-controller  Scaled up replica set nginx-7998648bbc to 3

[ec2-user@ip-10-0-1-172 hj]$ kubectl get pods -o wide
NAME                         READY   STATUS    RESTARTS   AGE    IP           NODE                                            NOMINATED NODE   READINESS GATES
nginx-7998648bbc-glbmn       1/1     Running   0          17s    10.0.3.102   ip-10-0-3-117.ap-northeast-2.compute.internal   <none>           <none>
nginx-7998648bbc-xxrc9       1/1     Running   0          17s    10.0.3.36    ip-10-0-3-117.ap-northeast-2.compute.internal   <none>           <none>
nginx-7998648bbc-z2r2l       1/1     Running   0          17s    10.0.4.109   ip-10-0-4-148.ap-northeast-2.compute.internal   <none>           <none>

[ec2-user@ip-10-0-1-172 hj]$ kubectl get pods --show-labels
NAME                         READY   STATUS    RESTARTS   AGE     LABELS
flask-app-66f4b576f4-4zf5q   1/1     Running   0          5h28m   app=flask,pod-template-hash=66f4b576f4
flask-app-66f4b576f4-586rm   1/1     Running   0          5h28m   app=flask,pod-template-hash=66f4b576f4
nginx-7998648bbc-glbmn       1/1     Running   0          26m     app=nginxpod,pod-template-hash=7998648bbc
nginx-7998648bbc-xxrc9       1/1     Running   0          26m     app=nginxpod,pod-template-hash=7998648bbc
nginx-7998648bbc-z2r2l       1/1     Running   0          26m     app=nginxpod,pod-template-hash=7998648bbc

[ec2-user@ip-10-0-1-172 hj]$ kubectl describe pod nginx-7998648bbc-z2r2l
Name:             nginx-7998648bbc-z2r2l
Namespace:        default
Priority:         0
Service Account:  default
Node:             ip-10-0-4-148.ap-northeast-2.compute.internal/10.0.4.148
Start Time:       Thu, 20 Feb 2025 01:45:13 +0000
Labels:           app=nginxpod
                  pod-template-hash=7998648bbc
Annotations:      <none>
Status:           Running
IP:               10.0.4.109
IPs:
  IP:           10.0.4.109
Controlled By:  ReplicaSet/nginx-7998648bbc
Containers:
  nginxpod:
    Container ID:   containerd://96730e6a94864511ea06e536631ebb45d66f19d61274d210bd97bc3e44eb36e7
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:91734281c0ebfc6f1aea979cffeed5079cfe786228a71cc6f1f46a228cde6e34
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 20 Feb 2025 01:45:15 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-cb8zb (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-cb8zb:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  20m   default-scheduler  Successfully assigned default/nginx-7998648bbc-z2r2l to ip-10-0-4-148.ap-northeast-2.compute.internal
  Normal  Pulling    20m   kubelet            Pulling image "nginx"
  Normal  Pulled     20m   kubelet            Successfully pulled image "nginx" in 1.376s (1.376s including waiting). Image size: 72188133 bytes.
  Normal  Created    20m   kubelet            Created container nginxpod
  Normal  Started    20m   kubelet            Started container nginxpod

[ec2-user@ip-10-0-1-172 hj]$ kubectl run shell -it --rm --image centos:7 bash
If you don't see a command prompt, try pressing enter.

[root@shell /]# curl 10.0.3.36:80
<h1>Welcome to nginx!</h1>

[root@shell /]# exit
exit
Session ended, resume using 'kubectl attach shell -c shell -i -t' command when the pod is running
pod "shell" deleted
```

<br>
<br>
<br>

# ClusterIP

```
[ec2-user@ip-10-0-1-172 hj]$ kubectl apply -f svc-cip.yaml
service/svc-cip created

[ec2-user@ip-10-0-1-172 hj]$ kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE   SELECTOR
kubernetes   ClusterIP   172.20.0.1       <none>        443/TCP    17h   <none>
svc-cip      ClusterIP   172.20.154.241   <none>        5000/TCP   9s    app=nginxpod

[ec2-user@ip-10-0-1-172 hj]$ kubectl describe svc svc-cip
Name:                     svc-cip
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginxpod
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.154.241
IPs:                      172.20.154.241
Port:                     http  5000/TCP
TargetPort:               80/TCP
Endpoints:                10.0.3.102:80,10.0.3.36:80,10.0.4.109:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

[ec2-user@ip-10-0-1-172 hj]$ kubectl get ep
NAME         ENDPOINTS                                  AGE
kubernetes   10.0.3.191:443,10.0.4.145:443              18h
svc-cip      10.0.3.102:80,10.0.3.36:80,10.0.4.109:80   2m49s
svc-lb       10.0.3.102:80,10.0.3.36:80,10.0.4.109:80   24m

[ec2-user@ip-10-0-1-172 hj]$ kubectl run shell -it --rm --image centos:7 bash
If you don't see a command prompt, try pressing enter.

[root@shell /]# curl 172.20.154.241:5000
<h1>Welcome to nginx!</h1>

[root@shell /]# curl svc-cip:5000
<h1>Welcome to nginx!</h1>

[root@shell /]# exit
exit
Session ended, resume using 'kubectl attach shell -c shell -i -t' command when the pod is running
pod "shell" deleted

[ec2-user@ip-10-0-1-172 hj]$ kubectl delete svc svc-cip
service "svc-cip" deleted
```

<br>
<br>
<br>

# NodePort

```
[ec2-user@ip-10-0-1-172 hj]$ kubectl apply -f svc-np.yaml
service/svc-np created

[ec2-user@ip-10-0-1-172 hj]$ kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE   SELECTOR
kubernetes   ClusterIP   172.20.0.1       <none>        443/TCP          18h   <none>
svc-np       NodePort    172.20.115.175   <none>        5000:32570/TCP   10s   app=nginxpod

[ec2-user@ip-10-0-1-172 hj]$ kubectl describe svc svc-np
Name:                     svc-np
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginxpod
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.115.175
IPs:                      172.20.115.175
Port:                     http  5000/TCP
TargetPort:               80/TCP
NodePort:                 http  32570/TCP
Endpoints:                10.0.3.36:80,10.0.4.109:80,10.0.3.102:80
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:                   <none>

[ec2-user@ip-10-0-1-172 hj]$ kubectl get ep
NAME         ENDPOINTS                                  AGE
kubernetes   10.0.3.191:443,10.0.4.145:443              18h
svc-np       10.0.3.102:80,10.0.3.36:80,10.0.4.109:80   26s

[ec2-user@ip-10-0-1-172 hj]$ kubectl get nodes -o wide
NAME                                            STATUS   ROLES    AGE   VERSION               INTERNAL-IP   EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-10-0-3-117.ap-northeast-2.compute.internal   Ready    <none>   17h   v1.31.5-eks-5d632ec   10.0.3.117    <none>        Amazon Linux 2   5.10.233-224.894.amzn2.x86_64   containerd://1.7.25
ip-10-0-4-148.ap-northeast-2.compute.internal   Ready    <none>   17h   v1.31.5-eks-5d632ec   10.0.4.148    <none>        Amazon Linux 2   5.10.233-224.894.amzn2.x86_64   containerd://1.7.25

[ec2-user@ip-10-0-1-172 hj]$ curl 10.0.3.117:32570
^C

# tf-eks-node-group-sg 인바운드규칙에 Bastion 인스턴스에서 들어오는 모든 유형, 포트 추가

[ec2-user@ip-10-0-1-172 hj]$ curl 10.0.3.117:32570
<h1>Welcome to nginx!</h1>

[ec2-user@ip-10-0-1-172 hj]$ curl ip-10-0-3-117.ap-northeast-2.compute.internal:32570
<h1>Welcome to nginx!</h1>

[ec2-user@ip-10-0-1-172 hj]$ kubectl delete svc svc-np
service "svc-np" deleted
```

<br>
<br>
<br>

# LoadBalancer

```
[ec2-user@ip-10-0-1-172 hj]$ kubectl apply -f svc-lb.yaml
service/svc-lb created

[ec2-user@ip-10-0-1-172 hj]$ kubectl get svc -o wide
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP                              PORT(S)          AGE   SELECTOR
kubernetes   ClusterIP      172.20.0.1       <none>                                   443/TCP          18h   <none>
svc-lb       LoadBalancer   172.20.211.139   XXXX-<계정ID>.<리전>.elb.amazonaws.com   5000:31644/TCP   10s   app=nginxpod

[ec2-user@ip-10-0-1-172 hj]$ kubectl describe svc svc-lb
Name:                     svc-lb
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginxpod
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.211.139
IPs:                      172.20.211.139
LoadBalancer Ingress:     XXXX-<계정ID>.<리전>.elb.amazonaws.com
Port:                     http  5000/TCP
TargetPort:               80/TCP
NodePort:                 http  31644/TCP
Endpoints:                10.0.3.36:80,10.0.4.109:80,10.0.3.102:80
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  20s   service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   18s   service-controller  Ensured load balancer

[ec2-user@ip-10-0-1-172 hj]$ kubectl get ep
NAME         ENDPOINTS                                  AGE
kubernetes   10.0.3.191:443,10.0.4.145:443              18h
svc-lb       10.0.3.102:80,10.0.3.36:80,10.0.4.109:80   28s

[ec2-user@ip-10-0-1-172 hj]$ curl XXXX-<계정ID>.<리전>.elb.amazonaws.com:5000
<h1>Welcome to nginx!</h1>

# svc-lb 라는 이름으로는 클러스터 IP만 호출 가능함
[ec2-user@ip-10-0-1-172 hj]$ curl svc-lb:5000
curl: (6) Could not resolve host: svc-lb

[ec2-user@ip-10-0-1-172 hj]$ kubectl run shell -it --rm --image centos:7 bash
If you don't see a command prompt, try pressing enter.

[root@shell /]# curl svc-lb:5000
<h1>Welcome to nginx!</h1>

[root@shell /]# exit
exit
Session ended, resume using 'kubectl attach shell -c shell -i -t' command when the pod is running
pod "shell" deleted

# 로드밸런스 타입은 노드포트 타입도 포함함
[ec2-user@ip-10-0-1-172 hj]$ curl 10.0.3.117:31644
<h1>Welcome to nginx!</h1>
```

<br>
<br>
<br>
