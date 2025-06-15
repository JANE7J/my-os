# MyOS - Multi-Stage Operating System

A custom x86 operating system built from scratch with a multi-stage bootloader architecture.

## 🚀 Features

- **Multi-Stage Boot Process**: Bootloader + Kernel architecture
- **Interactive Command Line**: 7 built-in commands
- **Working Calculator**: Full arithmetic with proper display
- **Professional Interface**: Clean menu system and navigation
- **Unlimited Kernel Space**: 2048+ bytes for future expansion
- **Real Hardware Compatible**: Boots on real x86 systems

## 🛠️ Built With

- **Assembly Language**: NASM (Netwide Assembler)
- **Architecture**: x86 (16-bit real mode → 32-bit protected mode)
- **Build System**: Custom shell scripts
- **Testing**: QEMU emulator

## 📋 Available Commands

1. **help** - Show available commands
2. **calc** - Interactive calculator
3. **clear** - Clear the screen
4. **time** - Show system uptime
5. **memory** - Show memory usage
6. **game** - Simple number guessing game
7. **shutdown** - Safely shutdown the system

## 🔧 Building the OS

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nasm qemu-system-x86

# Arch Linux
sudo pacman -S nasm qemu-arch-extra

# macOS
brew install nasm qemu

# macOS
brew install nasm qemu
# Build the multi-stage OS
./tools/build_multistage.sh

# Clean build artifacts
./tools/clean.sh
## 🎮 Running the OS

### In QEMU (Recommended for testing)
```bash
qemu-system-x86_64 -drive format=raw,file=build/myos_disk.img
### In VirtualBox
1. Create a new VM (Other/DOS)
2. Use `build/myos_disk.img` as the disk image
3. Boot the VM

### On Real Hardware ⚠️
```bash
# BE EXTREMELY CAREFUL - This will overwrite the target drive!
sudo dd if=build/myos_disk.img of=/dev/sdX bs=512
📁 Project Structure
my_os/
├── src/
│   ├── stage1/
│   │   └── bootloader.asm    # First stage bootloader (512 bytes)
│   └── stage2/
│       └── kernel.asm        # Second stage kernel (2048+ bytes)
├── tools/
│   ├── build_multistage.sh   # Main build script
│   └── clean.sh              # Clean build artifacts
├── build/                    # Generated build files (gitignored)
└── README.md                 # This file
🏗️ Architecture
Stage 1 Bootloader (512 bytes)

Loaded by BIOS at 0x7C00
Sets up basic environment
Loads Stage 2 kernel from disk
Jumps to kernel entry point

Stage 2 Kernel (2048+ bytes)

Full command-line interface
Calculator with proper arithmetic
Interactive games and utilities
Memory and system management
🎯 Technical Details

Boot Signature: 0xAA55 (required by BIOS)
Memory Layout:

Stage 1: 0x7C00-0x7DFF (512 bytes)
Stage 2: 0x8000+ (2048+ bytes)


Disk Layout:

Sector 1: Stage 1 bootloader
Sector 2+: Stage 2 kernel
🧪 Testing
The OS has been tested on:

✅ QEMU x86_64 emulator
✅ VirtualBox VM
✅ Real x86 hardware

🔮 Future Enhancements

File system support
Memory management
Process scheduling
Network stack
GUI interface
📝 License
This project is open source and available under the MIT License.
🤝 Contributing
Contributions are welcome! Please feel free to submit issues and pull requests.

Built with ❤️ and lots of assembly code
