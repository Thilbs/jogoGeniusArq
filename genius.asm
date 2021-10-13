#macro que recebe o input do usuario em w a s d
#e retorna o numero correspondente para ser comparado no array
.macro letra_para_num(%letra)
	move $a0, %letra	
	beq $a0, 119, letra_w	#w
	beq $a0, 97, letra_a	#a	
	beq $a0, 115, letra_s	#s
	beq $a0, 100, letra_d	#d
	li $t5, 5		#default se nenhum input for w a s d
	j sair_letra
	letra_w: 		#1 azul	
	li $t5, 1
	j sair_letra
	letra_a:		#3 amarelo
	li $t5, 3
	j sair_letra
	letra_s:		#2 vermelho
	li $t5, 2
	j sair_letra
	letra_d:		#4 verde
	li $t5, 4
	j sair_letra
	sair_letra:
.end_macro

#macro que faz o bitmap parar (syscall 32: sleep)
#o parametro eh passado em milissegundo, o tempo de sleep desejado
.macro sleep(%dormir)
	li $a0, %dormir
	li $v0, 32
	syscall
.end_macro 

.data
	preto: .word 0x000000 		#preto		
	amarelo: .word 0xffff00 	#amarelo
	azul: .word 0x0000ff 		#azul
	verde: .word 0x00ff00 		#verde
	vermelho: .word 0xff0000 	#vermelho
	
	initial_address: .word 0x10010000 #endereco inicial do bitmap	
	welcome: .asciiz "Bem vindo ao GENIUS!\n"
	cores: .asciiz "Azul: w --- Amarelo: a --- Vermelho: s --- Verde: d\n\n"
	msgVitoria: .asciiz "\nVoce ganhou!\n"
	msgPerdeu: .asciiz "\n\nVoce errou, que pena!\n"
	digitar: .asciiz "Digite a sequencia:"
	newline: .asciiz "\n"
	apagar: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	
	#array com o tipo de dados (align) 2 - word
	#reservando o espaço total de 40 bytes para esse array
	array:
	.align 2
	.space 40
		
.text
main:
	la $s0, initial_address 	#endereco inicial bitmap
	li $s1, 0 			#contador do loop principal
	li $s2, 1 			#contador for (i)
	li $s3, 0 			#contador do loop para verficar o input
	
	#gerar sequencia
	move $t0, $zero 		#indice do array
	li $t1, 40 			#indice do tamanho total do array
	jal seqAleatoria		#gerar sequencia aleatoria e salvar no array
	
	#pintar tela
	la $a0, welcome			#printa mensagem de welcome
	li $v0, 4
	syscall
	la $a0, cores			#printa mensagem do comando de cada cor
	li $v0, 4
	syscall
	jal pintar_tela			#pintar o bitmap inicial
	
	#WHILE principal
	move $t0, $zero
	#for: dura 10 vezes, começando com 1 ($s2)
	#cada sequencia que o usuario acertar incrementa 1
	for:
	bgt $s2, 10, ganhou   		#se o $s2 ficar maior que 10 printa a msg de vitoria 
	#enquanto: dura $s2 vezes, ou seja, se for a primeira sequencia dura 1
	#e vai aumentando até chegar a sequencia 10	
	#pinta a sequencia no bitmap
	enquanto:	
	beq $s1, $s2, end
	lw $t2, array($t0)		#da load no array e compara para pintar a cor no display
	beq $t2 , 1 , fazul
	beq $t2 , 2 , fvermelho
	beq $t2 , 3 , famarelo
	beq $t2 , 4 , fverde
	fazul:
	jal pintar_azul
	j continua
	fvermelho:
	jal pintar_vermelho
	j continua
	famarelo:
	jal pintar_amarelo
	j continua
	fverde:
	jal pintar_verde
	j continua	
	continua:
	addi $t0, $t0, 4		#adiciona 4 para pegar a proxima posicao do array
	addi $s1, $s1, 1
	j enquanto
	#fim do "enquanto" 
	end:
	la $a0, digitar
	li $v0, 4
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	move $t0, $zero
	#input: laco que tem a mesma duracao do "enquanto"
	#aqui o programa recebe o input do usuario e compara com a posicao correta no array
	#se estiver correto vai progredindo ate finalizar aquela sequencia
	#se errar automaticamente encerra o programa
	input:	
	beq $s3, $s2, fim
	li $v0, 12			#syscall 12 para receber o caracter do usuario
	syscall
	letra_para_num($v0)		#transforma o input: w a s d para numero (formato do array)
	lw $a0, array($t0)
	bne $t5, $a0, perdeu		#compara o numero do input com a posicao correta do array
	addi $s3, $s3, 1		#se estiver errado encerra o programa
	addi $t0, $t0, 4		#caso esteja correto continua ate finalizar a sequencia
	j input	
	#fim: faz tudo que e necessario para que a proxima iteracao do "for" funcione normalmente
	fim:
	addi $s2, $s2, 1
	li $s1, 0
	li $s3, 0
	li $t0, 0
	la $a0, apagar			#pula varias linhas para "apagar a tela" e a sequencia
	li $v0, 4
	syscall
	j for
	#ganhou: printa a mensagem de vitoria e encerra o programa
	ganhou:
	la $a0, msgVitoria
	li $v0, 4
	syscall
	j exit
	#perdeu: printa a mensagem de derrota e encerra o programa
	perdeu:
	la $a0, msgPerdeu
	li $v0, 4
	syscall
	j exit
	exit:	
	
