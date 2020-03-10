#!/usr/bin/env bash

git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3

# initialize public key infrastructure
./easyrsa init-pki
# build new certificate authority
./easyrsa build-ca nopass

# generate server cert and key
./easyrsa build-server-full server nopass
# generate client cert and key
./easyrsa build-client-full client1.domain.tld nopass

# copy to custom folder
mkdir ~/.rsa-certs/
cp pki/ca.crt ~/.rsa-certs/
cp pki/issued/server.crt ~/.rsa-certs/
cp pki/private/server.key ~/.rsa-certs/
cp pki/issued/client1.domain.tld.crt ~/.rsa-certs
cp pki/private/client1.domain.tld.key ~/.rsa-certs/
cd ~/.rsa-certs/

# upload server certificate and key
aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt --region eu-north-1
# upload client certificate and key
aws acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt --region eu-north-1