#!/bin/bash
# Dollar Horde - Android Export Script
# Run this after: sudo apt install openjdk-11-jdk
# And Android SDK installed at ~/Android/Sdk

set -e

PROJECT_DIR="$HOME/.godot_projects/dollar_horde"
BUILD_DIR="$PROJECT_DIR/builds"
GODOT="$HOME/.godot_projects/dollar_games/MyDollarGame/Godot_v4.4-stable_linux.x86_64"

mkdir -p "$BUILD_DIR"

export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/34.0.0:$PATH"

echo "Building Android APK..."
"$GODOT" --headless --path "$PROJECT_DIR" --export-debug Android "$BUILD_DIR/dollar_horde-debug.apk"

if [ -f "$BUILD_DIR/dollar_horde-debug.apk" ]; then
    echo "✅ APK built: $BUILD_DIR/dollar_horde-debug.apk"
    ls -la "$BUILD_DIR/dollar_horde-debug.apk"
else
    echo "❌ Build failed"
    exit 1
fi