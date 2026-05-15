#pragma once

#include <cstddef>

struct plutovg_surface_t;
struct plutovg_canvas_t;

extern "C" {

plutovg_surface_t* plutovg_surface_create_for_data(unsigned char* data, int width, int height, int stride);
void plutovg_surface_destroy(plutovg_surface_t* surface);
plutovg_canvas_t* plutovg_canvas_create(plutovg_surface_t* surface);
void plutovg_canvas_destroy(plutovg_canvas_t* canvas);
void plutovg_canvas_scale(plutovg_canvas_t* canvas, double sx, double sy);
void plutovg_canvas_translate(plutovg_canvas_t* canvas, double tx, double ty);
void plutovg_convert_argb_to_rgba(unsigned char* dst, const unsigned char* src, int stride, int width, int height);

}
