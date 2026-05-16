#pragma once
typedef struct plutovg_surface_t plutovg_surface_t;
typedef struct plutovg_canvas_t plutovg_canvas_t;
plutovg_surface_t* plutovg_surface_create_for_data(unsigned char* data, int w, int h, int stride);
void plutovg_surface_destroy(plutovg_surface_t* surface);
plutovg_canvas_t* plutovg_canvas_create(plutovg_surface_t* surface);
void plutovg_canvas_destroy(plutovg_canvas_t* canvas);
void plutovg_canvas_scale(plutovg_canvas_t* canvas, double x, double y);
void plutovg_canvas_translate(plutovg_canvas_t* canvas, double x, double y);
void plutovg_convert_argb_to_rgba(unsigned char* dst, const unsigned char* src, int width, int height, int stride);
