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
	while getopts "x:c:m:e:w:t:" opt
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
		*)
			echo "usage ./deliver.sh -xcmewt" >&2
			exit 1
			;;
		esac
	done
}

function defaults() {
	[ -z "$MICROSERVICE" ] && die "MICROSERVICE parameter is required"
	[ -z "$ENV" ] && die "ENV parameter is required"
	[ -z "$WORKSPACE" ] && WORKSPACE=../..
	[ -z "$COMPOSE" ] && COMPOSE="$WORKSPACE/docker/$MICROSERVICE/docker-compose.yml"
	[ -z "$TEMPLATE" ] && TEMPLATE="$MICROSERVICE"
	[ -z "$CONTEXT" ] && CONTEXT=default
}

parse_opts "$@"
defaults

export MICROSERVICE
export ENV
export WORKSPACE

CONFIG=$(mktemp)
config_fingerprint "$COMPOSE" "$MICROSERVICE" "$ENV" "$TEMPLATE" "$WORKSPACE" > "$CONFIG"
# shellcheck disable=SC1090
source "$CONFIG"
rm "$CONFIG"

docker --context "$CONTEXT" stack deploy -c "$COMPOSE" "$MICROSERVICE"
