#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Kali NetHunter Kernel Builder              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

SECONDS=0 # builtin bash timer
DEVICE="sweet"
ZIPNAME="NetHunter-${DEVICE}-$(date '+%Y%m%d-%H%M').zip"

# Export build variables (same as original build.sh)
export ARCH=arm64
export KBUILD_BUILD_USER="nethunter"
export KBUILD_BUILD_HOST="kali"

# Use the same Clang toolchain path
export PATH="$HOME/evo16/prebuilts/clang/host/linux-x86/clang-r547379/bin/:$PATH"

# Kernel config
DEFCONFIG="sweet_defconfig"
THREADS=$(nproc)

echo -e "${YELLOW}Configuration:${NC}"
echo "  • Device: Sweet (Redmi Note 10 Pro)"
echo "  • Defconfig: $DEFCONFIG"
echo "  • CPU Threads: $THREADS"
echo "  • Compiler: Clang LLVM"
echo "  • Architecture: arm64"
echo "  • Output: out/"
echo ""

# Clean previous build (optional)
if [[ $1 = "-c" || $1 = "--clean" ]]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf out
    echo -e "${GREEN}✓ Clean completed${NC}"
    echo ""
fi

# Generate config
echo -e "${YELLOW}[1/3] Generating defconfig...${NC}"
make O=out ARCH=arm64 ${DEFCONFIG} 2>&1 | grep -v "warning: override"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to generate defconfig!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Defconfig generated${NC}"
echo ""

# Build kernel
echo -e "${YELLOW}[2/3] Building kernel image...${NC}"
echo -e "${BLUE}This may take 10-30 minutes depending on your CPU...${NC}"
echo ""

make -j${THREADS} \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee build.log

BUILD_STATUS=${PIPESTATUS[0]}

kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

echo ""
echo -e "${YELLOW}[3/3] Finalizing...${NC}"
echo ""

if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ] || [ ! -f "$dtb" ]; then
    echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║            BUILD FAILED! ✗                     ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Check build.log for errors${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           BUILD SUCCESSFUL! ✓                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

MINUTES=$((SECONDS / 60))
SECS=$((SECONDS % 60))

echo -e "${YELLOW}Build Details:${NC}"
echo -e "  • Time taken: ${GREEN}${MINUTES}m ${SECS}s${NC}"

# Show kernel image info
if [ -f "$kernel" ]; then
    SIZE=$(du -h "$kernel" | cut -f1)
    echo -e "  • Kernel: ${GREEN}${kernel}${NC} (${SIZE})"
fi
if [ -f "$dtbo" ]; then
    SIZE=$(du -h "$dtbo" | cut -f1)
    echo -e "  • DTBO: ${GREEN}${dtbo}${NC} (${SIZE})"
fi
if [ -f "$dtb" ]; then
    SIZE=$(du -h "$dtb" | cut -f1)
    echo -e "  • DTB: ${GREEN}${dtb}${NC} (${SIZE})"
fi

echo ""
echo -e "${YELLOW}Creating flashable ZIP...${NC}"

# Clone AnyKernel3 if not exists
if [ ! -d "AnyKernel3" ]; then
    if ! git clone -q https://github.com/mikoker/AnyKernel3 -b master AnyKernel3; then
        echo -e "${RED}Couldn't clone AnyKernel3! Aborting...${NC}"
        exit 1
    fi
fi

# Modify anykernel.sh for NetHunter
sed -i "s/device\.name1=.*/device.name1=${DEVICE}/" AnyKernel3/anykernel.sh
sed -i "s/device\.name2=.*/device.name2=${DEVICE}in/" AnyKernel3/anykernel.sh
sed -i "s/kernel\.string=.*/kernel.string=NetHunter Kernel by nethunter @ $(date '+%Y-%m-%d')/" AnyKernel3/anykernel.sh

# Copy kernel files
cp $kernel AnyKernel3/
cp $dtbo AnyKernel3/
cp $dtb AnyKernel3/

# Create ZIP
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder 2>&1 | grep -v "adding:"
cd ..

# Cleanup
rm -rf AnyKernel3

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          FLASHABLE ZIP CREATED! ✓              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Flashable ZIP:${NC} ${GREEN}${ZIPNAME}${NC}"
echo ""
echo -e "${YELLOW}Installation:${NC}"
echo "  1. Copy ZIP to your device"
echo "  2. Boot to TWRP/OrangeFox recovery"
echo "  3. Flash the ZIP"
echo "  4. Reboot and enjoy NetHunter!"
echo ""
