; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
ALEATORIOS EQU 0x20000400
ORDENADOS EQU 0x20000500
TAMANHO EQU 23
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		
; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; -------------------------------------------------------------------------------
; Fun��o main()
Start  
; Comece o c�digo aqui <======================================================
	LDR R0, =valores 			; carrega em r0 o endere�o inicial do vetor valores
	LDR R1, =ALEATORIOS 		; carrega em r1 o endere�o inicial da RAM para salvar
	LDR R2, =TAMANHO			; carrega em r2 o tamanho do vetor
	MOV R9, #0					; inicia um contador

loop
	LDRB R3, [R0], #1		; r3 recebe o valor guardado no endere�o de r0
	STRB R3, [R1], #1		; endere�o guardado em r1 recebe o valor de r3
	ADD R9, R9, #1			; contador ++
	CMP R2, R9				; verifica se o contador atingiu o tamanho do vetor
	BNE loop


	
valores DCB 3, 244, 14, 233, 1, 6, 9, 18, 13, 254, 21, 34, 2, 67, 135,  8, 89, 43, 5, 105, 144, 201, 55

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
