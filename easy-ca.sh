#!/bin/bash
# Author    daweedm <m@daweed.be>
# URL       https://github.com/daweedm
# License   GPL-3.0 - https://github.com/daweedm/easy-ca/blob/master/LICENSE
# A command line interface written in Bash for openSSL allowing you to easily manage your certificates and quickly become a CA

function fill_openssl_alt_name_ext {
	cat <<-EOF >> "$1"
		authorityKeyIdentifier=keyid,issuer
		basicConstraints=CA:FALSE
		keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
		subjectAltName = @alt_names

		[alt_names]
		DNS.1 = ${EASY_CA_OPENSSL_ALT_NAME}
	EOF
}

function fill_openssl_cnf {
	cat <<-EOF >> "$1"

		#
		# OpenSSL example configuration file.
		# This is mostly being used for generation of certificate requests.
		#
		# This definition stops the following lines choking if HOME isn't
		# defined.
		HOME			= .
		RANDFILE		= \$ENV::HOME/.rnd

		# Extra OBJECT IDENTIFIER info:
		#oid_file		= \$ENV::HOME/.oid
		oid_section		= new_oids

		# To use this configuration file with the "-extfile" option of the
		# "openssl x509" utility, name here the section containing the
		# X.509v3 extensions to use:
		# extensions		= 
		# (Alternatively, use a configuration file that has only
		# X.509v3 extensions in its main [= default] section.)

		[ new_oids ]

		# We can add new OIDs in here for use by 'ca', 'req' and 'ts'.
		# Add a simple OID like this:
		# testoid1=1.2.3.4
		# Or use config file substitution like this:
		# testoid2=\${testoid1}.5.6

		# Policies used by the TSA examples.
		tsa_policy1 = 1.2.3.4.1
		tsa_policy2 = 1.2.3.4.5.6
		tsa_policy3 = 1.2.3.4.5.7

		####################################################################
		[ ca ]
		default_ca	= CA_default		# The default ca section

		####################################################################
		[ CA_default ]

		dir		= ${EASY_CA_OPENSSL_CNF[dir]}		# Where everything is kept
		certs		= \$dir/public/certs	# Where the issued certs are kept
		crl_dir		= \$dir/crl		# Where the issued crl are kept
		database	= \$dir/index.txt	# database index file.
		#unique_subject	= no			# Set to 'no' to allow creation of
							# several certs with same subject.
		new_certs_dir	= \$dir/public/newcerts	# default place for new certs.

		certificate	= \$dir/CA.pem 		# The CA certificate
		serial		= \$dir/serial 		# The current serial number
		crlnumber	= \$dir/crlnumber	# the current crl number
							# must be commented out to leave a V1 CRL
		crl		= \$dir/crl.pem 	# The current CRL
		private_key	= \$dir/CA.key		# The private key
		RANDFILE	= \$dir/private/.rand	# private random number file

		x509_extensions	= usr_cert		# The extensions to add to the cert

		# Comment out the following two lines for the "traditional"
		# (and highly broken) format.
		name_opt 	= ca_default		# Subject Name options
		cert_opt 	= ca_default		# Certificate field options

		# Extension copying option: use with caution.
		# copy_extensions = copy

		# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
		# so this is commented out by default to leave a V1 CRL.
		# crlnumber must also be commented out to leave a V1 CRL.
		# crl_extensions	= crl_ext

		default_days	= 365			# how long to certify for
		default_crl_days= 30			# how long before next CRL
		default_md	= ${EASY_CA_OPENSSL_CNF[default_md]}	# use public key default MD
		preserve	= no			# keep passed DN ordering

		# A few difference way of specifying how similar the request should look
		# For type CA, the listed attributes must be the same, and the optional
		# and supplied fields are just that :-)
		policy		= ${EASY_CA_OPENSSL_CNF[policy]}

		# For the CA policy
		[ policy_match ]
		countryName		= match
		stateOrProvinceName	= match
		organizationName	= match
		organizationalUnitName	= optional
		commonName		= supplied
		emailAddress		= optional

		# For the 'anything' policy
		# At this point in time, you must list all acceptable 'object'
		# types.
		[ policy_anything ]
		countryName		= optional
		stateOrProvinceName	= optional
		localityName		= optional
		organizationName	= optional
		organizationalUnitName	= optional
		commonName		= supplied
		emailAddress		= optional

		####################################################################
		[ req ]
		default_bits		= 4096
		default_keyfile 	= privkey.pem
		distinguished_name	= req_distinguished_name
		attributes		= req_attributes
		x509_extensions		= v3_req	# The extensions to add to the self signed cert

		# Passwords for private keys if not present they will be prompted for
		# input_password = secret
		# output_password = secret

		# This sets a mask for permitted string types. There are several options. 
		# default: PrintableString, T61String, BMPString.
		# pkix	 : PrintableString, BMPString (PKIX recommendation before 2004)
		# utf8only: only UTF8Strings (PKIX recommendation after 2004).
		# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
		# MASK:XXXX a literal mask value.
		# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
		string_mask = utf8only

		# req_extensions = v3_req # The extensions to add to a certificate request

		[ req_distinguished_name ]
		countryName			= Country Name (2 letter code)
		countryName_default		= ${EASY_CA_OPENSSL_CNF[countryName_default]}
		countryName_min			= 2
		countryName_max			= 2

		stateOrProvinceName		= State or Province Name (full name)
		stateOrProvinceName_default	= ${EASY_CA_OPENSSL_CNF[stateOrProvinceName_default]}

		localityName			= Locality Name (eg, city)

		0.organizationName		= Organization Name (eg, company)
		0.organizationName_default	= ${EASY_CA_OPENSSL_CNF[organizationName_default]}

		# we can do this but it is not needed normally :-)
		#1.organizationName		= Second Organization Name (eg, company)
		#1.organizationName_default	= World Wide Web Pty Ltd

		organizationalUnitName		= Organizational Unit Name (eg, section)
		organizationalUnitName_default	= ${EASY_CA_OPENSSL_CNF[organizationalUnitName_default]}

		commonName			= Common Name (e.g. server FQDN or YOUR name)
		commonName_max			= 64

		emailAddress			= Email Address
		emailAddress_max		= 64

		# SET-ex3			= SET extension number 3

		[ req_attributes ]
		challengePassword		= A challenge password
		challengePassword_min		= 4
		challengePassword_max		= 20

		unstructuredName		= An optional company name

		[ usr_cert ]

		# These extensions are added when 'ca' signs a request.

		# This goes against PKIX guidelines but some CAs do it and some software
		# requires this to avoid interpreting an end user certificate as a CA.

		basicConstraints=CA:FALSE

		# Here are some examples of the usage of nsCertType. If it is omitted
		# the certificate can be used for anything *except* object signing.

		# This is OK for an SSL server.
		# nsCertType			= server

		# For an object signing certificate this would be used.
		# nsCertType = objsign

		# For normal client use this is typical
		# nsCertType = client, email

		# and for everything including object signing:
		# nsCertType = client, email, objsign

		# This is typical in keyUsage for a client certificate.
		# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

		# This will be displayed in Netscape's comment listbox.
		nsComment			= "OpenSSL Generated Certificate"

		# PKIX recommendations harmless if included in all certificates.
		subjectKeyIdentifier=hash
		authorityKeyIdentifier=keyid,issuer

		# This stuff is for subjectAltName and issuerAltname.
		# Import the email address.
		# subjectAltName=email:copy
		# An alternative to produce certificates that aren't
		# deprecated according to PKIX.
		# subjectAltName=email:move

		# Copy subject details
		# issuerAltName=issuer:copy

		#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
		#nsBaseUrl
		#nsRevocationUrl
		#nsRenewalUrl
		#nsCaPolicyUrl
		#nsSslServerName

		# This is required for TSA certificates.
		# extendedKeyUsage = critical,timeStamping

		[ v3_intermediate_ca ]
		# Extensions for a typical intermediate CA man x509v3_config
		subjectKeyIdentifier = hash
		authorityKeyIdentifier = keyid:always,issuer
		#basicConstraints = critical, CA:true, pathlen:0
		basicConstraints = critical, CA:true
		keyUsage = critical, digitalSignature, cRLSign, keyCertSign

		[ v3_req ]

		# Extensions to add to a certificate request

		basicConstraints = CA:FALSE
		keyUsage = nonRepudiation, digitalSignature, keyEncipherment

		#subjectAltName = @alt_names

		#[ alt_names ]
		#DNS.1 = hello.be

		[ v3_ca ]


		# Extensions for a typical CA


		# PKIX recommendation.

		subjectKeyIdentifier=hash

		authorityKeyIdentifier=keyid:always,issuer

		basicConstraints = critical,CA:true

		# Key usage: this is typical for a CA certificate. However since it will
		# prevent it being used as an test self-signed certificate it is best
		# left out by default.
		# keyUsage = cRLSign, keyCertSign

		# Some might want this also
		# nsCertType = sslCA, emailCA

		# Include email address in subject alt name: another PKIX recommendation
		# subjectAltName=email:copy
		# Copy issuer details
		# issuerAltName=issuer:copy

		# DER hex encoding of an extension: beware experts only!
		# obj=DER:02:03
		# Where 'obj' is a standard or added object
		# You can even override a supported extension:
		# basicConstraints= critical, DER:30:03:01:01:FF

		[ crl_ext ]

		# CRL extensions.
		# Only issuerAltName and authorityKeyIdentifier make any sense in a CRL.

		# issuerAltName=issuer:copy
		authorityKeyIdentifier=keyid:always

		[ proxy_cert_ext ]
		# These extensions should be added when creating a proxy certificate

		# This goes against PKIX guidelines but some CAs do it and some software
		# requires this to avoid interpreting an end user certificate as a CA.

		basicConstraints=CA:FALSE

		# Here are some examples of the usage of nsCertType. If it is omitted
		# the certificate can be used for anything *except* object signing.

		# This is OK for an SSL server.
		# nsCertType			= server

		# For an object signing certificate this would be used.
		# nsCertType = objsign

		# For normal client use this is typical
		# nsCertType = client, email

		# and for everything including object signing:
		# nsCertType = client, email, objsign

		# This is typical in keyUsage for a client certificate.
		# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

		# This will be displayed in Netscape's comment listbox.
		nsComment			= "OpenSSL Generated Certificate"

		# PKIX recommendations harmless if included in all certificates.
		subjectKeyIdentifier=hash
		authorityKeyIdentifier=keyid,issuer

		# This stuff is for subjectAltName and issuerAltname.
		# Import the email address.
		# subjectAltName=email:copy
		# An alternative to produce certificates that aren't
		# deprecated according to PKIX.
		# subjectAltName=email:move

		# Copy subject details
		# issuerAltName=issuer:copy

		#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
		#nsBaseUrl
		#nsRevocationUrl
		#nsRenewalUrl
		#nsCaPolicyUrl
		#nsSslServerName

		# This really needs to be in place for it to be a proxy certificate.
		proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

		####################################################################
		[ tsa ]

		default_tsa = tsa_config1	# the default TSA section

		[ tsa_config1 ]

		# These are used by the TSA reply generation only.
		dir		= ./demoCA		# TSA root directory
		serial		= \$dir/tsaserial	# The current serial number (mandatory)
		crypto_device	= builtin		# OpenSSL engine to use for signing
		signer_cert	= \$dir/tsacert.pem 	# The TSA signing certificate
							# (optional)
		certs		= \$dir/cacert.pem	# Certificate chain to include in reply
							# (optional)
		signer_key	= \$dir/private/tsakey.pem # The TSA private key (optional)
		signer_digest  = sha256			# Signing digest to use. (Optional)
		default_policy	= tsa_policy1		# Policy if request did not specify it
							# (optional)
		other_policies	= tsa_policy2, tsa_policy3	# acceptable policies (optional)
		digests     = sha1, sha256, sha384, sha512  # Acceptable message digests (mandatory)
		accuracy	= secs:1, millisecs:500, microsecs:100	# (optional)
		clock_precision_digits  = 0	# number of digits after dot. (optional)
		ordering		= yes	# Is ordering defined for timestamps?
						# (optional, default: no)
		tsa_name		= yes	# Must the TSA name be included in the reply?
						# (optional, default: no)
		ess_cert_id_chain	= no	# Must the ESS cert id chain be included?
						# (optional, default: no)
	EOF
}

