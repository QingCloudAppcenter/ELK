#!/usr/bin/env bash

set -e

# jvm.options
# -Des.allow_insecure_settings=true

HOST=192.168.2.4
VIP=${VIP:-192.168.2.200}
PORT=80
IDX=case12
TYPE=_doc

echo '西红柿,番茄 => 西红柿,番茄' | curl -F "file=@-;filename=synonym.txt" http://$HOST/dicts/

curl -H 'Content-Type: application/json' -XPUT $VIP:$PORT/$IDX -d '
{
  "settings": {
    "index": {
      "analysis": {
        "analyzer": {
          "by_smart": {
            "type": "custom",
            "tokenizer": "ik_smart",
            "filter": ["by_tfr","by_sfr"],
            "char_filter": ["by_cfr"]
          },
          "by_max_word": {
            "type": "custom",
            "tokenizer": "ik_max_word",
            "filter": ["by_tfr","by_sfr"],
            "char_filter": ["by_cfr"]
          }
        },
        "filter": {
          "by_tfr": {
            "type": "stop",
            "stopwords": [" "]
          },
          "by_sfr": {
            "type": "synonym",
            "synonyms_path": "/data/elasticsearch/dicts/synonym.txt"
          }
        },
        "char_filter": {
          "by_cfr": {
            "type": "mapping",
            "mappings": ["| => |"]
          }
        }
      }
    }
  },
  "mappings": {
    "_doc": {
      "properties": {
        "content": {
          "type": "text",
          "analyzer": "by_max_word",
          "search_analyzer": "by_smart"
        }
      }
    }
  }
}
'

curl -H 'Content-Type: application/json' -XPOST http://$VIP:$PORT/$IDX/$TYPE -d'{"content":"我有一个西红柿"}'
curl -H 'Content-Type: application/json' -XPOST http://$VIP:$PORT/$IDX/$TYPE -d'{"content":"番茄炒蛋饭在北京"}'
curl -H 'Content-Type: application/json' -XPOST http://$VIP:$PORT/$IDX/$TYPE -d'{"content":"西红柿鸡蛋面在中国"}'

query() {
  curl -H 'Content-Type: application/json' -XPOST http://$VIP:$PORT/$IDX/$TYPE/_search  -d'{
    "query" : { "match" : { "content" : "番茄" }},
    "highlight" : {
      "pre_tags" : ["<tag1>", "<tag2>"],
      "post_tags" : ["</tag1>", "</tag2>"],
      "fields" : {
        "content" : {}
      }
    }
  }'
}
