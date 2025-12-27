#!/bin/sh

echo "deploy hook executed for domain: $RENEWED_LINEAGE"

for CERT_DIR in "$RENEWED_LINEAGE"/*; do
  for CERT_FILE in "$CERT_DIR"; do
    echo "updating permissions for $CERT_FILE to 1000:1000"
    chown 1000:1000 "$CERT_FILE"
  done
done

echo "deploy hook completed for domain: $RENEWED_LINEAGE"