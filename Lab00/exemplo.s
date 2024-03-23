; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instrucoes do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declaracoes EQU - Defines
;<NOME>         EQU <VALOR>
ALEATORIOS EQU 0x20000400
ORDENADOS EQU 0x20000500
TAMANHO EQU 23
; -------------------------------------------------------------------------------
; Area de Dados - Declaracoes de variaveis
		AREA  DATA, ALIGN=2
		
		; Se alguma vari?vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variavel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari?vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi??o da RAM		
; -------------------------------------------------------------------------------
; Area de Codigo - Tudo abaixo da diretiva a seguir sera armazenado na memoria de 
;                  codigo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma funcao do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a funcao Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma funcao externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; funcao <func>

; -------------------------------------------------------------------------------
; Funcao main()
Start  
; Comece o codigo aqui <======================================================
	LDR R0, =valores 			; carrega em r0 o endereco inicial do vetor valores
	LDR R1, =ALEATORIOS 		; carrega em r1 o endereco inicial da RAM para salvar
	LDR R2, =TAMANHO			; carrega em r2 o tamanho do vetor
	MOV R3, #0					; inicia um contador

carregaAleatorios
	LDRB R4, [R0], #1		; r4 recebe o valor guardado no endereco de r0
	STRB R4, [R1], #1		; endereco guardado em r1 recebe o valor de r4
	ADD R3, R3, #1			; contador ++
	CMP R2, R3				; verifica se o contador atingiu o tamanho do vetor
	BNE carregaAleatorios
	
	LDR R5, =ORDENADOS			; carrega em r5 o endereco inicial do RAM para salvar os numeros a serem ordenados
	LDR R1, =ALEATORIOS 		; carrega em r1 o endereco inicial da RAM para ler os valores da lista
	LDR R2, =TAMANHO			; carrega em r2 o tamanho do vetor
	MOV R6, #0					; inicializa um contador para armazenar o tamanho da lista a ser ordenada
	MOV R3, #0					; inicia um contador da lista de aleatorios
	LDRB R4, [R1], #1			; r4 recebe o valor guardado no endereco de r1
	
reiniciaFibonacci
	MOV R7, #0					; a(n-2) da sequencia de fibonacci
	MOV R8, #1					; a(n-1) da sequencia de fibonacci
	
fibonacci
	ADD R9, R7, R8				; carrega em r9 (que é o an) o valor de r7 + r8
	MOV R7, R8					; carrega em r7 o valor de r8 (sera o novo a(n-2))
	MOV R8, R9					; carrega em r8 o valor de r9 (sera o novo a(n-1))
	CMP R4, R9					
	BLO proximoLista
	BNE fibonacci
	ADD R6, R6, #1				; incremeta contador
	STRB R4, [R5], #1			; endereco guardado em r5 recebe o valor de r4 que esta na sequencia de fibonacci
	
proximoLista
	ADD R3, R3, #1				; contador ++
	CMP R2, R3					; verifica se o contador atingiu o tamanho do vetor
	IT NE
		LDRBNE R4, [R1], #1		; r4 recebe o valor guardado no endereco de r1 se o numero da lista do menos que an
	BNE reiniciaFibonacci 
	


	
valores DCB 3, 244, 14, 233, 1, 6, 9, 18, 13, 254, 21, 34, 2, 67, 135,  8, 89, 43, 5, 105, 144, 201, 55
	NOP
	
    ALIGN                           ; garante que o fim da se??o est? alinhada 
    END                             ; fim do arquivo