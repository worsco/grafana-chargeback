# Deploy managed Grafana for openshift-monitoring

Run this as a cluster admin.

## Setup

```bash
export DEPLOY-NAMESPACE=my-grafana
```

## Create namespace

```bash
oc new-project $DEPLOY-NAMESPACE
```

Optional - add network policies and quota to mimic production env 

```bash
helm upgrade -i --create-namespace admin helm/admin -n ${DEPLOY-NAMESPACE}
```

## Deploy operator

```bash
helm upgrade -i --create-namespace grafana-operator helm/operator -n ${DEPLOY-NAMESPACE}
```

## Manually approve the InstallPlan to install the grafana-operator

```bash
oc get installplans -n ${DEPLOY-NAMESPACE}
```

```bash
oc patch installplan <INSTALLPLAN> -n ${DEPLOY-NAMESPACE} --type merge -p '{"spec":{"approved":true}}'
```

## Patch the CSV so that it is using a named registry in the image instead of defaulting to "grafana/grafana"

```bash
oc patch csv grafana-operator.v3.5.0 --type='json' \
-p='[{"op": "replace", "path": "/spec/install/spec/deployments/0/spec/template/spec/containers/0/args", "value":["--grafana-image=quay.io/app-sre/grafana","--grafana-image-tag=6.5.1"]}]' \
-n ${DEPLOY-NAMESPACE}
```

## Optional - update dashboards for your OCP version

This will update the json files within helm/grafana/dashboards/openshift-monitoring.

```bash
./export-openshift-monitoring-dashboards.sh
```

## Deploy grafana

```bash
helm upgrade -i --create-namespace grafana helm/grafana \
-n ${DEPLOY-NAMESPACE} \
--set grafana.datasources.prometheus.openshift_monitoring.password=$(oc extract secret/grafana-datasources -n openshift-monitoring --keys=prometheus.yaml --to=- | grep -zoP '"basicAuthPassword":\s*"\K[^\s,]*(?=\s*",)')
```
