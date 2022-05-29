# Creating a self-signed SSL cert

This is done multiple times in twinwork-notes, I figure it's easier to break it out into its own area. This was also pulled from this gist: https://gist.github.com/jessedearing/2351836 (comments are pretty useful)

```
CERT_NAME=selfsigned
KEY_SIZE=2048

openssl genrsa -des3 -out ${CERT_NAME}.key ${KEY_SIZE}
openssl req -new -key ${CERT_NAME}.key -out ${CERT_NAME}.csr
cp ${CERT_NAME}.key ${CERT_NAME}.key.original
openssl rsa -in ${CERT_NAME}.key.original -out ${CERT_NAME}.key
rm ${CERT_NAME}.key.original
openssl x509 -req -days 365 -in ${CERT_NAME}.csr -signkey ${CERT_NAME}.key -out ${CERT_NAME}.crt
mkdir -p  /usr/local/etc/ssl/{private,public,certs}
cp ${CERT_NAME}.csr /usr/local/etc/ssl/public/
cp ${CERT_NAME}.crt /usr/local/etc/ssl/certs/
cp ${CERT_NAME}.key /usr/local/etc/ssl/private/
```