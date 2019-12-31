

/*
 *asm_functions.h
 *
 * Used for 'extern' declarations, to simplify test file
 */

//------------------
// Main API
//------------------

extern int mm_init();
extern void * mm_alloc(size_t size);
extern void mm_free(void * ptr);

//------------------
// Helper functions
//------------------


//------------------
// Macros
//------------------

extern long MAX(long a, long b);
extern long PACK(long size, long alloc_flag);

extern long GET(void * ptr);
extern void PUT(void * ptr, long val);

extern long GET_SIZE(void * ptr);
extern long GET_ALLOC(void * ptr);

extern void * HDRP(void * ptr);
extern void * FTRP(void * ptr);
extern void NEXT_BLKP(void * ptr);
extern void PREV_BLKP(void * ptr);
