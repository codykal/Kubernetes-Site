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

## EFS CSI Driver
This project also required that I create a install the EFS CSI driver into my helm chart. The EFS CSI Driver allows EFS to be mounted within an EKS Cluster. This involved
setting up several EFS Resources, including a several EFS Service accounts:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: aws-efs-csi-driver
  name: aws-efs-csi-driver
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::{{ .Values.account_id.id }}:role/AmazonEKS_EFS_CSI_DriverRole

---

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: aws-efs-csi-driver
  name: efs-csi-node-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::{{ .Values.account_id.id }}:role/AmazonEKS_EFS_CSI_DriverRole

```

## CI/CD

Next, I wanted to set up some CI/CD to automate makedocs pages, whenever there were changes made to the repository. I set this up using github actions:

```
name: Tests and Integration

on: [push]

jobs:
  Tests:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@master

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1

    - name: setup AWS CLI
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    
    - name: Terraform Initilialize
      run: terraform init

    - name: Terraform Validate
      run: terraform validate

    - name: Terraform Plan
      run: terraform plan

    #Helm Tests
    - name: Set up Helm
      uses: azure/setup-helm@v3
    
    - name: Helm Lint
      run: helm lint .
      working-directory: ./helm/k-site

```
I started by setting up some basic linting and formatting tests for CI, then worked on implementing CD:

```
  #Continuous Delivery
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@master

    - name: setup python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    
    - name: install mkdocs
      run: pip install mkdocs
    
    - name: mkdocs build
      run: mkdocs build
      working-directory: ./mkdocs/my-project

    - name: Upload to S3
      uses: jakejarvis/s3-sync-action@master
      with:
        args: --follow-symlinks --delete
      env:
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET}}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY}}
        AWS_REGION: 'us-west-2'
        SOURCE_DIR: ./mkdocs/my-project/site

```

This would run the makedocs commands to build the site and then push them to a specific AWS S3 bucket, which has a Lambda function attached to it. This Lambda function will run and upload the files from S3 to EFS. 

Once uploaded to EFS, the Kubernetes pods have the EFS drive mounted and set as their default page within Nginx, which will display the new page.


## Logging and Visibility

I wanted to allow logging and visibility into my EKS Cluster, so I setup a fluentbit daemonset on the cluster.

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: amazon-cloudwatch
  labels:
    k8s-app: fluent-bit
    version: v1
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    matchLabels:
      k8s-app: fluent-bit
  template:
    metadata:
      labels:
        k8s-app: fluent-bit
        version: v1
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - name: fluent-bit
        image: public.ecr.aws/aws-observability/aws-for-fluent-bit:stable
        imagePullPolicy: Always
        env:
            - name: AWS_REGION
              valueFrom:
                configMapKeyRef:
                  name: fluent-bit-cluster-info
                  key: logs.region
            - name: CLUSTER_NAME
              valueFrom:
                configMapKeyRef:
                  name: fluent-bit-cluster-info
                  key: cluster.name
            - name: HTTP_SERVER
              valueFrom:
                configMapKeyRef:
                  name: fluent-bit-cluster-info
                  key: http.server
            - name: HTTP_PORT
              valueFrom:
                configMapKeyRef:
                  name: fluent-bit-cluster-info
                  key: http.port
            - name: READ_FROM_HEAD
              valueFrom:
                configMapKeyRef:
                  name: fluent-bit-cluster-info
                  key: read.head
            - name: READ_FROM_TAIL
              valueFrom:
                configMapKeyRef:
                  name: fluent-bit-cluster-info
                  key: read.tail
            - name: HOST_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            - name: HOSTNAME
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.name
            - name: CI_VERSION
              value: "k8s/1.3.17"
        resources:
            limits:
              memory: 200Mi
            requests:
              cpu: 500m
              memory: 100Mi
        volumeMounts:
        # Please don't change below read-only permissions
        - name: fluentbitstate
          mountPath: /var/fluent-bit/state
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
        - name: runlogjournal
          mountPath: /run/log/journal
          readOnly: true
        - name: dmesg
          mountPath: /var/log/dmesg
          readOnly: true
      terminationGracePeriodSeconds: 10
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      volumes:
      - name: fluentbitstate
        hostPath:
          path: /var/fluent-bit/state
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
      - name: runlogjournal
        hostPath:
          path: /run/log/journal
      - name: dmesg
        hostPath:
          path: /var/log/dmesg
      serviceAccountName: fluent-bit
```

This daemonset installs the fluentbit pod, which will keep log files and send them to Cloudwatch.



