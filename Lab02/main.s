; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este programa deve esperar o usu�rio pressionar uma chave.
; Caso o usu�rio pressione uma chave, um LED deve piscar a cada 1 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Defini��es de Valores
INVALID_DIGIT			EQU 256 ; Representa um d�gito inv�lido do teclado matricial

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
		IMPORT PLL_Init
		IMPORT SysTick_Init
		IMPORT SysTick_Wait1ms			
		
		IMPORT GPIO_Init
			
		IMPORT LCD_Init
		IMPORT LCD_Line2
		IMPORT LCD_Reset
		IMPORT LCD_PrintString
		
		IMPORT MapMatrixKeyboard


; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init				; Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init			; Chama a subrotina para inicializar o SysTick
	BL GPIO_Init			; Chama a subrotina que inicializa os GPIO

Reiniciar
	BL LCD_Init				; Chama a subrotina que inicializa o LCD
	MOV R6, #INVALID_DIGIT	; R6 usado para guardar o d�gito lido do teclado
	MOV R7, #0				; R7 usado para contar quantos d�gitos o usu�rio digitou
	
	
MainLoop
	BL MapMatrixKeyboard		; L� o d�gito pressionado no teclado e guarda em R6
	MOV R6, #INVALID_DIGIT		; Depois de contabilizado, invalida R6 para evitar erros
	CMP R7, #15					; Verifica se 16 d�gitos foram inseridos (primeira linha)	
	BEQ LCD_Reset
	BEQ Reiniciar				; Chama a subrotina que inicializa o LCD
	B MainLoop					; Se n�o, retoma o loop para receber o pr�ximo
	

; ****************************************
; Escrever c�digo que l� o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da se��o est� alinhada 
    END                          ;Fim do arquivo
