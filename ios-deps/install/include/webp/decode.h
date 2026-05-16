#pragma once
#include <stddef.h>
#include <stdint.h>
typedef struct WebPDecoderConfig WebPDecoderConfig;
static inline int WebPGetInfo(const uint8_t* d, size_t s,
  int* w, int* h) { return 0; }
static inline uint8_t* WebPDecodeRGBA(const uint8_t* d,
  size_t s, int* w, int* h) { return nullptr; }
static inline uint8_t* WebPDecodeRGBAInto(
  const uint8_t* d, size_t s,
  uint8_t* out, size_t out_size, int stride) { return nullptr; }
static inline void WebPFree(void* p) {}
