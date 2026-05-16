#pragma once
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

typedef unsigned char JSAMPLE;
typedef JSAMPLE* JSAMPROW;
typedef JSAMPROW* JSAMPARRAY;
typedef unsigned int JDIMENSION;
typedef int boolean;
typedef unsigned char JOCTET;

#define JPEG_EOI      0xD9
#define JPEG_HEADER_OK 1
#define JMSG_LENGTH_MAX 200
#define JCS_UNKNOWN   0
#define JCS_GRAYSCALE 1
#define JCS_RGB       2
#define JCS_YCbCr     3
#define JCS_CMYK      4
#define JCS_YCCK      5
#define JCS_EXT_RGB   6
#define JCS_EXT_RGBA  7
#define TRUE  1
#define FALSE 0

typedef int J_COLOR_SPACE;

struct jpeg_error_mgr {
  void (*error_exit)(void*);
  void (*output_message)(void*);
  void (*format_message)(void*, char*);
  void (*reset_error_mgr)(void*);
  int msg_code;
  char jpeg_message_table[1][JMSG_LENGTH_MAX];
  int last_jpeg_message;
  int num_warnings;
  char* addon_message_table;
  int first_addon_message;
  int last_addon_message;
};

struct jpeg_source_mgr {
  const JOCTET* next_input_byte;
  size_t bytes_in_buffer;
  void (*init_source)(void*);
  boolean (*fill_input_buffer)(void*);
  void (*skip_input_data)(void*, long);
  boolean (*resync_to_restart)(void*, int);
  void (*term_source)(void*);
};

struct jpeg_decompress_struct {
  struct jpeg_error_mgr* err;
  void* mem;
  void* progress;
  void* client_data;
  boolean is_decompressor;
  int global_state;
  struct jpeg_source_mgr* src;
  JDIMENSION image_width;
  JDIMENSION image_height;
  int num_components;
  J_COLOR_SPACE jpeg_color_space;
  J_COLOR_SPACE out_color_space;
  J_COLOR_SPACE output_color_space;
  unsigned int scale_num;
  unsigned int scale_denom;
  double output_gamma;
  boolean buffered_image;
  boolean raw_data_out;
  int dct_method;
  boolean do_fancy_upsampling;
  boolean do_block_smoothing;
  boolean quantize_colors;
  int dither_mode;
  boolean two_pass_quantize;
  int desired_number_of_colors;
  boolean enable_1pass_quant;
  boolean enable_external_quant;
  boolean enable_2pass_quant;
  JDIMENSION output_width;
  JDIMENSION output_height;
  int out_color_components;
  int output_components;
  int rec_outbuf_height;
  int actual_number_of_colors;
  void* colormap;
  JDIMENSION output_scanline;
  int input_scan_number;
  JDIMENSION input_iMCU_row;
  int output_scan_number;
  JDIMENSION output_iMCU_row;
  int (*coef_bits)[64];
  void* quant_tbl_ptrs[4];
  void* dc_huff_tbl_ptrs[4];
  void* ac_huff_tbl_ptrs[4];
  int data_precision;
  void* comp_info;
  boolean progressive_mode;
  boolean arith_code;
  unsigned char arith_dc_L[16];
  unsigned char arith_dc_U[16];
  unsigned char arith_ac_K[16];
  unsigned int restart_interval;
  boolean saw_JFIF_marker;
  uint8_t JFIF_major_version;
  uint8_t JFIF_minor_version;
  uint8_t density_unit;
  uint16_t X_density;
  uint16_t Y_density;
  boolean saw_Adobe_marker;
  uint8_t Adobe_transform;
  boolean CCIR601_sampling;
  void* marker_list;
  int max_h_samp_factor;
  int max_v_samp_factor;
  int min_DCT_scaled_size;
  JDIMENSION total_iMCU_rows;
  void* sample_range_limit;
  int comps_in_scan;
  void* cur_comp_info[4];
  JDIMENSION MCUs_per_row;
  JDIMENSION MCU_rows_in_scan;
  int blocks_in_MCU;
  int MCU_membership[10];
  int Ss, Se, Ah, Al;
  int unread_marker;
  void* master;
  void* main;
  void* coef;
  void* post;
  void* inputctl;
  void* marker;
  void* entropy;
  void* idct;
  void* upsample;
  void* cconvert;
  void* cquantize;
};

