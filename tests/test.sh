#!/usr/bin/env bash

# This is a simple test script to test the functionality of the helm chart
OUTFILE=$(mktemp -d --tmpdir=.)/test-manifest.yaml
KUBEVERSION="1.26.5"

helm dependencies update
helm template . > $OUTFILE
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

kubeconform -strict -summary -kubernetes-version $KUBEVERSION -exit-on-error $OUTFILE
if [ $? -eq 0 ]; then
  echo "Manifest file is valid"
  if [ -f $OUTFILE ]; then
    cat $OUTFILE
    rm -f $OUTFILE
    rmdir $(dirname $OUTFILE)
  fi
else
  echo "Manifest file is invalid"
  exit 1
fi