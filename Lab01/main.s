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
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
        IMPORT  PortQ_Output
		IMPORT  PortB_Output
		IMPORT  PortA_Output
        IMPORT  PortJ_Input	

; Mapeamento dos 7 segmentos (0 a F)
MAPEAMENTO_7SEG DCB	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	
	LDR R11, =MAPEAMENTO_7SEG	 ; Desloca escolhendo o respectivo n�mero das unidades

MainLoop
;Verifica_Nenhuma
;	CMP	R0, #2_00000001			 ;Verifica se nenhuma chave est� pressionada
;	BNE Verifica_SW1			 ;Se o teste viu que tem pelo menos alguma chave pressionada pula
;	MOV R0, #0                   ;N�o acender nenhum LED
;	BL PortQ_Output
;	BL PortB_Output
;	B MainLoop					 ;Se o teste viu que nenhuma chave est� pressionada, volta para o la�o principal
;Verifica_SW1	
;	CMP R0, #2_00000000			 ;Verifica se somente a chave SW1 est� pressionada

	MOV R1, #2					; contador proximo numero
	
	LDRB R10, [R11, R1]
	AND R0, R10, #2_11110000	; Atualiza DSDP:DSE (PA7:PA4)
	BL PortA_Output
	AND R0, R10, #2_00001111	; Atualiza DSD:DSA (PQ3:PQ0)
	BL PortQ_Output
	MOV R0, #2_00110000			 ; Ativa o transistor do DS1 (PB4 e PB5)
	BL PortB_Output
	
	
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da se��o est� alinhada 
    END                          ;Fim do arquivo
