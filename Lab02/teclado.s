; matrix_keyboard.s
; Desenvolvido para a placa EK-TM4C1294XL
; Template by Prof. Guilherme Peron - 24/08/2020

; -------------------------------------------------------------------------------
        THUMB                        ; Instru??es do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declara??es EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
COFRE_FECHANDO 	EQU 2
; -------------------------------------------------------------------------------
; ?rea de Dados - Declara??es de vari?veis
		AREA  DATA, ALIGN=2
		; Se alguma vari?vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari?vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari?vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi??o da RAM		

; -------------------------------------------------------------------------------
; ?rea de C?digo - Tudo abaixo da diretiva a seguir ser? armazenado na mem?ria de 
;                  c?digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun??o do arquivo for chamada em outro arquivo
		; EXPORT <func>				; Permite chamar a fun??o a partir de outro arquivo
		EXPORT MapMatrixKeyboard
		
		; Se chamar alguma fun??o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma fun??o de outro
		IMPORT PortM_Output
		IMPORT PortL_Input
		IMPORT LCD_PrintString
		IMPORT SysTick_Wait1ms
; -------------------------------------------------------------------------------

; Fun??o MapMatrixKeyboard
; Mapeia o teclado matricial
; Par?metro de entrada:
; Par?metro de sa?da:
MapMatrixKeyboard
	PUSH {LR}
	
	; -----------------------------------------------------------
	MOV R0, #2_11100000		; Iterando sobre a primeira coluna
	BL PortM_Output
	BL PortL_Input
	
	CMP R0, #2_1110			; Numero 1 foi pressionado
	BEQ DIGIT_1
	
	CMP R0, #2_1101			; Numero 4 foi pressionado
	BEQ DIGIT_4
	
	CMP R0, #2_1011			; Numero 7 foi pressionado
	BEQ.W DIGIT_7
	
	CMP R0, #2_0111			; Simbolo * foi pressionado
	BEQ.W DIGIT_AST			; Error: Branch offset out of range (BEQ.W corrige o problema)
	; -----------------------------------------------------------
	
	; -----------------------------------------------------------
	MOV R0, #2_11010000		; Iterando sobre a segunda coluna
	BL PortM_Output
	BL PortL_Input
	
	CMP R0, #2_1110			; Numero 2 foi pressionado
	BEQ DIGIT_2
	
	CMP R0, #2_1101			; Numero 5 foi pressionado
	BEQ DIGIT_5
	
	CMP R0, #2_1011			; Numero 8 foi pressionado
	BEQ.W DIGIT_8
	
	CMP R0, #2_0111			; Numero 0 foi pressionado
	BEQ DIGIT_0
	; -----------------------------------------------------------
	
	; -----------------------------------------------------------
	MOV R0, #2_10110000		; Iterando sobre a terceira coluna
	BL PortM_Output
	BL PortL_Input
	
	CMP R0, #2_1110			; Numero 3 foi pressionado
	BEQ DIGIT_3
	
	CMP R0, #2_1101			; Numero 6 foi pressionado
	BEQ DIGIT_6
	
	CMP R0, #2_1011			; Numero 9 foi pressionado
	BEQ.W DIGIT_9
	
	CMP R0, #2_0111			; Símbolo # foi pressionado
	BEQ.W DIGIT_HASH		; Error: Branch offset out of range (BEQ.W corrige o problema)
	; -----------------------------------------------------------
	
	; -----------------------------------------------------------
	MOV R0, #2_0111000		; Iterando sobre a quarta coluna
	BL PortM_Output
	BL PortL_Input
	
	CMP R0, #2_1110			; Letra A foi pressionado
	BEQ.W DIGIT_A
	
	CMP R0, #2_1101			; Letra B foi pressionado
	BEQ.W DIGIT_B
	
	CMP R0, #2_1011			; Letra C foi pressionado
	BEQ.W DIGIT_C
	
	CMP R0, #2_0111			; Letra D foi pressionado
	BEQ.W DIGIT_D
	; -----------------------------------------------------------
	
	POP {LR}
	BX LR

; Funções DIGIT_X
; Tratam a resposta do sistema para cada tecla pressionada
; Parametro de entrada: N?o tem
; Parametro de saída: R6 -> O dígito inserido
DIGIT_0
	PUSH {LR}
	
	MOV R6, #0x0			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_0_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_1
	PUSH {LR}
	
	MOV R6, #0x1			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_1_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_2
	PUSH {LR}
	
	MOV R6, #0x2			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_2_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_3
	PUSH {LR}
	
	MOV R6, #0x3			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_3_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_4
	PUSH {LR}
	
	MOV R6, #0x4			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_4_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_5
	PUSH {LR}
	
	MOV R6, #0x5			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_5_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_6
	PUSH {LR}
	
	MOV R6, #0x6			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_6_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_7
	PUSH {LR}
	
	MOV R6, #0x7			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_7_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_8
	PUSH {LR}
	
	MOV R6, #0x8			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_8_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_9
	PUSH {LR}
	
	MOV R6, #0x9			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_9_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR
	
DIGIT_A
	PUSH {LR}
	
	MOV R6, #0xA			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_A_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR
	
DIGIT_B
	PUSH {LR}
	
	MOV R6, #0xB			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_B_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR
	
DIGIT_C
	PUSH {LR}
	
	MOV R6, #0xC			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_C_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR
	
DIGIT_D
	PUSH {LR}
	
	MOV R6, #0xD			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_D_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_AST
	PUSH {LR}
	
	MOV R6, #0xE			; Guarda o d?gito inserido
	
	LDR R4, =DIGIT_AST_STR	; Imprime o d?gito no LCD
	BL LCD_PrintString
	
	BL Debouncing			; Trata o bouncing da tecla via software
	
	ADD R7, R7, #1			; Incrementa o contador de d?gitos inseridos
	
	POP {LR}				; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

DIGIT_HASH
	PUSH {LR}
	
	CMP R7, #4					; Verifica se 4 d?gitos j? foram inseridos
	MOVHS R5, #COFRE_FECHANDO	; Senha de 4 d?gitos inserida, coloca o cofre em processo de fechamento
	
	BL Debouncing				; Trata o bouncing da tecla via software
	
	POP {LR}					; Retorna ap?s d?gito inserido ter sido guardado e impresso
	BX LR

; Função Debouncing
; Trata o bouncing da tecla aguardando um tempo fixo (0,5s)
; Parametro de entrada: Não tem
; Parametro de saída: Não tem
Debouncing
	PUSH {LR}
	
	MOV R0, #500
	BL SysTick_Wait1ms
	
	POP {LR}
	BX LR

; Definição dos textos do LCD
DIGIT_0_STR	DCB "0", 0
DIGIT_1_STR	DCB "1", 0
DIGIT_2_STR	DCB "2", 0
DIGIT_3_STR	DCB "3", 0
DIGIT_4_STR	DCB "4", 0
DIGIT_5_STR	DCB "5", 0
DIGIT_6_STR	DCB "6", 0
DIGIT_7_STR	DCB "7", 0
DIGIT_8_STR	DCB "8", 0
DIGIT_9_STR	DCB "9", 0
DIGIT_A_STR	DCB "A", 0
DIGIT_B_STR	DCB "B", 0
DIGIT_C_STR	DCB "C", 0
DIGIT_D_STR	DCB "D", 0

DIGIT_AST_STR DCB "*", 0
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN					; Garante que o fim da se??o est? alinhada 
    END						; Fim do arquivo