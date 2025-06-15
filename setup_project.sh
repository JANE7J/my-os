#!/bin/bash
# OS Development Project Setup Script

echo "🏗️  Setting up professional OS development structure..."

# Navigate to your OS directory
cd ~/my_os

# Create professional directory structure
echo "📁 Creating directories..."
mkdir -p src          # Source code
mkdir -p build        # Compiled binaries
mkdir -p docs         # Documentation
mkdir -p tools        # Build scripts and utilities
mkdir -p tests        # Test files
mkdir -p backup       # Backup versions

# Back up your current working OS
echo "💾 Backing up your working OS..."
if [ -f "enhanced_os.asm" ]; then
    cp enhanced_os.asm backup/enhanced_os_$(date +%Y%m%d).asm
    cp enhanced_os.asm src/kernel_v1.asm
    echo "✅ Backed up enhanced_os.asm"
fi

if [ -f "build/enhanced_os.bin" ]; then
    cp build/enhanced_os.bin backup/enhanced_os_$(date +%Y%m%d).bin
    cp build/enhanced_os.bin build/kernel_v1.bin
    echo "✅ Backed up enhanced_os.bin"
fi

# Create main source files
echo "📝 Creating source files..."

# Main kernel file
cat > src/kernel.asm << 'EOF'
; MyOS Kernel v2.0 - Professional Structure
; Based on working enhanced_os.asm

[BITS 16]
[ORG 0x7C00]

; Boot sector code will go here
; This will be expanded to multi-stage bootloader

jmp start

; Include your working code here
; (Copy from your enhanced_os.asm)

start:
    ; Initialize
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    ; Your existing working code goes here
    ; TODO: Copy from enhanced_os.asm
    
    ; Placeholder for now
    mov si, welcome_msg
    call print_string
    
    ; Main loop
main_loop:
    xor ah, ah
    int 0x16    ; Get key
    
    cmp al, 'q'
    je quit
    
    jmp main_loop

quit:
    mov si, quit_msg
    call print_string
    hlt

print_string:
    mov ah, 0x0E
    mov bh, 0
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

welcome_msg db 'MyOS v2.0 - Professional Structure', 13, 10, 0
quit_msg db 'Goodbye!', 13, 10, 0

; Boot sector signature
times 510-($-$$) db 0
dw 0xAA55
EOF

# Create bootloader file
cat > src/bootloader.asm << 'EOF'
; Stage 1 Bootloader - Loads main kernel
; This will be the future multi-stage bootloader

[BITS 16]
[ORG 0x7C00]

; This will load Stage 2 kernel from disk
; For now, it's a placeholder

jmp 0x0000:start

start:
    ; Initialize segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    ; Display loading message
    mov si, loading_msg
    call print_string
    
    ; TODO: Load Stage 2 kernel from disk
    ; For now, just continue with embedded code
    
    ; Jump to main kernel code
    ; (This will change when we implement disk loading)
    
    hlt

print_string:
    mov ah, 0x0E
    mov bh, 0
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

loading_msg db 'Loading MyOS Kernel...', 13, 10, 0

; Boot sector signature
times 510-($-$$) db 0
dw 0xAA55
EOF

# Create build script
cat > tools/build.sh << 'EOF'
#!/bin/bash
# Professional Build Script for MyOS

echo "🔨 Building MyOS..."

# Create build directory if it doesn't exist
mkdir -p build

# Build main kernel
echo "📦 Assembling kernel..."
nasm -f bin src/kernel.asm -o build/kernel.bin

if [ $? -eq 0 ]; then
    echo "✅ Kernel built successfully"
    ls -l build/kernel.bin
else
    echo "❌ Kernel build failed"
    exit 1
fi

# Build bootloader (for future use)
echo "📦 Assembling bootloader..."
nasm -f bin src/bootloader.asm -o build/bootloader.bin

if [ $? -eq 0 ]; then
    echo "✅ Bootloader built successfully"
else
    echo "⚠️  Bootloader build failed (this is OK for now)"
fi

echo "🎉 Build complete!"
echo "🚀 Test with: qemu-system-x86_64 -drive format=raw,file=build/kernel.bin"
EOF

# Make build script executable
chmod +x tools/build.sh

# Create documentation
cat > docs/README.md << 'EOF'
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
EOF

# Create test script
cat > tests/test_build.sh << 'EOF'
#!/bin/bash
# Test script to verify builds work

echo "🧪 Testing MyOS builds..."

# Test kernel build
echo "Testing kernel build..."
cd ..
./tools/build.sh

if [ -f "build/kernel.bin" ]; then
    echo "✅ Kernel build test passed"
    
    # Check size
    size=$(stat -c%s build/kernel.bin)
    echo "📏 Kernel size: $size bytes"
    
    if [ $size -eq 512 ]; then
        echo "✅ Perfect boot sector size"
    elif [ $size -lt 512 ]; then
        echo "⚠️  Kernel smaller than boot sector"
    else
        echo "❌ Kernel too big for single boot sector"
        echo "💡 Time for multi-stage bootloader!"
    fi
else
    echo "❌ Kernel build test failed"
fi

echo "🎯 Test complete"
EOF

chmod +x tests/test_build.sh

# Create version info
cat > VERSION << 'EOF'
MyOS Development Version 2.0
Professional Structure Implementation
Date: $(date)
Status: Transitioning to multi-stage bootloader
EOF

echo "✅ Project structure created successfully!"
echo ""
echo "📁 Your new structure:"
ls -la
echo ""
echo "🔍 Next steps:"
echo "1. Copy your working enhanced_os.asm code into src/kernel.asm"
echo "2. Run ./tools/build.sh to test"
echo "3. Ready for multi-stage bootloader development!"
