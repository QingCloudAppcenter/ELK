#!/usr/bin/env bash

set -e

HOST=${HOST:-192.168.2.4}
IDX=case03
TYPE=doc

cat << EOF |
青云
优帆科技
优帆
EOF
curl -F file=@-\;filename=newword.dic http://192.168.2.5/dicts/

curl -H 'Content-Type: application/json' -XPUT $HOST:9200/$IDX -d'{
  "mappings": {
    "doc": {
      "message": {
        "content": { 
          "type": "text",
          "analyzer": "ik_max_word",
          "search_analyzer": "ik_max_word"
        }
      }
    }
  }
}'

curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"我有一个西红柿"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"番茄炒蛋饭在北京"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"西红柿鸡蛋面在中国"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"美国留给伊拉克的是个烂摊子吗"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"公安部：各地校车将享最高路权"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"中韩渔警冲突调查：韩警平均每天扣1艘中国渔船"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"中国驻洛杉矶领事馆遭亚裔男子枪击 嫌犯已自首"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"北京优帆科技有限公司于2012年4月正式成立，是全球首家实现资源秒级响应并按秒计量的基础云服务商"}'
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE -d'{"content":"青云的12字决：从初创企业到云生态的蜕变"}'

keyword=优帆科技
cat << EOF |
{
  "query" : { "match" : { "message" : "$keyword" }},
  "highlight" : {
    "pre_tags" : ["<tag1>", "<tag2>"],
    "post_tags" : ["</tag1>", "</tag2>"],
    "fields" : {
      "message" : {}
    }
  }
}
EOF
curl -H 'Content-Type: application/json' -XPOST http://$HOST:9200/$IDX/$TYPE/_search -d@-
