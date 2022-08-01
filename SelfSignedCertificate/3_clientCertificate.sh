#!/bin/sh

CA_ROOT_CERT=."/CA/ca.crt"
CA_ROOT_PKEY=."/CA/ca.key"

CLIENT_OUTPUTDIR="./CLIENT"

CONFIG_FILE="./confClient.conf"

mkdir $CLIENT_OUTPUTDIR

cat <<EOF >$CONFIG_FILE
[ req ]
  prompt = no
  encrypt_key = no
  default_bits = 2048
  default_md = sha256
  distinguished_name = req_client_dn
  x509_extensions = client_reqext

[ req_client_dn ]
  C = US
  ST = AK
  L = Juneau
  O = theClientGuy
  OU = Blackhat
  CN = *.theClientGuy.com
  0.emailAddress=chillteam@theClientGuy.com

[ client_reqext ]
  #subjectKeyIdentifier = hash
  basicConstraints = CA:false
  extendedKeyUsage = clientAuth
  #NOTE: clientAuth: Client certificates are used to authenticate the client (user) identity to the server.
  keyUsage = critical,digitalSignature
  subjectAltName = @alternate_names

[ alternate_names ]
  DNS.1 = theClientGuy
  DNS.2 = *.theClientGuy.com
  URI = https://theClientGuy.com

EOF


# # Generate CSR for the client
openssl req -nodes -newkey rsa:2048 -keyout "$CLIENT_OUTPUTDIR/client.key" -out "$CLIENT_OUTPUTDIR/client.csr" -config $CONFIG_FILE

# # Sign the CSR and generate client cert
openssl x509 -req -in "$CLIENT_OUTPUTDIR/client.csr" -days 365 -CA "$CA_ROOT_CERT" -CAkey "$CA_ROOT_PKEY" -CAcreateserial -out "$CLIENT_OUTPUTDIR/client.crt"

## openssl pkcs12 -export -out $CLIENT_OUTPUTDIR/clientcert.pfx -inkey "$CLIENT_OUTPUTDIR/client.key" -in "$CLIENT_OUTPUTDIR/client.crt" -passout pass:ca_pass-phrase

rm "$CONFIG_FILE"

