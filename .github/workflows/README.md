# GitHub Actions Workflows

This repository uses GitHub Actions for automated kernel builds.

## Available Workflows

### Build Kernel
[![Build Kernel](https://github.com/Mryassinov/kernel_splidder/actions/workflows/build-kernel.yml/badge.svg)](https://github.com/Mryassinov/kernel_splidder/actions/workflows/build-kernel.yml)

Automatically builds the kernel when:
- Code is pushed to `a16-KSU-Next` branch
- Pull request is created
- Manual trigger (with device selection)

### Manual Build
You can manually trigger a build from the [Actions tab](https://github.com/Mryassinov/kernel_splidder/actions/workflows/build-kernel.yml) and select the device.
