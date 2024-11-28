#k8s 升级

#https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

#找到对应节点，
kubectl get nodes 

ssh 进入

#升级节点apt 源

sudo apt update
sudo apt-cache madison kubeadm

sudo apt-get update && sudo apt-get install -y kubeadm='1.30.x-*'


#停止调度，驱逐pod
kubectl cordon <node-to-uncordon>
kubectl drain <node-to-drain> --ignore-daemonsets 

#升级组件.
sudo kubeadm upgrade plan

sudo kubeadm upgrade apply v1.30.x --igress-upgrade-etcd

# 升级 kubelet 和 kubectl
sudo apt-get update && sudo apt-get install -y kubelet='1.30.x-*' kubectl='1.30.x-*'

sudo systemctl daemon-reload
sudo systemctl restart kubelet

#恢复调度
kubectl uncordon <node-to-uncordon>