#pragma once

#include <cstddef>
#include <csetjmp>

struct jpeg_error_mgr
{
    jmp_buf jbuf;
};
struct jpeg_destination_mgr
{
};
struct jpeg_compress_struct
{
    jpeg_error_mgr* err;
    jpeg_destination_mgr* dest;
    int image_width;
    int image_height;
    int input_components;
    int in_color_space;
};
struct jpeg_decompress_struct
{
    jpeg_error_mgr* err;
    int image_width;
    int image_height;
    int output_components;
    int output_color_space;
};

struct jpeg_compress_struct;
struct jpeg_decompress_struct;

#define JCS_GRAYSCALE 1
#define JCS_RGB 2
#define JCS_YCbCr 3
#define JCS_CMYK 4
#define JCS_YCCK 5

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

extern "C" {

void jpeg_std_error(jpeg_error_mgr* err);
void jpeg_create_compress(jpeg_compress_struct* cinfo, int version, size_t structsize);
void jpeg_create_decompress(jpeg_decompress_struct* cinfo, int version, size_t structsize);
void jpeg_set_defaults(jpeg_compress_struct* cinfo);
void jpeg_set_quality(jpeg_compress_struct* cinfo, int quality, int force_baseline);
void jpeg_start_compress(jpeg_compress_struct* cinfo, int write_all_tables);
int jpeg_write_scanlines(jpeg_compress_struct* cinfo, unsigned char** scanlines, int max_lines);
void jpeg_finish_compress(jpeg_compress_struct* cinfo);
void jpeg_destroy_compress(jpeg_compress_struct* cinfo);
int jpeg_read_header(jpeg_decompress_struct* cinfo, int require_image);
int jpeg_start_decompress(jpeg_decompress_struct* cinfo);
int jpeg_read_scanlines(jpeg_decompress_struct* cinfo, unsigned char** scanlines, int max_lines);
void jpeg_finish_decompress(jpeg_decompress_struct* cinfo);
void jpeg_destroy_decompress(jpeg_decompress_struct* cinfo);
void jpeg_mem_src(jpeg_decompress_struct* cinfo, const unsigned char* data, unsigned long size);

}

#define JPEG_LIB_VERSION 80
#define jpeg_create_compress(cinfo) jpeg_create_compress(cinfo, JPEG_LIB_VERSION, sizeof(jpeg_compress_struct))
#define jpeg_create_decompress(cinfo) jpeg_create_decompress(cinfo, JPEG_LIB_VERSION, sizeof(jpeg_decompress_struct))
