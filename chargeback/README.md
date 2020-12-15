# charge-back demo


Install the chargeback demo into the namespace "chargeback-demo"

## Assign variables
```bash
export MYPROJECT=chargeback-demo
export PROM_LABEL=team
```

## Create project
```bash
oc new-project ${MYPROJECT}
```

## Label on the namespace so that prometheus will read in the PrometheusRule resource
```bash
oc label namespace ${MYPROJECT} openshift.io/cluster-monitoring='true'
```

## Create the PrometheusRule in the namespace

```bash
envsubst < ./chargeback-rules.yaml | oc apply -f - -n ${MYPROJECT}
```

The label on projects (namespaces) is cluster dependent -- they need to be specific for your needs.  For this example, we will add some labels to namespaces as approriate.  Replacing <NAMESPACE-PROJECT#> with your namespaces.

```bash
oc label namespace <NAMESPACE-PROJECT1> ${!PROM_LABEL}=team1
oc label namespace <NAMESPACE-PROJECT2> ${!PROM_LABEL}=team1
oc label namespace <NAMESPACE-PROJECT3> ${!PROM_LABEL}=team2
oc label namespace <NAMESPACE-PROJECT4> ${!PROM_LABEL}=team2
```

Finally, Create the dashboard in a namespace that is watched by the grafana operator.

```bash
export GRAFANA_OPERATOR=<NAMESPACE-BEING-WATCHED-BY-GRAFANA-OPERATOR>
oc apply -f dashboard.yaml -n ${GRAFANA_OPERATOR}
```
