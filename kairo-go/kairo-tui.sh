#!/bin/bash
###############################################################################
# Kairo Go™ Handheld Console TUI
#
# Product Name:       Kairo Go
# Platform:           Portable / Dockable Gaming Console
# Firmware Type:      Text-Based System Interface (TUI)
# Version:            1.0.0
# Release Date:       19/10/2003
#
# Developed By:       OSAKA Systems
# Development Team:   Osaka Systems Embedded & Firmware Division
# Lineage:            Osaka '0 Series System Software
# Architecture:       ARM64 / Custom Embedded SoC
#
# Description:
#   This script implements the Kairo Go TUI for managing software, performing
#   system updates, and accessing developer tools. It allows users to:
#     - Launch custom software executables with saved shortcuts
#     - Configure developer tools and access a shell for advanced operations
#     - Update the system via apt or pacman depending on OS
#     - Suspend, restart, or shut down the console safely
#     - View battery, Wi-Fi, and system information at a glance
#
# Features:
#   - Text-based interface optimized for handheld/docked modes
#   - Software management with automatic executable permission setting
#   - Developer shell and utilities for debugging, system inspection, and network tools
#   - Secure execution of installed applications
#   - Minimal dependencies for lightweight operation on Raspberry Pi / embedded systems
#   - Startup sound and configurable interface settings
#
# Legal & Licensing Notice:
#   Copyright © 2003 OSAKA Systems. All rights reserved.
#
#   This software is proprietary and confidential. It is intended solely
#   for installation and execution on official Kairo Go hardware.
#   Unauthorized use, reproduction, modification, reverse engineering,
#   distribution, or disclosure, in whole or in part, without prior
#   written consent from OSAKA Systems, is strictly prohibited.
#
# Warranty Disclaimer:
#   Provided "as is" without warranty of any kind. OSAKA Systems shall not
#   be liable for any damages arising from the use of this firmware.
#
# Security Notice:
#   Attempts to bypass protections, inject unauthorized code, or tamper with
#   firmware settings are prohibited and may void the warranty.
#
# Internal Use Only:
#   Intended for authorized OSAKA Systems personnel. Not for public release.
#
# Contact:
#   OSAKA Systems
#   Embedded Systems Division
#   support@osakasystems.com
#
###############################################################################



############################
# CONFIG
############################
BASE_DIR="/root/kairo-go"
CONFIG_DIR="$HOME/.config/kairo-ui"
SETTINGS_FILE="$CONFIG_DIR/settings.conf"
LAUNCHER_DIR="$BASE_DIR/launchers"

THEME="$BASE_DIR/kairo-theme.rc"
SND_START="$BASE_DIR/sounds/startup.wav"
SND_OK="$BASE_DIR/sounds/confirm.wav"

mkdir -p "$CONFIG_DIR" "$LAUNCHER_DIR"

############################
# TERMINAL SIZING
############################
H=$(tput lines); W=$(tput cols)
HEIGHT=$((H-8)); WIDTH=$((W-12)); MENU=$((HEIGHT-10))
((HEIGHT<26))&&HEIGHT=26
((WIDTH<88))&&WIDTH=88
((MENU<16))&&MENU=16

############################
# SETTINGS
############################
load_settings() {
  [ -f "$SETTINGS_FILE" ] && source "$SETTINGS_FILE"
  : "${SOUND:=on}"
  export DIALOGRC="$THEME"
}

save_setting() {
  grep -v "^$1=" "$SETTINGS_FILE" 2>/dev/null > "$SETTINGS_FILE.tmp"
  echo "$1=\"$2\"" >> "$SETTINGS_FILE.tmp"
  mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
}

############################
# AUDIO
############################
sfx() {
  [ "$SOUND" = "on" ] && mpv --no-video --quiet "$1" &>/dev/null &
}

############################
# STATUS BAR
############################
power_status() {
  if [ -f /sys/class/power_supply/AC/online ]; then
    grep -q 1 /sys/class/power_supply/AC/online && echo Docked || echo Undocked
  else echo Unknown; fi
}

battery_status() {
  BAT="/sys/class/power_supply/BAT0"
  [ -d "$BAT" ] && echo "$(cat $BAT/capacity)% $(cat $BAT/status)" || power_status
}

wifi_status() {
  SSID=$(nmcli -t -f NAME,TYPE c show --active | grep wifi | cut -d: -f1)
  [ -n "$SSID" ] && echo "WiFi($SSID)" || echo "No WiFi"
}

update_bar() {
  BACKTITLE="[ $(battery_status) | $(wifi_status) | $(date '+%H:%M') ]"
}

