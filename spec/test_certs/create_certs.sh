#!/bin/sh
openssl genrsa -out cadb.key 4096
openssl req -x509 -new -nodes -key cadb.key -days 3650 -subj '/CN=localhost' -config cert.cfg -out chain.pem
openssl genrsa -out privkey.pem 4096
openssl req -new -key privkey.pem -out db.csr -subj '/CN=localhost' -config cert.cfg
openssl x509 -req -in db.csr -CA chain.pem -CAkey cadb.key -CAcreateserial -out cert.pem -days 365