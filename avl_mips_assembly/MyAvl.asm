.data

#Estruturas ============================================================
#Node: .space 28 #Este é o espaço da estrutura nó
memory: .space 20000
TreeRoot: .space 4      #Este é o espaço onde será guardado O endereco de memoria da raiz
valAlocation: .space 4  #alocndo espaço para deslocamento de alocacao
valDecremento: .space 4 #O espaço onde está gravado o valor do decremento 
bufferValor: .space 4 #alocando espaco para o valor
#Arquivos ==============================================================
buffer: .space 8
espaco: .asciiz " "
fin: .asciiz "../AvlAssembly/tree.in"
fout: .asciiz "../AvlAssembly/tree.out"
.text
	#Abrindo Arquivo
	li $v0, 13
	la $a0, fin
	li $a1, 0
	li $a2, 0
	syscall
	
	addi $s7, $v0, 0 #Salvando descritor do arquivo
	#Lendo arquivo
	li $v0, 14
	addi $a0, $s7, 0
	la $a1, buffer	#Salvando no buffer
	li $a2, 8
	syscall
	
	li $v0, 16
	addi $a0, $s7, 0 # depois de ler o arquivo eu posso usar o registrador $s7
	syscall  
	
	
main:
	#Zerando $v0
	addi $v0, $zero, 0	
	
	li $a0, 0    #Zeraando $a0
	li $v0, 42
	li $a1, 501 #Gerando numeros aleatórios entre 0 e 500
	syscall
	
	#Carregando no buffer
	la $s0, buffer
	lw $a0, 0($s0) #Carregando N
	
	addi $t8, $a0, 0  #Salvando o numero total de inteiros em $t8
	sw $t8, valDecremento #Salvando na memoria
	
			
#InserirValores
inserindoValores:	
	beq $t8, 0, endInserindoValores	
	addi $t8, $zero, 0    #Zerando $t8 para uso posterior
	
	#li $t8, buffer #aquiFoiModifica
	#inserindo nodes sem loop
	#lw $a0, 4($t8)    #Incializando a semente
	li $t8, 4 #aquiFoiModifica
	addi $a0, $t8, 0
	li $v0, 42
	li $a1, 9999 #Gerando numeros aleatórios entre 0 e 10000
	syscall 
	
	addi $t8, $zero, 0    #Zerando $t8 para uso posterior
	
	addi $v0, $zero, 0 #zerando 
	
	la $a1, TreeRoot
	jal inserir
	
	lw $t8, valDecremento
	addi $t8, $t8, -1
	sw $t8, valDecremento
	j inserindoValores
endInserindoValores:	

#Escrevendo em arquivo
	li $v0, 13
	la $a0, fout
	li $a1, 1 #abrindo o arquivo para escrita
	li $a2, 0	
	syscall
	
	addi $s7, $v0, 0 #salvando o descritor do arquivo em $s7
	
	lw $a1, TreeRoot #carregando o endereco salvo na raiz da arvore
	addi $t0,$zero, 0 #zerando $t0
	jal buscaOrdem

	li $v0, 16
	addi $a0, $s7, 0
	syscall	
	
	#terminando programa
	li $v0, 10
	syscall 
		
