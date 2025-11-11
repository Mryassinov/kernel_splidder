# Kernel Splidder with KernelSU-Next

Custom kernel for Xiaomi SM6150 devices with KernelSU-Next v1.1.1 integration.

## 📱 Supported Devices
- **Xiaomi Redmi Note 10 Pro (sweet)** - Fully tested ✅
- Other SM6150 devices: tucana, toco, phoenix, davinci

## ✨ Features
- 🔐 **KernelSU-Next v1.1.1** - Advanced kernel-based root solution
- 🎭 **SUSFS** - Hide root from detection (banking apps, games)
- 🧩 **Module System** - Magisk-compatible module support
- 🔄 **Zygisk** - ReZygisk v1.0.0 for advanced modifications
- 🛡️ **SELinux Enforcing** - Security maintained
- 📦 **Magic Mount** - Systemless modifications

## 📥 Installation

### Requirements
- Unlocked bootloader
- Custom recovery (TWRP/OrangeFox)
- Backup of current boot partition

### Steps
1. Download latest release: `splidder-ksun-sweet-*.zip`
2. Boot to recovery
3. Flash the zip
4. Wipe Dalvik/Cache
5. Reboot
6. Install KernelSU Manager from [releases](https://github.com/KernelSU-Next/KernelSU-Next/releases)

## 🔧 Build from Source
```bash
git clone https://github.com/Mryassinov/kernel_splidder.git -b a16-KSU-Next
cd kernel_splidder
git submodule update --init --recursive
./build.sh
# Enter: sweet
```

## 📊 Specifications
- **Kernel Version**: 4.14.356
- **KernelSU-Next**: v1.1.1 (12882)
- **Android**: 16 (API 36)
- **Architecture**: aarch64
- **Compiler**: Clang 18

## 🙏 Credits
- [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) - Root solution
- [TheHewra](https://github.com/TheHewra/kernel_xiaomi_sm6150) - Base kernel
- SUSFS by simonpunk
- ReZygisk implementation

## 📜 License
GPL-2.0

## 🐛 Issues
Report issues at: https://github.com/Mryassinov/kernel_splidder/issues

---
**Maintainer**: Mryassinov  
**Last Updated**: November 2025
