
#  deployment (IRSA 적용 전)

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
testcode-deployment   2/2     2            2           5s

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace --show-labels
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
testcode-deployment   2/2     2            2           20s   app=testcode

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace -o wide
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES                                                                       SELECTOR
testcode-deployment   2/2     2            2           14s   testcode-container   XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr:test   app=testcode
```

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe deployment -n testcode-namespace
Name:                   testcode-deployment
Namespace:              testcode-namespace
CreationTimestamp:      Thu, 20 Feb 2025 15:06:32 +0000
Labels:                 app=testcode
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=testcode
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=testcode
  Containers:
   testcode-container:
    Image:      XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr:test
    Port:       5000/TCP
    Host Port:  0/TCP
    Environment Variables from:
      mysql-config  ConfigMap  Optional: false
    Environment:
      MYSQL_USER:       <set to the key 'MYSQL_USER' in secret 'mysql-secret'>      Optional: false
      MYSQL_DATABASE:   <set to the key 'MYSQL_DATABASE' in secret 'mysql-secret'>  Optional: false
      AWS_SECRET_NAME:  rds!db-XXXX
      AWS_REGION:       ap-northeast-2
    Mounts:             <none>
  Volumes:              <none>
  Node-Selectors:       <none>
  Tolerations:          <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   testcode-deployment-759fd8b8c8 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  36s   deployment-controller  Scaled up replica set testcode-deployment-759fd8b8c8 to 2
```

<br>
<br>
<br>

# secret

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get secret -n testcode-namespace
NAME           TYPE     DATA   AGE
mysql-secret   Opaque   2      7m20s
```

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe secret -n testcode-namespace
Name:         mysql-secret
Namespace:    testcode-namespace
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
MYSQL_DATABASE:  4 bytes
MYSQL_USER:      5 bytes
```

<br>
<br>
<br>

# configmap

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get configmap -n testcode-namespace
NAME               DATA   AGE
kube-root-ca.crt   1      47m
mysql-config       2      8m1s
```

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe configmap mysql-config -n testcode-namespace
Name:         mysql-config
Namespace:    testcode-namespace
Labels:       <none>
Annotations:  <none>

Data
====
MYSQL_HOST:
----
rds.tf.private.com

MYSQL_PORT:
----
3306


BinaryData
====

Events:  <none>
```

<br>
<br>
<br>

# pod

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -n testcode-namespace
NAME                                   READY   STATUS    RESTARTS   AGE
testcode-deployment-759fd8b8c8-957jx   1/1     Running   0          4m33s
testcode-deployment-759fd8b8c8-g9ff2   1/1     Running   0          4m33s

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -n testcode-namespace --show-labels
NAME                                   READY   STATUS    RESTARTS   AGE    LABELS
testcode-deployment-759fd8b8c8-957jx   1/1     Running   0          5m5s   app=testcode,pod-template-hash=759fd8b8c8
testcode-deployment-759fd8b8c8-g9ff2   1/1     Running   0          5m5s   app=testcode,pod-template-hash=759fd8b8c8

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -o wide -n testcode-namespace
NAME                                   READY   STATUS    RESTARTS   AGE    IP           NODE                                            NOMINATED NODE   READINESS GATES
testcode-deployment-759fd8b8c8-957jx   1/1     Running   0          115s   10.0.4.109   ip-10-0-4-148.ap-northeast-2.compute.internal   <none>           <none>
testcode-deployment-759fd8b8c8-g9ff2   1/1     Running   0          115s   10.0.3.36    ip-10-0-3-117.ap-northeast-2.compute.internal   <none>           <none>
```

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe pod testcode-deployment-759fd8b8c8-957jx -n testcode-namespace
Name:             testcode-deployment-759fd8b8c8-957jx
Namespace:        testcode-namespace
Priority:         0
Service Account:  default
Node:             ip-10-0-4-148.ap-northeast-2.compute.internal/10.0.4.148
Start Time:       Thu, 20 Feb 2025 15:06:32 +0000
Labels:           app=testcode
                  pod-template-hash=759fd8b8c8
Annotations:      <none>
Status:           Running
IP:               10.0.4.109
IPs:
  IP:           10.0.4.109
Controlled By:  ReplicaSet/testcode-deployment-759fd8b8c8
Containers:
  testcode-container:
    Container ID:   containerd://4c2dfe91907dbbe44511fb59dcc614fd04c9d56dabb8b430000d7394e022bcff
    Image:          XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr:test
    Image ID:       XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr@sha256:XXXX
    Port:           5000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Thu, 20 Feb 2025 15:06:33 +0000
    Ready:          True
    Restart Count:  0
    Environment Variables from:
      mysql-config  ConfigMap  Optional: false
    Environment:
      MYSQL_USER:       <set to the key 'MYSQL_USER' in secret 'mysql-secret'>      Optional: false
      MYSQL_DATABASE:   <set to the key 'MYSQL_DATABASE' in secret 'mysql-secret'>  Optional: false
      AWS_SECRET_NAME:  rds!db-XXXX
      AWS_REGION:       ap-northeast-2
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vgwjl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-vgwjl:
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
  Normal  Scheduled  6m8s  default-scheduler  Successfully assigned testcode-namespace/testcode-deployment-759fd8b8c8-957jx to ip-10-0-4-148.ap-northeast-2.compute.internal
  Normal  Pulled     6m8s  kubelet            Container image "XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr:test" already present on machine
  Normal  Created    6m8s  kubelet            Created container testcode-container
  Normal  Started    6m7s  kubelet            Started container testcode-container
```

