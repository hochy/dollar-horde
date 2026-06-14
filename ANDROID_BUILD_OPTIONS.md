# Dollar Horde - Android Build Options

## Option 1: GitHub Actions (Recommended - No local setup needed)

Push to main branch to trigger automatic build:
```bash
cd /home/jeremy/.godot_projects/dollar_horde
git add .
git commit -m "Ready for Android build"
git push origin main  # If repo exists on GitHub
```

The `.github/workflows/godot-export.yml` will build and produce artifacts.

## Option 2: Local Build with SDK

### Install Java 11+
```bash
# Ubuntu/Debian:
sudo apt update
sudo apt install openjdk-11-jdk -y

# Set as default:
sudo update-alternatives --config java  # Select Java 11
```

### Install Android SDK (with Java 11)
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk

# Download SDK tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip -q commandlinetools-linux-9477386_latest.zip
mkdir -p cmdline-tools && mv cmdline-tools .
cd cmdline-tools

# Install platform tools and build tools
yes | bin/sdkmanager --sdk_root=~/Android/Sdk "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;26.1.10909125"
```

### Set Environment Variables
```bash
echo 'export ANDROID_SDK_ROOT=~/Android/Sdk' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
```

### Build
```bash
cd /home/jeremy/.godot_projects/dollar_horde
./scripts/build-android.sh
```

## Option 3: Use Godot Editor GUI
Open project in Godot, go to Editor → Manage Export Templates, then Export → Android.