#!/usr/bin/env bash

set -e

svcNames="elasticsearch caddy"

postInit() {
  local dir1=/data/elasticsearch/analysis
  local dir2=/opt/app/conf/elasticsearch/scripts
  mkdir -p $dir1 $dir2
  chown -R caddy.svc $dir1
  chown -R elasticsearch.svc $dir2
}

preStart() {
  sysctl -qw vm.max_map_count=262144
  sysctl -qw vm.swappiness=0
}

