#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

#define DOMINO 		  4096
#define BLOCOS        8
#define THREAD		  

#define CHECK_ERROR(call) do {                                                    \
   if( cudaSuccess != call) {                                                             \
      std::cerr << std::endl << "CUDA ERRO: " <<                             \
         cudaGetErrorString(call) <<  " in file: " << __FILE__                \
         << " in line: " << __LINE__ << std::endl;                               \
         exit(0);                                                                                 \
   } } while (0)

typedef struct automato {
	char letra;
	automato *prox;
	automato *ant;
	automato *inf;
	int final;
} Automato;

__global__ void automato(char** alfabeto, char *frase){
	int matchs = 0;
	int xAtual = 0;
	int yAtual = 0;
	int x = blockDim.x * blockIdx.x + threadIdx.x;
	int i = 0;
	for (i = 0; i < 5; i++) {
		if (frase[x] != alfabeto[xAtual][yAtual])
			break;
		else
			matchs++;
	}
	
	
}

Automato* newAutomato(Automato* ant) {
	Automato *nv = (Automato*) malloc(sizeof(Automato));
	nv->prox = NULL;
	nv->inf = NULL;
	nv->ant = ant;
	
	return nv;
}

Automato* addAlgarismo(Automato *at, char algm) {
	if(at != NULL)
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
	char frase[255];
	int i =0;
	int pos = 0;
	Automato *temp = at;	
	while(temp != NULL)
	{	
		Automato *ant;
		do
		{
			frase[i] = temp->letra;			
			i++;
			ant = temp; 
			temp= temp->prox;
		}while(temp != NULL);
		temp = ant;
		
		int j = 0;
		while(j <= pos && temp != NULL )
		{
			temp = temp->inf;
			j++;
		}
		pos++;
		
		if(temp == NULL)
		{
			temp = ant->ant; //Caralho!
			pos = 0;
		}
		printf("Run to the Hills\n");
						
	}
	printf("%s\n",frase);	

}

int main (int argc, char **argv)
{	
	Automato *at = newAutomato(NULL);
	at->letra = 'a';
	at->prox = NULL;
	
	

	//char m[3][3] = {"abc",
	//				"acc",
	//				"adc"};
	
	char frase[255] = "abc acd abb agd acc";
	Automato *temp = at;
	int i=0;
	while(frase[i] != '\0')
	{
		if(frase[i] != ' ')
		{
			temp = addAlgarismo(temp, frase[i]);
			//printf("Letra: %c\n", temp->letra); 
		}
		else
		{
			temp->final = 1;
			temp = at;
		}
		i++;
		
	}  
	imprimir(at);
   return EXIT_SUCCESS;
}





