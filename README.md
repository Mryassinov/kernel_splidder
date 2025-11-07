# Kernel for Xiaomi SM6150 Devices
Modified and maintained by Mryassinov
Based on TheHewra's work

Original repository: https://github.com/TheHewra/kernel_xiaomi_sm6150

---

## 🔧 Modified by Mryassinov

This is a customized version of the Xiaomi SM6150 kernel.

**Original Repository:** [TheHewra/kernel_xiaomi_sm6150](https://github.com/TheHewra/kernel_xiaomi_sm6150)  
**Modified By:** Mryassinov  
**Branch:** a16

### 📋 Quick Build
```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-android-
make vendor/sm6150-perf_defconfig
make -j$(nproc)
```

### 📝 Changes
- Custom kernel version identifier
- Personal optimizations and configurations

For questions or issues, open an issue on this repository.
