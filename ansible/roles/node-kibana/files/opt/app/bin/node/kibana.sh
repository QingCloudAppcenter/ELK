prepareDirs() {
  local svc; for svc in $(getServices -a); do
    local svcName=${svc%%/*}
    mkdir -p /data/$svcName/{data,logs}
    local svcUser=$svcName
    if [[ "$svcName" =~ ^haproxy|keepalived$ ]]; then svcUser=syslog; fi
    chown -R $svcUser.svc /data/$svcName
  done
}

initNode() {
  _initNode
  prepareDirs
  ln -sf /opt/app/conf/caddy/index.html /data/index.html
}

start() {
  [ "$MY_IP" = "${KIBANA_NODES%% *}" ] || retry 60 1 0 checkKibanaIndexCreated || log "WARN: index still not created."
  _start
}

checkKibanaIndexCreated() {
  test -n "$(curl -s -m3 "$ES_VIP:9200/_cat/indices/.kibana-7_8?h=i")"
}

checkSvc() {
  _checkSvc $@ || return $?
  if [ "$1" == "kibana" ]; then checkEndpoint http:9200 $ES_VIP; fi
}

upgrade() {
  [ "$MY_IP" = "${KIBANA_NODES%% *}" ] || retry 60 1 0 checkKibanaIndexCreated || log "WARN: index still not created."
  _start
}
