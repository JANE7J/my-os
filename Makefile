# Multi-Sector OS Makefile
# Builds bootloader + kernel system

# Output files
BOOTLOADER = build/bootloader.bin
KERNEL = build/kernel.bin
OS_IMAGE = build/myos.bin

# Source files
BOOT_SRC = bootloader.asm
KERNEL_SRC = kernel.asm

# Create build directory
$(shell mkdir -p build)

# Build everything
all: $(OS_IMAGE)

# Combine bootloader and kernel
$(OS_IMAGE): $(BOOTLOADER) $(KERNEL)
	@echo "Creating complete OS image..."
	cat $(BOOTLOADER) $(KERNEL) > $(OS_IMAGE)
	@echo "OS image created: $(OS_IMAGE)"

# Build bootloader (512 bytes)
$(BOOTLOADER): $(BOOT_SRC)
	@echo "Building bootloader..."
	nasm -f bin $(BOOT_SRC) -o $(BOOTLOADER)
	@echo "Bootloader size: $$(stat -c%s $(BOOTLOADER)) bytes"

# Build kernel (unlimited size)
$(KERNEL): $(KERNEL_SRC)
	@echo "Building kernel..."
	nasm -f bin $(KERNEL_SRC) -o $(KERNEL)
	@echo "Kernel size: $$(stat -c%s $(KERNEL)) bytes"

# Run the OS in QEMU
run: $(OS_IMAGE)
	@echo "Starting MyOS in QEMU..."
	qemu-system-x86_64 -drive format=raw,file=$(OS_IMAGE)

# Run with debug info
debug: $(OS_IMAGE)
	@echo "Starting MyOS with debug info..."
	qemu-system-x86_64 -drive format=raw,file=$(OS_IMAGE) -monitor stdio

# Show build information
info: $(OS_IMAGE)
	@echo "=== MyOS Build Information ==="
	@echo "Bootloader: $$(stat -c%s $(BOOTLOADER)) bytes"
	@echo "Kernel: $$(stat -c%s $(KERNEL)) bytes"
	@echo "Total OS: $$(stat -c%s $(OS_IMAGE)) bytes"
	@echo "Files created:"
	@ls -la build/

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -f build/*.bin
	@echo "Clean complete"

# Force rebuild
rebuild: clean all

# Create bootable USB (be careful with device!)
# Usage: make usb DEVICE=/dev/sdX
usb: $(OS_IMAGE)
	@echo "WARNING: This will overwrite $(DEVICE)!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read
	sudo dd if=$(OS_IMAGE) of=$(DEVICE) bs=512 count=10
	@echo "Bootable USB created on $(DEVICE)"

# Create CD/DVD image
iso: $(OS_IMAGE)
	@echo "Creating ISO image..."
	mkdir -p build/iso
	cp $(OS_IMAGE) build/iso/
	genisoimage -o build/myos.iso -b myos.bin build/iso/
	@echo "ISO created: build/myos.iso"

# Show help
help:
	@echo "MyOS Multi-Sector Build System"
	@echo "Available targets:"
	@echo "  all     - Build complete OS (default)"
	@echo "  run     - Build and run OS in QEMU"
	@echo "  debug   - Run with QEMU debug monitor"
	@echo "  info    - Show build information"
	@echo "  clean   - Remove build files"
	@echo "  rebuild - Clean and rebuild"
	@echo "  usb     - Create bootable USB (specify DEVICE=)"
	@echo "  iso     - Create bootable ISO image"
	@echo "  help    - Show this help"

.PHONY: all run debug info clean rebuild usb iso help
