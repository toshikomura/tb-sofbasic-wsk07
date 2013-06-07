#include <stdio.h>

void *allocate(size_t);
void deallocate(void *);
void imprMapa();

#define malloc allocate
#define free  deallocate 

int main(){
        void *a, *b, *c, *d, *e;

        a = malloc(125);
        b = malloc(13);
        c = malloc(50);
        d = malloc(26);

        imprMapa();

        free(c);
        free(d);

        imprMapa();
        
        a = malloc(250);
        c = malloc(130);

        imprMapa();

        free(a);
        free(b);
        free(c);
        free(d);

        imprMapa();

        return 0;
}
