#!/bin/sh

CA_OUTPUTDIR=."/CA"
mkdir $CA_OUTPUTDIR

CONFIG_FILE="./confRoot.conf"

cat <<EOF >$CONFIG_FILE
[ req ]
  prompt = no
  encrypt_key = yes
  default_bits = 2048
  default_md = sha256
  distinguished_name = req_distinguished_name
  x509_extensions = x509_extensions

[ req_distinguished_name ]
  C = US
  ST = TN
  L = Nashville
  O = IAmTheCA
  OU = SigningDept.
  CN = *.iamtheca.com
  0.emailAddress=renjith@iamtheca.com
  1.emailAddress=renjith@myotherco.org

[ x509_extensions ]
  subjectKeyIdentifier = hash
  authorityKeyIdentifier = keyid:always,issuer:always
  basicConstraints = CA:true
  keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign
  issuerAltName = issuer:copy
  subjectAltName = @alternate_names

[ alternate_names ]
  DNS.1 = *.iamtheca.com
  DNS.2 = *.iamtheca.org
  IP.1 = 10.121.132.143
  IP.2 = 10.231.242.253
EOF


# Generate self signed root CA cert
##NOTE include the -nodes to generate unencypted private key file.  Then it wont ask passphrase while CA generate certs.
openssl req -x509 -newkey rsa:2048 -days 1825 -keyout "$CA_OUTPUTDIR/ca.key" -out "$CA_OUTPUTDIR/ca.crt" -config "$CONFIG_FILE"

rm $CONFIG_FILE
