#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//definindo um n�
typedef struct Node{
    int valor;
    int altura;
    int fatorBalanceamento;
    int alturaDireita;
    int alturaEsquerda;
    struct Node *pai;
    struct Node *filhoDir;
    struct Node *filhoEsq;
} Node;
//Definindo uma �rvore
typedef struct Tree{
    Node *raiz;
}Tree;

///Todas as buscas s�o feitas apartir da raiz
Node* buscar(int valor, Node*raiz){

    Node*resultado = NULL;

    if(raiz != NULL){
        Node *ptr= raiz;
        Node *aux = NULL;

        //Enquanto o endereco de mem�ria armazenado em PTR for diferente de nulo
        while(ptr!=NULL){
            if(valor < ptr->valor){
                aux = ptr;
                ptr = ptr->filhoEsq;
            }
            else if(valor > ptr->valor){
                aux = ptr;
                ptr = ptr->filhoDir;
            }
            else{
                aux = ptr;
                ptr = NULL;
            }
            resultado = aux; //Retorna o candidato a pai do novo n�
        }
    }

    return resultado;

}

//Funcao para calcular o fator de balanceamento
void calcularFatorBalanceamento(Node *noInserido){

    Node *ptr;
    ptr = noInserido;

    if(ptr->filhoEsq != NULL){
        ptr->filhoEsq->alturaEsquerda = ptr->filhoEsq->alturaEsquerda;
    }
    else{
        ptr->filhoEsq->alturaEsquerda = 0;
    }
    if(ptr->filhoDir != NULL){
        ptr->filhoDir->alturaDireita= ptr->filhoDir->alturaDireita;
    }
    else{
        ptr->filhoDir->alturaDireita =0 ;
    }

    ptr->fatorBalanceamento = ptr->alturaDireita - ptr->alturaEsquerda;

    ptr->altura = fmax(ptr->alturaDireita,ptr->alturaEsquerda) + 1;

}

//Inser��o de  novo valor
Node *inserir(int valor,Tree*arvore){
    Node *resultado = NULL;
    resultado = buscar(valor,arvore->raiz);

    if(resultado != NULL){
        //Comparando se o valor do n� que eu encontrei � diferente do que eu quero inserir
        if(resultado->valor != valor){
            if(valor < resultado->valor){
                resultado->filhoEsq = malloc(sizeof(Node)); // Alocando espa�o para o filho da esquerda
                resultado->filhoEsq->valor = valor; //Noovo valor � inserido
                resultado->filhoEsq->altura = resultado->altura + 1; // Ajustando a altura do novo n�
                //inicializando fatores de balanceamento e altura de sub arvore do novo n� inserido
                //resutado->filhoEsq->fatorBalanceamento = 0;
                //resultado->filhoEsq->alturaEsquerda = 0;
                //resultado->filhoEsq->alturaDireita = 0;
                //Calcualar balanceamento do n� inserido
                calcularFatorBalanceamento(resultado->filhoEsq);


            }
            else if(valor > resultado->valor){
                resultado->filhoDir = malloc(sizeof(Node));//Alocando espa�o para o filho da esquerda
                resultado->filhoDir->valor = valor; // Inserindo valor
                resultado->filhoDir->altura = resultado->altura + 1; // Ajustando a altura do novo n�
                //inicializando fatores de balanceamento e altura de sub arvore
                //resutado->filhoDir->fatorBalanceamento = 0;
                //resultado->filhoDir->alturaEsquerda = 0;
                //resultado->filhoDir->alturaDireita = 0;
                //ajustando balanceamento
                calcularFatorBalanceamento(resultado->filhoDir);
            }
        }
    }
    else{
        //Primeiro n� da �rvore
        //Inicializando valores do n� raiz
        arvore->raiz->valor = valor;
        arvore->raiz->altura = 0;
        arvore->raiz->fatorBalanceamento = 0;
        arvore->raiz->alturaEsquerda = 0;
        arvore->raiz->alturaDireita = 0;
        arvore->raiz->filhoDir = NULL;
        arvore->raiz->filhoEsq = NULL;
        arvore->raiz->pai = NULL;
    }

}


int main(){


    return 0;
}