#chamada de funcoes
#a1 endereco do no raiz da arvore
#a0 valor buscado
# $t1 = ptr, $t2 = auxiliar, $t0 o valor carregado
buscar: addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t0, 0($a1)   #Carregando o conteudo do no raiz
	addi $t3, $a0, 0 #Salvando o valor buscado em $t3
	addi $t1, $a1, 0 #salvando o endereco do node Raiz em $t1
	
	beq $t0, 0, endLoopBusca #Se o nó for nulo
	lw $t6, 0($a1)		 #Salvando endereco Tuardado na raiz	
	lw $t0 , 0($t6) 	 #Carregando em Valor o valor do no raiz
	la $t2, 0		 #zerando auxiliar
	la $t1, ($t6) 		 #CarregandoEndereco		
	loopBusca:
		beq $t1, 0, endLoopBusca
		slt $t7, $t3,$t0	#se o valor buscado for menor
		bne $t7, 1, verMaior
		addi $t2, $t1,0	  #salvando o endereco de PTR em auxiliar
		lw $t1, 24($t1)	  #carrgando o endereco do filho mais a esquerda 
		addi $v0, $t2,0	  #Salvando o endereco do possivel pai
		beq $t1, 0, enderecoNulo1
			lw $t0,0($t1)	  #carregando proximo valor para comparacao		
		enderecoNulo1:
		j loopBusca
	verMaior:
		sgt $t7, $t3, $t0
		bne $t7,1, elseLB
		addi $t2, $t1,0	  #salvando o endereco de PTR em auxiliar
		lw $t1, 28($t1)	  #carrgando o endereco do filho mais a direita 
		addi $v0, $t2, 0 	  #Salvando o endereco do possivel pai
		beq $t1, 0, enderecoNulo2
			lw $t0,0($t1)	  #carregando proximo valor para comparacao		
		enderecoNulo2:	
		j loopBusca	
	elseLB:
		addi $t2, $t1, 0  	#salvando o endereco do potencial aux em $t2		
		addi $t1 , $zero, 0 #zerando ptr		
		addi $v0, $t2, 0 	#Salvando o endereco do potencial pai em $v0 para retorno
	endLoopBusca:
		#final da função buscar
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
#$a1 O endereco de memória da raiz
#$a0 o valor que eu quero inserir
#$t1 resultado da busca
#$t2 auxiliar
inserir:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#Com o endereco da raiz e o valor que eu quero inserir eu faço uma chamada de busca
	addi $s0, $a0, 0 #salvando valor buscado no registrador
	addi $s7, $a1, 0 #Salvando em #$s7 o endereco de memoria da raiz
	jal buscar
	addi $t1, $v0, 0 #Salvando o endereco de retorno em resultado de busca
	
	beq $t1, 0, gravarRaiz #Se for nulo, passa para gravar na raiz
		addi $t2 , $zero, 0 #zerando $t2
		lw $t7, 0($t1) #Careegando o valor em $t7
		slt $t6, $s0, $t7#se o valor que eu  quero inserir é menor
		bne $t6, 1, elseMenor
		jal malloc
		sw $v0, 24($t1) #Gravando o endereco alocado em malloc em $t1
		lw $t6, 24($t1) #Carregando endereco alocado dinamicamente em $t6
		sw $s0, 0($t6) #Guardando o valor em $t6 
		sw $t1, 20($t6) #Setando o pai do filho a esquerda
		la $t2, ($t6) 	#Carregando o endereco do filho da esquerda em $t2
		j zerarEstrutura
	elseMenor:
		jal malloc
		sw $v0, 28($t1) #Gravando o endereco alocado em malloc em $t1
		lw $t6, 28($t1) #Carregando endereco alocado dinamicamente em $t6
		sw $s0, 0($t6) #Guardando o valor em $t6 
		sw $t1, 20($t6) #Setando o pai do filho a direita
		la $t2, ($t6) 	#Carregando o endereco do filho da esquerda em $t2
	zerarEstrutura:
		sw $zero, 24($t2) #Zerando Filho esquerda
		sw $zero, 28($t2) #zerando filho direita
		sw $zero, 4($t2)  #zerando altura
		sw $zero, 8($t2)  #zerando altura Esqueda
		sw $zero, 12($t2)  #zerando altura Direita
		
		addi $a0, $t2, 0
		addi $a1, $s7, 0
		jal atualizarFatorBalanceamento		
				
		j endInserir
	gravarRaiz:
		addi $s1, $a1, 0 #salvando em $s1 o endereco guardado em  $s1
		jal malloc
		sw $v0, 0($a1) #salvando o endereco de memória no espaco da memoria guardado para o node raiz
		lw $t6, 0($a1) #carregando o endereco do node raiz da memória
		sw $s0, 0($t6) #Salvando o valor na raiz
		sw $zero, 24($t6)  #Zerando Filho esquerda
		sw $zero, 28($t6)  #zerando filho direita
		sw $zero, 20($t6)  #zerando o pai
		sw $zero, 4($t6)   #zerando altura
		sw $zero, 8($t6)  #zerando altura Esqueda
		sw $zero, 12($t6)  #zerando altura Direita
			
	endInserir:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
