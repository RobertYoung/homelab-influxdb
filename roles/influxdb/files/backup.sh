#!/bin/bash

set -e

echo "Running backup script"

TIMESTAMP_RFC3339=$(date --rfc-3339=seconds)
FILENAME=$SERVICE_NAME-latest.tar.gz
TAR_FILE=/tmp/$FILENAME
BACKUP_DIR=/backup

rm -rf $TAR_FILE || true
rm -rf $BACKUP_DIR/* || true

echo "Backing up $SERVICE_NAME"

trap 'echo "Backup command failed. Cleaning up..."; rm -f "$TAR_FILE" zi* "$BACKUP_DIR/*"; exit 1' ERR

if [ "$(influx config ls --json)" = "{}" ]; then
  influx config create \
    --config-name influxdb \
    --host-url https://$INFLUXDB_HOST:$INFLUXDB_PORT \
    --org $INFLUXDB_ORG \
    --token $INFLUXDB_TOKEN \
    --active
fi

influx backup \
  --skip-verify \
  $BACKUP_DIR

cd $BACKUP_DIR

echo "Creating tarball $TAR_FILE"

tar -czvf $TAR_FILE --warning=none .

echo "Created $TAR_FILE"

trap - ERR

echo "Uploading to s3://$BUCKET_NAME/$SERVICE_NAME/$FILENAME"

aws s3 cp $TAR_FILE s3://$BUCKET_NAME/$SERVICE_NAME/$FILENAME

echo "Backed up $SERVICE_NAME to s3://$BUCKET_NAME/$SERVICE_NAME/$FILENAME"

echo "Setting time to topic "backup/$SERVICE_NAME/time""

mosquitto_pub -h $MOSQUITTO_HOST -t "backup/$SERVICE_NAME/time" -m "$TIMESTAMP_RFC3339" -u "$MOSQUITTO_USERNAME" -P "$MOSQUITTO_PASSWORD" --retain

echo "Finished backing up $SERVICE_NAME"