li $v0 , 10				#syscall 10 finaliza a execuçao
syscall

#gera o array de 10 numeros aleatorios
#syscall 42 pega um numero "aleatorio" entre 0 e 3 ($a1)
#depois eh somado 1 para que a sequencia fique entre 1 e 4
#os numeros sao salvos no array na posicao correta
seqAleatoria:		
	beq $t0, $t1 , saiDaSeq
	addi $a1, $zero, 4
	addi $v0, $zero, 42	
	syscall	
	addi $a0, $a0, 1
	sw $a0, array($t0)
	addi $t0, $t0, 4	#cada posicao no array ocupa 4 bytes
	j seqAleatoria		
	saiDaSeq:
	move $t0, $zero		#deixa o indice do array novamente zerado
	jr $ra

#pinta o bitmap com as 4 cores do GENIUS e fica na tela por 5s
#depois apaga a tela do bitmap e encerra a funcao
pintar_tela:
	lw $t3, azul
	sw $t3, 804($s0)
	sw $t3, 808($s0)
	sw $t3, 932($s0)
	sw $t3, 936($s0)
	lw $t3, vermelho
	sw $t3, 812($s0)
	sw $t3, 816($s0)
	sw $t3, 940($s0)
	sw $t3, 944($s0)
	lw $t3, amarelo
	sw $t3, 1060($s0)
	sw $t3, 1064($s0)
	sw $t3, 1188($s0)
	sw $t3, 1192($s0)
	lw $t3, verde
	sw $t3, 1068($s0)
	sw $t3, 1072($s0)
	sw $t3, 1196($s0)
	sw $t3, 1200($s0)
	sleep(5000)
	lw $t3, preto	
	sw $t3, 804($s0)
	sw $t3, 808($s0)
	sw $t3, 932($s0)
	sw $t3, 936($s0)
	sw $t3, 812($s0)
	sw $t3, 816($s0)
	sw $t3, 940($s0)
	sw $t3, 944($s0)
	sw $t3, 1060($s0)
	sw $t3, 1064($s0)
	sw $t3, 1188($s0)
	sw $t3, 1192($s0)
	sw $t3, 1068($s0)
	sw $t3, 1072($s0)
	sw $t3, 1196($s0)
	sw $t3, 1200($s0)
	sleep(1000)
	jr $ra

#pinta o bitmap de azul no local reservado, aguarda 1 seg e apaga a tela
pintar_azul:
	lw $t3, azul
	sw $t3, 804($s0)
	sw $t3, 808($s0)
	sw $t3, 932($s0)
	sw $t3, 936($s0)
	sleep(1000)
	lw $t3, preto
	sw $t3, 804($s0)
	sw $t3, 808($s0)
	sw $t3, 932($s0)
	sw $t3, 936($s0)
	sleep(1000)
	jr $ra
	
#pinta o bitmap de vermelho no local reservado, aguarda 1 seg e apaga a tela
pintar_vermelho:
	lw $t3, vermelho
	sw $t3, 812($s0)
	sw $t3, 816($s0)
	sw $t3, 940($s0)
	sw $t3, 944($s0)
	sleep(1000)
	lw $t3, preto
	sw $t3, 812($s0)
	sw $t3, 816($s0)
	sw $t3, 940($s0)
	sw $t3, 944($s0)
	sleep(1000)
	jr $ra
	
#pinta o bitmap de amarelo no local reservado, aguarda 1 seg e apaga a tela
pintar_amarelo:
	lw $t3, amarelo
	sw $t3, 1060($s0)
	sw $t3, 1064($s0)
	sw $t3, 1188($s0)
	sw $t3, 1192($s0)
	sleep(1000)
	lw $t3, preto
	sw $t3, 1060($s0)
	sw $t3, 1064($s0)
	sw $t3, 1188($s0)
	sw $t3, 1192($s0)
	sleep(1000)
	jr $ra
	
#pinta o bitmap de verde no local reservado, aguarda 1 seg e apaga a tela
pintar_verde:
	lw $t3, verde
	sw $t3, 1068($s0)
	sw $t3, 1072($s0)
	sw $t3, 1196($s0)
	sw $t3, 1200($s0)
	sleep(1000)
	lw $t3, preto
	sw $t3, 1068($s0)
	sw $t3, 1072($s0)
	sw $t3, 1196($s0)
	sw $t3, 1200($s0)
	sleep(1000)
	jr $ra
