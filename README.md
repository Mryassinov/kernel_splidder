# Kernel Splidder

[![Build Kernel](https://github.com/Mryassinov/kernel_splidder/actions/workflows/build-kernel.yml/badge.svg)](https://github.com/Mryassinov/kernel_splidder/actions/workflows/build-kernel.yml)
[![Latest Release](https://img.shields.io/github/v/release/Mryassinov/kernel_splidder)](https://github.com/Mryassinov/kernel_splidder/releases/latest)
[![License](https://img.shields.io/github/license/Mryassinov/kernel_splidder)](LICENSE)

Modified Xiaomi SM6150 kernel with KernelSU-Next v1.1.1 integration.

## 🌟 Features

- **KernelSU-Next v1.1.1** - Advanced root management
- **SUSFS** - Root hiding for banking apps and games
- **Zygisk** - ReZygisk support
- **SELinux Enforcing** - Security maintained
- **Automated Builds** - CI/CD with GitHub Actions

## 📱 Supported Devices

- Xiaomi Redmi Note 10 Pro (sweet) ✅ Tested
- Xiaomi Mi 10 Lite (toco)
- Xiaomi Mi Note 10 Lite (tucana)
- Xiaomi Mi 9 Lite (phoenix)
- Xiaomi Mi 9 (davinci)

## 📥 Download

Get the latest build from [Releases](https://github.com/Mryassinov/kernel_splidder/releases/latest)

Or download build artifacts from [Actions](https://github.com/Mryassinov/kernel_splidder/actions)

## 🔧 Building

### Local Build
```bash
git clone https://github.com/Mryassinov/kernel_splidder.git -b a16-KSU-Next
cd kernel_splidder
git submodule update --init --recursive
./build.sh
```

### GitHub Actions
Builds are triggered automatically on push, or you can trigger manually from the Actions tab.

## 📚 Documentation

- [Installation Guide](docs/INSTALL.md)
- [Building Guide](docs/BUILD.md)
- [KernelSU-Next Features](README_KSUN.md)

## 🙏 Credits

- [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)
- [TheHewra](https://github.com/TheHewra/kernel_xiaomi_sm6150)
- SUSFS by simonpunk

## 📜 License

GPL-2.0
# Test change
