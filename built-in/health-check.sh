#!/bin/sh

# Check if the environment variable is set
if [ -z "$HEALTHCHECK_PATH" ]; then
  echo `date` ":HEALTHCHECK_PATH environment variable not set. Not checking filesystem" >> /proc/1/fd/1
else 
  # Check if the file exists
  if [ ! -f "$HEALTHCHECK_PATH" ]; then
    echo `date` "File not found at $HEALTHCHECK_PATH" >> /proc/1/fd/1
    echo `date` "Kill SSH Daemon to prevent wrong service." >> /proc/1/fd/1
    kill -15 $(pidof sshd)
    exit 1
  fi
fi

# Check if ssh is running (basic check)
if netstat -an | grep :22 > /dev/null; then
  echo `date` "Healthcheck OK. SSH service is running."
else
  echo `date` "SSH service is not running, restarting container." >> /proc/1/fd/1
  reboot
  exit 1
fi

exit 0