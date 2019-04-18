#!/usr/bin/env bash

set -e

# jvm.options
# -Des.allow_insecure_settings=true

curl -H 'Content-Type: application/json' -XPUT 192.168.2.4:9200/_snapshot/qingstor-repo/ -d '
{
  "type": "s3",
  "settings": {
    "endpoint": "s3.pek3a.qingstor.com", 
    "allow_insecure_settings": "true",
    "access_key": "SYMBKWUTYPHSVBGKQNTK",
    "secret_key": "QI6FQX6aSmnKIA0S56t02WVHJAQbi5DiAhk7v1f8",
    "bucket": "harbor2",
    "base_path": "es660"
  }
}
'

curl 192.168.2.4:9200/_snapshot/qingstor-repo

curl -XPUT 'http://192.168.2.4:9200/_snapshot/qingstor-repo/snapshot1?wait_for_completion=true'

