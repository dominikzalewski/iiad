#!/bin/bash

# shellcheck disable=SC1091
source config_fingerprint.sh

function die() {
	echo "$1" >&2
	exit 200
}

function show_help() {
	echo "help" >&2
}

function parse_opts() {
	while getopts "x:c:m:e:w:t:v:r:" opt
	do
		case "$opt" in
		c)  COMPOSE=$OPTARG
			;;
		x)  CONTEXT=$OPTARG
			;;
		m)  MICROSERVICE=$OPTARG
			;;
		e)  ENV=$OPTARG
			;;
		w)  WORKSPACE=$OPTARG
			;;
		t)  TEMPLATE=$OPTARG
			;;
		v)  VERSION=$OPTARG
			;;
		r)  REGISTRY=$OPTARG
			;;
		*)
			echo "usage ./deliver.sh -xcmewtv" >&2
			exit 1
			;;
		esac
	done
}

function defaults() {
	[ -z "$MICROSERVICE" ] && die "MICROSERVICE parameter is required"
	[ -z "$ENV" ] && die "ENV parameter is required"
	[ -z "$WORKSPACE" ] && WORKSPACE=../..
	[ -z "$COMPOSE" ] && COMPOSE="$WORKSPACE/iiad/$MICROSERVICE/docker-compose.yml"
	[ -z "$TEMPLATE" ] && TEMPLATE="$MICROSERVICE"
	[ -z "$CONTEXT" ] && CONTEXT=default
}

parse_opts "$@"
defaults
source "$WORKSPACE/context/$MICROSERVICE.$ENV"

export MICROSERVICE
export ENV
export WORKSPACE
export MEMORY
export VERSION
export REGISTRY
export PORT

CONFIG=$(mktemp)
config_fingerprint "$COMPOSE" "$MICROSERVICE" "$ENV" "$TEMPLATE" "$WORKSPACE" > "$CONFIG"
# shellcheck disable=SC1090
source "$CONFIG"
rm "$CONFIG"

docker --context "$CONTEXT" stack deploy -c "$COMPOSE" "${MICROSERVICE}-${ENV}"
