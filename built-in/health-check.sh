#!/bin/sh

# Check if the environment variable is set
if [ -z "$HEALTHCHECK_PATH" ]; then
  echo "HEALTHCHECK_PATH environment variable not set. Not checking filesystem"
else 
  # Check if the file exists
  if [ ! -f "$HEALTHCHECK_PATH" ]; then
    echo "File not found at $HEALTHCHECK_PATH" >&2
    exit 1
  fi
fi

# Check if ssh is running (basic check)
if netstat -an | grep :22 > /dev/null; then
  echo "SSH service is running."
else
  echo "SSH service is not running." >&2
  exit 1
fi

exit 0