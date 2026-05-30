# Dhamma Sarana Vesak 2026

Buddhist video content and donation advertisement assets for Dhamma Sarana Vihara, Keysborough — Vesak & Poson 2026.

## Repository structure

```
├── videos.txt              # YouTube URLs to download
├── download.sh             # Local download script (uses yt-dlp)
├── *.mp4                   # Downloaded videos (stored in Git LFS)
└── Advertisement/
    ├── poster.jpg          # Static background image for ads
    ├── sinhala_script.txt  # Sinhala voiceover script
    ├── english_script.txt  # English voiceover script
    ├── generate_videos.sh  # Generates ads using Edge TTS (free)
    ├── generate_videos_azure.sh  # Generates ads using Azure TTS
    ├── vesak_sinhala.mp4   # Edge TTS output — Sinhala
    ├── vesak_english.mp4   # Edge TTS output — English
    ├── vesak_sinhala_azure.mp4   # Azure TTS output — Sinhala (latest)
    └── vesak_english_azure.mp4   # Azure TTS output — English (latest)
```

## Running locally

**Download videos from YouTube:**
```bash
# Add URLs to videos.txt, then:
./download.sh
```

**Generate advertisement videos (Edge TTS — no credentials needed):**
```bash
cd Advertisement
./generate_videos.sh
```

**Generate advertisement videos (Azure TTS — higher quality):**
```bash
# Set your Azure Speech key in generate_videos_azure.sh, then:
cd Advertisement
./generate_videos_azure.sh
```

## GitHub Actions workflows

All three workflows run on macOS runners and push results back to the `main` branch.

### 1. Download New Videos (`download-videos.yml`)

**Trigger:** Push to `main` when `videos.txt` changes, or manual dispatch.

Downloads any URLs in `videos.txt` that have not been fetched before (tracked via `download_archive.txt`). New `.mp4` files are stored in Git LFS and committed back automatically.

### 2. Generate Ads — Azure TTS (`generate-ads-azure.yml`)

**Trigger:** Push to `main` when any `Advertisement/` source file changes, or manual dispatch.

Generates Sinhala and English advertisement videos using Azure Cognitive Services Text-to-Speech. Outputs are saved under two names each:
- `vesak_sinhala_azure.mp4` / `vesak_english_azure.mp4` — latest, always overwritten
- `vesak_sinhala_azure_YYYYMMDD.mp4` / `vesak_english_azure_YYYYMMDD.mp4` — dated snapshot

**Required secrets:**

| Secret | Description |
|---|---|
| `AZURE_SPEECH_KEY` | Azure Cognitive Services subscription key |
| `AZURE_SPEECH_REGION` | Azure region (default: `australiaeast`) |

### 3. Generate Ads — Edge TTS (`generate-ads.yml`)

**Trigger:** Push to `main` when any `Advertisement/` source file changes, or manual dispatch.

Generates Sinhala and English advertisement videos using Microsoft Edge TTS (free, no credentials required). Outputs: `vesak_sinhala.mp4` and `vesak_english.mp4`.

## Git LFS

All `.mp4` files are tracked via [Git LFS](https://git-lfs.github.com/). After cloning, run:

```bash
git lfs install
git lfs pull
```
