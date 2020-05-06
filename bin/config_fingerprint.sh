#!/bin/bash

function config_fingerprint() {

	local DOCKER_COMPOSE=$1
	# shellcheck disable=SC2034
	local MICROSERVICE=$2
	local ENV=$3
	local TEMPLATE=$4
	local WORKSPACE=$5
	[ -e "$DOCKER_COMPOSE" ] || DOCKER_COMPOSE="$WORKSPACE/docker/$TEMPLATE/docker-compose.yml"

	yq r -j "$DOCKER_COMPOSE" |\
		jq --raw-output '(.configs,.secrets) | to_entries | map(select(.value | has("file")) | .key, .value.name, .value.file)[]' |\
	while read -r entry; read -r name; read -r file
	do
		# shellcheck disable=SC2016
		interpolated=$(echo "$file" | envsubst '${ENV}${MICROSERVICE}${WORKSPACE}${TEMPLATE}')
		# shellcheck disable=SC2001
		name_without_references="$(echo "$name"| sed s/\$.*//)"
		remainder=$(( 64 - ${#name_without_references} ))
		# shellcheck disable=SC2148
		echo "export ${entry}_DIGEST=\"$(sha512sum "$interpolated" | awk '{print $1}' | cut -c -${remainder})\""
	done | sort
}
