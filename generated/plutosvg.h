#pragma once

#include <cstddef>

struct plutosvg_document_t;
struct plutovg_canvas_t;

extern "C" {

plutosvg_document_t* plutosvg_document_load_from_data(const char* data, size_t size);
float plutosvg_document_get_width(plutosvg_document_t* document);
float plutosvg_document_get_height(plutosvg_document_t* document);
int plutosvg_document_render(plutosvg_document_t* document, void* definput, plutovg_canvas_t* canvas, void* unused1, void* unused2, void* unused3);
void plutosvg_document_destroy(plutosvg_document_t* document);

}
