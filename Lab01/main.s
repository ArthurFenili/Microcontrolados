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
		IMPORT  PortB_Output
        IMPORT  PortJ_Input	
		IMPORT 	PortP_Output
		IMPORT LED_Output
		IMPORT Display_Output

; Mapeamento dos 7 segmentos (0 a F)
MAPEAMENTO_7SEG DCB	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                  ; chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ; chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ; chama a subrotina que inicializa os GPIO
	
	MOV R9, #0					 ; Contador incrementar ou decrementar após varias piscadas de transistor
	MOV R4, #0					 ; Contador para piscar os leds

	MOV R7, #0					 ; contador
	MOV R6, #1					 ; passo
	MOV R5, #1					 ; sentido (1 crescente 0 decrescente)

MainLoop
	BL Display_Output			 ; chama a subrotina para acender o display
	BL LED_Output				 ; chama s subrotina para acender os leds
	CMP R9, #50				 ; verificação pra piscar os leds e incrementar/decrementar contador
	IT EQ
		BLEQ chamaLED			 ; se for momento de piscar led, chama a subrotina de piscar
	CMP R9, #50
	ITT EQ
		MOVEQ R9, #0
		BLEQ chamaContador		 ; se for momento de modificar o contador, chama a subrotina para incrementar ou decrementar
	ADD R9, R9, #1
	
	BL PortJ_Input				 ; chama a subrotina que lê o estado das chaves e coloca o resultado em R0
	CMP R0, #2_00000010			 ; verifica se SW1 foi apertada
	BEQ Verifica_SW1			 ; se foi, pula
	CMP R0, #2_00000001			 ; verifica se SW2 foi apertada
	BEQ Verifica_SW2		  	 ; se foi, pula
	
	B MainLoop					 ; retorna para o começo do loop principal

Verifica_SW1		
	CMP R6, #9					 ; verifica se o passo chegou em 9
	ITE LO
		ADDLO R6, #1  			 ; se não chegou, incrementa passo em 1
		MOVHS R6, #1			 ; se chegou, reinicia contagem do passo
	B MainLoop                   ; retorna para o começo do loop principal
	
Verifica_SW2	
	CMP R5, #1					 ; verifica se o sentido é crescente
	ITE EQ
		MOVEQ R5, #0			 ; se for, muda a flag para decrescente
		MOVNE R5, #1			 ; se não for, muda a flag para crescente
	B MainLoop					 ; retorna para o começo do loop principal
		
chamaContador
	CMP R5, #1					 ; verifica a flag do sentido
	BEQ contadorCrescente		 ; pula para função de incremento do contador
	BNE contadorDecrescente	 	 ; pula para função de decremento do contador
	
contadorCrescente
	CMP R7, #99;				 ; verifica se o contador chegou em 99
	ITE LO
		ADDLO R7, R6;			 ; se não chegou, incrementa o contador com o numero atual do passo
		MOVHS R7, #0			 ; se chegou reinicia o contador para 0
	BX LR

contadorDecrescente
	CMP R7, #0					 ; verifica se o contador chegou em 0
	ITE HI
		SUBHI R7, R6			 ; se não chegou, decrementa o contador com o numero atual do passo
		MOVLS R7, #99			 ; se chegou reinicia o contador para 99
	BX LR


chamaLED
; Pisca LED de fora pra dentro
	MOV R8, #1
	ADD R4, R4, R8 				 ; incrementa em 1 o estágio do led
	CMP R4, #7					 ; verifica se o estágio do led já chegou no ultimo
	IT HI
		MOVHI R4, #0			 ; se sim, reinicia
	BX LR

Pisca_Transistor_PP5
	MOV R0, #2_00100000
	PUSH {LR}
	BL PortP_Output				 ; chama a subrotina para ativar o transistor
	MOV R0, #1
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortP_Output				 ; chama a subrotina para desativar o transistor
	MOV R0, #1
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

Pisca_Transistor_PB4
	MOV R0, #2_00010000
	PUSH {LR}
	BL PortB_Output				 ; chama a subrotina para ativar o transistor
	MOV R0, #1
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortB_Output				 ; chama a subrotina para desativar o transistor
	MOV R0, #1
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

Pisca_Transistor_PB5
	MOV R0, #2_00100000
	PUSH {LR}
	BL PortB_Output				 ; chama a subrotina para ativar o transistor
	MOV R0, #1
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortB_Output				 ; chama a subrotina para desativar o transistor
	MOV R0, #1
	BL SysTick_Wait1ms
	POP {LR}
	BX LR
	
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