function init_easy_ca_directory {
	mkdir -m 755 -p "$1"

	mkdir -m 755 "$1/public" # public content
	mkdir -m 755 "$1/public/certs" # certificates
	mkdir -m 755 "$1/public/newcerts" # TODO

	mkdir -m 711 "$1/private" # private content
	mkdir -m 711 "$1/private/keys" # will contain keys

	mkdir -m 711 "$1/crl" # will contain certificate revocation list

	mkdir -m 711 "$1/csr" # will contain certificate signing requests

	mkdir -m 755 "$1/children"

	touch "$1/index.txt"
	chmod 600 "$1/index.txt"

	touch "$1/index.txt.attr"
	chmod 600 "$1/index.txt.attr"

	echo 1000 >> "$1/serial"
	#chmod 600 "$1/serial"

	touch "$1/openssl.cnf"
	chmod 600 "$1/openssl.cnf"

	echo "Yes" >> "$1/.easyca"
	chmod 600 "$1/.easyca"
}

function is_easy_ca_directory {
	if [ -f "$1/.easyca" ]; then
		echo 1
	else
		echo 0
	fi
}

function ask_for_int {
	INTEGER_VALUE=
	while ! [[ "$INTEGER_VALUE" =~ ^[0-9]+$ ]]; do
		read INTEGER_VALUE
	done
	echo "$INTEGER_VALUE"
}


