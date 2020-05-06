#!/usr/bin/env bats

source bin/config_fingerprint.sh

export DOCKER_COMPOSE=test/docker-compose.yml
export ENV=dev
export MICROSERVICE=service1

function setup() {
	WORKSPACE=`mktemp -d`
	mkdir -p $WORKSPACE/docker/${MICROSERVICE}
	mkdir -p $WORKSPACE/secrets-prod/certs
	mkdir -p $WORKSPACE/configs/${ENV}
	mkdir -p $WORKSPACE/configs/${MICROSERVICE}
	echo "tom" > $WORKSPACE/secrets-prod/certs/wildcard.crt
	echo "john" > $WORKSPACE/configs/localtime
	echo "amy" > $WORKSPACE/configs/${ENV}/file1
	echo "jelly" > $WORKSPACE/configs/${MICROSERVICE}/file2
}

function teardown() {
	echo $WORKSPACE >&2
	rm -r $WORKSPACE
}

@test "should execute OK for happy path" {
	export WORKSPACE
	OUTPUT=$(config_fingerprint "$DOCKER_COMPOSE" "$MICROSERVICE" "$ENV" "$TEMPLATE" "$WORKSPACE")
	echo "$OUTPUT" | diff test/expected_service1.out -
}
