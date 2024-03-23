; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
ALEATORIOS EQU 0x20000400
ORDENADOS EQU 0x20000500
TAMANHO EQU 23
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		
; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; -------------------------------------------------------------------------------
; Função main()
Start  
; Comece o código aqui <======================================================
	LDR R0, =valores 			; carrega em r0 o endereço inicial do vetor valores
	LDR R1, =ALEATORIOS 		; carrega em r1 o endereço inicial da RAM para salvar
	LDR R2, =TAMANHO			; carrega em r2 o tamanho do vetor
	MOV R9, #0					; inicia um contador

loop
	LDRB R3, [R0], #1		; r3 recebe o valor guardado no endereço de r0
	STRB R3, [R1], #1		; endereço guardado em r1 recebe o valor de r3
	ADD R9, R9, #1			; contador ++
	CMP R2, R9				; verifica se o contador atingiu o tamanho do vetor
	BNE loop


	
valores DCB 3, 244, 14, 233, 1, 6, 9, 18, 13, 254, 21, 34, 2, 67, 135,  8, 89, 43, 5, 105, 144, 201, 55

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
