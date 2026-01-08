#!/bin/bash
echo "╔════════════════════════════════════════╗"
echo "║      Kernel Build Test Suite           ║"
echo "╚════════════════════════════════════════╝"
echo ""

KERNEL_ZIP=$(ls -t builds/*.zip 2>/dev/null | head -1)

if [ -z "$KERNEL_ZIP" ]; then
    echo "✗ No kernel ZIP found"
    exit 1
fi

echo "Testing: $(basename $KERNEL_ZIP)"
echo ""

# Test 1: ZIP integrity
echo "[1/5] Checking ZIP integrity..."
if unzip -t "$KERNEL_ZIP" > /dev/null 2>&1; then
    echo "  ✓ ZIP is valid"
else
    echo "  ✗ ZIP is corrupted"
    exit 1
fi

# Test 2: Required files
echo "[2/5] Verifying required files..."
files=("Image.gz" "dtb.img" "dtbo.img" "anykernel.sh")
for file in "${files[@]}"; do
    if unzip -l "$KERNEL_ZIP" 2>/dev/null | grep -q "$file"; then
        echo "  ✓ $file present"
    else
        echo "  ! $file missing (may be normal)"
    fi
done

# Test 3: Checksums
echo "[3/5] Checking checksums..."
if [ -f "${KERNEL_ZIP}.md5" ]; then
    if (cd "$(dirname "$KERNEL_ZIP")" && md5sum -c "$(basename "${KERNEL_ZIP}.md5")" > /dev/null 2>&1); then
        echo "  ✓ MD5 verified"
    else
        echo "  ✗ MD5 mismatch"
    fi
else
    echo "  ! MD5 file not found"
fi

# Test 4: File size
echo "[4/5] Checking file sizes..."
SIZE=$(stat -c%s "$KERNEL_ZIP" 2>/dev/null || stat -f%z "$KERNEL_ZIP" 2>/dev/null)
SIZE_MB=$((SIZE / 1024 / 1024))
if [ $SIZE_MB -gt 10 ] && [ $SIZE_MB -lt 30 ]; then
    echo "  ✓ Size is normal: ${SIZE_MB}MB"
else
    echo "  ⚠ Unusual size: ${SIZE_MB}MB"
fi

# Test 5: Extract and verify Image.gz
echo "[5/5] Extracting and checking Image.gz..."
TEMP_DIR=$(mktemp -d)
if unzip -q "$KERNEL_ZIP" Image.gz -d "$TEMP_DIR" 2>/dev/null; then
    if [ -f "$TEMP_DIR/Image.gz" ]; then
        IMG_SIZE=$(stat -c%s "$TEMP_DIR/Image.gz" 2>/dev/null || stat -f%z "$TEMP_DIR/Image.gz" 2>/dev/null)
        echo "  ✓ Image.gz size: $((IMG_SIZE / 1024 / 1024))MB"
    else
        echo "  ✗ Cannot extract Image.gz"
    fi
else
    echo "  ✗ Failed to extract Image.gz"
fi
rm -rf "$TEMP_DIR"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║          Tests Complete!               ║"
echo "╚════════════════════════════════════════╝"
