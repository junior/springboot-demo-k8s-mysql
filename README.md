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

> Use mysql-pv-manual.yaml if deploying local

#### Create Service for MySQL

```shell
kubectl apply -f mysql-svc.yaml
```

#### Create Deployment for MySQL

```shell
kubectl apply -f mysql-dep.yaml
```

#### Optional: Insert Data

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

#### Optional: Test with port-forward

```shell
kubectl logs -l app=demoapp --follow
```
