#!/usr/bin/env bash
#
# This script tests a helm chart is well-formed (helm lint) and tries to install 
# and test a deployment via helm test (https://docs.helm.sh/developing_charts/#chart-tests)

CHART_NAME=${CHART_NAME:-technical-on-boarding}
NAMESPACE=${NAMESPACE:?NAMESPACE must be set}
RELEASE=${RELEASE:?RELEASE must be set}

if [[ ! -d ${CHART_NAME} ]]; then
  echo >&2 "Directory for chart '$CHART_NAME' does not exist."
  exit 1
fi

# test the format of the chart, exit on failure
helm lint ${CHART_NAME} || exit $?

# test the deployment of chart, and helm test if you got them
helm install --wait --replace --name ${RELEASE} --namespace ${NAMESPACE} ./${CHART_NAME}
if [[ -d ${CHART_NAME}/templates/tests ]]; then
  helm test ${RELEASE} --cleanup
  HELM_TEST_EXIT_CODE=$?
fi

# cleanup
helm delete --purge ${RELEASE}
exit ${HELM_TEST_EXIT_CODE}
