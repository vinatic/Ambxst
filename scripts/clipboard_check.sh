#!/usr/bin/env bash
# Check clipboard and insert into database
# Usage: clipboard_check.sh <db_path> <script_path> <data_dir>

set -euo pipefail

DB_PATH="$1"
SCRIPT_PATH="$2"
DATA_DIR="$3"

# Check for files first (text/uri-list)
if FILE_CONTENT=$(wl-paste --type text/uri-list 2>/dev/null); then
    HASH=$(echo -n "$FILE_CONTENT" | tr -d '\r' | md5sum | cut -d' ' -f1)
    echo -n "$FILE_CONTENT" | tr -d '\r' | "$SCRIPT_PATH" "$DB_PATH" "$HASH" "text/uri-list" 0 ""
    exit 0
fi

# Check for images
if IMAGE_MIME=$(wl-paste --list-types 2>/dev/null | grep '^image/' | head -1); then
    if [ -n "$IMAGE_MIME" ]; then
        HASH=$(wl-paste --type "$IMAGE_MIME" 2>/dev/null | md5sum | cut -d' ' -f1)
        BINARY_PATH="$DATA_DIR/$HASH"
        wl-paste --type "$IMAGE_MIME" 2>/dev/null > "$BINARY_PATH"
        echo -n '' | "$SCRIPT_PATH" "$DB_PATH" "$HASH" "$IMAGE_MIME" 1 "$BINARY_PATH"
        exit 0
    fi
fi

# Check for plain text
if TEXT_CONTENT=$(wl-paste --type text/plain 2>/dev/null); then
    HASH=$(echo -n "$TEXT_CONTENT" | md5sum | cut -d' ' -f1)
    echo -n "$TEXT_CONTENT" | "$SCRIPT_PATH" "$DB_PATH" "$HASH" "text/plain" 0 ""
    exit 0
fi
