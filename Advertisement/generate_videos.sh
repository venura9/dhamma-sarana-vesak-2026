#!/bin/bash

# ─────────────────────────────────────────
# Vesak Donation Video Generator
# Generates Sinhala and English videos
# using the poster as a static background
# ─────────────────────────────────────────

POSTER="poster.jpg"
SINHALA_SCRIPT="sinhala_script.txt"
ENGLISH_SCRIPT="english_script.txt"
SINHALA_AUDIO="sinhala.mp3"
ENGLISH_AUDIO="english.mp3"
SINHALA_VIDEO="vesak_sinhala.mp4"
ENGLISH_VIDEO="vesak_english.mp4"
LOG_FILE="generate_videos.log"

# Redirect all stdout and stderr to log file and terminal
exec > >(tee "$LOG_FILE") 2>&1

echo "============================="
echo " Run: $(date)"
echo "============================="

# ─── Install missing dependencies ────────

if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install it from https://brew.sh and re-run."
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg not found, installing..."
    brew install ffmpeg
fi

if ! command -v python3 &> /dev/null; then
    echo "python3 not found, installing..."
    brew install python
fi

if ! python3 -c "import edge_tts" &> /dev/null; then
    echo "edge-tts not found, installing..."
    pip3 install edge-tts --break-system-packages
fi

# ─── Check required files exist ──────────

if [ ! -f "$POSTER" ]; then
    echo "Error: $POSTER not found in current directory."
    exit 1
fi

if [ ! -f "$SINHALA_SCRIPT" ]; then
    echo "Error: $SINHALA_SCRIPT not found in current directory."
    exit 1
fi

if [ ! -f "$ENGLISH_SCRIPT" ]; then
    echo "Error: $ENGLISH_SCRIPT not found in current directory."
    exit 1
fi

# ─── Generate audio ──────────────────────

echo "Generating Sinhala audio..."
python3 -m edge_tts \
    --voice "si-LK-ThiliniNeural" \
    --rate="-20%" \
    --file "$SINHALA_SCRIPT" \
    --write-media "$SINHALA_AUDIO"

echo "Generating English audio..."
python3 -m edge_tts \
    --voice "en-AU-WilliamMultilingualNeural" \
    --rate="-30%" \
    --file "$ENGLISH_SCRIPT" \
    --write-media "$ENGLISH_AUDIO"

# ─── Generate videos ─────────────────────
# Note: scale filter rounds width/height down to nearest even number
# required by libx264

echo "Creating Sinhala video..."
ffmpeg -y -loop 1 -i "$POSTER" -i "$SINHALA_AUDIO" \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
    -c:v libx264 -tune stillimage \
    -c:a aac -b:a 192k \
    -pix_fmt yuv420p -shortest \
    "$SINHALA_VIDEO"

echo "Creating English video..."
ffmpeg -y -loop 1 -i "$POSTER" -i "$ENGLISH_AUDIO" \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
    -c:v libx264 -tune stillimage \
    -c:a aac -b:a 192k \
    -pix_fmt yuv420p -shortest \
    "$ENGLISH_VIDEO"

# ─── Cleanup temp audio ──────────────────

rm -f "$SINHALA_AUDIO" "$ENGLISH_AUDIO"

echo ""
echo "Done!"
echo "  $SINHALA_VIDEO"
echo "  $ENGLISH_VIDEO"
