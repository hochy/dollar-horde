#!/bin/bash
# Dollar Horde - Docker Build (works without local SDK setup)
# Requires Docker installed

set -e

PROJECT_DIR="/home/jeremy/.godot_projects/dollar_horde"
BUILD_DIR="$PROJECT_DIR/builds"

echo "🐳 Building Dollar Horde APK with Docker..."

# Create builds directory
mkdir -p "$BUILD_DIR"

# Use Godot CI Docker image with Android support
docker run --rm \
  -v "$PROJECT_DIR:/project" \
  -v "$BUILD_DIR:/build" \
  -w "/project" \
  barichello/godot-ci:4.4-stable \
  --headless --export-debug "Android" "/build/dollar_horde.apk"

if [ -f "$BUILD_DIR/dollar_horde.apk" ]; then
  echo "✅ APK built: $BUILD_DIR/dollar_horde.apk"
  ls -la "$BUILD_DIR/dollar_horde.apk"
else
  echo "❌ Build failed"
fi