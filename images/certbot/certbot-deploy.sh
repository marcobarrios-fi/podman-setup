#!/bin/sh

# marcobarrios.fi Certbot Deploy Shell Script
# /usr/local/bin/certbot-deploy
# /etc/letsencrypt/renewal-hooks/deploy/
# Copies generated certificates and private keys to the SSL directory
# This script is executed by Certbot after a successful certificate renewal

# The shell variable RENEWED_LINEAGE points to the live subdirectory containing the renewed certificates and keys
# The shell variable RENEWED_DOMAINS contains a space-delimited list of renewed domains

for domain in $RENEWED_DOMAINS; do
  # Copy private key to the SSL directory
  echo "Copying $domain private key to SSL keys directory";
  cp --update "$RENEWED_LINEAGE/privkey.pem" "$SSL_KEYS_DIR/$domain.key"
  # Copy certificate to the SSL directory
  echo "Copying $domain certificate to SSL certificates directory";
  cp --update "$RENEWED_LINEAGE/fullchain.pem" "$SSL_CERTS_DIR/$domain.crt"
  # Stop processing after the first domain
  break
done