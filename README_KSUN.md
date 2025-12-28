# Kernel Splidder with KernelSU-Next v3.0.0

Modified Xiaomi SM6150 kernel with integrated KernelSU-Next v3.0.0 support.

## Features

- ✅ KernelSU-Next v3.0.0 (build 32927)
- ✅ Kprobes hook mode (non-intrusive)
- ✅ Manager signature verification
- ✅ Full root management capabilities
- ✅ Module support
- ✅ SELinux policy management

## Device Support

- **Device**: Xiaomi Redmi Note 10 Pro (codename: sweet)
- **Chipset**: Qualcomm SM6150 (Snapdragon 732G)
- **Android Version**: Compatible with Android 11+

## Installation

### Prerequisites
- Unlocked bootloader
- Custom recovery (TWRP/OrangeFox recommended)
- Backup of current boot partition

### Steps
1. Download `splidder-sweet-YYYYMMDD-HHMM.zip` from releases
2. Boot into recovery mode
3. Flash the kernel zip
4. Reboot system
5. Install [KernelSU Manager](https://github.com/rsuntk/KernelSU-Next/releases) app
6. Verify installation in KernelSU Manager

## Building from Source
```bash
# Clone the repository
git clone -b KSUN-3.0.0 https://github.com/Mryassinov/kernel_splidder.git
cd kernel_splidder

# Initialize submodules
git submodule update --init --recursive

# Build the kernel
./build.sh

# Output will be in out/arch/arm64/boot/
```

## Technical Details

### KernelSU Integration
- **Version**: v3.0.0 (build 32927)
- **Hook Mode**: Kprobes
- **Manager Signature**: 79e590113c4c4c0c222978e413a5faa801666957b1212a328e46c00c69821bf7

### Modified Files
- `arch/arm64/configs/sweet_defconfig` - Device configuration
- `drivers/Kconfig` - KernelSU driver config
- `drivers/Makefile` - Build integration
- `fs/namespace.c` - Root namespace management
- `include/linux/seccomp.h` - Security headers

### Build Configuration
- Toolchain: Clang/GCC cross-compiler
- Architecture: ARM64
- Defconfig: sweet_defconfig

## Changelog

### v1.1-ksun3.0.0 (2024-12-28)
- Integrated KernelSU-Next v3.0.0
- Implemented kprobes hook mode
- Added manager signature verification
- Updated device configurations
- Optimized for SM6150 platform

## Known Issues

- None currently reported

## Support & Community

- **Issues**: [GitHub Issues](https://github.com/Mryassinov/kernel_splidder/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Mryassinov/kernel_splidder/discussions)

## Credits

- **KernelSU-Next**: [rsuntk/KernelSU-Next](https://github.com/rsuntk/KernelSU-Next)
- **Base Kernel**: [TheHewra/kernel_xiaomi_sm6150](https://github.com/TheHewra/kernel_xiaomi_sm6150)
- **Integration & Maintenance**: Mryassinov

## License

This project follows the same license as the Linux kernel (GPL-2.0).

## Disclaimer

⚠️ **Warning**: Flashing custom kernels may void your warranty and can brick your device if done incorrectly. Proceed at your own risk. Always maintain backups.

