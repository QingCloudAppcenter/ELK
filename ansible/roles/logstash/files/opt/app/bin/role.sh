#!/usr/bin/env bash

set -e

svcNames="logstash caddy"

prepareDirs() {
  local dataDir=/data/logstash esDir=/data/elasticsearch
  local cfgDir=$dataDir/config pluginsDir=$dataDir/plugins queueDir=$dataDir/queue
  mkdir -p /data/elasticsearch/{dicts,logs} /data/logstash/{config,plugins,queue}
  chown -R root.root /data/

  cp /opt/app/conf/logstash/template.json /data/elasticsearch/dicts/logstash.json
}

postInit() {
  prepareDirs
}
