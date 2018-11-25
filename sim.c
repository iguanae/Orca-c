#include "field.h"
#include "sim.h"

static Term const indexed_terms[] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd',
    'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '.', '*', ':', ';', '#',
};

enum { Terms_array_num = sizeof indexed_terms };

static inline size_t index_of_term(Term c) {
  for (size_t i = 0; i < Terms_array_num; ++i) {
    if (indexed_terms[i] == c)
      return i;
  }
  return SIZE_MAX;
}

static inline Term term_lowered(Term c) {
  return (c >= 'A' && c <= 'Z') ? (char)(c - ('a' - 'A')) : c;
}

// Always returns 0 through (sizeof indexed_terms) - 1, and works on
// capitalized terms as well. The index of the lower-cased term is returned if
// the term is capitalized.
static inline size_t semantic_index_of_term(Term c) {
  Term c0 = term_lowered(c);
  for (size_t i = 0; i < Terms_array_num; ++i) {
    if (indexed_terms[i] == c0)
      return i;
  }
  return 0;
}

static inline Term terms_sum(Term a, Term b) {
  size_t ia = semantic_index_of_term(a);
  size_t ib = semantic_index_of_term(b);
  return indexed_terms[(ia + ib) % Terms_array_num];
}

static inline Term terms_mod(Term a, Term b) {
  size_t ia = semantic_index_of_term(a);
  size_t ib = semantic_index_of_term(b);
  return indexed_terms[ib == 0 ? 0 : (ia % ib)];
}

static inline void act_a(Field* f, size_t y, size_t x) {
  Term inp0 = field_peek_relative(f, y, x, 0, 1);
  Term inp1 = field_peek_relative(f, y, x, 0, 2);
  if (inp0 != '.' && inp1 != '.') {
    Term t = terms_sum(inp0, inp1);
    field_poke_relative(f, y, x, 1, 0, t);
  }
}

static inline void act_m(Field* f, size_t y, size_t x) {
  Term inp0 = field_peek_relative(f, y, x, 0, 1);
  Term inp1 = field_peek_relative(f, y, x, 0, 2);
  if (inp0 != '.' && inp1 != '.') {
    Term t = terms_mod(inp0, inp1);
    field_poke_relative(f, y, x, 1, 0, t);
  }
}

void orca_run(Field* f) {
  size_t ny = f->height;
  size_t nx = f->width;
  Term* f_buffer = f->buffer;
  for (size_t iy = 0; iy < ny; ++iy) {
    Term* row = f_buffer + iy * nx;
    for (size_t ix = 0; ix < nx; ++ix) {
      Term c = row[ix];
      switch (c) {
      case 'a':
        act_a(f, (U32)iy, (U32)ix);
        break;
      case 'm':
        act_m(f, (U32)iy, (U32)ix);
        break;
      }
    }
  }
}