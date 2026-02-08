#!/bin/bash

# 1. Retrieve version from openwrt-version
if [ ! -f "openwrt-version" ]; then
    echo "❌ Error: openwrt-version not found!"
    exit 1
fi

VERSION=$(cat openwrt-version | tr -d '[:space:]')
echo "Step 1: Target OpenWrt version identified: $VERSION"

# 2. Install Build Dependencies
echo "Step 2: Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y \
    binutils bzip2 diffutils findutils flex gawk gcc gettext grep \
    libc-dev libz-dev make perl python3 rsync subversion unzip which git \
    libncurses5-dev libncursesw5-dev  # Required for menuconfig UI

# 3. Clone Official Source Code
echo "Step 3: Cloning official OpenWrt source code (Branch/Tag: $VERSION)..."
if [ -d "openwrt" ]; then
    echo "Cleaning up existing directory..."
    rm -rf openwrt
fi
git clone --depth 1 --branch "$VERSION" https://github.com/openwrt/openwrt.git openwrt

cd openwrt || exit

# 4. Update and Install Feeds
echo "Step 4: Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 5. Run Graphical Configuration
echo "Step 5: Launching menuconfig..."
echo "--- IMPORTANT: Remember to SAVE your configuration before exiting ---"
sleep 3
make menuconfig

# 6. Export .config with Version Suffix
if [ -f ".config" ]; then
    OUTPUT_FILENAME="config-${VERSION}"
    
    echo "Step 6: Configuration saved. Exporting file..."
    
    # Copy to the parent directory (workspace root) for easy access
    cp .config ../"$OUTPUT_FILENAME"
    
    echo "--------------------------------------------------------"
    echo "✅ SUCCESS!"
    echo "Your configuration file is: $OUTPUT_FILENAME"
    echo "Look at the file explorer on the left, right-click the file,"
    echo "and select 'Download' to save it to your local computer."
    echo "--------------------------------------------------------"
else
    echo "❌ Error: .config file was not generated. Did you save before exiting?"
fi
