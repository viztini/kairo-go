# Kairo Go — TUI Game Console

**Fictional Project** — A lightweight terminal-based game and software launcher inspired by handheld consoles, built in **WSL** in just **6 hours**. Built in mind for a Raspberry Pi

This script provides a **text-based interface (TUI)** for running small Linux games and custom executables, with developer tools included for power users.

---

## Overview

Kairo Go is a Bash-based TUI that allows users to:

- Launch games and other software from a single menu.  
- Manage software by adding new executables with saved shortcuts.  
- Access a developer shell for advanced operations.  
- Update the system using standard package managers (`apt` or `pacman`).  
- Include demo software such as **Snake**.  Thanks to 

This project is designed to be **ultra-lightweight**, running entirely in a terminal with minimal resource requirements.

---

## Features

- Text-based interface for low-resource environments.  
- Software library with saved launchers for easy access.  
- Developer tools with shell access.  
- System operations: suspend, restart, shutdown.  
- Audio support for music and sound effects.  
- Minimal dependencies, runs on virtually any Linux system with minimal script tweaking.  

---

## Installation

Clone or download the repository, then from the folder run:

```bash
./kairo-tui.sh
````

### Adding Software

Place your executables in:

```
~/kairo-go/software/<software-name>
```

Then use the TUI to register the software for launch. Permissions are automatically set to executable.

---

## Demo Software Included

* **Snake** — Terminal-based classic game.
* Other user-contributed games for testing the launcher.

---

## Developer Notes

* Written entirely in Bash using `dialog` for the TUI.
* Provides a shell with developer commands for advanced users.
* Supports adding new software and managing shortcuts via the interface.
* Networking options (Wi-Fi/Ethernet) can be accessed via the shell.

---

## Future Roadmap

Kairo Go is designed to be **lightweight, extensible, and fun**. Planned future features include:

### Software & Games

* **Expanded game library**: More classic and small terminal-based games.
* **Snake improvements**: High-score tracking, levels, and speed customization.
* **Minecraft demo (terminal 3D)**: A simple, lightweight proof-of-concept 3D voxel engine in text mode.
* **User-contributed software**: Easy integration for community-created apps and games.
* **Web Browsing**: Basic web browser such as w3m, or some other form.

### System Features

* **Battery indicator**: Visual TUI bars showing remaining power.
* **Audio enhancements**: Support for additional audio formats and volume controls.
* **Media support**: MP3/WAV playback, and eventually basic video playback.
* **Network integration**: Simplified TUI-based Wi-Fi setup and Ethernet connectivity.

### Developer Tools

* **Extended shell utilities**: Scripts and shortcuts for managing software and system settings.
* **Software registration wizard**: Automatically detect executables and save launchers.
* **Logging & debugging**: Optional verbose mode for developers to test new games or apps.

### Platform Improvements

* **Optimized performance**: Keep Kairo Go running fast on **low-spec systems**.
* **Portable deployment**: Support for more Linux distributions and minimal installations.
* **Customizable TUI themes**: Adjust interface colors and layout.

> Kairo Go’s goal is to be the **ultimate lightweight console environment** for small Linux systems, fun for both users and developers alike.

---

## Licensing

All software included is for demonstration purposes. This is a **fictional project** and not intended for distribution on real hardware.
Snake game is mostly based on https://github.com/pjhades/bash-snake with a couple minior changes

---

## Contact

Support / Issues: [GitHub Issues]
