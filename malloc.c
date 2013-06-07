#include <stdio.h>
#include <time.h>
#include "tt.h"

#define MAX_ELEM 4
#define TAM_MAX  16
#define NUM_OPER 8

#define malloc allocate
#define free  deallocate 

int main () {
  void *vetor[MAX_ELEM+1];
  int i, j, tam;
  
  
  for (i=0; i<MAX_ELEM; i++){
    vetor[i] = NULL;
  }

  srand (time(0));
  for ( i=0; i<MAX_ELEM/2; i++ ){
    tam = rand () % TAM_MAX;  
    vetor[i]= malloc (tam+1);
    printf("Alocando %d bytes em vetor[%d]\n", tam, i );
  }
  
  for (i=0; i<NUM_OPER; i++){
      j = rand () % MAX_ELEM;  
      if ( vetor[j] == NULL ){ 
          tam = rand () % TAM_MAX;  
          printf("Alocando %d bytes em vetor[%d]\n", tam, j );
          vetor[j] = malloc (tam+1);
      } 
      else{
          printf("Liberando vetor[%d]\n", j );
          free ( vetor[j] );
          vetor[j] = NULL;
      }
  }    
  
  imprMapa();
  
  for (i=0; i<MAX_ELEM; i++)
    if (vetor[i] != NULL)
      free (vetor[i]);

  imprMapa();
}
