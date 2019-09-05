#!/usr/bin/env bash

sme_web_bff_path="${HOME}/work/sme-web-bff"

export NODE_ENV="dev"

cd "${sme_web_bff_path}"
node build/express.js 
