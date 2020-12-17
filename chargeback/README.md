# charge-back demo


Install the chargeback demo into the namespace "chargeback-demo"

## Assign variables
```bash
export DEPLOY_NAMESPACE=chargeback-demo
export PROM_LABEL=team
```

## Create project
```bash
oc new-project ${DEPLOY_NAMESPACE}
```

## Label on the namespace so that prometheus will read in the PrometheusRule resource
```bash
oc label namespace ${DEPLOY_NAMESPACE} openshift.io/cluster-monitoring='true'
```

## Create the PrometheusRule in the namespace

```bash
envsubst < ./chargeback-rules.yaml | oc apply -f - -n ${DEPLOY_NAMESPACE}
```

The label on projects (namespaces) is cluster dependent -- they need to be specific for your needs.  For this example, we will add some labels to namespaces as approriate.  Replacing <NAMESPACE-PROJECT#> with your namespaces.

```bash
oc label namespace <NAMESPACE-PROJECT1> team=team1
oc label namespace <NAMESPACE-PROJECT2> team=team1
oc label namespace <NAMESPACE-PROJECT3> team=team2
oc label namespace <NAMESPACE-PROJECT4> team=team2
```

Finally, Create the dashboard in a namespace that is watched by the grafana operator.

```bash
export GRAFANA_OPERATOR=<NAMESPACE-BEING-WATCHED-BY-GRAFANA-OPERATOR>
oc apply -f dashboard.yaml -n ${GRAFANA_OPERATOR}
```
