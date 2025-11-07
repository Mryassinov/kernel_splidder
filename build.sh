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
