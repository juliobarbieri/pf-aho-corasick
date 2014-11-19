#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <string.h>
#include <iostream>

#define BLOCOS     1
//#define THREAD

#define CHECK_ERROR(call) do {                                                    \
   if( cudaSuccess != call) {                                                             \
      std::cerr << std::endl << "CUDA ERRO: " <<                             \
         cudaGetErrorString(call) <<  " in file: " << __FILE__                \
         << " in line: " << __LINE__ << std::endl;                               \
         exit(0);                                                                                 \
   } } while (0)

using namespace std;

typedef struct automato {
	char letra;
	automato *prox;
	automato *ant;
	automato *inf;
	int final;
} Automato;

__global__ void pfac(Automato* at, int *matches, char *frase){

	int x = blockDim.x * blockIdx.x + threadIdx.x;


}

Automato* newAutomato(Automato* ant) {
	Automato *nv = (Automato*) malloc(sizeof(Automato));
	nv->prox = NULL;
	nv->inf = NULL;
	nv->ant = ant;

	return nv;
}

Automato* addAlgarismo(Automato *at, char algm, int first) {
	if (at != NULL && at->letra == algm && first == 1) {
		return at;
	}
	// Caso algarismo novo seja diferente do algarismo da raiz
	else if (at != NULL && at->letra != algm && first == 1) {
		Automato *pt = at->inf;
		Automato *ant = pt;
		while (pt != NULL) {
			if (pt->letra == algm) {
				return pt;
			}
			else {
				if (pt != NULL) {
					ant = pt;
					pt = pt->inf;
				}

			}
		}
		Automato *nv = newAutomato(at);
		nv->letra = algm;
		if (ant != NULL) {
			ant->inf = nv;
			return ant->inf;
		}
		else {
			at->inf = nv;
			return at->inf;
		}

	}

	else if(at != NULL && first == 0)
	{
		Automato *pt = at->prox;
		Automato *ant = NULL;
		while (pt != NULL) {

			if (pt->letra == algm) {
				return pt;
			}
			else
			{
				ant = pt;
				pt = pt->inf;
			}
		}

		Automato *nv = newAutomato(at);
		nv->letra = algm;

		if (ant != NULL) {
			ant->inf = nv;
		}
		else {
			at->prox = nv;
		}

		return nv;
	}
	else
	{
		Automato *nv = newAutomato(NULL);
		nv->letra = algm;
		return nv;
	}
}

void imprimir(Automato *at)
{
	Automato *temp = at;

	while (temp != NULL) {
		printf("%c ", temp->letra);
		imprimir(temp->prox);
		temp = temp->inf;
		printf("\n");
	}

}

/*Automato* mallocGPU(Automato *at)
{
	Automato *temp = at;

	while (temp != NULL) {
		imprimir(temp->prox);
		temp = temp->inf;
	}
}*/

int main (int argc, char **argv)
{
	int GPU = 0;

	Automato *at = newAutomato(NULL);
	at->letra = 'a';
	at->prox = NULL;

	char frase[255] = "ab abg bede ef"; //"abc acd abb agd acc";
	int THREADS = strlen(frase);

	Automato *temp = at;

	int i = 0;
	int first = 1;

	while(frase[i] != '\0')
	{
		if(frase[i] != ' ')
		{
			temp = addAlgarismo(temp, frase[i], first);
			first = 0;
			//printf("Letra: %c\n", temp->letra);
		}
		else
		{
			temp->final = 1;
			temp = at;
			first = 1;
		}
		i++;

	}
	imprimir(at);

	// CPU
	char h_fita[255] = "ab abg bede ef";
	int *h_matches = (int*) malloc(sizeof(int));

	// GPU
	Automato *d_at = NULL;
	char *d_fita = NULL;
	int *d_matches = NULL;

	CHECK_ERROR(cudaSetDevice(GPU));

	*h_matches = 0;

	//Reset na GPU selecionada
	CHECK_ERROR(cudaDeviceReset());

	CHECK_ERROR(cudaMalloc((void**) &d_at, sizeof(Automato*)));
	CHECK_ERROR(cudaMalloc((void**) &d_fita, 255*sizeof(char)));
	CHECK_ERROR(cudaMalloc((void**) &d_matches, sizeof(int)));

	//Copiando CPU --> GPU
	CHECK_ERROR(cudaMemcpy(d_at, at, sizeof(Automato*),  cudaMemcpyHostToDevice));
	CHECK_ERROR(cudaMemcpy(d_fita, h_fita, 255*sizeof(char),  cudaMemcpyHostToDevice));
	CHECK_ERROR(cudaMemcpy(d_matches, h_matches, sizeof(int),  cudaMemcpyHostToDevice));


	pfac <<<BLOCOS, THREADS>>> (d_at, d_matches, d_fita);

	//Copiando GPU --> CPU
	CHECK_ERROR(cudaMemcpy(at, d_at, sizeof(Automato*),  cudaMemcpyDeviceToHost));
	CHECK_ERROR(cudaMemcpy(h_fita, d_fita, 255*sizeof(char),  cudaMemcpyDeviceToHost));
	CHECK_ERROR(cudaMemcpy(h_matches, d_matches, sizeof(int),  cudaMemcpyDeviceToHost));

	// Liberando memória na GPU
	CHECK_ERROR(cudaFree(d_at));
	CHECK_ERROR(cudaFree(d_fita));
	CHECK_ERROR(cudaFree(d_matches));

	// Liberando memória na CPU
	free(at);
	free(h_matches);
	free(h_fita);


   return EXIT_SUCCESS;
}



