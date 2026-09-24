#!/bin/bash

set -e

SERVER_DIR="/home/guru/bedrock-server"
WORLDS_DIR="$SERVER_DIR/worlds"

BACKUP_DIR="/home/guru/Minecraft-world-backup"
BACKUP_WORLDS="$BACKUP_DIR/worlds"

LOG_FILE="/home/guru/minecraft-backup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================"
log "Minecraft backup started"

if ! tmux has-session -t minecraft 2>/dev/null; then
    log "ERROR: tmux session 'minecraft' does not exist."
    exit 1
fi

log "Notifying players..."
tmux send-keys -t minecraft "say Server backup starting in 10 seconds..." Enter

sleep 10

log "Stopping Minecraft..."

tmux send-keys -t minecraft "stop" Enter

for i in {1..60}; do
    if ! pgrep -f "$SERVER_DIR/bedrock_server" >/dev/null; then
        break
    fi
    sleep 1
done

if pgrep -f "$SERVER_DIR/bedrock_server" >/dev/null; then
    log "ERROR: Minecraft did not stop within 60 seconds."
    exit 1
fi

log "Minecraft stopped."

log "Copying worlds..."

rsync -a --delete \
    "$WORLDS_DIR/" \
    "$BACKUP_WORLDS/"

log "Worlds copied."

cd "$BACKUP_DIR"

git add worlds

if git diff --cached --quiet; then
    log "No changes detected."
else
    git commit -m "Minecraft world backup $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    log "Backup pushed to GitHub."
fi

log "Starting Minecraft..."

tmux send-keys -t minecraft \
    "cd $SERVER_DIR && LD_LIBRARY_PATH=. ./bedrock_server" Enter

sleep 10

if pgrep -f "$SERVER_DIR/bedrock_server" >/dev/null; then
    log "Minecraft started successfully."
else
    log "ERROR: Minecraft failed to start."
    exit 1
fi

log "Minecraft backup completed."
log "========================================"