WORKING_DIRECTORY=
while getopts ":d:" opt; do
	case $opt in
		d)
			WORKING_DIRECTORY="$OPTARG"
		;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
		;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
		;;
	esac
done

if [ -n "$WORKING_DIRECTORY" ]; then
	if [ "$(is_easy_ca_directory $WORKING_DIRECTORY)" -eq  "0" ]; then
		echo "Not a valid easy-ca directory: $WORKING_DIRECTORY"
	exit 1
	fi
else
	echo "CREATING NEW CERTIFICATION AUTHORITY"
	echo "Enter the absolute path where you want to store it"
	read -e WORKING_DIRECTORY
	if [ -d "$WORKING_DIRECTORY" ]; then
        	echo "Directory already exits: $WORKING_DIRECTORY"
		exit 1
	else
		root_base_path="$WORKING_DIRECTORY/root"
		root_key_path="$root_base_path/CA.key"
		root_pem_path="$root_base_path/CA.pem"
		root_cnf_path="$root_base_path/openssl.cnf"

		init_easy_ca_directory "$root_base_path"

		echo "Root CA key size ?"
		read root_ca_key_size

		echo "Expires in (how many days) ?"
		root_ca_days=$(ask_for_int)

		# Write root CA's openssl config file
		unset EASY_CA_OPENSSL_CNF
		declare -A EASY_CA_OPENSSL_CNF

		echo "Default md ? (example: sha512)"
		read default_md
		echo "Default country ? (example: BE)" ?
		read default_country
		echo "Default state or province name ?"
		read default_state_or_province_name
		echo "Default organization name ?"
		read default_organization_name
		echo "Default organization unit name ?"
		read default_organization_unit_name

                EASY_CA_OPENSSL_CNF[dir]="$root_base_path"
		EASY_CA_OPENSSL_CNF[policy]="policy_match"
                EASY_CA_OPENSSL_CNF[default_md]="$default_md"
                EASY_CA_OPENSSL_CNF[countryName_default]="$default_country"
                EASY_CA_OPENSSL_CNF[stateOrProvinceName_default]="$default_state_or_province_name"
                EASY_CA_OPENSSL_CNF[organizationName_default]="$default_organization_name"
		EASY_CA_OPENSSL_CNF[organizationalUnitName_default]="$default_organization_unit_name"

                fill_openssl_cnf "$root_base_path/openssl.cnf"

		openssl genrsa -aes256 -out "$root_key_path" "$root_ca_key_size" -config "$root_cnf_path"
		chmod 400 "$root_key_path"
		openssl req -config "$root_cnf_path" -key "$root_key_path" -new -x509 -days "$root_ca_days" -extensions v3_ca -out "$root_pem_path"
		chmod 444 "$root_pem_path"
		WORKING_DIRECTORY="$root_base_path"
	fi