struct jpeg_destination_mgr {
  JOCTET* next_output_byte;
  size_t free_in_buffer;
  void (*init_destination)(j_compress_ptr);
  boolean (*empty_output_buffer)(j_compress_ptr);
  void (*term_destination)(j_compress_ptr);
};

struct jpeg_compress_struct {
  struct jpeg_error_mgr* err;
  void* mem;
  void* progress;
  void* client_data;
  boolean is_decompressor;
  int global_state;
  struct jpeg_destination_mgr* dest;
  JDIMENSION image_width;
  JDIMENSION image_height;
  int input_components;
  J_COLOR_SPACE in_color_space;
  double input_gamma;
  int data_precision;
  int num_components;
  J_COLOR_SPACE jpeg_color_space;
  void* comp_info;
  void* quant_tbl_ptrs[4];
  void* dc_huff_tbl_ptrs[4];
  void* ac_huff_tbl_ptrs[4];
  int num_scans;
  const void* scan_info;
  boolean raw_data_in;
  boolean arith_code;
  boolean optimize_coding;
  boolean CCIR601_sampling;
  int smoothing_factor;
  int dct_method;
  unsigned int restart_interval;
  int restart_in_rows;
  boolean write_JFIF_header;
  uint8_t JFIF_major_version;
  uint8_t JFIF_minor_version;
  uint8_t density_unit;
  uint16_t X_density;
  uint16_t Y_density;
  boolean write_Adobe_marker;
  JDIMENSION next_scanline;
  boolean progressive_mode;
  int max_h_samp_factor;
  int max_v_samp_factor;
  JDIMENSION total_iMCU_rows;
  int comps_in_scan;
  void* cur_comp_info[4];
  JDIMENSION MCUs_per_row;
  JDIMENSION MCU_rows_in_scan;
  int blocks_in_MCU;
  int MCU_membership[10];
  int Ss, Se, Ah, Al;
  void* master;
  void* main;
  void* prep;
  void* coef;
  void* marker;
  void* cconvert;
  void* downsample;
  void* fdct;
  void* entropy;
  void* script_space;
  int script_space_size;
};

typedef void* j_common_ptr;
typedef struct jpeg_decompress_struct* j_decompress_ptr;
typedef struct jpeg_compress_struct* j_compress_ptr;

#ifdef __cplusplus
extern "C" {
#endif
struct jpeg_error_mgr* jpeg_std_error(struct jpeg_error_mgr*);
void jpeg_create_decompress(j_decompress_ptr);
void jpeg_create_compress(j_compress_ptr);
void jpeg_stdio_src(j_decompress_ptr, FILE*);
void jpeg_mem_src(j_decompress_ptr, const unsigned char*, unsigned long);
void jpeg_mem_dest(j_compress_ptr, unsigned char**, unsigned long*);
int  jpeg_read_header(j_decompress_ptr, boolean);
boolean jpeg_start_decompress(j_decompress_ptr);
JDIMENSION jpeg_read_scanlines(j_decompress_ptr, JSAMPARRAY, JDIMENSION);
boolean jpeg_finish_decompress(j_decompress_ptr);
void jpeg_destroy_decompress(j_decompress_ptr);
void jpeg_destroy_compress(j_compress_ptr);
void jpeg_set_defaults(j_compress_ptr);
void jpeg_set_quality(j_compress_ptr, int, boolean);
void jpeg_start_compress(j_compress_ptr, boolean);
JDIMENSION jpeg_write_scanlines(j_compress_ptr, JSAMPARRAY, JDIMENSION);
void jpeg_finish_compress(j_compress_ptr);
void jpeg_mem_src_custom(j_decompress_ptr cinfo,
  const JOCTET* buf, size_t bufsize);
boolean jpeg_resync_to_restart(j_decompress_ptr, int);
#ifdef __cplusplus
}
#endif
