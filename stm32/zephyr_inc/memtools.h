/*
  memtools.h
  June 2019

  Tools for anlysing and debugging memory on stm32.  See also debug_alloc.h
*/

#ifndef __MEMTOOLS__
#define __MEMTOOLS__
void memtools_find_unused( int (*printf_func)(const char *fmt, ...) );
//register char * memtools_sp asm ("sp");
void memtools_isnan(float *vec, int n, char *label, int (*printf_func)(const char *fmt, ...));
void *codec2_malloc();
void codec2_free(void *ptr);
void *codec2_calloc();

#define MALLOC(size) codec2_malloc(size)

#define CALLOC(nmemb, size) codec2_calloc(nmemb, size)

#define FREE(ptr) codec2_free(ptr)
#endif