#Performando rotações===============================================================================				
#$a0 -> noARotacionar
#$a1 -> NoArvore
#$t0 -> ptr , 
#$t1 -> fEsq, $t2 ->registrador auxiliar para verificação
RSD: #Rotacao simples direita
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t0, $a0, 0 #salvando o endereco em registrador
	lw $t1,24($t0)   #carregando endereco de filho esquerda $t0
	lw $t2, 28($t1)  #carregando em registrdor auxiliar o endereço Fdir 
	sw $t2,24($t0)   #salvando o endereco carregado no endereco de Fesq
	beq $t2, 0, seguirRSD
		sw $t0,20($t2) #Setando pai de no rotacionado
	seguirRSD:

	sw $t0, 28($t1)  #fEsq->filhoDir = ptr;
	lw $t2, 20($t0)  #Carregando pai de ptr
	sw $t2, 20($t1)  #Setando pai de ptr como pai de fesq
	addi $t2, $t1, 0 #Salvando o endereco de Ptr no registrador $t2
	sw $t2, 20($t0)  #Setando o pai de PTR em Fesq  
	
	#Recalculando fatores de balanceamento
	addi $s4, $t0, 0 #Salvando em $s4 o endereco guardado em $t0
	addi $s5, $t1, 0 #salvando o endereco de FEsq em $t1
	addi $a0, $t0, 0
	jal calcularFatorBalanceamento
	
	addi $t0, $s4, 0 #Carregando o endereco salvado em  $s4
	addi $t1, $s5, 0 #Carregando endereco de Fesq salvo em registrador 
	
	addi $a0, $t1, 0
	jal calcularFatorBalanceamento

	addi $t1, $s5, 0 #Carregando o endereco salvado em  $s5

	lw $t2, 20($t1) #carregando no pai de $t1 em registrador t2
	beq $t2, 0, gravarNovaRaizRSD
		#Será utilixado um registradores $t3 e $t4
		lw $t3, 0($t2) #carregando valor do node pai
		lw $t4, 0($t1) #Carregando valor do node Fesq
		slt $t7, $t4, $t3
		bne $t7, 1, ehFilhoDirRSD
			sw $t1, 24($t2)#Setando Fesq como filho mais a esqueda de $t1
			j endRSD			
		ehFilhoDirRSD:
			sw $t1, 28($t2)#Setando Fesq como filho mais a direita de $t1
			j endRSD
	gravarNovaRaizRSD:	
		sw $t1, 0($a1) #gravando o endereco da nova raiz
		lw $t2, 0($a1) #Carregando o endereco da nova raiz em $t2
	j endRSD
endRSD:
	addi $v0, $t2, 0 #salvando o endereco de FEsq no endereco de retorno
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


