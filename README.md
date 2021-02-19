# Springboot demo app

SpringBoot Demo with MySQL running on Kubernetes

## Build Demo App image

```shell
docker build --pull --no-cache --squash --rm --progress plain -f Dockerfile -t sbdemo .
```

## Deploy to Kubernetes

### Create namespace

```shell
kubectl create namespace demoapp
```

### Default namespace to demoapp

```shell
kubectl config set-context --current --namespace=demoapp
```

### Create MySQL Secrets

```shell
kubectl create secret generic mysql-secrets \
  --from-literal=rootpassword=r00tDefaultPassword1! \
  --from-literal=username=demo \
  --from-literal=password=defaultPassword1! \
  --from-literal=database=DB
```

### Deploy MySQL 5.7

#### Create PVC for MySQl on Oracle Cloud Infrastructure using CSI for Block Volume

```shell
kubectl apply -f mysql-pvc-oci-bv.yaml
```

> Use mysql-pvc-manual.yaml if deploying local

#### Create Service for MySQL

```shell
kubectl apply -f mysql-svc.yaml
```

#### Create Deployment for MySQL

```shell
kubectl apply -f mysql-dep.yaml
```

### Deploy the Spring Boot Demo App

#### Create Service for Demo App

```shell
kubectl apply -f app-svc.yaml
```

#### Create Deployment for Demo App

```shell
kubectl apply -f app-dep.yaml
```

#### Optional: Check logs

```shell
kubectl logs -l app=demoapp --follow
```

#### Optional: Insert Data to MySQL

##### Connect to mysql

```shell
kubectl run -it --rm --image=mysql:5.7 --restart=Never mysql-client -- mysql DB -h mysql -pr00tDefaultPassword1!
```

Press enter

```shell
If you don't see a command prompt, try pressing enter.

mysql>
```

```sql
insert into users (first_name, last_name) values ('joe', 'doe');
```

Expected results:

```shell
If you don't see a command prompt, try pressing enter.

mysql> insert into users (first_name, last_name) values ('joe', 'doe');
Query OK, 1 row affected (0.00 sec)

mysql> quit
Bye
pod "mysql-client" deleted
```

#### Optional: Test with port-forward

```shell
kubectl port-forward deploy/demoapp 8081:8081
```

Navigate to http://localhost:8081/users

#### Test with LoadBalancer IP Address

```shell
kubectl get svc
```

Navigate to http://<demoapp_EXTERNAL_IP_ADDRESS>/users

## Create Horizontal Pod Autoscaler for Demo App

### Install metrics server

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Create autoscale for Demo App

```shell
kubectl autoscale deployment demoapp --cpu-percent=30 --min=1 --max=10
```

### Check HPA

```shell
kubectl get hpa
```

### Increase load

```shell
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://demoapp/users; done"
```

Within a minute or so, we should see the higher CPU load by executing:

```shell
kubectl get hpa
```

## Prometheus and Grafana

### Install the grafana-prometheus stack

```shell
helm install prometheus prometheus-community/kube-prometheus-stack
```

### get the grafana admin password

```shell
kubectl get secret prometheus-grafana \
 -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
 ```

### Test Grafana with port-forward

 ```shell
kubectl port-forward svc/prometheus-grafana 8085:80
 ```

 Navigate to http://localhost:8085/
