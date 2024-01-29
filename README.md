# Kubernetes Site Project

I created this project as a self learning exercise, to improve my Terraform skills and to gain some more operating Kubernetes clusters within AWS.

This project features many different AWS services.

* EKS
* EFS
* Load Balancer
* S3
* Lambda
* VPCs
* IAM
* CloudWatch

This project is written in Terraform.

## Helm

This project uses Helm to keep Kubernetes resources tracked. The Helm Chart makes use of several services to integrate and connect other AWS services to the Kubernetes cluster:

* EFS CSI Driver
* Load Balancer Controller
* FluentBit

## Basic Setup

This project hosts a static website via EKS. Once the cluster is up and running, the user can use mkdocs to make changes to the underlying .md files. Once changes are made the user commits
changes to the repository and pushes to remote origin. Once pushed, Github Actions builds the website html and css files, and pushes them to the S3 bucket specified in the Terraform infra.

Once recieved, the S3 bucket uses a S3 notification to alert Lambda to move the files to EFS. Lambda moves the files EFS automatically whenever new files are added to S3 bucket, or any files are overwritten.

Once in EFS, the files become available to the EKS cluster via the EFS CSI Driver. The EFS CSI Driver mounts the EFS drive to the EKS cluster. In the Kubernetes manifest, there is a persistentvolume which contains the EFS mount.

The EFS Drive is then mounted at "/usr/share/nginx/html" within the nginx pods. The nginx pods will then display the site files.


Finally, we set up Fluentbit logging to run as a daemonset on each node in the cluster. Fluentbit also sets up a service account, configmap, clusterrole and clusterrole binding in order to have the correct permissions and ability to run correctly within the cluster.

Fluentbit then pushes error logs from the cluster to cloudwatch.

An ingress resource is set within the cluster to grab incoming traffic directed to docs.codykall.com, this traffic will be redirected a nginx service, which points the traffic to the nginx pods. The traffic is also encrypted via SSL.


