
#include <stdio.h>
#include "minunit.h"

extern int mm_init();

int tests_run = 0;

static char * test1(){

  mu_assert("failed", 0 == 0);
  return 0;
}

static char * runtests(){

  mu_run_test(test1);
  return 0;
}

int main(){

  int res = mm_init();

  char * result = runtests();
  if (result == 0){
    printf("Test passed\n");
  }
  
  return 0;

}
