#!/bin/bash

# KernelSU Kernel Verification Script
# Run this before flashing your kernel

echo "============================================"
echo "  KernelSU Kernel Verification Script"
echo "============================================"
echo ""

KERNEL_DIR="$HOME/kernel_splidder"
KERNEL_IMAGE="$KERNEL_DIR/out/arch/arm64/boot/Image.gz"
KERNEL_RAW="$KERNEL_DIR/out/arch/arm64/boot/Image"
ZIP_FILE="$KERNEL_DIR/splidder-sweet-20251107-2022.zip"

cd "$KERNEL_DIR" || exit 1

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Test 1: Check if kernel image exists
echo "[1/10] Checking kernel image..."
if [ -f "$KERNEL_IMAGE" ]; then
    pass "Kernel image found: $KERNEL_IMAGE"
    KERNEL_SIZE=$(du -h "$KERNEL_IMAGE" | cut -f1)
    echo "      Size: $KERNEL_SIZE"
else
    fail "Kernel image not found!"
    exit 1
fi
echo ""

# Test 2: Check for KernelSU strings
echo "[2/10] Checking for KernelSU signatures..."
KSU_STRINGS=$(strings "$KERNEL_RAW" 2>/dev/null | grep -i "kernelsu" | wc -l)
if [ "$KSU_STRINGS" -gt 0 ]; then
    pass "Found $KSU_STRINGS KernelSU references in kernel"
    echo "      Sample strings:"
    strings "$KERNEL_RAW" 2>/dev/null | grep -i "kernelsu" | head -3 | sed 's/^/      - /'
else
    fail "No KernelSU strings found in kernel!"
    exit 1
fi
echo ""

# Test 3: Check CONFIG_KSU
echo "[3/10] Checking kernel configuration..."
if grep -q "CONFIG_KSU=y" out/.config 2>/dev/null; then
    pass "CONFIG_KSU is enabled"
else
    fail "CONFIG_KSU is not enabled in config!"
fi
echo ""

# Test 4: Check build log for KernelSU compilation
echo "[4/10] Checking build log for KernelSU modules..."
if [ -f "build.log" ]; then
    KSU_MODULES=$(grep -c "CC.*kernelsu" build.log)
    if [ "$KSU_MODULES" -gt 0 ]; then
        pass "Found $KSU_MODULES KernelSU modules compiled"
    else
        warn "No KernelSU compilation found in build.log"
    fi
else
    warn "build.log not found, skipping this check"
fi
echo ""

# Test 5: Check for compilation errors
echo "[5/10] Checking for build errors..."
if [ -f "build.log" ]; then
    ERRORS=$(grep -i "error:" build.log | grep -v "0 errors" | wc -l)
    if [ "$ERRORS" -eq 0 ]; then
        pass "No compilation errors found"
    else
        fail "Found $ERRORS compilation errors!"
        echo "      Last 3 errors:"
        grep -i "error:" build.log | tail -3 | sed 's/^/      /'
    fi
else
    warn "build.log not found, cannot check for errors"
fi
echo ""

# Test 6: Check ZIP file
echo "[6/10] Checking flashable ZIP..."
if [ -f "$ZIP_FILE" ]; then
    pass "ZIP file found: $(basename $ZIP_FILE)"
    ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
    echo "      Size: $ZIP_SIZE"
    echo "      Contents:"
    unzip -l "$ZIP_FILE" | grep -E "Image.gz|dtb|dtbo|anykernel.sh" | sed 's/^/      /'
else
    fail "ZIP file not found!"
fi
echo ""

# Test 7: Check kernel version
echo "[7/10] Checking kernel version..."
KERNEL_VERSION=$(strings "$KERNEL_RAW" 2>/dev/null | grep "Linux version" | head -1)
if [ -n "$KERNEL_VERSION" ]; then
    pass "Kernel version found"
    echo "      $KERNEL_VERSION"
else
    warn "Could not extract kernel version"
fi
echo ""

# Test 8: Check for unresolved symbols
echo "[8/10] Checking for unresolved symbols..."
if [ -f "build.log" ]; then
    UNRESOLVED=$(grep -i "undefined\|unresolved" build.log | grep -v "CONFIG" | wc -l)
    if [ "$UNRESOLVED" -eq 0 ]; then
        pass "No unresolved symbols"
    else
        warn "Found $UNRESOLVED potential issues"
        grep -i "undefined\|unresolved" build.log | head -3 | sed 's/^/      /'
    fi
else
    warn "build.log not found, cannot check symbols"
fi
echo ""

# Test 9: Check AnyKernel3 configuration
echo "[9/10] Checking AnyKernel3 script..."
if [ -f "AnyKernel3/anykernel.sh" ]; then
    if grep -qi "sweet" AnyKernel3/anykernel.sh; then
        pass "AnyKernel3 configured for sweet device"
    else
        warn "Device name 'sweet' not found in AnyKernel3 script"
    fi
else
    warn "AnyKernel3 script not found"
fi
echo ""

# Test 10: Check DTB/DTBO
echo "[10/10] Checking device tree files..."
if [ -f "AnyKernel3/dtb.img" ]; then
    pass "DTB file found ($(du -h AnyKernel3/dtb.img | cut -f1))"
else
    warn "DTB file not found"
fi
if [ -f "AnyKernel3/dtbo.img" ]; then
    pass "DTBO file found ($(du -h AnyKernel3/dtbo.img | cut -f1))"
else
    warn "DTBO file not found"
fi
echo ""

# Summary
echo "============================================"
echo "  Verification Summary"
echo "============================================"
echo ""

# Count checks
TOTAL_CHECKS=10
PASSED_CHECKS=$(grep -c "✓" /tmp/ksu_verify_$$.tmp 2>/dev/null || echo "0")

echo "Kernel Image: $KERNEL_IMAGE"
echo "Kernel Size:  $KERNEL_SIZE"
echo "ZIP File:     $(basename $ZIP_FILE)"
echo "ZIP Size:     $ZIP_SIZE"
echo ""

if [ -f "$KERNEL_IMAGE" ] && [ "$KSU_STRINGS" -gt 0 ]; then
    pass "Kernel appears to be properly built with KernelSU"
    echo ""
    echo -e "${GREEN}Ready to flash!${NC}"
    echo ""
    echo "Flashing instructions:"
    echo "1. Backup your current boot.img"
    echo "2. Copy ZIP to phone: adb push $ZIP_FILE /sdcard/"
    echo "3. Boot to recovery (TWRP/OrangeFox)"
    echo "4. Flash the ZIP"
    echo "5. Reboot and install KernelSU Manager v0.9.5"
else
    fail "Kernel verification failed!"
    echo ""
    echo "Please review the errors above before flashing."
    exit 1
fi

echo ""
echo "============================================"
