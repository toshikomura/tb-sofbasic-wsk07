#include <stdio.h>
#include <time.h>
#include "gv07-wsk07.h"

#define MAX_ELEM 16
#define TAM_MAX  64
#define NUM_OPER 32


// ---------
#define malloc allocate
#define free   deallocate
// ---------


int main ( int argc, char** argv ) {

  void *vetor[MAX_ELEM+1];
  int i, j, tam;

  // faz cada elemento do vetor apontar para NULL
  for (i=0; i<MAX_ELEM; i++)
    vetor[i] = NULL;

  // gera uma semente baseada no tempo atual para os números
  // aleatórios.
  srand (time(0));

  // inicia a metade superior do conjunto de elementos
  for ( i=0; i<MAX_ELEM/2; i++ ) {
    tam = (rand () % TAM_MAX);  // tam = [0..TAM_MAX]
    printf("Alocando %d bytes em vetor[%d]\n", tam, i );
    vetor[i] = malloc (tam+1);
  }

  // Serão tentadas NUM_OPER operações de alocacao/liberacao 
  for (i=0; i<NUM_OPER; i++) 
    {
      j = rand () % MAX_ELEM;  // j = [0..TAM_MAX]
      if ( vetor[j] == NULL ) // aloca elemento
        { 
          tam = (rand () % TAM_MAX);  // tam = [0..TAM_MAX]
          printf("Alocando %d bytes em vetor[%d]\n", tam, j );
          vetor[j] = malloc (tam+1);
          //imprMapa ();
        } 
      else
        {
          printf("Liberando vetor[%d]\n", j );
          free(vetor[j]);
          vetor[j] = NULL;
          //imprMapa ();
        }
    } 

  imprMapa ();
   printf("Libero saiu\n");

  for (i=0; i<MAX_ELEM; i++)
    if (vetor[i] != NULL){
      free (vetor[i]);
    }

  imprMapa ();
}
