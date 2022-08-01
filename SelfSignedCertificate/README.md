# SelfSignedCertificate

The scripts creates -
* CA certificate
* Server certificate, signed by CA
* Client certificate, signed by CA.

Once you generate the client and server certificate, you run OpenSSL client and server to test whether both can establish a SSL communication.



# Generate CA certificate
## 1. Generate Certificate Authoritie's (CA) private key and self signed certificate.
```bash
openssl req -x509 -newkey rsa:2048 -days 1825 -keyout ca.key -out ca.crt -config ./confRoot.conf
```

___Notes___
* Instead of ca.crt you can provide something like ca.pem.
* *-x509* flag says to output certificate file instead of requesting a certificate.
* ca.crt is the CA's certificate file.  It is a public key file, which has identity informations and signature.  This file is encoded (not encrypted).
* ca.key is the encrypted private key file.  It is passphrase protected.
* All other details of CA is read from the config file.

### View the certificate content
If you cat the .crt file you could see the content starting with BEGIN CERTIFICATE.  To see the public key file in human readable format, you can use below command
```bash
openssl x509 -in ca.crt -noout -text
```

To read the encrypted content of the private key file (now this is encrypted), you can simply CAT the file and you will see the content starting "BEGIN ENCRYPTED PRIVATE KEY".
If you have the passphrase, you can read the decrypted content of the private key file (ex: ca.key) with -
```bash
openssl rsa -in ca.key -out ./output.txt
```


# Generate Server certificate
##  2.1 Generate Server's private key and certificate signing request (CSR) file.
```bash
openssl req -nodes -newkey rsa:2048 -keyout server.key -out server.csr -config ./confServer.conf
```

___Notes___
* This is same as explained in #1 above, except this time we want to self sign the certificate with CA's certificate.  You can interchange .csr, with .pem or .crt.  
* As we are not creating certificate, will do not include the _-x509_ flag.
* _-days_ option is also not included because we are not creating certificate. We are creating CSR file.
* All other details of Server is read from the config file.

If you cat the .csr file, you will notice "BEGIN CERTIFICATE REQUEST"; which means this is note a certificate file, but a request file for generating certificate.  In real world, the .csr file will be send to well known CA's and they will sign it.  Here you are your own CA and you will sign it.


## 2.2. Use CA's private key to sign web server's CSR file and generate signed certificate.
```bash
openssl x509 -req -in server.csr -days 730 -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
```

___Note___
* This will be promted CA's passphrase.  Remember, you are the CA now.  Inputs are server's certificate request file, CA's public key (ca.crt) and CA's private key (ca.key).  This process will create a unique serial number in the server certificate.  Now is the time to add additional details like Alternate Subject name.

## 2.3. Verify whether the server's certificate is valid 
To verify a signed certificate, pass the ca public file (ca.crt) and the server's certificate
```bash
openssl verify -CAfile ca.crt server.crt
```


# Generate certificate for the client application
## 3. Follow steps 2.1 & 2.2 to create client certificate.  
Provide meaningful name to the client certificate.

## Test your certificates with OpenSSL client and server
* In a terminal start an SSL server with the server certificate:
```bash
openssl s_server -key server.key -cert server.crt -accept 44330
```
___Note___
* *44330* is the port where the server will start listening.

* Open another terminal and spawn a SSL client.
```bash
openssl s_client -connect :44330 -cert client.crt -key client.key
```

If everything went correct there is a SSL tunnel opened between two terminals.  Type something in one of the terminal and you will see it in the other terminal.

