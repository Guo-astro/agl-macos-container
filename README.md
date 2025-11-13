# AGL Development Environment for macOS

A Docker-based development environment for building Automotive Grade Linux (AGL) and Yocto Project images on macOS. This container includes all necessary tools and libraries for AGL development, with support for both Qt5 and Qt6.

[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![AGL](https://img.shields.io/badge/AGL-Ready-green.svg)](https://www.automotivelinux.org/)
[![Yocto](https://img.shields.io/badge/Yocto-Compatible-orange.svg)](https://www.yoctoproject.org/)

> **Blog Reference**: This setup is based on the detailed guide at [Building AGL Development Environment on Mac (2025)](https://goastro.website/blog/building-agl-dev-env-mac-1-build-yocto-using-docker-2025/)

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
- [Usage](#-usage)
- [What's Included](#-whats-included)
- [Verification](#-verification)
- [Development Workflow](#-development-workflow)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

- **Complete AGL Development Stack**: All libraries and tools needed for Automotive Grade Linux development
- **Dual Qt Support**: Both Qt5 (5.15.3) and Qt6 (6.2.4) for maximum compatibility
- **Persistent Workspace**: Docker volume-based storage that persists across container restarts
- **Finder Integration**: Access workspace files directly from macOS Finder via Samba
- **Pre-configured Environment**: Ready to build Yocto/Poky and AGL images out of the box
- **Optimized for macOS**: Specifically designed for Apple Silicon and Intel Macs

## 🔧 Prerequisites

### Required

- **macOS**: Monterey (12.0) or later recommended
- **Docker Desktop for Mac**: Version 4.0 or later
  - [Download Docker Desktop](https://docs.docker.com/docker-for-mac/)
  - Ensure Docker is running before proceeding

### System Recommendations

- **RAM**: 8GB minimum, 16GB+ recommended for building AGL images
- **Disk Space**: 50GB+ free space for builds
- **CPU**: Multi-core processor recommended (builds are CPU-intensive)

## 🚀 Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/Guo-astro/agl-macos-container.git
cd agl-macos-container

# 2. Build the Docker image
docker build --build-arg BASE_DISTRO=ubuntu-22.04 -t agl-poky-dev:latest .

# 3. Create and setup workspace volume
docker volume create --name myvolume
docker run -it --rm -v myvolume:/workdir busybox chown -R 1000:1000 /workdir

# 4. Start the development container
docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir

# 5. Inside container: Clone Poky and start building
cd /workdir
git clone git://git.yoctoproject.org/poky
cd poky
source oe-init-build-env
bitbake core-image-minimal
```

## 📖 Detailed Setup

### Step 1: Install Docker Desktop

1. Download and install [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/)
2. Start Docker Desktop
3. Verify installation:
   ```bash
   docker --version
   ```

### Step 2: Build the AGL Development Image

```bash
# Build with Ubuntu 22.04 base
docker build --build-arg BASE_DISTRO=ubuntu-22.04 -t agl-poky-dev:latest .
```

Build time: ~5-10 minutes depending on your internet connection.

### Step 3: Create Persistent Workspace Volume

```bash
# Create a named volume for persistent storage
docker volume create --name myvolume

# Set proper ownership (uid:gid 1000:1000)
docker run -it --rm -v myvolume:/workdir busybox chown -R 1000:1000 /workdir
```

### Step 4: Setup Samba for Finder Access (Optional but Recommended)

This allows you to edit files from macOS while builds run in the container.

```bash
# Create Samba container
docker create -t -p 445:445 --name samba -v myvolume:/workdir crops/samba

# Start Samba and create network alias
docker start samba && sudo ifconfig lo0 127.0.0.2 alias up
```

**Connect from Finder:**
1. Press `⌘ + K` in Finder
2. Enter: `smb://127.0.0.2/workdir`
3. Click "Connect" and select "Guest"

> **Note**: The `127.0.0.2` alias is removed on reboot. Re-run the command after restart, or create a LaunchDaemon for persistence.

### Step 5: Start Development Container

```bash
docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir
```

You should see a prompt like:
```
pokyuser@abc123def456:/workdir$
```

## 💻 Usage

### Building Yocto/Poky Images

```bash
# Inside the container
cd /workdir

# Clone Poky repository (first time only)
git clone git://git.yoctoproject.org/poky
cd poky

# Checkout desired branch (e.g., scarthgap)
git checkout -t origin/scarthgap -b my-scarthgap

# Initialize build environment
source oe-init-build-env

# Build a minimal image
bitbake core-image-minimal
```

### Building AGL Images

```bash
# Inside the container
cd /workdir
mkdir agl-workspace && cd agl-workspace

# Clone AGL layers
git clone https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl
git clone https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl-demo
git clone https://gerrit.automotivelinux.org/gerrit/AGL/meta-agl-devel

# Clone required Yocto layers
git clone git://git.yoctoproject.org/poky
git clone git://git.openembedded.org/meta-openembedded

# Follow AGL documentation for layer configuration and building
# See: https://docs.automotivelinux.org/
```

### Common BitBake Commands

```bash
# Build an image
bitbake <image-name>

# Clean a recipe
bitbake -c clean <recipe-name>

# Show available layers
bitbake-layers show-layers

# Add a layer
bitbake-layers add-layer /path/to/layer

# Run QEMU with built image
runqemu qemux86-64
```

## 📦 What's Included

### Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| BitBake | 2.12.1 | Yocto build engine |
| Git | 2.34.1 | Version control |
| Python | 3.10.12 | Build scripting |
| CMake | 3.22.1 | Build system |
| Meson | 0.61.2 | Build system |
| Ninja | Latest | Build executor |

### Graphics & UI Frameworks

| Library | Version | Purpose |
|---------|---------|---------|
| Qt5 | 5.15.3 | GUI framework (stable) |
| Qt6 | 6.2.4 | GUI framework (modern) |
| Wayland | 1.20.0 | Display protocol |
| Qt Wayland | Latest | Qt Wayland integration |

### Multimedia & Audio

| Library | Version | Purpose |
|---------|---------|---------|
| GStreamer | 1.20.3 | Multimedia framework |
| PipeWire | 0.3.48 | Audio/video routing |
| ALSA | Latest | Audio library |
| PulseAudio | Latest | Audio server |

### Automotive & IPC

| Library | Version | Purpose |
|---------|---------|---------|
| CAN Utils | Latest | Vehicle network tools |
| D-Bus | 1.12.20 | Inter-process communication |
| WebSockets | 4.0.20 | AGL Application Framework |

### Security & System

| Library | Version | Purpose |
|---------|---------|---------|
| AppArmor | 3.0.4 | Security framework |
| systemd | Latest | Service management |
| OpenSSL | Latest | Cryptography |

### Data Formats & Parsing

| Library | Version | Purpose |
|---------|---------|---------|
| JSON-C | 0.15 | JSON parsing |
| libjansson | Latest | JSON library |
| libxml2 | Latest | XML parsing |

### Testing & Documentation

- Google Test/Mock - Testing frameworks
- Doxygen - Documentation generation
- Graphviz - Visualization tools

## ✅ Verification

Run the automated verification script:

```bash
./verify-agl-setup.sh
```

Expected output:
```
=========================================
AGL Development Environment Verification
=========================================

✓ Test 1: Docker volume exists
✓ Test 2: Container can start and access volume
✓ Test 3: Essential development tools
✓ Test 4: AGL-specific libraries
✓ Test 5: Yocto/Poky environment

=========================================
✓ All verification tests passed!
=========================================
```

### Manual Verification

```bash
# Check Qt versions
docker run --rm agl-poky-dev:latest -- qmake --version
docker run --rm agl-poky-dev:latest -- qmake6 --version

# Check BitBake
docker run --rm -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir \
  -- /bin/bash -c "cd /workdir/poky && source oe-init-build-env && bitbake --version"

# Check library versions
docker run --rm agl-poky-dev:latest -- pkg-config --modversion \
  wayland-client gstreamer-1.0 dbus-1 libwebsockets
```

## 🔄 Development Workflow

### Starting Your Work Session

```bash
# 1. Start Samba (if using Finder integration)
docker start samba && sudo ifconfig lo0 127.0.0.2 alias up

# 2. Start development container
docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir

# 3. Navigate to your project
cd /workdir/poky  # or your AGL workspace

# 4. Initialize build environment
source oe-init-build-env

# 5. Start building
bitbake <your-target>
```

### Editing Files

- **Option 1**: Use Finder (via Samba) and your favorite macOS editor
- **Option 2**: Use CLI editors inside the container (vim, nano included)
- **Option 3**: Use VS Code Remote Containers extension

### Exiting and Resuming

```bash
# Exit container (your work is saved in the volume)
exit

# Resume later - just restart the container
docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir
# Your files and build cache are preserved!
```

## 🐛 Troubleshooting

### Platform Warning on Apple Silicon

```
WARNING: The requested image's platform (linux/amd64) does not match 
the detected host platform (linux/arm64/v8)
```

**Solution**: This is expected. The container runs via emulation and works correctly.

### Samba Connection Issues

**Problem**: Cannot connect to `smb://127.0.0.2/workdir`

**Solutions**:
1. Verify Samba is running: `docker ps | grep samba`
2. Check alias exists: `ifconfig lo0 | grep 127.0.0.2`
3. Recreate alias: `sudo ifconfig lo0 127.0.0.2 alias up`
4. Try connecting as Guest (not with credentials)

### BitBake Command Not Found

**Problem**: `bitbake: command not found`

**Solution**: Source the environment setup:
```bash
cd /workdir/poky
source oe-init-build-env
```

### Disk Space Issues

**Problem**: Build fails with "No space left on device"

**Solutions**:
1. Check available space: `df -h`
2. Clean old builds: `bitbake -c cleansstate <recipe>`
3. Remove unused Docker resources: `docker system prune -a`
4. Increase Docker Desktop disk allocation in Settings

### Permission Issues

**Problem**: Cannot write to `/workdir`

**Solution**: Reset volume permissions:
```bash
docker run -it --rm -v myvolume:/workdir busybox chown -R 1000:1000 /workdir
```

### Build Failures Behind Corporate Firewall

**Problem**: Fetcher failures or Git timeouts

**Solutions**:
1. Configure proxy in `conf/local.conf`:
   ```bash
   http_proxy = "http://proxy.example.com:8080"
   https_proxy = "http://proxy.example.com:8080"
   ftp_proxy = "http://proxy.example.com:8080"
   ```
2. See [Yocto Proxy Documentation](https://wiki.yoctoproject.org/wiki/Working_Behind_a_Network_Proxy)

## 📚 Additional Resources

### Official Documentation

- [AGL Documentation](https://docs.automotivelinux.org/)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)
- [Qt6 Documentation](https://doc.qt.io/qt-6/)

### Related Blog Posts

- [Part 1: Build Yocto using Docker (This guide)](https://goastro.website/blog/building-agl-dev-env-mac-1-build-yocto-using-docker-2025/)
- [Part 2: Configure Poky Layers for AGL](https://goastro.website/blog/building-agl-dev-env-mac-2-configure-poky-layers-bitbake-agl)

### Community

- [AGL Mailing Lists](https://lists.automotivelinux.org/)
- [Yocto Project Mailing Lists](https://www.yoctoproject.org/community/mailing-lists/)
- [AGL Slack](https://automotivelinux.slack.com/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Reporting Issues

Please use the GitHub issue tracker to report bugs or request features. Include:
- Your macOS version
- Docker Desktop version
- Steps to reproduce the issue
- Relevant error messages

## 📄 License

This project inherits the license from the upstream `crops/poky` container.

See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Based on the [crops/poky](https://github.com/crops/poky-container) project
- Built for the [Automotive Grade Linux](https://www.automotivelinux.org/) community
- Inspired by the [Yocto Project](https://www.yoctoproject.org/)

---

**Maintained by**: [Guo-astro](https://github.com/Guo-astro)  
**Blog**: [goastro.website](https://goastro.website)  
**Last Updated**: November 13, 2025

## 📦 Docker Hub publishing (CI)

This repository includes a GitHub Actions workflow that can build and publish the Docker image to Docker Hub when changes are pushed to the `main` branch.

To enable automatic publishing:

1. Create a Docker Hub repository (for example `DOCKERHUB_USERNAME/agl-poky-dev`).
2. In GitHub, go to Settings → Secrets and variables → Actions and add two repository secrets:
  - `DOCKERHUB_USERNAME` — your Docker Hub username
  - `DOCKERHUB_TOKEN` — a Docker Hub access token (recommended) or your password
3. Push to the `main` branch. The workflow at `.github/workflows/docker-publish.yml` will build multi-arch images (linux/amd64, linux/arm64) and push them to Docker Hub.

If you prefer to publish manually from your machine, run:

```bash
# Build locally and tag for Docker Hub
docker build --build-arg BASE_DISTRO=ubuntu-22.04 -t <DOCKERHUB_USERNAME>/agl-poky-dev:latest .

# Login to Docker Hub
docker login -u <DOCKERHUB_USERNAME>

# Push image
docker push <DOCKERHUB_USERNAME>/agl-poky-dev:latest
```

Replace `<DOCKERHUB_USERNAME>` with your Docker Hub username. The automated workflow uses these secrets to authenticate and push the image on every push to `main`.

---

### Quick Reference Card

```bash
# Build image
docker build --build-arg BASE_DISTRO=ubuntu-22.04 -t agl-poky-dev:latest .

# Setup workspace
docker volume create --name myvolume
docker run -it --rm -v myvolume:/workdir busybox chown -R 1000:1000 /workdir

# Start Samba (optional)
docker create -t -p 445:445 --name samba -v myvolume:/workdir crops/samba
docker start samba && sudo ifconfig lo0 127.0.0.2 alias up

# Start container
docker run --rm -it -v myvolume:/workdir agl-poky-dev:latest --workdir=/workdir

# Inside container
source oe-init-build-env
bitbake core-image-minimal
```

---

**Happy Building! 🚗💨**
