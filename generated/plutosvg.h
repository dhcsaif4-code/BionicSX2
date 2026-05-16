#pragma once

#include <cstddef>

struct plutosvg_document_t;
struct plutovg_surface_t;
struct plutovg_canvas_t;

extern "C" {

plutosvg_document_t* plutosvg_document_load_from_data(const char* data, size_t size, float dpi, const float* max_width, const float* max_height, plutovg_surface_t* surface);

static inline plutosvg_document_t* plutosvg_document_load_from_data(const char* data, size_t size, float dpi, float max_width, float max_height, plutovg_surface_t* surface) {
    return plutosvg_document_load_from_data(data, size, dpi, &max_width, &max_height, surface);
}

float plutosvg_document_get_width(plutosvg_document_t* document);
float plutosvg_document_get_height(plutosvg_document_t* document);
int plutosvg_document_render(plutosvg_document_t* document, void* definput, plutovg_canvas_t* canvas, void* unused1, void* unused2, void* unused3);
void plutosvg_document_destroy(plutosvg_document_t* document);

}
