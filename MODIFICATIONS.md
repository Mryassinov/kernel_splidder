# Kernel Modifications Log

**Maintainer:** Mryassinov  
**Repository:** https://github.com/Mryassinov/kernel_splidder  
**Base:** TheHewra's kernel_xiaomi_sm6150 (sixteen branch)  
**Date:** 2025-11-07

## Changes Made

### Version Identification
- Added custom `CONFIG_LOCALVERSION="-Mryassinov-a16"` to all defconfig files
- Kernel will identify as: `Linux version X.X.X-Mryassinov-a16`

### Documentation
- Updated README with maintainer information
- Created this modifications log
- Added build script for easier compilation

### Planned Enhancements
- [ ] Performance optimizations
- [ ] Custom governor tweaks
- [ ] Device-specific improvements
- [ ] Additional driver support

## Build Environment
- Architecture: ARM64
- Toolchain: aarch64-linux-android-
- Target Devices: Xiaomi SM6150 based devices

## Credits
Original kernel by **TheHewra**: https://github.com/TheHewra/kernel_xiaomi_sm6150

## License
GPL v2 (same as Linux kernel)
