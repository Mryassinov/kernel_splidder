#!/bin/bash
# Quick Kernel Personalization for Mryassinov
# Run from: ~/kernel_xiaomi_sm6150

set -e

echo "╔════════════════════════════════════════╗"
echo "║  Mryassinov Kernel Personalization    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 1. Add custom version to defconfig files
echo "[1/5] Updating defconfig files with custom version..."
DEFCONFIG_FILES=$(find arch/arm64/configs -name "*defconfig" -type f)
for file in $DEFCONFIG_FILES; do
    if grep -q "CONFIG_LOCALVERSION=" "$file"; then
        sed -i 's/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="-Mryassinov-a16"/' "$file"
    else
        echo 'CONFIG_LOCALVERSION="-Mryassinov-a16"' >> "$file"
    fi
    echo "  ✓ Updated: $(basename $file)"
done

# 2. Update or create README
echo ""
echo "[2/5] Updating README..."
if [ -f README.md ]; then
    cat >> README.md << 'EOF'

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
EOF
    echo "  ✓ README.md updated"
else
    cat > README.md << 'EOF'
# Xiaomi SM6150 Kernel - Modified by Mryassinov

Custom kernel for Xiaomi SM6150 devices.

**Original Source:** [TheHewra/kernel_xiaomi_sm6150](https://github.com/TheHewra/kernel_xiaomi_sm6150)

## Building
```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-android-
make vendor/sm6150-perf_defconfig
make -j$(nproc)
```
EOF
    echo "  ✓ README.md created"
fi

# 3. Create MODIFICATIONS file
echo ""
echo "[3/5] Creating MODIFICATIONS.md..."
cat > MODIFICATIONS.md << EOF
# Kernel Modifications Log

**Maintainer:** Mryassinov  
**Repository:** https://github.com/Mryassinov/kernel_splidder  
**Base:** TheHewra's kernel_xiaomi_sm6150 (sixteen branch)  
**Date:** $(date +"%Y-%m-%d")

## Changes Made

### Version Identification
- Added custom \`CONFIG_LOCALVERSION="-Mryassinov-a16"\` to all defconfig files
- Kernel will identify as: \`Linux version X.X.X-Mryassinov-a16\`

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
EOF
echo "  ✓ MODIFICATIONS.md created"

# 4. Create build script
echo ""
echo "[4/5] Creating build.sh..."
cat > build.sh << 'EOF'
#!/bin/bash

# Mryassinov Kernel Build Script
# For Xiaomi SM6150 devices

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔════════════════════════════════════════╗"
echo "║   Mryassinov Kernel Build Script      ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Setup environment
export ARCH=arm64
export SUBARCH=arm64

# Check toolchain
if [ -z "$CROSS_COMPILE" ]; then
    echo -e "${YELLOW}⚠ CROSS_COMPILE not set${NC}"
    echo "Set it with: export CROSS_COMPILE=aarch64-linux-android-"
    exit 1
fi

# Select defconfig
DEFCONFIG=${1:-vendor/sm6150-perf_defconfig}
echo -e "${GREEN}Using defconfig: $DEFCONFIG${NC}"

# Clean (optional)
if [ "$2" == "clean" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    make clean && make mrproper
fi

# Configure
echo -e "${GREEN}Configuring kernel...${NC}"
make $DEFCONFIG
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Configuration failed!${NC}"
    exit 1
fi

# Build
echo -e "${GREEN}Building kernel with $(nproc) threads...${NC}"
START=$(date +%s)

make -j$(nproc)

if [ $? -eq 0 ]; then
    END=$(date +%s)
    ELAPSED=$((END - START))
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Build Successful! ✓             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo -e "Build time: ${ELAPSED}s"
    echo ""
    echo "Kernel images:"
    find arch/arm64/boot -name "Image*" -type f
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi
EOF
chmod +x build.sh
echo "  ✓ build.sh created and made executable"

# 5. Stage changes
echo ""
echo "[5/5] Staging changes..."
git add README.md MODIFICATIONS.md build.sh
git add arch/arm64/configs/

echo ""
echo "╔════════════════════════════════════════╗"
echo "║          Setup Complete! ✓             ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📊 Changes staged:"
git status --short
echo ""
echo "📝 Next steps:"
echo "  1. Review changes:  git diff --cached"
echo "  2. Commit:          git commit -m 'Custom modifications by Mryassinov'"
echo "  3. Push:            git push -u origin mryassinov-modifications"
echo "  4. Build kernel:    ./build.sh"
echo ""
