#!/bin/bash
# Copilot Execution Plan Script
set -e

# 1. Initialization
SPACE_NAME="${SPACE_NAME:-default_space}"
BACKUP_BUCKET="s3://my-backups/${SPACE_NAME}/"
WEBHOOK_URL="${WEBHOOK_URL:-}" # Set via env or .env
WORKDIR="config/json"
cd "$WORKDIR"

# 2. JSON Verification
if ! python3 ../verify_jsons.py; then
  ERROR_MSG="JSON verification failed in $WORKDIR"
  echo "$ERROR_MSG"
  # 6. Notifications (failure)
  if [ -n "$WEBHOOK_URL" ]; then
    curl -X POST -H "Content-Type: application/json" -d "{\"status\":\"failure\",\"message\":\"$ERROR_MSG\"}" "$WEBHOOK_URL"
  fi
  exit 1
fi

# 3. Port Injection
PORT=$(jq -r '.port' ../ports.json)
DOCKER_COMPOSE="../../docker-compose.yml"
K8S_DEPLOY="../../k8s/deployment.yaml"
if [ -f "$DOCKER_COMPOSE" ]; then
  sed -i "s/\(ports:\s*\[\)[0-9]*\(\]\)/\1$PORT\2/" "$DOCKER_COMPOSE"
fi
if [ -f "$K8S_DEPLOY" ]; then
  sed -i "s/\(containerPort: \)[0-9]*/\1$PORT/" "$K8S_DEPLOY"
fi

# 4. Backup Sync
TMP_BACKUP="/tmp/copilot_backup"
mkdir -p "$TMP_BACKUP"
aws s3 sync "$BACKUP_BUCKET" "$TMP_BACKUP" --exclude "*" --include "*.json" || true
for file in *.json; do
  if ! cmp -s "$file" "$TMP_BACKUP/$file"; then
    aws s3 cp "$file" "$BACKUP_BUCKET$file"
  fi
done

# 5. Audit Logging
cd ../../audit
LOG_ENTRY="{\"timestamp\":\"$(date -Iseconds)\",\"action\":\"copilot_run\",\"outcome\":\"success\",\"source\":\"run_copilot_tasks.sh\"}"
echo "$LOG_ENTRY" | jq . >> logs.json

# 6. Notifications (success)
if [ -n "$WEBHOOK_URL" ]; then
  curl -X POST -H "Content-Type: application/json" -d "{\"status\":\"success\",\"message\":\"Copilot tasks completed successfully.\"}" "$WEBHOOK_URL"
fi

# 7. Cleanup & Exit
rm -rf "$TMP_BACKUP"
exit 0
