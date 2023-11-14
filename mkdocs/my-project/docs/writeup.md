# Project Writeup

## Starting Off


For this project, I wanted to do something that deepened my understanding of Kubernetes, and integrated AWS.

I started by creating a project Diagram of how I wanted to map things out:

![Diagram](./image/Kubernetes-Site.drawio.png)

## AWS Load Balancer Controller Plugin


Next, I worked on getting all the required dependencies into EKS that would allow me to connect to other AWS services. I started by connecting
AWS Load Balancer Controller. This required reading AWS docs, and setting up a few yaml files in Helm such as the load balancer controller service account:


```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::{{ .Values.account_id.id }}:role/AmazonEKSLoadBalancerControllerRole
```
