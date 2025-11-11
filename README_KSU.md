# Kernel Splidder with KernelSU

Modified Xiaomi SM6150 kernel with KernelSU v0.9.5 integration.

## Features
- KernelSU v0.9.5 (root solution)
- Safe Mode support (Volume Down during boot)
- Full syscall hooks integration
- Module umount support
- Terminal support

## Supported Devices
- Xiaomi Redmi Note 10 Pro (sweet)
- Other SM6150 devices (see build.sh)

## Building
```bash
./build.sh
# Enter device codename when prompted
```

## Installation
1. Boot to TWRP/OrangeFox recovery
2. Flash the generated zip: `splidder-ks-{device}-{date}.zip`
3. Reboot
4. Install KernelSU Manager v0.9.5

## KernelSU Manager
Download from: https://github.com/tiann/KernelSU/releases/tag/v0.9.5

## Credits
- Based on TheHewra's kernel
- KernelSU by tiann
- Maintained by Mryassinov