#$a0 -> noARotacionar
#$a1 -> NoArvore
#$t0 -> ptr , 
#$t1 -> fDir, $t2 ->registrador auxiliar para verificação	
RSE: #Rotacao simples esquerda
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t0, $a0, 0 #salvando o endereco em registrador
	lw $t1,28($t0)   #carregando endereco de filho Direita $t0
	lw $t2, 24($t1)  #carregando em registrdor auxiliar o endereço Fdir (Filo Esq do filho Dir)
	sw $t2,28($t0)   #salvando o endereco carregado no endereco de Fesq
	beq $t2, 0, seguirRSE
		sw $t0,20($t2) #Setando pai de no rotacionado
	seguirRSE:

	sw $t0, 24($t1)  #fDir->filhoEsq = ptr;
	lw $t2, 20($t0)  #carregando pai de ptr
	sw $t2, 20($t1)  #setando pai de ptr como pai de $t1
	addi $t2, $t1, 0 #Salvando o endereco de Ptr no registrador $t2
	sw $t2, 20($t0)  #Setando o pai de PTR em Fesq

	#Recalculando fatores de balanceamento
	addi $s4, $t0, 0 #Salvando em $s4 o endereco guardado em $t0
	addi $s5, $t1, 0 #salvando o endereco de FDir em $t1
	addi $a0, $t0, 0
	jal calcularFatorBalanceamento
	
	addi $t0, $s4, 0 #Carregando o endereco salvado em  $s4
	addi $t1, $s5, 0 #Carregando endereco de FDir salvo em registrador
			
	addi $s4, $t1, 0 #Salvando em $s4 o endereco guardado em $t1
	addi $a0, $t1, 0
	jal calcularFatorBalanceamento
	
	addi $t1, $s5, 0 #Carregando o endereco salvado em  $s5

					
	lw $t2, 20($t1) #carregando no pai de $t1 em registrador t2
	beq $t2, 0, gravarNovaRaizRSE
		#Será utilixado um registradores $t3 e $t4
		lw $t3, 0($t2) #carregando valor do node pai
		lw $t4, 0($t1) #Carregando valor do node FDir
		slt $t7, $t4, $t3
		bne $t7, 1, ehFilhoDirRSE
			sw $t1, 24($t2)#Setando Fesq como filho mais a esqueda de $t1
			j endRSE			
		ehFilhoDirRSE:
			sw $t1, 28($t2)#Setando Fesq como filho mais a direita de $t1
			j endRSE
	gravarNovaRaizRSE:	
		sw $t1, 0($a1) #gravando o endereco da nova raiz
		lw $t2, 0($a1) #Carregando o endereco da nova raiz em $t2
	j endRSE
endRSE:
	addi $v0, $t2, 0 #salvando o endereco de FEsq no endereco de retorno
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	

#verificando rotações=============================================================
#$a0 -> endereco do node desbalanceado
#$a1 -> Endereco do do node Raiz
#$t0 ->Temporario para guardar fbDo no desbalanceado
#$t1-> enderecos FilhoDir e FilhoEsq, $t2 rotacionador
verificandoRotacoes:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	beq $a0, 0, endVR # se o no não for nulo
	lw $t0, 16($a0) #carregando FB do no em $t0
	bne $t0, 2, verDoisNeg
		lw $t0, 28($a0) #carregando o endereco do filho a direita em $t0
		seq $t7, $t0, 0
		beq $t7, 1, elseVRE
			addi $t8, $t0, 0 #Salvando o endereco do Direita em $t8
			lw $t0, 16($t8) #Fator de balanceamento do filhoDireita
			seq $t7, $t0, -1
			bne $t7,1,elseVRE#Verificar Rotação esquerda
			#Rotação dupla esquerda
			addi $s3, $a0, 0 #salvando endereco do node desbalanceado em $s3
			lw $a0, 28($a0) #salvando em $a0 o endereco do filho a direita
			jal RSD			
		elseVRE:
		addi $a0, $s3, 0 	#restaurando o endereco de node desbalanceado
		jal RSE
		addi $a0, $v0, 0  #adicionando o retorno da funcao com o no rotacionado		
	verDoisNeg:
	lw $t0, 16($a0) #carregando FB do no em $t0
	bne $t0, -2, endVR
		lw $t0, 24($a0) #carregando o endereco do filho a esquerda em $t0
		seq $t7, $t0, 0
		beq $t7, 1, elseVRD
			addi $t8, $t0,0 #Salvando o endereco do Fesq em $t8
			lw $t0, 16($t8) #Fator de balanceamento do filhoEsquerda
			seq $t7, $t0, 1
			bne $t7,1,elseVRD#Verificar Rotação esquerda
			#Rotação dupla Direita
			addi $s3, $a0, 0 #salvando endereco do node desbalanceado em $s3
			lw $a0, 24($a0) #salvando em $a0 o endereco do filho a esquerda
			jal RSE			
		elseVRD:
		addi $a0, $s3, 0 	#restaurando o endereco de node desbalanceado
		jal RSD
		addi $a0, $v0, 0  #adicionando o retorno da funcao com o no rotacionado
endVR:
	addi $v0, $a0, 0 #guardando rotacionadoe em $v0 para retorno
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	 jr $ra