<br>
<br>
<br>

# Service : ClusterIP

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get svc -n testcode-namespace
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   15s

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get svc -n testcode-namespace -o wide
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE   SELECTOR
testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   19s   app=testcode

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get svc -n testcode-namespace --show-labels
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE   LABELS
testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   38s   <none>

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get ep -n testcode-namespace
NAME           ENDPOINTS                        AGE
testcode-svc   10.0.3.36:5000,10.0.4.109:5000   88s
```

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe svc testcode-svc -n testcode-namespace
Name:                     testcode-svc
Namespace:                testcode-namespace
Labels:                   <none>
Annotations:              <none>
Selector:                 app=testcode
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.244.125
IPs:                      172.20.244.125
Port:                     8080-5000  8080/TCP
TargetPort:               5000/TCP
Endpoints:                10.0.4.109:5000,10.0.3.36:5000
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
```

<br>
<br>
<br>

# deployment (IRSA 적용 후)

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
testcode-deployment   2/2     2            2           11s

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace --show-labels
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
testcode-deployment   2/2     2            2           41s   app=testcode

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace -o wide
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES                                                                       SELECTOR
testcode-deployment   2/2     2            2           26s   testcode-container   XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr:test   app=testcode
```

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe deployment -n testcode-namespace
Name:                   testcode-deployment
Namespace:              testcode-namespace
CreationTimestamp:      Thu, 20 Feb 2025 15:58:20 +0000
Labels:                 app=testcode
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=testcode
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=testcode
  Service Account:  secrets-access-sa
  Containers:
   testcode-container:
    Image:      XXXX.dkr.ecr.ap-northeast-2.amazonaws.com/test-ecr-namespace/test-ecr:test
    Port:       5000/TCP
    Host Port:  0/TCP
    Environment Variables from:
      mysql-config  ConfigMap  Optional: false
    Environment:
      MYSQL_USER:       <set to the key 'MYSQL_USER' in secret 'mysql-secret'>      Optional: false
      MYSQL_DATABASE:   <set to the key 'MYSQL_DATABASE' in secret 'mysql-secret'>  Optional: false
      AWS_SECRET_NAME:  rds!db-XXXX
      AWS_REGION:       ap-northeast-2
    Mounts:             <none>
  Volumes:              <none>
  Node-Selectors:       <none>
  Tolerations:          <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   testcode-deployment-6cc546794 (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  2m37s  deployment-controller  Scaled up replica set testcode-deployment-6cc546794 to 2
```

<br>
<br>
<br>

# serviceaccount

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get serviceaccount -n testcode-namespace
NAME                SECRETS   AGE
default             0         115m
secrets-access-sa   0         62s

[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe serviceaccount -n testcode-namespace
Name:                default
Namespace:           testcode-namespace
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>


Name:                secrets-access-sa
Namespace:           testcode-namespace
Labels:              app.kubernetes.io/managed-by=eksctl
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::XXXX:role/eksctl-tf-eks-cluster-addon-iamserviceaccount-Role1-t2HFV9MKIA5e
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```

<br>
<br>
<br>

# namespace

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get namespace
NAME                 STATUS   AGE
default              Active   32h
kube-node-lease      Active   32h
kube-public          Active   32h
kube-system          Active   32h
testcode-namespace   Active   150m

[ec2-user@ip-10-0-1-172 testcode]$ kubectl describe namespace testcode-namespace
Name:         testcode-namespace
Labels:       kubernetes.io/metadata.name=testcode-namespace
Annotations:  <none>
Status:       Active

No resource quota.

No LimitRange resource.
```

<br>
<br>
<br>

# kubectl get all -n testcode-namespace

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get all -n testcode-namespace
NAME                                      READY   STATUS    RESTARTS   AGE
pod/testcode-deployment-6cc546794-96cmg   1/1     Running   0          26m
pod/testcode-deployment-6cc546794-9kmks   1/1     Running   0          26m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   60m

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/testcode-deployment   2/2     2            2           26m

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/testcode-deployment-6cc546794   2         2         2       26m
```

<br>
<br>
<br>
