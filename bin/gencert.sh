#/bin/bash

# Generate a dummy cert signed by a dummy CA that is trusted to
# by localhost. This is required for intra-service communication
# of services in the website - e.g. Shiny apps making R curl
# requests through the Apache virtual host.
# This SOP should be replaced with Vault-issued certs that are
# signed with a real, internal CA (with secured key) that clients
# can choose to trust once.

set -e

umask 077

CN_HOSTNAME=$1

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -z $CN_HOSTNAME ]]; then
  echo "Usage: gencert.sh hostname"
  exit 1
fi

TTL_DAYS=90
CA_CSR=ebrcsavmCA.csr
CA_KEY=ebrcsavmCA.key
CA_CRT=ebrcsavmCA.crt
CA_SUBJ='/CN=ebrcInternalSavmCA'
CLIENT_CSR=localhost.csr
CLIENT_KEY=localhost.key
CLIENT_CRT=localhost.crt
CLIENT_SUBJ="/CN=$CN_HOSTNAME"

# Create a Certificate Authority private key (no -des3 so no password)
openssl genrsa -out "$CA_KEY" 2048

# Create CA
openssl req              \
  -new                   \
  -x509                  \
  -sha256                \
  -subj "$CA_SUBJ" \
  -days $TTL_DAYS        \
  -key  "$CA_KEY"        \
  -out "$CA_CRT"

# Create client key
openssl genrsa -out "$CLIENT_KEY" 2048

# create client CSR
openssl req -new \
  -sha256 \
  -key "$CLIENT_KEY" \
  -subj "$CLIENT_SUBJ" \
  -out "$CLIENT_CSR"

# CA signs CSR
openssl x509 -req     \
   -sha256            \
   -days $TTL_DAYS    \
   -in "$CLIENT_CSR"  \
   -CA "$CA_CRT"      \
   -CAkey "$CA_KEY"   \
   -set_serial 01     \
   -out "$CLIENT_CRT"

# install and trust CA
\cp -f "$CA_CRT" "/etc/pki/ca-trust/source/anchors/$CA_CRT"
update-ca-trust extract

\cp -f "$CLIENT_KEY" "/etc/pki/tls/private/$CLIENT_KEY"
\cp -f "$CLIENT_CRT" "/etc/pki/tls/certs/$CLIENT_CRT"

systemctl restart shiny-server
systemctl restart httpd