fi

action=
while true; do
	echo "easy-ca: $WORKING_DIRECTORY"
	echo "What do you want to do ?"
	echo "0) List children CA"
	echo "1) Change directory"
	echo "2) Create a new intermediate CA"
	echo "3) Create a new self-signed certificate"
	echo "4) Exit"
	read action
	case $action in
		0)
			for child_ca in "$WORKING_DIRECTORY/children/*"; do
				if [ -d "$child_ca" ]; then
					echo "$child_ca"
				fi
			done
		;;
		1)
			echo "You are here: $WORKING_DIRECTORY"
			echo "Where do you want to go ?"
			read target_dir
			if [ ! -d "$WORKING_DIRECTORY/children/$target_dir" ]; then
				echo "Error: $WORKING_DIRECTORY/$target_dir does not exists"
			else
				WORKING_DIRECTORY+="/children/$target_dir"
				echo "Directory changed to $WORKING_DIRECTORY"
			fi
		;;
		2)
			echo "Enter the CA directory name:"
			read intermediate_ca_dir
			if [ ! -d "$WORKING_DIRECTORY/children/$intermediate_ca_dir" ]; then
				intermediate_ca_base_name="$intermediate_ca_dir"
				echo "Intermediate CA key size ?"
				intermediate_ca_key_size=$(ask_for_int)
				echo "Expires in (how many days) ?"
				intermediate_ca_days=$(ask_for_int)

				intermediate_ca_base_path="$WORKING_DIRECTORY/children/$intermediate_ca_dir"
				intermediate_ca_cnf_path="$intermediate_ca_base_path/openssl.cnf"
				intermediate_ca_key_path="$intermediate_ca_base_path/CA.key"
				intermediate_ca_csr_path="$intermediate_ca_base_path/csr/${intermediate_ca_base_name}.csr"
				intermediate_ca_pem_path="$intermediate_ca_base_path/CA.pem"

				init_easy_ca_directory "$intermediate_ca_base_path"

				echo "Default md ? (example: sha512)"
				read default_md
				echo "Default country ? (example: BE)" ?
               			read default_country
               			echo "Default state or province name ?"
                		read default_state_or_province_name
				echo "Default organization name ?"
				read default_organization_name
				echo "Default organization unit name ?"
				read default_organization_unit_name

				echo "Allow this CA to sign others CA ? (Y/n)"
				read should_not_be_leaf

				extensions="v3_intermediate_ca"
				if [ "$should_not_be_leaf" = "Y" ]; then
					extensions="v3_ca"
				fi

		                unset EASY_CA_OPENSSL_CNF
                		declare -A EASY_CA_OPENSSL_CNF

		                EASY_CA_OPENSSL_CNF[dir]="$intermediate_ca_base_path"
				EASY_CA_OPENSSL_CNF[policy]="policy_anything"
		                EASY_CA_OPENSSL_CNF[default_md]="$default_md"
		                EASY_CA_OPENSSL_CNF[countryName_default]="$default_country"
		                EASY_CA_OPENSSL_CNF[stateOrProvinceName_default]="$default_state_or_province_name"
		                EASY_CA_OPENSSL_CNF[organizationName_default]="$default_organization_name"
		                EASY_CA_OPENSSL_CNF[organizationalUnitName_default]="$default_organization_unit_name"

                		fill_openssl_cnf "$intermediate_ca_cnf_path"

				# Generate intermediate CA's private key
				openssl genrsa -aes256 -out "$intermediate_ca_key_path" "$intermediate_ca_key_size"
				chmod 400 "$intermediate_ca_key_path"
				# Create a certificate signing request
				openssl req -config "$intermediate_ca_cnf_path" -new -key "$intermediate_ca_key_path" -out "$intermediate_ca_csr_path"
				chmod 400 "$intermediate_ca_csr_path"
				# Sign the CSR with parent CA
				openssl ca -config "$WORKING_DIRECTORY/openssl.cnf" -extensions "$extensions" -days "$intermediate_ca_days" -notext -in "$intermediate_ca_csr_path" -out "$intermediate_ca_pem_path"
				chmod 444 "$intermediate_ca_pem_path"
			else
				echo "Sorry, $intermediate_ca_dir already exists"
			fi
		;;
		3)
			echo "Enter the certificate common name:"
			read cert_cn
			if [ ! -f "$WORKING_DIRECTORY/private/keys/${cert_cn}.key" ]; then
				certificate_pem_path="$WORKING_DIRECTORY/public/certs/${cert_cn}.pem"
				certificate_key_path="$WORKING_DIRECTORY/private/keys/${cert_cn}.key"
				certificate_csr_path="$WORKING_DIRECTORY/csr/${cert_cn}.csr"
				certificate_ext_path="$WORKING_DIRECTORY/V3.ext.tmp"

				echo "Certificate expires in (days) ?"
				read certificate_days

				# Generate certificate private key & CSR
				openssl req -config "$WORKING_DIRECTORY/openssl.cnf" -new -newkey rsa -nodes -keyout "$certificate_key_path" -out "$certificate_csr_path"
				chmod 400 "$certificate_key_path"
				chmod 400 "$certificate_csr_path"
				# Create the temporary openssl's extension file (containing the subjectAltName(s) for compatibility with newer clients like Chrome 58+)
				EASY_CA_OPENSSL_ALT_NAME="$cert_cn"
				fill_openssl_alt_name_ext "$certificate_ext_path"
				# Sign the CSR with CA
				openssl ca -config "$WORKING_DIRECTORY/openssl.cnf" -days "$certificate_days" -in "$certificate_csr_path" -out "$certificate_pem_path" -extfile "$certificate_ext_path"
				chmod 444 "$certificate_pem_path"
				rm "$certificate_ext_path"

			else
				echo "Sorry, $cert_cn already exists"
			fi
		;;
		4)
			echo "Bye"
			exit 0
		;;
		:)
			echo "Unsupported action"
		;;
	esac
done
