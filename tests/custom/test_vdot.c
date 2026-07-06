#include <stdint.h>

// Custom instruction macros
// VDOT rd, rs1, rs2: funct7=0000000, funct3=000, opcode=0x0B
#define VDOT(rd, rs1, rs2) \
    asm volatile(".word %3\n" \
        : "=r"(rd) \
        : "r"(rs1), "r"(rs2), \
          "i"(0x0000000B | \
              (((%2) & 0x1f) << 20) | \
              (((%1) & 0x1f) << 15) | \
              (((%0) & 0x1f) << 7)))

// Tohost/fromhost for simulator communication
volatile uint64_t tohost   __attribute__((section(".tohost")))   = 0;
volatile uint64_t fromhost __attribute__((section(".fromhost"))) = 0;

void _start() {
    uint64_t a = 0x0102030401020304ULL; // 4x INT8: [1,2,3,4,1,2,3,4]
    uint64_t b = 0x0102030401020304ULL;
    uint64_t result = 0;

    // VDOT: expected = 1*1 + 2*2 + 3*3 + 4*4 + 1*1 + 2*2 + 3*3 + 4*4 = 60
    VDOT(result, a, b);

    // Signal pass (1) or fail (3) to simulator via tohost
    if (result == 60)
        tohost = 1; // PASS
    else
        tohost = (result << 1) | 1; // FAIL with result encoded

    while(1);
}
