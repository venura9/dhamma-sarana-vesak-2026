#!/bin/bash

# ─────────────────────────────────────────
# Vesak Donation Video Generator
# Uses Azure Cognitive Services TTS
# ─────────────────────────────────────────

AZURE_KEY=""
AZURE_REGION="australiaeast"

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

# ─── Generate audio via Azure TTS ────────

echo "Generating Sinhala audio via Azure TTS..."
SINHALA_TEXT=$(cat "$SINHALA_SCRIPT")
HTTP_STATUS=$(curl -X POST \
  "https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1" \
  -H "Ocp-Apim-Subscription-Key: ${AZURE_KEY}" \
  -H "Content-Type: application/ssml+xml" \
  -H "X-Microsoft-OutputFormat: audio-48khz-192kbitrate-mono-mp3" \
  -w "%{http_code}" \
  -o "$SINHALA_AUDIO" \
  -d "<?xml version='1.0'?>
<speak version='1.0' xml:lang='si-LK'>
  <voice name='si-LK-ThiliniNeural'>
    <prosody rate='-35%'>
      ${SINHALA_TEXT}
    </prosody>
  </voice>
</speak>")

if [ "$HTTP_STATUS" != "200" ]; then
    echo "Error: Azure TTS failed for Sinhala (HTTP $HTTP_STATUS)"
    cat "$SINHALA_AUDIO"
    exit 1
fi
echo "Sinhala audio OK (HTTP $HTTP_STATUS)"

echo "Generating English audio via Azure TTS..."
ENGLISH_TEXT=$(cat "$ENGLISH_SCRIPT")
HTTP_STATUS=$(curl -X POST \
  "https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1" \
  -H "Ocp-Apim-Subscription-Key: ${AZURE_KEY}" \
  -H "Content-Type: application/ssml+xml" \
  -H "X-Microsoft-OutputFormat: audio-48khz-192kbitrate-mono-mp3" \
  -w "%{http_code}" \
  -o "$ENGLISH_AUDIO" \
  -d "<?xml version='1.0'?>
<speak version='1.0' xml:lang='en-AU'>
  <voice name='en-AU-WilliamMultilingualNeural'>
    <prosody rate='-30%'>
      ${ENGLISH_TEXT}
    </prosody>
  </voice>
</speak>")

if [ "$HTTP_STATUS" != "200" ]; then
    echo "Error: Azure TTS failed for English (HTTP $HTTP_STATUS)"
    cat "$ENGLISH_AUDIO"
    exit 1
fi
echo "English audio OK (HTTP $HTTP_STATUS)"

# ─── Generate videos ─────────────────────

echo "Creating Sinhala video..."
ffmpeg -y -loop 1 -i "$POSTER" -i "$SINHALA_AUDIO" \
    -vf 'scale=trunc(iw/2)*2:trunc(ih/2)*2' \
    -c:v libx264 -tune stillimage \
    -c:a aac -b:a 192k \
    -pix_fmt yuv420p -shortest \
    "$SINHALA_VIDEO"

echo "Creating English video..."
ffmpeg -y -loop 1 -i "$POSTER" -i "$ENGLISH_AUDIO" \
    -vf 'scale=trunc(iw/2)*2:trunc(ih/2)*2' \
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
