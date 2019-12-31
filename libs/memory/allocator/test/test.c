
#include <stdio.h>
#include "minunit.h"
#include "asm_functions.h"

int tests_run = 0;

static char * mm_init_test(){

  int res = mm_init();
  mu_assert("mm_init failed\n", res == 0);
  return 0;
}

static char * first_malloc(){

  void * ptr = mm_alloc(4);
  mu_assert("Initial mm_alloc failed\n", ptr != 0);
  return 0;
}

static char * runtests(){

  mu_run_test(mm_init_test);
  mu_run_test(first_malloc);
  
  return 0;
}

int main(){

  char * result = runtests();

  printf("Tests run: %d\n", tests_run);
  
  if (result == 0){
    printf("Tests passed\n");
  } else {
    printf("%s\n", result);
  }

  
  return 0;

}
