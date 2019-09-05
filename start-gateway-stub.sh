#!/usr/bin/env bash

docker run -p 127.0.0.1:8082:8080/tcp --name gateway-stub -d realfengjia/fakeit --spec https://contracts.svc.europa-preprod.jupiter.myobdev.com/spec.json --use-example --permissive
p
