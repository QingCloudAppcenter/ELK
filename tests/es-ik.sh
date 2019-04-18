#!/usr/bin/env bash

set -e

curl -XPUT 192.168.2.4:9200/_template/text_cn -d'{
  "template": "text-cn*",
  "settings": {
    "number_of_replicas": 0
  },
  "mappings": {
    "doc": {
      "_source": {
        "enabled": true
      },
      "properties": {
        "content": {
          "type": "text",
          "analyzer": "ik_max_word",
          "search_analyzer": "ik_smart"
        }
      }
    }
  }
}'

curl -XPUT 192.168.2.4:9200/test-cn -d'{
  "settings": {
    "number_of_replicas": 0
  },
  "mappings": {
    "doc": {
      "properties": {
        "content": {
          "type": "text",
          "analyzer": "ik_max_word",
          "search_analyzer": "ik_max_word"
        }
      }
    }
  }
}'

curl -H 'Content-Type: application/json' -XPOST http://192.168.2.4:9200/logstash-2019.04.15/_search -d'
{
  "query" : { "match" : { "message": "优帆科技" }},
  "highlight" : {
    "pre_tags" : ["<tag1>", "<tag2>"],
    "post_tags" : ["</tag1>", "</tag2>"],
    "fields" : {
      "message": {}
    }
  }
}'|jq '.hits.hits[].highlight.message'
