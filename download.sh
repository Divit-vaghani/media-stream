#!/bin/bash
set -e

# ============================================
#  Download & Extract Media → Start Streaming
# ============================================

MEDIA_DIR="$(cd "$(dirname "$0")" && pwd)/media"
mkdir -p "$MEDIA_DIR"

# --- Get URL from argument or prompt ---
URL="${1:-}"
if [ -z "$URL" ]; then
    read -p "🔗 Enter download URL: " URL
fi

if [ -z "$URL" ]; then
    echo "❌ No URL provided. Exiting."
    exit 1
fi

echo ""
echo "📥 Downloading from: $URL"
echo "📂 Target directory: $MEDIA_DIR"
echo ""

# --- Download the file ---
FILENAME=$(basename "$URL" | sed 's/?.*//')
FILEPATH="$MEDIA_DIR/$FILENAME"

wget -c --progress=bar:force -O "$FILEPATH" "$URL"
echo ""
echo "✅ Download complete: $FILEPATH"

# --- Extract if it's an archive ---
cd "$MEDIA_DIR"

case "$FILENAME" in
    *.zip)
        echo "📦 Extracting ZIP..."
        unzip -o "$FILENAME"
        rm -f "$FILENAME"
        ;;
    *.tar.gz|*.tgz)
        echo "📦 Extracting TAR.GZ..."
        tar xzf "$FILENAME"
        rm -f "$FILENAME"
        ;;
    *.tar.bz2)
        echo "📦 Extracting TAR.BZ2..."
        tar xjf "$FILENAME"
        rm -f "$FILENAME"
        ;;
    *.tar)
        echo "📦 Extracting TAR..."
        tar xf "$FILENAME"
        rm -f "$FILENAME"
        ;;
    *.rar)
        echo "📦 Extracting RAR..."
        unrar x -o+ "$FILENAME"
        rm -f "$FILENAME"
        ;;
    *.7z)
        echo "📦 Extracting 7Z..."
        7z x "$FILENAME" -aoa
        rm -f "$FILENAME"
        ;;
    *)
        echo "ℹ️  Not an archive, keeping file as-is."
        ;;
esac

echo ""
echo "📂 Media directory contents:"
ls -lhR "$MEDIA_DIR"
echo ""

# --- Start the media server ---
echo "🚀 Starting media server on port 8090..."

# Kill any existing server on port 8090
fuser -k 8090/tcp 2>/dev/null || true

cd "$MEDIA_DIR"
nohup python3 -m http.server 8090 --bind 0.0.0.0 > /dev/null 2>&1 &
SERVER_PID=$!

echo ""
echo "============================================"
echo "  ✅ MEDIA SERVER IS RUNNING! (PID: $SERVER_PID)"
echo "============================================"
echo ""
echo "  Open in phone browser to browse files:"
echo "  http://<YOUR-HETZNER-IP>:8090/"
echo ""
echo "  Copy a file link → Open in VLC → Stream!"
echo ""
echo "  To stop: kill $SERVER_PID"
echo "============================================"
