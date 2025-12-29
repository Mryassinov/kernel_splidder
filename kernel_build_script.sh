#!/bin/bash
#
# Kernel Compilation Script with KernelSU Support
# Author: Mryassinov
# License: GPL-2.0
#

set -e  # Exit on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Start timer
SECONDS=0

# Configuration
KERNEL_VERSION="Splidder v1.1"
KERNELSU_VERSION="v3.0.0"
ALLOWED_CODENAMES=("sweet" "tucana" "toco" "phoenix" "davinci")
AK3_REPO="https://github.com/Mryassinov/AnyKernel3-Splidder"
AK3_BRANCH="master"

# Build configuration
export ARCH=arm64
export KBUILD_BUILD_USER=Mryassinov
export KBUILD_BUILD_HOST=kernel-builder
export PATH="$HOME/evo16/prebuilts/clang/host/linux-x86/clang-r547379/bin/:$PATH"

# Functions
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║        Kernel Splidder Build Script                      ║"
    echo "║        KernelSU-Next Integration                          ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

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

check_dependencies() {
    print_info "Checking build dependencies..."
    
    local missing_deps=()
    
    # Check for required commands
    command -v make >/dev/null 2>&1 || missing_deps+=("make")
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v zip >/dev/null 2>&1 || missing_deps+=("zip")
    
    # Check for compiler
    if ! command -v clang >/dev/null 2>&1; then
        if [ ! -d "$HOME/evo16/prebuilts/clang/host/linux-x86/clang-r547379" ]; then
            print_error "Clang compiler not found!"
            print_info "Please install clang or update the PATH in the script"
            exit 1
        fi
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Install them with: sudo apt install ${missing_deps[*]}"
        exit 1
    fi
    
    print_success "All dependencies satisfied"
}

get_git_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        GIT_HASH=$(git rev-parse --short=8 HEAD)
        COMMIT_COUNT=$(git rev-list --count HEAD)
        print_info "Git: Branch=${GIT_BRANCH}, Commit=${GIT_HASH}, Count=${COMMIT_COUNT}"
    else
        print_warning "Not a git repository"
        GIT_BRANCH="unknown"
        GIT_HASH="unknown"
        COMMIT_COUNT="0"
    fi
}

check_kernelsu() {
    print_info "Checking KernelSU integration..."
    
    if [ -d "KernelSU-Next" ]; then
        print_success "KernelSU-Next submodule found"
        
        # Get KernelSU version
        if [ -f "KernelSU-Next/kernel/ksu.c" ] || [ -d "drivers/kernelsu" ]; then
            print_success "KernelSU driver integrated"
            KERNELSU_ENABLED=true
        else
            print_warning "KernelSU directory exists but driver not integrated"
            KERNELSU_ENABLED=false
        fi
    else
        print_warning "KernelSU-Next not found"
        KERNELSU_ENABLED=false
    fi
}

show_build_info() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Build Information:${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "  Kernel Version:  ${GREEN}${KERNEL_VERSION}${NC}"
    echo -e "  Device:          ${GREEN}${DEVICE}${NC}"
    echo -e "  Defconfig:       ${GREEN}${DEVICE}_defconfig${NC}"
    echo -e "  Git Branch:      ${GREEN}${GIT_BRANCH}${NC}"
    echo -e "  Git Commit:      ${GREEN}${GIT_HASH}${NC}"
    
    if [ "$KERNELSU_ENABLED" = true ]; then
        echo -e "  KernelSU:        ${GREEN}✓ Enabled (${KERNELSU_VERSION})${NC}"
    else
        echo -e "  KernelSU:        ${RED}✗ Disabled${NC}"
    fi
    
    echo -e "  Build User:      ${GREEN}${KBUILD_BUILD_USER}${NC}"
    echo -e "  Build Host:      ${GREEN}${KBUILD_BUILD_HOST}${NC}"
    echo -e "  Architecture:    ${GREEN}${ARCH}${NC}"
    echo -e "  CPU Threads:     ${GREEN}$(nproc)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}\n"
}

clean_build() {
    print_info "Cleaning output directory..."
    rm -rf out
    rm -rf AnyKernel3
    rm -f *.zip
    print_success "Build directory cleaned"
}

# Parse command line arguments
CLEAN_BUILD=false
VERBOSE=false
THREADS=$(nproc)

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -j|--jobs)
            THREADS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -c, --clean       Clean build directory before compilation"
            echo "  -v, --verbose     Enable verbose output"
            echo "  -j, --jobs N      Use N parallel jobs (default: $(nproc))"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Supported devices: ${ALLOWED_CODENAMES[*]}"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Main script starts here
print_banner

# Check dependencies
check_dependencies

# Get git information
get_git_info

# Check KernelSU
check_kernelsu

# Clean if requested
if [ "$CLEAN_BUILD" = true ]; then
    clean_build
fi

# Prompt for device
echo -e "${YELLOW}Supported devices: ${ALLOWED_CODENAMES[*]}${NC}"
read -p "$(echo -e ${CYAN}Enter device codename:${NC} )" DEVICE

# Validate device
if [[ ! " ${ALLOWED_CODENAMES[@]} " =~ " ${DEVICE} " ]]; then
    print_error "Invalid codename: ${DEVICE}"
    print_info "Allowed codenames: ${ALLOWED_CODENAMES[*]}"
    exit 1
fi

# Generate zip name with more info
TIMESTAMP=$(date '+%Y%m%d-%H%M')
if [ "$KERNELSU_ENABLED" = true ]; then
    ZIPNAME="splidder-${DEVICE}-ksun-${TIMESTAMP}.zip"
