.macro letra(%letra)
	move $a0, %letra
	#w
	beq $a0, 119, letra_w
	#a
	beq $a0, 97, letra_a
	#s
	beq $a0, 115, letra_s
	#d
	beq $a0, 100, letra_d
	letra_w:
	#1 azul
	li $t5, 1
	j sair_letra
	letra_a:
	#3 amarelo
	li $t5, 3
	j sair_letra
	letra_s:
	#2 vermelho
	li $t5, 2
	j sair_letra
	letra_d:
	#4 verde
	li $t5, 4
	j sair_letra
	sair_letra:
.end_macro

.macro sleep(%dormir)
	li $a0, %dormir
	li $v0, 32
	syscall
.end_macro 

.data
	preto: .word 0x000000 #black		
	amarelo: .word 0xffff00 #yellow
	azul: .word 0x0000ff #blue
	verde: .word 0x00ff00 #green
	vermelho: .word 0xff0000 #red
	
	initial_address: .word 0x10010000	
	welcome: .asciiz "Bem vindo ao GENIUS!\n"
	msgVitoria: .asciiz "\nVoce ganhou!\n"
	msgPerdeu: .asciiz "\nVoce perdeu, que pena!\n"
	digitar: .asciiz "Digite a sequencia:"
	newline: .asciiz "\n"
	apagar: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	
	array:
	.align 2
	.space 40
		
.text
main:
	la $s0, initial_address #endereco bitmap
	li $s1, 0 #contador loop principal
	li $s2, 1 #contador for (i)
	li $s3, 0 #contador do input
	
	#gerar sequencia - OK	
	move $t0, $zero #indice
	li $t1, 40 #tamanho do array
	jal loop
	
	#pintar tela - OK
	la $a0, welcome
	li $v0, 4
	syscall
	jal pintar_tela
	
	#WHILE: compara a sequencia e pinta fase 1
	move $t0, $zero
	for:
	bgt $s2, 10, ganhou    	
	enquanto:	
	beq $s1, $s2, end
	lw $t2, array($t0)
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
	addi $t0, $t0, 4
	addi $s1, $s1, 1
	j enquanto
	end:
	la $a0, digitar
	li $v0, 4
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	move $t0, $zero
	#for do input
	input:	
	beq $s3, $s2, fim
	li $v0, 12
	syscall
	letra($v0)
	lw $a0, array($t0)
	bne $t5, $a0, perdeu
	addi $s3, $s3, 1
	addi $t0, $t0, 4	
	j input	
	fim:
	addi $s2, $s2, 1
	li $s1, 0
	li $s3, 0
	li $t0, 0
	la $a0, apagar
	li $v0, 4
	syscall
	j for
	ganhou:
	la $a0, msgVitoria
	li $v0, 4
	syscall
	j exit
	perdeu:
	la $a0, msgPerdeu
	li $v0, 4
	syscall
	j exit
	exit:
	#digita a sequencia 1
	#checa a entrada ve se ta certo, passar pra 2
	#compara a sequencia e pinta fase 2
	#digita a sequencia 2
	#ate acabar a 10
	#ou ate ele errar 	
	
li $v0 , 10
syscall

loop:		
	beq $t0, $t1 , saiDoLoop
	addi $a1, $zero, 4
	addi $v0, $zero, 42	
	syscall	
	addi $a0, $a0, 1
	sw $a0, array($t0)
	addi $t0, $t0, 4
	j loop	
	saiDoLoop:	
	move $t0, $zero
	jr $ra
	#imprime:
		#beq $t0, $t1, acabar
		#li $v0, 1
		#lw $a0, array($t0)
		#syscall
		#addi $t0, $t0, 4
		#j imprime
		#acabar:
		#jr $ra	

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

apagar_tela:
	
	li $t3, 0
	li $t4, 512
	while:
	bgt $t3, $t4, end_while
		sll $t3, $t3, 2
		add $t3, $t3, $s0
		sw $s1, 0($t3)
		addi $t3, $t3, 1
	j while
	end_while:
		sleep(1000)
		jr $ra
