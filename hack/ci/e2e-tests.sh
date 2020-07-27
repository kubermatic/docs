#!/usr/bin/env bash

set -euo pipefail

CONTROLLER_IMAGE="quay.io/kubermatic/cluster-exposer:v1.0.0"

if [[ -z ${JOB_NAME} ]]; then
	echo "This script should only be running in a CI environment."
	exit 0
fi

if [[ -z ${PROW_JOB_ID} ]]; then
	echo "Build id env variable has to be set."
	exit 0
fi

export CYPRESS_KUBERMATIC_DEX_DEV_E2E_USERNAME="roxy@loodse.com"
export CYPRESS_KUBERMATIC_DEX_DEV_E2E_USERNAME_2="roxy2@loodse.com"
export CYPRESS_KUBERMATIC_DEX_DEV_E2E_PASSWORD="password"

# function cleanup {
# 	kubectl delete service -l "prow.k8s.io/id=$PROW_JOB_ID"

# 	# Kill all descendant processes
# 	pkill -P $$
# }
# trap cleanup EXIT

# echo "done with setup"
# # Set docker config
# echo $IMAGE_PULL_SECRET_DATA | base64 -d > /config.json

# sed 's/localhost/localhost dex.oauth/' < /etc/hosts > /hosts
# cat /hosts > /etc/hosts

# # Start docker daemon
# dockerd > /dev/null 2> /dev/null &

# # Wait for it to start
# while (! docker stats --no-stream ); do
#   # Docker takes a few seconds to initialize
#   echo "Waiting for Docker..."
#   sleep 1
# done


#cd "${GOPATH}/src/github.com/kubermatic/kubermatic"
#source hack/lib.sh
echodate() {
  echo "[$(date -Is)]" "$@"
}

retry() {
  # Works only with bash but doesn't fail on other shells
  start_time=$(date +%s)
  set +e
  actual_retry $@
  rc=$?
  set -e
  elapsed_time=$(($(date +%s) - $start_time))
  write_junit "$rc" "$elapsed_time"
  return $rc
}

actual_retry() {
  retries=$1 ; shift

  count=0
  delay=1
  until "$@"; do
    rc=$?
    count=$(( count + 1 ))
    if [ $count -lt "$retries" ]; then
      echo "Retry $count/$retries exited $rc, retrying in $delay seconds..." >/dev/stderr
      sleep $delay
    else
      echo "Retry $count/$retries exited $rc, no more retries left." >/dev/stderr
      return $rc
    fi
    delay=$(( delay * 2 ))
  done
  return 0
}

TEST_NAME="Get Vault token"

write_junit() {
  # Doesn't make any sense if we don't know a testname
  if [ -z "${TEST_NAME:-}" ]; then return; fi
  # Only run in CI
  if [ -z "$ARTIFACTS" ]; then return; fi

  rc=$1
  duration=${2:-0}
  errors=0
  failure=""
  if [ "$rc" -ne 0 ]; then
    errors=1
    failure='<failure type="Failure">Step failed</failure>'
  fi
  TEST_NAME="[Kubermatic] ${TEST_NAME#\[Kubermatic\] }"
  cat <<EOF > ${ARTIFACTS}/junit.$(echo $TEST_NAME|sed 's/ /_/g').xml
<?xml version="1.0" ?>
<testsuites>
    <testsuite errors="$errors" failures="$errors" name="$TEST_NAME" tests="1">
        <testcase classname="$TEST_NAME" name="$TEST_NAME" time="$duration">
          $failure
        </testcase>
    </testsuite>
</testsuites>
EOF
}

appendTrap() {
  command="$1"
  signal="$2"

  # Have existing traps, must append
  if [[ "$(trap -p|grep $signal)" ]]; then
  existingHandlerName="$(trap -p|grep $signal|awk '{print $3}'|tr -d "'")"

  newHandlerName="${command}_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)"
  # Need eval to get a random func name
  eval "$newHandlerName() { $command; $existingHandlerName; }"
  echodate "Appending $command as trap for $signal, existing command $existingHandlerName"
  trap $newHandlerName $signal
  # First trap
  else
    echodate "Using $command as trap for $signal"
    trap $command $signal
  fi
}
echodate "Getting secrets from Vault"
export VAULT_ADDR=https://vault.loodse.com/
export VAULT_TOKEN=$(vault write \
  --format=json auth/approle/login \
  role_id=$VAULT_ROLE_ID secret_id=$VAULT_SECRET_ID \
  | jq .auth.client_token -r)
export VALUES_FILE=/tmp/values.yaml
TEST_NAME="Get Values file from Vault"
retry 5 vault kv get -field=values.yaml \
  dev/seed-clusters/ci.kubermatic.io > $VALUES_FILE

# Set docker config
echo $IMAGE_PULL_SECRET_DATA | base64 -d > /config.json

# Start docker daemon
if ps xf| grep -v grep | grep -q dockerd; then
  echodate "Docker already started"
else
  echodate "Starting docker"
  dockerd > /tmp/docker.log 2>&1 &
  echodate "Started docker"
fi

function docker_logs {
  originalRC=$?
  if [[ $originalRC -ne 0 ]]; then
    echodate "Printing docker logs"
    cat /tmp/docker.log
    echodate "Done printing docker logs"
  fi
  return $originalRC
}
appendTrap docker_logs EXIT

# Wait for it to start
echodate "Waiting for docker"
retry 5 docker stats --no-stream
echodate "Docker became ready"

# Load kind image
docker load --input /kindest.tar
echo "Done loading kind image"
deploy.sh
echo "done running deploy.sh"
DOCKER_CONFIG=/ docker run --name controller -d -v /root/.kube/config:/inner -v /etc/kubeconfig/kubeconfig:/outer --network host --privileged ${CONTROLLER_IMAGE} --kubeconfig-inner "/inner" --kubeconfig-outer "/outer" --namespace "default" --build-id "$PROW_JOB_ID"
echo "done with docker run"
docker logs -f controller &

expose.sh
echo "done with expose.sh"
npm run versioninfo
npm run e2e:local
