# MyOS - Personal Operating System

## Overview
A custom operating system built from scratch in x86 assembly.

## Current Features
- 7 interactive commands (A, B, C, H, I, Q, T)
- Colorful interface with rainbow header
- Beep functionality
- Professional project structure

## Development Status
- ✅ Basic boot sector OS working
- 🔄 Transitioning to multi-stage bootloader
- 📋 Planning file system implementation

## Build Instructions
```bash
# Build the OS
./tools/build.sh

# Test in emulator
qemu-system-x86_64 -drive format=raw,file=build/kernel.bin

# Test on real hardware (careful!)
sudo dd if=build/kernel.bin of=/dev/sdX bs=512 count=1
```

## Project Structure
```
my_os/
├── src/           # Source code
├── build/         # Compiled binaries
├── docs/          # Documentation
├── tools/         # Build scripts
├── tests/         # Test files
└── backup/        # Version backups
```

## Next Steps
1. Implement multi-stage bootloader
2. Expand kernel beyond 512 bytes
3. Add file system support
4. Improve hardware interaction

## Development Log
- [Date] - Initial project organization
- [Date] - Working 7-command OS
- [Date] - Professional structure implemented
