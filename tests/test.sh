#!/usr/bin/env bash

# This is a simple test script to test the functionality of the helm chart
OUTDIR=$(mktemp -d --tmpdir=.)
OUTFILE=${OUTDIR}/test-manifest.yaml
KUBEVERSION="1.26.5"

if [ -f Chart.lock ]; then
  rm -f Chart.lock
fi

helm dependencies update
helm template . --output-dir $OUTDIR --debug
if [ $? -eq 0 ]; then
  echo "Helm chart is able to generate the manifest files successfully"
else
  echo "Helm chart build failed"
  exit 1
fi

helm lint . --debug
if [ $? -eq 0 ]; then
  echo "Helm chart is linting successfully"
else
  echo "Helm chart linting failed"
  exit 1
fi

kubeconform -strict -summary -kubernetes-version $KUBEVERSION -exit-on-error $OUTDIR
if [ $? -eq 0 ]; then
  echo "Manifest file is valid"
  for file in $(find ${OUTDIR} -type f -name "*.yaml"); do
    echo $file; echo; echo; cat $file; echo; echo;
  done
else
  echo "Manifest file is invalid"
  exit 1
fi