############################
# SOFTWARE MANAGEMENT
############################
add_launcher() {
  NAME=$(dialog --inputbox "Enter software name:" 10 50 2>&1 >/dev/tty) || return
  PATH_EXEC=$(dialog --inputbox "Enter full path to executable:" 10 60 2>&1 >/dev/tty) || return

  if [ ! -f "$PATH_EXEC" ]; then
    dialog --msgbox "File not found." 6 40
    return
  fi

  # Make it executable
  chmod +x "$PATH_EXEC"

  cat >"$LAUNCHER_DIR/$NAME.launch" <<EOL
NAME="$NAME"
EXEC="$PATH_EXEC"
EOL

  dialog --msgbox "Launcher $NAME saved and made executable!" 6 50
}

launcher_menu() {
  update_bar
  mapfile -t LAUNCHERS < <(ls "$LAUNCHER_DIR"/*.launch 2>/dev/null)
  OPTS=()
  for i in "${!LAUNCHERS[@]}"; do
    source "${LAUNCHERS[$i]}"
    OPTS+=("$((i+1))" "$NAME")
  done
  OPTS+=("A" "Add New Software Launcher")
  CHOICE=$(dialog --backtitle "$BACKTITLE" --cancel-label "Back" \
    --menu "Software Library" $HEIGHT $WIDTH $MENU "${OPTS[@]}" 2>&1 >/dev/tty) || return

  case "$CHOICE" in
    A) add_launcher ;;
    *) source "${LAUNCHERS[$((CHOICE-1))]}"; clear; exec "$EXEC" ;;
  esac
}

############################
# DEVELOPER TOOLS
############################
developer_shell() {
  dialog --msgbox "Developer Shell:\nTo exit and return to Kairo Go TUI, type:\n/root/kairo-go/kairo-tui.sh" 8 60
  bash
}

developer_tools() {
  while true; do
    update_bar
    CH=$(dialog --backtitle "$BACKTITLE" --menu "Developer Tools" \
      $HEIGHT $WIDTH $MENU \
      1 "Developer Shell" \
      2 "System Info" \
      3 "Network Tools" \
      4 "File Inspector" 2>&1 >/dev/tty) || break
    case $CH in
      1) developer_shell ;;
      2)
        clear
        echo "===== SYSTEM INFO ====="
        echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2)"
        echo "Memory: $(free -h | grep Mem)"
        echo "Disk: $(df -h /)"
        echo "OS: $(uname -a)"
        read -p "Press ENTER to return..." _
        ;;
      3)
        dialog --msgbox "Use nmcli in shell for advanced WiFi/network management." 8 50
        bash
        ;;
      4)
        dialog --msgbox "You can use 'ls', 'cat', etc. in shell for file inspection." 6 50
        bash
        ;;
    esac
  done
}

############################
# UPDATES
############################
update_system() {
  if command -v apt &>/dev/null; then
    dialog --infobox "Updating system with apt..." 5 40
    sleep 2
    sudo apt update && sudo apt upgrade -y
  elif command -v pacman &>/dev/null; then
    dialog --infobox "Updating system with pacman..." 5 40
    sleep 2
    sudo pacman -Syu --noconfirm
  else
    dialog --msgbox "No supported package manager found." 6 40
  fi
  dialog --msgbox "Update finished." 6 40
}

############################
# SETTINGS MENU
############################
settings_menu() {
  while true; do
    update_bar
    CH=$(dialog --backtitle "$BACKTITLE" --menu "Settings" \
      $HEIGHT $WIDTH $MENU \
      1 "Update System" \
      2 "Developer Tools" 2>&1 >/dev/tty) || break
    case $CH in
      1) update_system ;;
      2) developer_tools ;;
    esac
  done
}

############################
# MAIN
############################
clear
load_settings
sfx "$SND_START"

dialog --infobox "Kairo Go\nOSAKA Systems" 6 30
sleep 6

while true; do
  update_bar
  CHOICE=$(dialog --backtitle "$BACKTITLE" --menu "Home" \
    $HEIGHT $WIDTH $MENU \
    1 "Software Library" \
    2 "Settings" \
    3 "Suspend" \
    4 "Restart" \
    5 "Shutdown" \
    6 "Exit to Shell" 2>&1 >/dev/tty) || break

  case $CHOICE in
    1) launcher_menu ;;
    2) settings_menu ;;
    3) clear; systemctl suspend ;;
    4) clear; reboot ;;
    5) clear; shutdown now ;;
    6) clear; exit ;;
  esac
done

clear
echo "Kairo Go exited."
