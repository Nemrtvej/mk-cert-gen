#!/bin/bash

set -e
set -x

source config.sh

CA_KEY=output/ca_key.pem
CA_CERT=output/ca_cert.pem
SERVER_KEY=output/server_key.pem
SERVER_CERT=output/server_cert.pem
SERVER_REQ=output/server_req.pem

SERVER_RESULT="output/server.pem"
CA_RESULT="output/ca.pem"


rm -f ${CA_KEY} ${CA_CERT} ${SERVER_KEY} ${SERVER_CERT} ${SERVER_REQ} ${SERVER_RESULT} ${CA_RESULT}

# Creating the Certificate Authority's Certificate and Keys
openssl genrsa 2048 > "${CA_KEY}"
openssl req -new -x509 -nodes -days 3650 -key "${CA_KEY}" -out "${CA_CERT}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${CA_ORGANIZATION}/OU=${OU}/CN=${CA_COMMON_NAME}" -addext  "keyUsage=critical, Certificate Sign, CRL Sign"

# Create server key and certificate sign request (CSR)
openssl genrsa 2048 > "${SERVER_KEY}"
openssl req -new -nodes -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${SRV_ORGANIZATION}/OU=${OU}/CN=${SRV_COMMON_NAME}" \
   -key "${SERVER_KEY}" \
   -out "${SERVER_REQ}" \
   -addext  "extendedKeyUsage=TLS Web Server Authentication, TLS Web Client Authentication"

# Sign the server CSR and create the X509 cert for server
openssl x509 -req -days 3650 -set_serial 01 \
   -in "${SERVER_REQ}" \
   -out "${SERVER_CERT}" \
   -CA "${CA_CERT}" \
   -CAkey "${CA_KEY}"

cat "${CA_CERT}" "${CA_KEY}" > "${CA_RESULT}"
cat "${SERVER_CERT}" "${SERVER_KEY}" > "${SERVER_RESULT}"