else
    ZIPNAME="splidder-${DEVICE}-${TIMESTAMP}.zip"
fi

# Show build configuration
show_build_info

# Confirm before building
read -p "$(echo -e ${YELLOW}Proceed with compilation? [Y/n]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    print_info "Build cancelled"
    exit 0
fi

# Start compilation
echo -e "\n${GREEN}Starting kernel compilation...${NC}\n"

# Generate defconfig
print_info "Generating defconfig for ${DEVICE}..."
if ! make O=out ARCH=arm64 ${DEVICE}_defconfig; then
    print_error "Failed to generate defconfig!"
    exit 1
fi
print_success "Defconfig generated"

# Compile kernel
print_info "Compiling kernel with ${THREADS} threads..."

if [ "$VERBOSE" = true ]; then
    make -j${THREADS} \
        O=out \
        ARCH=arm64 \
        LLVM=1 \
        LLVM_IAS=1 \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi-
else
    make -j${THREADS} \
        O=out \
        ARCH=arm64 \
        LLVM=1 \
        LLVM_IAS=1 \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        2>&1 | grep -E "error:|warning:" || true
fi

# Check compilation result
kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

print_info "Verifying compiled files..."

if [ ! -f "$kernel" ]; then
    print_error "Kernel image not found: $kernel"
    exit 1
fi

if [ ! -f "$dtbo" ]; then
    print_warning "DTBO image not found: $dtbo (might be expected for some devices)"
fi

if [ ! -f "$dtb" ]; then
    print_warning "DTB image not found: $dtb (might be expected for some devices)"
fi

print_success "Kernel compiled successfully!"

# Get file sizes
KERNEL_SIZE=$(du -h "$kernel" | cut -f1)
print_info "Kernel size: ${KERNEL_SIZE}"

# Package kernel
echo -e "\n${CYAN}Packaging kernel...${NC}\n"

# Clone or use existing AnyKernel3
if [ -d "$AK3_DIR" ] && [ ! -z "$AK3_DIR" ]; then
    print_info "Using local AnyKernel3 from: $AK3_DIR"
    cp -r "$AK3_DIR" AnyKernel3
else
    print_info "Cloning AnyKernel3 from GitHub..."
    if ! git clone -q "$AK3_REPO" -b "$AK3_BRANCH" AnyKernel3; then
        print_error "Failed to clone AnyKernel3 repository!"
        exit 1
    fi
    print_success "AnyKernel3 cloned"
fi

# Modify AnyKernel3 configuration
print_info "Configuring AnyKernel3 for ${DEVICE}..."
sed -i "s/device\.name1=.*/device.name1=${DEVICE}/" AnyKernel3/anykernel.sh
sed -i "s/device\.name2=.*/device.name2=${DEVICE}in/" AnyKernel3/anykernel.sh

# Add kernel info to anykernel.sh
if [ "$KERNELSU_ENABLED" = true ]; then
    sed -i "s/kernel\.string=.*/kernel.string=${KERNEL_VERSION} with KernelSU ${KERNELSU_VERSION} by ${KBUILD_BUILD_USER}/" AnyKernel3/anykernel.sh
else
    sed -i "s/kernel\.string=.*/kernel.string=${KERNEL_VERSION} by ${KBUILD_BUILD_USER}/" AnyKernel3/anykernel.sh
fi

# Copy compiled files
print_info "Copying kernel files..."
cp "$kernel" AnyKernel3/

if [ -f "$dtbo" ]; then
    cp "$dtbo" AnyKernel3/
fi

if [ -f "$dtb" ]; then
    cp "$dtb" AnyKernel3/
fi

# Create flashable zip
print_info "Creating flashable ZIP..."
cd AnyKernel3
if ! zip -r9 "../$ZIPNAME" * -x .git README.md .gitignore >/dev/null 2>&1; then
    cd ..
    print_error "Failed to create ZIP file!"
    exit 1
fi
cd ..
print_success "Flashable ZIP created"

# Cleanup
rm -rf AnyKernel3

# Calculate build time
BUILD_TIME=$SECONDS
BUILD_MIN=$((BUILD_TIME / 60))
BUILD_SEC=$((BUILD_TIME % 60))

# Get final ZIP size
ZIP_SIZE=$(du -h "$ZIPNAME" | cut -f1)

# Print build summary
echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Build Completed Successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "  Device:          ${CYAN}${DEVICE}${NC}"
echo -e "  Kernel Version:  ${CYAN}${KERNEL_VERSION}${NC}"

if [ "$KERNELSU_ENABLED" = true ]; then
    echo -e "  KernelSU:        ${CYAN}✓ ${KERNELSU_VERSION}${NC}"
fi

echo -e "  Git Commit:      ${CYAN}${GIT_HASH}${NC}"
echo -e "  Build Time:      ${CYAN}${BUILD_MIN}m ${BUILD_SEC}s${NC}"
echo -e "  Kernel Size:     ${CYAN}${KERNEL_SIZE}${NC}"
echo -e "  ZIP Size:        ${CYAN}${ZIP_SIZE}${NC}"
echo -e "  Output ZIP:      ${CYAN}${ZIPNAME}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"

print_info "You can now flash ${ZIPNAME} via recovery"

if [ "$KERNELSU_ENABLED" = true ]; then
    echo -e "${YELLOW}Remember to install KernelSU Manager after flashing!${NC}"
    echo -e "${YELLOW}Download from: https://github.com/rsuntk/KernelSU-Next/releases${NC}\n"
fi
