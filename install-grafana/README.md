# Deploy managed Grafana for openshift-monitoring

Run this as a cluster admin.

## Setup

```bash
export DEPLOY_NAMESPACE=my-grafana
```

## Create namespace

```bash
oc new-project $DEPLOY_NAMESPACE
```

### Optional - Apply network policies and quota to mimic the production environment

```bash
# helm upgrade -i --create-namespace admin helm/admin -n ${DEPLOY_NAMESPACE}
```

## Deploy operator

```bash
helm upgrade -i --create-namespace grafana-operator helm/operator -n ${DEPLOY_NAMESPACE}
```

## Manually approve the InstallPlan to install the grafana-operator

```bash
oc get installplans -n ${DEPLOY_NAMESPACE}
```

```bash
oc patch installplan <INSTALLPLAN> -n ${DEPLOY_NAMESPACE} --type merge -p '{"spec":{"approved":true}}'
```

### OR use this script:

```bash
./approve-installplan.sh
```

## Patch the CSV so that it is using a named registry in the image instead of defaulting to "grafana/grafana"

```bash
oc patch csv grafana-operator.v3.5.0 --type='json' \
-p='[{"op": "replace", "path": "/spec/install/spec/deployments/0/spec/template/spec/containers/0/args", "value":["--grafana-image=quay.io/app-sre/grafana","--grafana-image-tag=6.5.1"]}]' \
-n ${DEPLOY_NAMESPACE}
```

## Optional - update dashboards for your OCP version

This will update the json files within helm/grafana/dashboards/openshift-monitoring.

```bash
./export-openshift-monitoring-dashboards.sh
```

## Deploy grafana

```bash
helm upgrade -i --create-namespace grafana helm/grafana \
-n ${DEPLOY_NAMESPACE} \
--set grafana.datasources.prometheus.openshift_monitoring.password=$(oc extract secret/grafana-datasources -n openshift-monitoring --keys=prometheus.yaml --to=- | grep -zoP '"basicAuthPassword":\s*"\K[^\s,]*(?=\s*",)')
```
