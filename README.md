# demo-k8-scikitlearn
Simple example to user kubernetes with scikitlearn

(Adapted from [Data Iku](https://blog.dataiku.com/how-to-perform-basic-ml-training-with-scikit-learn-docker-and-kubernetes))

## Create Python env

```
python3 -m venv k8test
source env/bin/activate
pip install scikit-learn
```

## Create `train.py` with `scikitlearn`

`vi train.py`

Contained within `train.py`:

```
from sklearn import svm
from sklearn import datasets
from joblib import dump, load

clf = svm.SVC()
X, y = datasets.load_iris(return_X_y=True)
clf.fit(X, y)
print ("Model finished training...Hooray")
dump(clf, 'svc_model.model')
```

## Create Dockerfile + Container
`vi Dockerfile`:

```
FROM jupyter/scipy-notebook

COPY train.py ./train.py
RUN python3 train.py
```

`docker build -t train-sklearn:0.1 .`

## Start Kubernetes (using `minikube` here)

`minikube start`

Check to see if running:
`kubectl get nodes`

## Login to Docker

`docker login`

Tag your image:
`docker tag train-sklearn:0.1 <my_repo>/train-sklearn:0.1`

Push it to Docker hub:
`docker push <my_repo>/train-sklearn:0.1`

## Create `train.yaml`

```
apiVersion: batch/v1
kind: Job
metadata:
  name: train-ml-k8s
spec:
  template:
    spec:
      containers:
      - name: train-ml-k8s
        imagePullPolicy: Always
        image: gcav66/train-sklearn:0.1
        command: ["python3",  "train.py"]
      restartPolicy: Never
  backoffLimit: 0
  ```
  
  `kubectl apply -f train.yaml`
  
  `kubectl get pods -A`
  
  
#Kill clusters that are having problems

For example,

`kubectl get pods -A` reveals:

```
NAMESPACE              NAME                                         READY   STATUS              RESTARTS       AGE
default                train-ml-k8s-1-n8js9                         0/1     ImagePullBackOff    0              16m
```

Then edit the `train.yaml` file and see if there are errors. Replace the old file with the new one:

`kubectl replace --force -f train.yaml`

Delete pods:

`kubectl delete pods <pod_namespace>`
