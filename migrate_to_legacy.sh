#!/bin/bash
#
# Migrate from KernelSU-Next (next) to Legacy Branch
# For kernel 4.14.x compatibility
# Author: Mryassinov
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Migrate to KernelSU-Next Legacy Branch                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"

# Check if we're in kernel directory
if [ ! -f "Makefile" ]; then
    print_error "Please run this script from the kernel root directory"
    exit 1
fi

KERNEL_VERSION=$(make kernelversion 2>/dev/null || echo "unknown")
print_info "Current kernel version: ${KERNEL_VERSION}"

# Check current KernelSU setup
if [ ! -d "KernelSU-Next" ]; then
    print_error "KernelSU-Next not found. Run setup_kernelsu_legacy.sh instead"
    exit 1
fi

print_warning "This will remove your current KernelSU-Next and reinstall legacy branch"
print_warning "Any local modifications to KernelSU-Next will be lost"
echo ""
read -p "Continue? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Migration cancelled"
    exit 0
fi

# Step 1: Clean current installation
print_info "Removing current KernelSU-Next installation..."

# Remove KernelSU-Next directory
if [ -d "KernelSU-Next" ]; then
    rm -rf KernelSU-Next
    print_success "Removed KernelSU-Next directory"
fi

# Remove drivers/kernelsu (might be symlink or directory)
if [ -L "drivers/kernelsu" ]; then
    rm drivers/kernelsu
    print_success "Removed drivers/kernelsu symlink"
elif [ -d "drivers/kernelsu" ]; then
    rm -rf drivers/kernelsu
    print_success "Removed drivers/kernelsu directory"
fi

# Step 2: Clean build artifacts
print_info "Cleaning build artifacts..."
rm -rf out
rm -f *.zip

# Step 3: Install legacy branch
print_info "Installing KernelSU-Next legacy branch..."
echo ""

curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy

if [ $? -ne 0 ]; then
    print_error "Failed to install KernelSU-Next legacy!"
    exit 1
fi

print_success "KernelSU-Next legacy installed!"

# Step 4: Update defconfig for all supported devices
print_info "Updating defconfigs..."

DEVICES=("sweet" "tucana" "toco" "phoenix" "davinci")
CONFIGS_UPDATED=0

for device in "${DEVICES[@]}"; do
    DEFCONFIG="arch/arm64/configs/${device}_defconfig"
    
    if [ ! -f "$DEFCONFIG" ]; then
        print_warning "Defconfig not found: ${device}_defconfig"
        continue
    fi
    
    print_info "Updating ${device}_defconfig..."
    
    # Required configs
    REQUIRED_CONFIGS=(
        "CONFIG_KPROBES=y"
        "CONFIG_KPROBE_EVENTS=y"
        "CONFIG_KSU_KPROBE_HOOKS=y"
        "CONFIG_KSU=y"
    )
    
    for config in "${REQUIRED_CONFIGS[@]}"; do
        CONFIG_NAME=$(echo "$config" | cut -d'=' -f1)
        
        if grep -q "^${CONFIG_NAME}=" "$DEFCONFIG"; then
            sed -i "s/^${CONFIG_NAME}=.*/${config}/" "$DEFCONFIG"
        elif grep -q "^# ${CONFIG_NAME} is not set" "$DEFCONFIG"; then
            sed -i "s/^# ${CONFIG_NAME} is not set/${config}/" "$DEFCONFIG"
        else
            echo "$config" >> "$DEFCONFIG"
        fi
    done
    
    print_success "Updated ${device}_defconfig"
    CONFIGS_UPDATED=$((CONFIGS_UPDATED + 1))
done

# Step 5: Verify installation
echo ""
print_info "Verifying installation..."

ERRORS=0

if [ ! -d "KernelSU-Next" ]; then
    print_error "✗ KernelSU-Next directory missing"
    ERRORS=$((ERRORS + 1))
else
    print_success "✓ KernelSU-Next directory exists"
fi

if [ ! -L "drivers/kernelsu" ] && [ ! -d "drivers/kernelsu" ]; then
    print_error "✗ drivers/kernelsu missing"
    ERRORS=$((ERRORS + 1))
else
    print_success "✓ drivers/kernelsu exists"
fi

if [ ! -f "drivers/kernelsu/ksu.c" ] && [ ! -f "KernelSU-Next/kernel/ksu.c" ]; then
    print_error "✗ KernelSU source files missing"
    ERRORS=$((ERRORS + 1))
else
    print_success "✓ KernelSU source files found"
fi

# Check KernelSU branch/version
if [ -d "KernelSU-Next/.git" ]; then
    cd KernelSU-Next
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    cd ..
    print_info "KernelSU-Next branch: ${BRANCH}"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Migration Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"
    
    print_info "Summary:"
    echo "  ✓ Removed old KernelSU-Next (next branch)"
    echo "  ✓ Installed KernelSU-Next legacy branch"
    echo "  ✓ Updated ${CONFIGS_UPDATED} defconfig(s)"
    echo "  ✓ Configured kprobes hooks"
    echo ""
    
    print_info "What changed:"
    echo "  - Branch: next → legacy"
    echo "  - Compatible: kernel 4.4 - 6.12"
    echo "  - Hook Mode: kprobes (non-intrusive)"
    echo "  - Version: Mix of v1.1.1 and v3.0.0"
    echo ""
    
    print_info "Next steps:"
    echo "  1. Review changes:  git status"
    echo "  2. Test build:      ./kernel_build_script.sh -c"
    echo "  3. If successful:   git add . && git commit"
    echo ""
    
    # Show what changed
    print_info "Changed files:"
    git status --short 2>/dev/null | head -20 || ls -la KernelSU-Next drivers/kernelsu 2>/dev/null
    
    echo ""
    read -p "Build kernel now to test? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        if [ -f "kernel_build_script.sh" ]; then
            ./kernel_build_script.sh -c
        elif [ -f "build.sh" ]; then
            ./build.sh -c
        else
            print_warning "No build script found. Build manually with: make"
        fi
    fi
else
    print_error "Migration completed with ${ERRORS} error(s)"
    print_warning "Please review and fix the errors above"
    exit 1
fi
