#!/bin/bash

DEFCONFIG="arch/arm64/configs/sweet_defconfig"
BACKUP="${DEFCONFIG}.backup-$(date +%Y%m%d-%H%M%S)"

echo "================================================"
echo "  Adding NetHunter Kernel Configurations"
echo "================================================"
echo ""

# Backup original defconfig
cp "$DEFCONFIG" "$BACKUP"
echo "✓ Backup created: $BACKUP"

# Add NetHunter configurations
cat >> "$DEFCONFIG" << 'NETHUNTER_CONFIG'

##################################################
# Kali NetHunter Kernel Configuration
##################################################

# Module support (REQUIRED)
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y

# Wireless Extensions (REQUIRED for injection)
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_PRIV=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y

# cfg80211 and mac80211 (REQUIRED)
CONFIG_CFG80211=y
CONFIG_CFG80211_WEXT=y
CONFIG_CFG80211_DEFAULT_PS=y
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y

# USB Gadget support (for HID/BadUSB attacks)
CONFIG_USB_GADGET=y
CONFIG_USB_CONFIGFS=y
CONFIG_USB_CONFIGFS_F_HID=y
CONFIG_USB_CONFIGFS_MASS_STORAGE=y
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_CONFIGFS_RNDIS=y
CONFIG_USB_CONFIGFS_ECM=y
CONFIG_USB_CONFIGFS_ACM=y

# HID support
CONFIG_HIDRAW=y
CONFIG_UHID=y
CONFIG_HID=y

# Networking (REQUIRED)
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_IPV6=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_NETFILTER_XTABLES=y
CONFIG_NETFILTER_XT_TARGET_LOG=y

# Bluetooth
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
CONFIG_BT_HIDP=y

# TUN/TAP for VPN
CONFIG_TUN=y

# VLAN support
CONFIG_VLAN_8021Q=y

# Monitor mode support
CONFIG_MAC80211_DEBUGFS=y
CONFIG_CFG80211_DEBUGFS=y

NETHUNTER_CONFIG

echo "✓ NetHunter configurations added"
echo ""
echo "Configuration summary:"
echo "  - WiFi injection support enabled"
echo "  - USB HID/Gadget support enabled"
echo "  - Bluetooth attack support enabled"
echo "  - TUN/TAP for VPN enabled"
echo ""
echo "Next step: ./build_kernel.sh"
echo ""
