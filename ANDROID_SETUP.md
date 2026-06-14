# Dollar Horde - Android Setup Guide

## Prerequisites
- Android SDK/NDK installed (or use Godot's built-in downloader)
- Java JDK 17+

## Installing Android Export Templates

### Option 1: Via Godot Editor (Recommended)
1. Open the project in Godot editor:
   ```bash
   godot --path ~/.godot_projects/dollar_horde
   ```

2. In Godot Editor:
   - Go to **Editor → Manage Export Templates**
   - Click **Download** for Godot 4.4 (if available)
   - Or click **Install** and provide the templates manually

### Option 2: Manual Download
```bash
# Download export templates for 4.4
curl -L "https://downloads.godotengine.org/export-templates/4.4.stable/Godot_v4.4-stable_export_templates.zip" -o ~/Downloads/godot-templates.zip

# Extract to Godot templates directory
mkdir -p ~/.local/share/godot/export_templates/4.4.stable
unzip ~/Downloads/godot-templates.zip -d ~/.local/share/godot/export_templates/4.4.stable/
```

## Building the APK

```bash
# Make script executable
chmod +x scripts/build-android.sh

# Build (debug version - no keystore needed)
./scripts/build-android.sh
```

## Android SDK Setup (if needed)

```bash
# Install Android SDK via command line tools
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip

# Install required SDK packages
~/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=~/android-sdk "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;26.1.10909125"

# Set environment variable
echo 'export ANDROID_SDK_ROOT=~/android-sdk' >> ~/.bashrc
```

## Project Settings (Already Configured)
- Package ID: `com.thedronedemon.dollarhorde`
- Orientation: Portrait
- Screen: 480x720 (scales to any phone)