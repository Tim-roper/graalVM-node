#!/usr/bin/env bash

graal_path="${HOME}/Downloads/graalvm-ce-19.2.0/Contents/Home/bin"
sme_web_bff_path="${HOME}/work/sme-web-bff"

export PATH=":${graal_path}:${PATH}"
export NODE_ENV="dev"

cd "${sme_web_bff_path}"

# node build/express.js 				# Vanilla Graal node runtime
node --jvm --polyglot ${sme_web_bff_path}/build/express.js 		# Run on JVM
