#!/bin/bash

echo "🧹 Auto Clearing Cache and Data (User-level only)..."

# 1. Clear general cache
echo "→ Clearing ~/.cache"
rm -rf ~/.cache/*

# 2. Clear Firefox cache (user profile)
echo "→ Clearing Firefox Cache"
find ~/.mozilla/firefox/ -type d -name "*.default-release" -exec rm -rf {}/cache2/* {}/*.sqlite {}/*.mfasl \;

# 3. Clear Chromium/Chrome cache (if installed)
echo "→ Clearing Chromium Cache"
rm -rf ~/.config/chromium/Default/Cache/*
rm -rf ~/.config/chromium/Default/Code\ Cache/js/*

# 4. Clear custom app data (example: VS Code)
echo "→ Clearing VS Code Cache"
rm -rf ~/.config/Code/Cache/*
rm -rf ~/.config/Code/CachedData/*
rm -rf ~/.config/Code/User/workspaceStorage/*

# 5. Optional: Clear thumbnail cache
echo "→ Clearing Thumbnail Cache"
rm -rf ~/.thumbnails/*
rm -rf ~/.cache/thumbnails/*

echo "✅ Done!"