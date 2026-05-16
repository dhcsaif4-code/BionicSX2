#pragma once
#include <stddef.h>

typedef struct plutosvg_document_t plutosvg_document_t;
typedef struct plutovg_surface_t plutovg_surface_t;

#ifdef __cplusplus
extern "C" {
#endif

/* Variadic-friendly stub — accepts any numeric combination */
static inline plutosvg_document_t* plutosvg_document_load_from_data(
  const char* data, size_t size, ...) {
  (void)data; (void)size;
  return (plutosvg_document_t*)0;
}

static inline void plutosvg_document_destroy(plutosvg_document_t* doc) {
  (void)doc;
}

static inline plutovg_surface_t* plutosvg_document_render_to_surface(
  plutosvg_document_t* doc, int width, int height,
  plutovg_surface_t* surface) {
  (void)doc; (void)width; (void)height; (void)surface;
  return (plutovg_surface_t*)0;
}

#ifdef __cplusplus
}
#endif
