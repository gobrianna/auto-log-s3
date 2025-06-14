#!/bin/bash

LOG_DIR="/var/log/checklists"
RETENTION_DAYS=30
S3_BUCKET="s3://checklists-backups"
REPORT_FILE="/var/reports/checklists-report.txt"



{
  echo "Log File Report - $(date)"
  echo "----------------------------------------"

  # Ensure LOG_DIR exists
  if [ ! -d "$LOG_DIR" ]; then
    echo "Log directory $LOG_DIR does not exist. Creating it now..."
    mkdir -p "$LOG_DIR"
  fi

  
  # Ensure REPORT_DIR exists
  REPORT_DIR=$(dirname "$REPORT_FILE")
  if [ ! -d "$REPORT_DIR" ]; then
    echo "Report directory $REPORT_DIR does not exist. Creating it now..."
    mkdir -p "$REPORT_DIR"
  fi

  
  # Check if AWS CLI is installed
  if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed or not in PATH."
    exit 1
  fi

  
  echo "Rotating Logs in $LOG_DIR..."

  
  # Rotate logs locally
  LOG_COUNT=$(find $LOG_DIR -type f -mtime +$RETENTION_DAYS | wc -l)
  if ! find $LOG_DIR -type f -mtime +$RETENTION_DAYS -exec rm {} \; &> /dev/null; then
    echo "ERROR: Failed to delete old logs."
    exit 1
  fi
  echo "Deleted $LOG_COUNT log files older than $RETENTION_DAYS days."

  
  # Sync remaining logs to S3
  echo "Syncing logs to $S3_BUCKET..."
  if ! aws s3 sync $LOG_DIR $S3_BUCKET --delete &> /dev/null; then
    echo "ERROR: Failed to sync logs to $S3_BUCKET."
    exit 1
  fi

  # Report completion
  echo "\(^ o ^)/~*~*~*~*"
  echo "Woo-hoo! Log rotation and S3 sync completed successfully."
} > $REPORT_FILE
