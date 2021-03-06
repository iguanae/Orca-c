#pragma once
#include "base.h"
#include <stdio.h> // FILE cannot be forward declared

// A reusable buffer for glyphs, stored with its dimensions. Also some helpers
// for loading/saving from files and doing common operations that a UI layer
// might want to do. Not used by the VM.

typedef struct {
  Glyph* buffer;
  U16 height;
  U16 width;
} Field;

void field_init(Field* field);
void field_init_fill(Field* field, Usz height, Usz width, Glyph fill_char);
void field_deinit(Field* field);
void field_resize_raw(Field* field, Usz height, Usz width);
void field_resize_raw_if_necessary(Field* field, Usz height, Usz width);
void field_copy(Field* src, Field* dest);
void field_fput(Field* field, FILE* stream);

typedef enum {
  Field_load_error_ok = 0,
  Field_load_error_cant_open_file = 1,
  Field_load_error_too_many_columns = 2,
  Field_load_error_too_many_rows = 3,
  Field_load_error_no_rows_read = 4,
  Field_load_error_not_a_rectangle = 5,
} Field_load_error;

Field_load_error field_load_file(char const* filepath, Field* field);
