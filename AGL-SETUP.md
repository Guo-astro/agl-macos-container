# AGL Development Environment Setup - Verified ✓

This document confirms that the Docker container has been successfully configured for AGL (Automotive Grade Linux) development.

## What Was Added

The Dockerfile has been enhanced with AGL-specific development dependencies:

### Graphics & Display Stack
- **Wayland** (v1.20.0) - Compositor protocol for AGL
- **Qt5** (v5.15.3) - GUI framework for AGL HMI development
  - qtbase5-dev
  - qtdeclarative5-dev
  - qtwayland5

### Multimedia & Audio
- **GStreamer** (v1.20.3) - Multimedia framework
- **PipeWire** (v0.3.48) - Audio/video routing
- **ALSA & PulseAudio** - Audio support
- **libgstreamer-plugins** - Base and bad plugin development libraries

### Automotive Communication
- **CAN bus utilities** (can-utils) - Vehicle network communication tools

### Security Frameworks
- **AppArmor** (v3.0.4) - Mandatory Access Control
- **libapparmor-dev** - Development headers

### IPC & Messaging
- **D-Bus** (v1.12.20) - Inter-process communication
- **WebSockets** (v4.0.20) - AGL Application Framework APIs
- **JSON-C** (v0.15) - JSON parsing for AGL APIs
- **libjansson** - Alternative JSON library

### Build Tools
- **CMake** (v3.22.1) - Build system
- **Meson** (v0.61.2) - Modern build system
- **Ninja** - Fast build executor

### Development Utilities
- **Google Test/Mock** - Testing frameworks
- **Doxygen & Graphviz** - Documentation generation
- **Python 3** (v3.10.12) - Scripting support
- **Git** (v2.34.1) - Version control

## Verification Results

All tests passed successfully! ✓

```bash
./verify-agl-setup.sh
```

### Test Results:
1. ✓ Docker volume creation and permissions
2. ✓ Container startup and workspace access
3. ✓ Essential development tools (git, python, cmake, meson, qmake)
4. ✓ AGL-specific libraries (Wayland, GStreamer, D-Bus, WebSockets, PipeWire, AppArmor)
5. ✓ Yocto/Poky environment (BitBake v2.12.1)

## Usage

### Build the Image

```bash
docker build --build-arg BASE_DISTRO=ubuntu-22.04 -t agl-poky-dev:latest .
```

### Setup (First Time)

Following the blog at https://goastro.website/blog/building-agl-dev-env-mac-1-build-yocto-using-docker-2025/

```bash
# Create volume
docker volume create --name myvolume

# Set permissions
docker run -it --rm -v myvolume:/workdir busybox chown -R 1000:1000 /workdir

# Start Samba (optional - for Finder access on Mac)
docker create -t -p 445:445 --name samba -v myvolume:/workdir crops/samba
docker start samba
sudo ifconfig lo0 127.0.0.2 alias up
# In Finder: Cmd+K, connect to smb://127.0.0.2/workdir
```

### Start Development Container

```bash
docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir
```

### Inside Container - Setup Yocto/Poky

```bash
# Clone Poky (first time only)
cd /workdir
git clone git://git.yoctoproject.org/poky
cd poky

# Checkout desired branch (e.g., scarthgap)
git checkout -t origin/scarthgap -b my-scarthgap

# Initialize build environment
source oe-init-build-env

# Start building
bitbake core-image-minimal
```

### For AGL Builds

To build actual AGL images, you'll need to:

1. Clone AGL meta layers:
```bash
cd /workdir
mkdir agl-workspace
cd agl-workspace

# Clone AGL meta layers
git clone https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl
git clone https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl-demo
git clone https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl-devel

# Clone additional required Yocto layers
git clone git://git.yoctoproject.org/poky
git clone git://git.openembedded.org/meta-openembedded
```

2. Follow AGL's official documentation for layer configuration and building.

## Platform Note

The container is built for `linux/amd64` platform. On Apple Silicon Macs (ARM64), you'll see a platform mismatch warning, but the container will still work through emulation.

## Files

- `Dockerfile` - Container definition with AGL dependencies
- `verify-agl-setup.sh` - Automated verification script
- `AGL-SETUP.md` - This documentation

## Next Steps

Refer to the blog series:
- Part 1: https://goastro.website/blog/building-agl-dev-env-mac-1-build-yocto-using-docker-2025/
- Part 2: Configure poky layers & bitbake for AGL

## Verified Components

| Component | Version | Purpose |
|-----------|---------|---------|
| Ubuntu Base | 22.04 | Operating system |
| BitBake | 2.12.1 | Yocto build tool |
| Wayland | 1.20.0 | Display protocol |
| Qt5 | 5.15.3 | GUI framework |
| GStreamer | 1.20.3 | Multimedia |
| PipeWire | 0.3.48 | Audio routing |
| D-Bus | 1.12.20 | IPC |
| WebSockets | 4.0.20 | AGL APIs |
| AppArmor | 3.0.4 | Security |
| CMake | 3.22.1 | Build system |
| Meson | 0.61.2 | Build system |
| Python | 3.10.12 | Scripting |
| Git | 2.34.1 | Version control |

---

**Status**: ✓ Verified and ready for AGL development (November 13, 2025)
