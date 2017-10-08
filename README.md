# easy-ca
A command line interface for openSSL written in Bash allowing you to easily manage your certification authorities and X509 certificates for your Public Key Infrastructure

## Requirements
- openssl 1.1.0+
- bash 4.4+

## Installation
```bash
git clone https://github.com/daweedm/easy-ca && chmod +x easy-ca/easy-ca.sh
```

## Usage
```bash
./easy-ca/easy-ca.sh [-d ROOT_CA_DIR]
```

If `-d` is not specified or isn't a compatible directory you'll be prompted to init a new root certification authority.

This script handles for you the creation of root CA, intermediate CA and certificates. It allows you to manage an infinite number of intermediate CA and certificates with a simple CLI.

## What does it do for you ?
- creation of CA and X509 certificates 
- intermediate CA and certificate signing by parent CA
- setting best files and folders permissions for security (the access to the private keys is limited to the user that created them (owner) and the certificates are readable by everyone in your system)
- setting defaults (country, state/province name, organization name, ...) in each openssl.cnf files
- handling alternatives names for each issued certificate (preventing errors in some new clients like Google Chrome 58+)
- prevent some intermediate CA to sign other CA if you want

## Directory structure
```bash
Daweed_Authority_Group_0/
└── ... # You can handle multiple certificate authorities
Daweed_Authority_Group_1/
└── root/ # naming convention for the Root CA
    ├── CA.key # the CA private key
    ├── CA.pem # the CA certificate
    ├── index.txt # emission db
    ├── index.txt.attr
    ├── serial
    ├── openssl.cnf # Each CA has its own openssl configuration file where you have access to more configuration options
    ├── crl/ # TODO: will be used for revocation
    ├── csr/ # contains the generated certificate signing requests
    ├── public/
    │     ├── newcerts/ # TODO: will be used for revocation
    │     └── certs/  
    │           └── web.daweed.be.pem
    ├── private/
    │     └── keys/
    │           ├── web.daweed.be.key
    │           └── ...
    └── children/ # contains the child CA
          ├── Daweed_Intermediate_CA_1/
          │     ├── CA.key # the CA private key
          │     ├── ...
          │     ├── openssl.cnf # Each CA has its own openssl configuration file where you have access to more configuration options 
          │     └── children/
          │           └── ... # contains the child CA
          │
          ├── Daweed_Intermediate_CA_2/
          └── ...
     
```

## TODO
- CRL handling

## Contribution
Any pull-request is welcome !
