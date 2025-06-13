#!/bin/bash

LOG_DIR="var/log/checklists"
RETENTION_DAYS=30
S3_BUCKET="s3://checklists-backups"

# Rotates logs locally
find $LOG_DIR -type f -mtime +$RETENTION_DAYS -exec rm {} \;

# Sync remaining logs to S3 also ensuring deletion sync
aws s3 sync $LOG_DIR $S3_BUCKET --delete
