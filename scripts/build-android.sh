#!/bin/bash
# Dollar Horde - Android Export Build Script
# Run this after installing Android export templates via Godot

set -e

PROJECT_DIR="$HOME/.godot_projects/dollar_horde"
BUILD_DIR="$PROJECT_DIR/builds"
OUTPUT_NAME="dollar_horde.apk"

echo "🏗️  Building Dollar Horde for Android..."

# Ensure build directory exists
mkdir -p "$BUILD_DIR"

# Set Android keystore path (for release builds)
export ANDROID_KEYSTORE="$HOME/.android/release.keystore"

# Validate keystore exists or create debug build
if [ ! -f "$ANDROID_KEYSTORE" ]; then
    echo "⚠️  No release keystore found, building debug APK..."
    godot --headless --path "$PROJECT_DIR" --export-debug Android "$BUILD_DIR/$OUTPUT_NAME"
else
    echo "📦 Building release APK with keystore..."
    godot --headless --path "$PROJECT_DIR" --export Android "$BUILD_DIR/$OUTPUT_NAME"
fi

if [ -f "$BUILD_DIR/$OUTPUT_NAME" ]; then
    echo "✅ Build complete: $BUILD_DIR/$OUTPUT_NAME"
    ls -la "$BUILD_DIR/$OUTPUT_NAME"
else
    echo "❌ Build failed - check Godot editor for export template errors"
    exit 1
fi