#!/bin/bash

echo "Approving operator InstallPlans.  Waiting a few seconds to make sure the InstallPlan gets created first."
sleep 10
for subscription in `oc get subscription -o name`
do 
  desiredcsv=$(oc get $subscription -o jsonpath='{ .spec.startingCSV }')
  until [ "$(oc get installplan --template="{{ range \$item := .items }}{{ range \$item.spec.clusterServiceVersionNames }}{{ if eq . \"$desiredcsv\"}}{{ printf \"%s\n\" \$item.metadata.name }}{{end}}{{end}}{{end}}")" != "" ]; do sleep 2; done
  installplans=$(oc get installplan --template="{{ range \$item := .items }}{{ range \$item.spec.clusterServiceVersionNames }}{{ if eq . \"$desiredcsv\"}}{{ printf \"%s\n\" \$item.metadata.name }}{{end}}{{end}}{{end}}")
  for installplan in $installplans
  do
    if [ "`oc get installplan $installplan -o jsonpath="{.spec.approved}"`" == "false" ]; then
      echo "Approving Subscription $subscription with install plan $installplan"
      oc patch  installplan $installplan --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
    else
      echo "Install Plan '$installplan' already approved"
    fi
  done
done
