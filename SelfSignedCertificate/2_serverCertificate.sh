#!/bin/sh

CA_ROOT_CERT=."/CA/ca.crt"
CA_ROOT_PKEY=."/CA/ca.key"

SERVER_OUTPUTDIR="./SERVER"

CONFIG_FILE="./confServer.conf"

mkdir $SERVER_OUTPUTDIR

cat <<EOF >$CONFIG_FILE
[ req ]
  prompt = no
  encrypt_key = no
  default_bits = 2048
  default_md = sha256
  distinguished_name = req_server_dn
  x509_extensions = server_reqext

[ req_server_dn ]
  C = US
  ST = IL
  L = Chicago
  O = theServerApp
  OU = PenTesting
  CN = *.theServerApp.com
  0.emailAddress=awesome_ceo@theServerApp.com


[ server_reqext ]
  subjectKeyIdentifier    = hash
  basicConstraints = CA:false
  extendedKeyUsage = serverAuth
  #NOTE: serverAuth Server certificates are used to authenticate server identity to the client(s), which is the normal case when doing TLS.
  keyUsage = digitalSignature, keyEncipherment, keyAgreement
  subjectAltName = @alternate_names

[ alternate_names ]
  DNS = *.theServerApp.com
  IP = 10.203.242.135, 10.203.532.135

EOF


# # Generate CSR for the server
openssl req -nodes -newkey rsa:2048 -keyout "$SERVER_OUTPUTDIR/server.key" -out "$SERVER_OUTPUTDIR/server.csr" -config $CONFIG_FILE

# # Sign the CSR and generate server cert
openssl x509 -req -in "$SERVER_OUTPUTDIR/server.csr" -days 730 -CA "$CA_ROOT_CERT" -CAkey "$CA_ROOT_PKEY" -CAcreateserial -out "$SERVER_OUTPUTDIR/server.crt"

## openssl pkcs12 -export -out $SERVER_OUTPUTDIR/servercert.pfx -inkey "$SERVER_OUTPUTDIR/server.key" -in "$SERVER_OUTPUTDIR/server.crt" -passout pass:ca_pass-phrase

rm "$CONFIG_FILE"

