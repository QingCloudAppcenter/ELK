#!/usr/bin/env bash

set -e

. /opt/app/bin/.env

# Error codes
EC_DEFAULT=1          # default
EC_RETRY_FAILED=2

command=$1
args="${@:2}"

log() {
  logger -t appctl --id=$$ [cmd=$command] "$@"
}

retry() {
  local tried=0
  local maxAttempts=$1
  local interval=$2
  local cmd="${@:3}"
  local retCode=$EC_RETRY_FAILED
  while [ $tried -lt $maxAttempts ]; do
    sleep $interval
    tried=$((tried+1))
    $cmd && return 0 || {
      retCode=$?
      log "'$cmd' ($tried/$maxAttempts) returned an error."
    }
  done

  log "'$cmd' still returned errors after $tried attempts. Stopping ..." && return $retCode
}

svcName=elasticsearch
[[ "$MY_ROLE" =~ ^elasticsearch ]] || svcName=$MY_ROLE
svc() {
  systemctl $@ $svcName
}

init() {
  svc enable
}

check() {
  svc is-active -q
}

start() {
  if [[ "$MY_ROLE" =~ ^elasticsearch ]]; then
    sysctl -qw vm.max_map_count=262144
    sysctl -qw vm.swappiness=0
  fi

  svc start
}

stop() {
  svc stop
}

restart() {
  stop && start
}

update() {
  svc is-enabled -q || return 0

  restart
}

$command $args
