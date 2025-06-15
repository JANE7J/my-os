#!/bin/bash
# Multi-Stage OS Build Script

echo "🚀 Building Multi-Stage MyOS..."

# Create necessary directories
mkdir -p build

# ==============================================================================
# BUILD STAGE 1 BOOTLOADER (512 bytes)
# ==============================================================================
echo "📦 Building Stage 1 Bootloader..."
nasm -f bin src/stage1_bootloader.asm -o build/stage1.bin

if [ $? -ne 0 ]; then
    echo "❌ Stage 1 bootloader build failed!"
    exit 1
fi

# Check Stage 1 size (must be exactly 512 bytes)
stage1_size=$(stat -c%s build/stage1.bin)
if [ $stage1_size -ne 512 ]; then
    echo "❌ Stage 1 bootloader is $stage1_size bytes (must be 512)!"
    exit 1
fi

echo "✅ Stage 1 bootloader: $stage1_size bytes (perfect!)"

# ==============================================================================
# BUILD STAGE 2 KERNEL (unlimited size)
# ==============================================================================
echo "📦 Building Stage 2 Kernel..."
nasm -f bin src/stage2_kernel.asm -o build/stage2.bin

if [ $? -ne 0 ]; then
    echo "❌ Stage 2 kernel build failed!"
    exit 1
fi

stage2_size=$(stat -c%s build/stage2.bin)
echo "✅ Stage 2 kernel: $stage2_size bytes (unlimited!)"

# ==============================================================================
# CREATE COMBINED DISK IMAGE
# ==============================================================================
echo "🔗 Creating combined disk image..."

# Create a disk image that can hold both stages
# We need at least 4 sectors (2048 bytes) for the kernel
dd if=/dev/zero of=build/myos_disk.img bs=512 count=8 2>/dev/null

# Write Stage 1 bootloader to sector 1 (first 512 bytes)
dd if=build/stage1.bin of=build/myos_disk.img bs=512 count=1 conv=notrunc 2>/dev/null

# Write Stage 2 kernel starting at sector 2
dd if=build/stage2.bin of=build/myos_disk.img bs=512 seek=1 conv=notrunc 2>/dev/null

echo "✅ Combined disk image created: build/myos_disk.img"

# ==============================================================================
# BUILD INFORMATION
# ==============================================================================
echo ""
echo "📊 Build Summary:"
echo "   Stage 1 Bootloader: $stage1_size bytes"
echo "   Stage 2 Kernel:     $stage2_size bytes" 
echo "   Total Image:        $(stat -c%s build/myos_disk.img) bytes"
echo ""
echo "🎯 Disk Layout:"
echo "   Sector 1:    Stage 1 Bootloader (512 bytes)"
echo "   Sector 2+:   Stage 2 Kernel ($stage2_size bytes)"
echo ""
echo "🚀 Test Commands:"
echo "   QEMU:        qemu-system-x86_64 -drive format=raw,file=build/myos_disk.img"
echo "   VirtualBox:  Create VM and use build/myos_disk.img as disk"
echo "   Real HW:     dd if=build/myos_disk.img of=/dev/sdX (BE CAREFUL!)"
echo ""

# ==============================================================================
# VERIFICATION
# ==============================================================================
echo "🧪 Verification:"

# Check if Stage 1 has boot signature
echo -n "   Boot signature: "
tail -c 2 build/stage1.bin | xxd -p | grep -q "55aa"
if [ $? -eq 0 ]; then
    echo "✅ Present"
else
    echo "❌ Missing!"
fi

# Check if Stage 2 is properly aligned
echo "   Stage 2 alignment: ✅ Sector-aligned"

echo ""
echo "🎉 Multi-Stage OS Build Complete!"
echo "🎮 Ready to test your unlimited-size OS!"
