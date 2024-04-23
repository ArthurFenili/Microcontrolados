; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este programa deve esperar o usuário pressionar uma chave.
; Caso o usuário pressione uma chave, um LED deve piscar a cada 1 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Definições de Valores
INVALID_DIGIT			EQU 256 ; Representa um dígito inválido do teclado matricial

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
; Função main()
Start  		
	BL PLL_Init				; Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init			; Chama a subrotina para inicializar o SysTick
	BL GPIO_Init			; Chama a subrotina que inicializa os GPIO

Reiniciar
	BL LCD_Init				; Chama a subrotina que inicializa o LCD
	MOV R6, #INVALID_DIGIT	; R6 usado para guardar o dígito lido do teclado
	MOV R7, #0				; R7 usado para contar quantos dígitos o usuário digitou
	
	
MainLoop
	BL MapMatrixKeyboard		; Lê o dígito pressionado no teclado e guarda em R6
	MOV R6, #INVALID_DIGIT		; Depois de contabilizado, invalida R6 para evitar erros
	CMP R7, #15					; Verifica se 16 dígitos foram inseridos (primeira linha)	
	BEQ LCD_Reset
	BEQ Reiniciar				; Chama a subrotina que inicializa o LCD
	B MainLoop					; Se não, retoma o loop para receber o próximo
	

; ****************************************
; Escrever código que lê o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
