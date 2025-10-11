#!/bin/bash
set -e

VERSION="${VERSION:-2025.10.05}"
INSTALL_METHOD="${INSTALLMETHOD:-appimage}"

echo "Installing OpenSCAD snapshot ${VERSION} using method: ${INSTALL_METHOD}"

if [ "${INSTALL_METHOD}" = "appimage" ]; then
    # Install via AppImage (specific version)
    echo "Installing via AppImage..."

    # Detect architecture
    ARCH=$(uname -m)
    echo "Detected architecture: ${ARCH}"

    # Install required packages
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        wget \
        fuse \
        libfuse2 \
        libglu1-mesa \
        libgl1 \
        libxrender1 \
        libxi6 \
        libxkbcommon-x11-0 \
        libdbus-1-3 \
        file

    # Download AppImage
    APPIMAGE_BASE_URL="https://files.openscad.org/snapshots"

    # Set filename patterns based on architecture
    if [ "${ARCH}" = "x86_64" ]; then
    # For x86_64 (Intel/AMD)
        ARCH_PATTERNS=("ai28033-x86_64" "x86_64" "ai-x86_64")
    elif [ "${ARCH}" = "aarch64" ]; then
    # For ARM 64-bit
        ARCH_PATTERNS=("ai-aarch64" "aarch64")
    else
        echo "ERROR: Unsupported architecture: ${ARCH}"
        echo "Supported architectures: x86_64, aarch64"
        exit 1
    fi

    # Search for an AppImage filename that matches the requested version
    for build_suffix in "${ARCH_PATTERNS[@]}"; do
        APPIMAGE_URL="${APPIMAGE_BASE_URL}/OpenSCAD-${VERSION}.${build_suffix}.AppImage"
        echo "Trying: ${APPIMAGE_URL}"

        if wget --spider "${APPIMAGE_URL}" 2>/dev/null; then
            echo "Found AppImage at: ${APPIMAGE_URL}"
            wget -q -O /tmp/openscad.AppImage "${APPIMAGE_URL}"
            chmod +x /tmp/openscad.AppImage

            # Check if FUSE is available
            if fusermount -V &>/dev/null; then
                echo "FUSE is available, installing as AppImage..."
                mv /tmp/openscad.AppImage /usr/local/bin/openscad
            else
                echo "FUSE not available, extracting AppImage..."
                cd /tmp
                ./openscad.AppImage --appimage-extract >/dev/null 2>&1
                mv squashfs-root /opt/openscad

                # Create a wrapper script
                cat > /usr/local/bin/openscad << 'EOF'
#!/bin/bash
exec /opt/openscad/AppRun "$@"
EOF
                chmod +x /usr/local/bin/openscad
                rm /tmp/openscad.AppImage
            fi

            echo "OpenSCAD AppImage installed successfully!"
            break
        fi
    done

    if [ ! -f /usr/local/bin/openscad ]; then
        echo "ERROR: Could not find AppImage for version ${VERSION}"
        echo "Available snapshots can be found at: https://files.openscad.org/snapshots/"
        exit 1
    fi

elif [ "${INSTALL_METHOD}" = "apt-nightly" ]; then
    # Install via APT repository (latest nightly)
    echo "Installing via APT repository (latest nightly)..."

    # Add the OpenSCAD nightly repository
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget ca-certificates

    # Add GPG key
    wget -qO- https://files.openscad.org/OBS-Repository-Key.pub | \
        tee /etc/apt/trusted.gpg.d/obs-openscad-nightly.asc

    # Detect Ubuntu/Debian version
    . /etc/os-release
    if [ "${ID}" = "ubuntu" ]; then
        UBUNTU_VERSION=$(echo "${VERSION_ID}" | tr -d '.')
        echo "deb https://download.opensuse.org/repositories/home:/t-paul/xUbuntu_${VERSION_ID}/ ./" \
            > /etc/apt/sources.list.d/openscad-nightly.list
    elif [ "${ID}" = "debian" ]; then
        DEBIAN_VERSION="${VERSION_ID}"
        echo "deb https://download.opensuse.org/repositories/home:/t-paul/Debian_${DEBIAN_VERSION}/ ./" \
            > /etc/apt/sources.list.d/openscad-nightly.list
    fi

    # Install openscad-nightly
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y openscad-nightly

    # Create a symlink for the openscad command
    ln -sf /usr/bin/openscad-nightly /usr/local/bin/openscad

    echo "OpenSCAD nightly installed successfully!"
fi

# Cleanup
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

# Verify installation/version
echo "Verifying installation..."
openscad --version || echo "Note: Version check may fail in headless environment"

echo "OpenSCAD installation complete!"