#Funções para calcular fatores de balanceamento===================================
#$a0 -> endereco do no cujoFatorSeraCalculado
#$t0 -> ptr, $t1(ponteiro auxiliar), $t2 hEsq , $t3Hdir altura, $t4 
calcularFatorBalanceamento:
	addi $sp, $sp, -4			
	sw $ra, 0($sp)
	addi $t0, $a0, 0
	lw $t1, 24($t0)#Carregando endereco filhoEsq
	beq $t1, 0, elseEsqNull
		lw $t2, 4($t1) #Pegando altura do filho à esqueda
		sw $t2, 8($t0) #Salvando altura do filho a esqueda em altura esquerda
	j verEsq
elseEsqNull:	
		sw $zero, 8($t0) #gravando zero em altura mais a esquerda
verEsq:		
 	lw $t1, 28($t0)#Carregando endereco filhoDir
 	beq $t1,0, elseDirNull
 		lw $t2, 4($t1) #Pegando a altura do filho a direita
 		sw $t2, 12($t0)#Salvando altura do filho a direita em altura direita
 		j endCalcularFatorBal
 elseDirNull:
 		sw $zero, 12($t0) #gravando zero em altura mais a direita
 
endCalcularFatorBal:
	lw $t2, 8($t0)	#carregando altura mais a esquerda
	lw $t3, 12($t0) #carregando altura mais a direita
	sub $t4, $t3,$t2 #fazendo o calculo do FatBal
	sw $t4, 16($t0) #salvando o FatBal no nó
	#verificando maior
	sge $t7, $t3, $t2
	bne $t7, 1, max 
 		addi $t4, $t3, 1 #verificando o maior e somando 1
 		j afterMax
 	max:	
 		addi $t4, $t2, 1 #verificando o maior e somando 1
 	afterMax:
 	sw $t4, 4($t0) #salvando o valor da altura
 	
 #saindo de "Calcular fator bal"	
 	lw $ra , 0($sp)
 	addi $sp, $sp, 4
 	jr $ra																																														

#Atualizar fator balanceamento=============================================================
#$a0 -> O node inserido
#$a1 -> o endereco de memoria da árvore
#$t0 -> ptr; $t1, $t2 Registradores auxiliares
atualizarFatorBalanceamento:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t0, $a0, 0#carregando o endereco de memória do node raiz
#O seguinte loop atualiza o fator de balanceamento do nodes e performa rotações
#nos nodes desbalanceados
loopAtualizar:
	beq $t0, 0, endLoopAtualizar
	addi $s3, $t0, 0 #Salvando O endereco contido em $t0 em $s3
	addi $a0, $t0, 0
	jal calcularFatorBalanceamento
	addi $t0, $s3, 0
	addi $a0, $t0,0
	jal verificandoRotacoes
	addi $t0, $v0, 0 #Gravando o endereco retornado em $v0 em $t0
	lw $t0, 20($t0) # ptr = ptr->pai	
	j loopAtualizar		
endLoopAtualizar:	
	lw $ra, 0($sp)	
	addi $sp, $sp, 4
	jr $ra
#																																																																																																																																																
#Alocando dinamicamente	
#$a0 -> O endereco para ser alocado
malloc:
	addi $sp , $sp, -4
	sw $ra, 0($sp)
	la $a0, memory #Carregando o endereco em $a0
	lw $t9, valAlocation
	add $v0,$t9, $a0 #Salvando o endereco a ser retornado em $v0
	addi $t9, $t9, 32
	sw $t9, valAlocation #Salvando o endereco em alocation
	addi $t9, $zero, 0   #zerando o $t9	
	#O endereco dinamicamente alocado está em $v0
	lw $ra, 0($sp)		
	addi $sp, $sp, 4
	jr $ra	#retorna com o endereco de alocação em $v0

#a1 ->endereco do node raiz
#$t0 -> registrador auxiliar para guardar endereco de memória
posOrdem:
	addi $sp, $sp, -8 #Dis espacos um para o endereco de retorno e outro para o endereco do node
	sw $ra, 0($sp)
	sw $a1, 4($sp) 	#Gravando endereco de  memória na pilha
	lw $t0, 28($a1) #pegando o endereco do filho a direita
	beq $t0, 0, poFEsq # se o filho mais a direita for nulo dá um branch para verificar o filho mais a esquerda
		addi $a1, $t0,0 #salva o endereco guardado em $t0 em $a0
		jal posOrdem	#faz uma chamada recursiva 
