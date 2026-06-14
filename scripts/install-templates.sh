#!/bin/bash
# Dollar Horde - Direct Android Template Install (headless-friendly)
# Downloads and installs templates without GUI

set -e

GODOT_VERSION="4.4.stable"
TEMPLATES_DIR="$HOME/.local/share/godot/export_templates"
DOWNLOAD_URL="https://downloads.godotengine.org/export_templates/4.4.stable/Godot_v4.4-stable_export_templates.zip"

echo "📥 Downloading Godot 4.4 Android export templates..."
mkdir -p "$TEMPLATES_DIR"

# Download if not cached
if [ ! -f "$HOME/.cache/godot-templates.zip" ]; then
    curl -L "$DOWNLOAD_URL" -o "$HOME/.cache/godot-templates.zip"
fi

echo "📂 Extracting templates..."
unzip -o "$HOME/.cache/godot-templates.zip" -d "$TEMPLATES_DIR/temp"

echo "📁 Moving to correct location..."
mkdir -p "$TEMPLATES_DIR/$GODOT_VERSION"
mv "$TEMPLATES_DIR/temp"/* "$TEMPLATES_DIR/$GODOT_VERSION/" 2>/dev/null || cp -r "$TEMPLATES_DIR/temp"/* "$TEMPLATES_DIR/$GODOT_VERSION/"

echo "✅ Templates installed to: $TEMPLATES_DIR/$GODOT_VERSION"
echo "🚀 Run ./scripts/build-android.sh to build the APK"