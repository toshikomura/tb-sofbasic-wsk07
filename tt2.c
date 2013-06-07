#include <stdio.h>
#include "gv07-wsk07.h"

#define malloc allocate
#define free  deallocate 
#define realloc reallocate

int main(){
        void *a, *b, *c, *d, *e;

        a = malloc(100);
        b = malloc(200);
        c = malloc(300);
        d = malloc(400);
        imprMapa();

        realloc(d,500);
        imprMapa();
        

        return 0;
}
