#!/bin/bash
# =============================================================
#  Auto Git Push Watcher
#  Watches the directory for file changes and auto-commits+pushes
# =============================================================

WATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
DEBOUNCE_SECONDS=2
LOG_FILE="$WATCH_DIR/.git-autopush.log"

cd "$WATCH_DIR" || exit 1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto-push watcher started on: $WATCH_DIR" >> "$LOG_FILE"

# Track last change time for debouncing
LAST_CHANGE=0

# Main loop: watch for file changes
/usr/bin/inotifywait -m -r \
  --exclude '\.git/|__pycache__|\.ipynb_checkpoints' \
  -e create -e modify -e moved_to -e close_write \
  --format '%w%f %e %T' --timefmt '%s' \
  "$WATCH_DIR" 2>/dev/null | while read -r FILE EVENT TIMESTAMP; do

    # Skip .git internal files and non-regular files
    case "$FILE" in
      *.git*|*__pycache__*|*.ipynb_checkpoints*|*.log|*.swp|*.swo|*~) continue ;;
    esac

    # Debounce: only act if enough time passed since last change
    CURRENT_TIME=$(date +%s)
    DIFF=$((CURRENT_TIME - LAST_CHANGE))
    if [ "$DIFF" -lt "$DEBOUNCE_SECONDS" ]; then
      continue
    fi
    LAST_CHANGE=$CURRENT_TIME

    # Wait a moment for the file write to fully complete
    sleep "$DEBOUNCE_SECONDS"

    cd "$WATCH_DIR" || continue

    # Check if there are actual changes to commit
    git add -A
    if git diff --cached --quiet; then
      continue  # No changes, skip
    fi

    # Build a descriptive commit message
    CHANGED_FILES=$(git diff --cached --name-only)
    FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

    # Get the first changed file name for the message
    FIRST_FILE=$(echo "$CHANGED_FILES" | head -1)
    BASENAME=$(basename "$FIRST_FILE")

    if [ "$FILE_COUNT" -eq 1 ]; then
      COMMIT_MSG="auto: update $BASENAME"
    else
      COMMIT_MSG="auto: update $FILE_COUNT files (incl. $BASENAME)"
    fi

    # Commit and push
    if git commit -m "$COMMIT_MSG" --quiet 2>>"$LOG_FILE"; then
      if git push --quiet 2>>"$LOG_FILE"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] PUSHED: $COMMIT_MSG" >> "$LOG_FILE"
      else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] PUSH FAILED for: $COMMIT_MSG" >> "$LOG_FILE"
      fi
    fi
done