poFEsq:	  
	lw $a1, 4($sp) #carregando o endereco salvo na pilha
	lw $t0, 24($a1) #carregando o endereco do filho mais a esquerda
	beq $t0, 0, imprimirValor #Se for nulo, imprime o valor
		addi $a1, $t0, 0 
		jal posOrdem
imprimirValor:
	lw $s1, 4($sp) #carregando o endereco salvo na pilha em $s1		
	lw $t0, 0($s1) #Carregando o valor do node em $t0
	
	addi $a2, $t0, 0
	jal escreverValor
			
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra

#a1 ->endereco do node raiz
#$t0 -> registrador auxiliar para guardar endereco de memória
buscaOrdem:
	addi $sp, $sp,-8 #Decrementando o stack pointer
	sw $ra,0($sp)    #Salvando o return address na pilha
	sw $a1,4($sp)    #salvando o endereco do node pilha
	addi $t0,$a1,0 #carregando o endereco do node raiz
	lw $t1, 24($a1) #carregando valo do filho mais a esquerda
	beq $t1, 0,saiFilhoEsq #Se o filho mais a esquerda for nulo vá praa o node pai
		move $a1,$t1   #passando o endereco do filho mais a esquerda para $a1
		jal buscaOrdem
	saiFilhoEsq:
		
		lw $t0,4($sp)#carregando o endereco do node no registrador t0
		lw $a2,0($t0)#Carregando o valor salvo no node
		jal escreverValor
	
	lw $t0,4($sp)	#carregando o endereco do node no registrador $t0
	lw $s1,28($t0)  #caregando endereco do vilho mais a direita
	lw $t1,0($t0)   #carregand o valor salvo no node em $t1
	beq $t1,0, saiFilhoDir #Se o filho da direita for nulo 
		move $a1,$t1 #passando o endereco do filho mais a esquerda para $a1
		jal escreverValor
	saiFilhoDir:
				
	lw $ra,0($sp)
	addi $sp,$sp,8
	jr $ra

#$a2 -> Guardara o valor a ser convertido
#$a1 -> O endereco do buffer o qual será usado para armazenar a cadeia
#$t3 -> rtegistrador contador do tamanho da string
#$t0, $t1, $t2 -> registradore auxiliares para aconversão
escreverValor:	 
	addi $sp, $sp, -4
	sw $ra, 0($sp) 
	
	la $a1, bufferValor #carregando o endereco do buffer
	
	addi $t0, $a2, 0#Salvando dividento
	li  $t1, 10	#carregando divisor
	li $t3, 0	#Carregando Contador de digito
	addi $a1, $a1, 4 #Começando no final do buffer da strings
	sb $zero, 0($a1) #Gravando bite nulo
convIntChar:
	divu $t0, $t1 	#Dividindo o valor pelo divisor, pois é a primeiraoperacao
	mflo $t0	#Pegando o quiciente
	mfhi $t2	#PEgando o resto
	addiu $t2, $t2, 0x30 #convertendo o resto em caractere
	addiu $a1, $a1, -1
	sb $t2, 0($a1)     #Gravar o digito convertido
	addi $t3, $t3, 1  #Icrementando Contador de digito
	bne $t0, 0,convIntChar #próxima iteracao
endConv:	
					
	li $v0, 15
	addi $a0, $s7, 0  #Carregando descritor de arquivo do registrador
	la $a1, bufferValor
	addi $a2,$t3, 0	  #falando a quantidade de bytes
	syscall
	
	li $v0, 15
	addi $a0, $s7, 0  #Carregando descritor de arquivo do registrador
	la $a1, espaco    #carregando o valor que eu quero escrever em arquivo	
	li $a2, 1	  #falando a quantidade de bytes
	syscall
	
	addi $t3, $zero, 0 #zerando o registrador $t3
	
	sw $zero, bufferValor
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
