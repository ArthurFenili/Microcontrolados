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
		EXPORT Pisca_Transistor_PP5
		EXPORT Pisca_Transistor_PB4
		EXPORT Pisca_Transistor_PB5

									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
        IMPORT  PortQ_Output
		IMPORT  PortB_Output
		IMPORT  PortA_Output
        IMPORT  PortJ_Input	
		IMPORT 	PortP_Output
		IMPORT LED_Output
		IMPORT Display_Output

; Mapeamento dos 7 segmentos (0 a F)
MAPEAMENTO_7SEG DCB	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	
	MOV R9, #0					 ; Contador para os leds

	MOV R7, #0; -- contador;
	MOV R6, #1; -- passo;
	MOV R5, #1; -- sentido (1 crescente 0 decrescente) ;

MainLoop
	BL Display_Output
	CMP R9, #100
	ITT EQ
		MOVEQ R9, #0
		BEQ chamaContador
	ADD R9, R9, #1
	
InputLoop
	BL PortJ_Input				 ;Chama a subrotina que lê o estado das chaves e coloca o resultado em R0
	CMP R0, #2_00000010
	BEQ Verifica_SW1
	CMP R0, #2_00000001
	BEQ Verifica_SW2
	

	B MainLoop

Verifica_SW1		
	CMP R6, #9
	ITE LO
		ADDLO R6, #1
		MOVHS R6, #1
	
	B MainLoop                   ;Volta para o laço principal
Verifica_SW2	
	CMP R5, #1
	ITE EQ
		MOVEQ R5, #0
		MOVNE R5, #1
	B MainLoop
		
chamaContador
	CMP R5, #1
	BEQ contadorCrescente
	BNE contadorDecrescente
	
	
contadorCrescente
	BL Display_Output
	CMP R7, #99;
	ITE LO
		ADDLO R7, R6;
		MOVHS R7, #0
	BL InputLoop

contadorDecrescente
	BL Display_Output
	CMP R7, #0
	ITE HI
		SUBHI R7, R6
		MOVLS R7, #99
	BL InputLoop


; Pisca LED de fora pra dentro
	MOV R8, #1
	BL LED_Output
	ADD R9, R9, R8
	CMP R9, #3
	IT HI
		MOVHI R9, #0
	B MainLoop

Pisca_Transistor_PP5
	MOV R0, #2_00100000
	PUSH {LR}
	BL PortP_Output
	MOV R0, #1
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortP_Output
	MOV R0, #1
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

Pisca_Transistor_PB4
	MOV R0, #2_00010000
	PUSH {LR}
	BL PortB_Output
	MOV R0, #1
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortB_Output
	MOV R0, #1
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

Pisca_Transistor_PB5
	MOV R0, #2_00100000
	PUSH {LR}
	BL PortB_Output
	MOV R0, #1
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortB_Output
	MOV R0, #1
	BL SysTick_Wait1ms
	POP {LR}
	BX LR
	
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
