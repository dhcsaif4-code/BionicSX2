/* CStubs.c — Pure C file for C-ABI stubs. NO C++ here. */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* DEV9 */
void DEV9init(void) {}
void DEV9open(void) {}
void DEV9close(void) {}
void DEV9shutdown(void) {}
void DEV9async(unsigned int x) {}
void DEV9irqHandler(void) {}
unsigned char  DEV9read8(unsigned int addr)  { return 0; }
unsigned short DEV9read16(unsigned int addr) { return 0; }
unsigned int   DEV9read32(unsigned int addr) { return 0; }
void DEV9write8(unsigned int addr, unsigned char val)   {}
void DEV9write16(unsigned int addr, unsigned short val) {}
void DEV9write32(unsigned int addr, unsigned int val)   {}
void DEV9readDMA8Mem(unsigned int* dst, int size)  {}
void DEV9writeDMA8Mem(unsigned int* src, int size) {}

/* USB */
void USBinit(void) {}
void USBopen(void) {}
void USBclose(void) {}
void USBshutdown(void) {}
void USBreset(void) {}
void USBasync(unsigned int x) {}
unsigned char  USBread8(unsigned int addr)  { return 0; }
unsigned short USBread16(unsigned int addr) { return 0; }
unsigned int   USBread32(unsigned int addr) { return 0; }
void USBwrite8(unsigned int addr, unsigned char val)   {}
void USBwrite16(unsigned int addr, unsigned short val) {}
void USBwrite32(unsigned int addr, unsigned int val)   {}

/* VIF / JIT */
void VifUnpackSSE_Init(void) {}
void vtlb_DynBackpatchLoadStore(unsigned long a, unsigned int b,
    unsigned int c, unsigned int d, unsigned int e, unsigned int f,
    unsigned char g, unsigned char h, unsigned char i,
    int j, int k, int l) {}

/* Misc */
void ShortSpin(void) {}
void GetOpticalDriveList(void) {}
void GetMetalAdapterList(void) {}

/* Memory alignment */
void* _aligned_malloc(unsigned long size, unsigned long align) {
    void* p = NULL;
    if (align < sizeof(void*)) align = sizeof(void*);
    posix_memalign(&p, align, size);
    return p;
}
void _aligned_free(void* p) { free(p); }

/* Assert */
void pxOnAssertFail(const char* msg, int line,
                    const char* file, const char* func) {
    fprintf(stderr, "[BionicSX2] Assert %s:%d %s: %s\n", file, line, func, msg);
    abort();
}

/* BC decompression */
void DecompressBlockBC1(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* s, unsigned char* d) {}
void DecompressBlockBC2(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* s, unsigned char* d) {}
void DecompressBlockBC3(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* s, unsigned char* d) {}

/* Discord */
void Discord_Initialize(const char* a, void* b, int c, const char* d) {}
void Discord_Shutdown(void) {}
void Discord_RunCallbacks(void) {}
void Discord_UpdatePresence(const void* p) {}
void Discord_ClearPresence(void) {}

/* 7z / CRC tables */
void CrcGenerateTable(void) {}
void Crc64GenerateTable(void) {}

/* cplus_demangle */
char* cplus_demangle(const char* m, int o) { return NULL; }
int cplus_demangle_opname(const char* o, void* r, int f) { return 0; }
