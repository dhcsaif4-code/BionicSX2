#pragma once
#include "plutovg.h"
typedef struct plutosvg_document_t plutosvg_document_t;
plutosvg_document_t* plutosvg_document_load_from_data(const char* data, size_t size, float dpi, float base_width, float base_height, plutovg_surface_t* surface);
float plutosvg_document_get_width(plutosvg_document_t* document);
float plutosvg_document_get_height(plutosvg_document_t* document);
int plutosvg_document_render(plutosvg_document_t* document, void* something, plutovg_canvas_t* canvas, void* a, void* b, void* c);
void plutosvg_document_destroy(plutosvg_document_t* document);
