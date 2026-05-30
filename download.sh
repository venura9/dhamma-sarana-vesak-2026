#!/bin/bash

# Install dependencies only if not already available
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp not found, installing..."
    brew install yt-dlp
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg not found, installing..."
    brew install ffmpeg
fi

# Download
yt-dlp -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio/best" \
    --merge-output-format mp4 \
    -o "%(title)s.%(ext)s" \
    -a videos.txt 2>&1 | tee download.log