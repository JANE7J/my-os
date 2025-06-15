// Minimal C Kernel - kernel/kernel.c
// Ultra-simple kernel to avoid linking issues

// Entry point - this will be called from the bootloader
void _start(void) __attribute__((section(".text.entry")));

// Simple function to write to video memory
static inline void write_string(const char* str, int row, unsigned char color) {
    volatile unsigned short* video_memory = (volatile unsigned short*)0xB8000;
    int col = 0;
    int pos = row * 80;  // 80 characters per row
    
    while (*str && col < 80) {
        video_memory[pos + col] = (color << 8) | *str;
        str++;
        col++;
    }
}

// Clear the screen
static inline void clear_screen(void) {
    volatile unsigned short* video_memory = (volatile unsigned short*)0xB8000;
    int i;
    
    for (i = 0; i < 80 * 25; i++) {
        video_memory[i] = 0x0720;  // Gray text on black, space character
    }
}

// Simple delay
static inline void delay(void) {
    volatile int i;
    for (i = 0; i < 50000000; i++) {
        // Burn CPU cycles
    }
}

// Kernel entry point
void _start(void) {
    int counter = 0;
    
    // Clear screen first
    clear_screen();
    
    // Display kernel messages
    write_string("MyOS C Kernel Successfully Loaded!", 1, 0x0B);  // Cyan
    write_string("Running in 32-bit protected mode", 2, 0x0A);   // Green
    write_string("Kernel Address: 0x1000", 4, 0x0F);             // White
    write_string("Video Memory: 0xB8000", 5, 0x0F);              // White
    
    // Main kernel loop with counter
    while (1) {
        // Display counter
        write_string("Kernel Running... Counter:", 7, 0x0E);      // Yellow
        
        // Simple counter display (just show if it's even/odd)
        if (counter % 2 == 0) {
            write_string("EVEN", 7, 0x0C);  // Red - at position after "Counter:"
        } else {
            write_string("ODD ", 7, 0x0C);  // Red
        }
        
        counter++;
        if (counter > 1000) counter = 0;  // Reset counter
        
        delay();  // Wait a bit
    }
}
