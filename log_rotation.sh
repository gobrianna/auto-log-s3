#!/bin/bash

LOG_DIR="var/log/checklists"
RETENTION_DAYS=30
S3_BUCKET="s3://checklists-backups"
REPORT_FILE="/var/reports/checklists-report.txt"

# Indicates start of script
{
  echo "Log File Report - $(date)"
  echo "----------------------------------------"
  echo "Rotating Logs in $LOG_DIR..."

  # Rotates logs locally
  LOG_COUNT=$(find $LOG_DIR -type f -mtime +$RETENTION_DAYS | wc -l)
  find $LOG_DIR -type f -mtime +$RETENTION_DAYS -exec rm {} \;
  echo "Deleted $LOG_COUNT log files older than $RETENTION_DAYS days."

  # Sync remaining logs to S3 also ensuring deletion sync
  echo "Syncing logs to $S3_BUCKET..."
  aws s3 sync $LOG_DIR $S3_BUCKET --delete 2>&1

  # Report completion
  echo "\(^ o ^)/~*~*~*~*"
  echo "Woo-hoo! Log rotation and S3 sync completed successfully."
} > $REPORT_FILE
