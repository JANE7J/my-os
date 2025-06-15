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
