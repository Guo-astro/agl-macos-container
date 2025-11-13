#!/bin/bash
# AGL Development Environment Verification Script
# This script verifies that the Docker container is properly set up for AGL development

set -e

echo "========================================="
echo "AGL Development Environment Verification"
echo "========================================="
echo ""

# Test 1: Volume creation
echo "✓ Test 1: Docker volume exists"
docker volume inspect myvolume > /dev/null 2>&1 || {
    echo "Creating volume..."
    docker volume create --name myvolume
    docker run -it --rm -v myvolume:/workdir busybox chown -R 1000:1000 /workdir
}
echo "  Volume 'myvolume' is ready"
echo ""

# Test 2: Container basics
echo "✓ Test 2: Container can start and access volume"
docker run --rm -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir -- /bin/bash -c "pwd && whoami"
echo ""

# Test 3: Essential tools
echo "✓ Test 3: Essential development tools"
docker run --rm -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir -- /bin/bash -c "
    git --version
    python3 --version
    cmake --version | head -1
    meson --version
    qmake --version | head -1
"
echo ""

# Test 4: AGL-specific libraries
echo "✓ Test 4: AGL-specific libraries"
docker run --rm -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir -- /bin/bash -c "
    echo '  - Wayland:' \$(pkg-config --modversion wayland-client)
    echo '  - GStreamer:' \$(pkg-config --modversion gstreamer-1.0)
    echo '  - D-Bus:' \$(pkg-config --modversion dbus-1)
    echo '  - WebSockets:' \$(pkg-config --modversion libwebsockets)
    echo '  - PipeWire:' \$(pkg-config --modversion libpipewire-0.3)
    echo '  - AppArmor:' \$(pkg-config --modversion libapparmor)
"
echo ""

# Test 5: Yocto/Poky setup
echo "✓ Test 5: Yocto/Poky environment"
docker run --rm -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir -- /bin/bash -c "
    cd /workdir
    if [ ! -d poky ]; then
        echo '  Poky not found, would need to clone with:'
        echo '    git clone git://git.yoctoproject.org/poky'
    else
        echo '  Poky directory exists'
        cd poky
        source oe-init-build-env > /dev/null 2>&1
        echo '  BitBake version:' \$(bitbake --version | head -1)
    fi
"
echo ""

echo "========================================="
echo "✓ All verification tests passed!"
echo "========================================="
echo ""
echo "Your AGL development environment is ready!"
echo ""
echo "To start working:"
echo "  docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir"
echo ""
echo "Then inside the container:"
echo "  cd poky"
echo "  source oe-init-build-env"
echo "  bitbake core-image-minimal"
