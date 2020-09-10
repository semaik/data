---
title: k8s重新生成Tocken并加入集群
date: 2020-09-10 14:23:09
categories: Kubernetes
tags:
    - Kubetnetes
---
#### 生成Token以及ca证书sha256hash值
```java
[root@node1 ~]# kubeadm token create --print-join-command 
W0710 09:11:07.688855   62169 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
kubeadm join 1.1.1.5:6443 --token 1cpem4.adim7zc1fqi4x1px     --discovery-token-ca-cert-hash sha256:9c4f217b0a12781be5c49262aa58738f873e7e0037719eeb0adeb7293bcdc1ca 
```
#### 如果之前怡景加入过集群需要关闭10250端口以及删除K8S目录
```java
[root@node3 ~]# rm -rf /etc/kubernetes/
[root@node2 ~]# netstat -anpt | grep 10250
tcp6       0      0 :::10250                :::*                    LISTEN      9992/kubelet        
[root@node2 ~]# kill -9 9992
```
#### node加入集群
复制生成的值
```java
kubeadm join 1.1.1.5:6443 --token 1cpem4.adim7zc1fqi4x1px     --discovery-token-ca-cert-hash sha256:9c4f217b0a12781be5c49262aa58738f873e7e0037719eeb0adeb7293bcdc1ca 
```










