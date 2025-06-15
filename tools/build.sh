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
