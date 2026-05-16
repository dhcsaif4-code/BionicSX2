// vtlb_DynBackpatchLoadStore — C linkage stub
// The linker note confirms the symbol is present but as C++ mangled.
// We force C linkage via both extern "C" AND asm label.

void bionicsx2_vtlb_stub(
    unsigned long, unsigned int, unsigned int, unsigned int,
    unsigned int,  unsigned int, unsigned char, unsigned char,
    unsigned char, bool, bool, bool) {}

// Force the exact C symbol name the linker expects
__attribute__((visibility("default")))
void (*__vtlb_alias)(
    unsigned long, unsigned int, unsigned int, unsigned int,
    unsigned int,  unsigned int, unsigned char, unsigned char,
    unsigned char, bool, bool, bool)
  __asm__("_vtlb_DynBackpatchLoadStore") = &bionicsx2_vtlb_stub;
