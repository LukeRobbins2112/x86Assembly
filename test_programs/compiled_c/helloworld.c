
#include <unistd.h>

int main(){

  size_t result = write(1, "hello", 5);

  return 0;
}
