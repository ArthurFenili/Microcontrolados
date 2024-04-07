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
	
	LDR R11, =MAPEAMENTO_7SEG	 ; Desloca escolhendo o respectivo número das unidades
	MOV R9, #0					 ; Contador para os leds


MainLoop
;Verifica_Nenhuma
;	CMP	R0, #2_00000001			 ;Verifica se nenhuma chave está pressionada
;	BNE Verifica_SW1			 ;Se o teste viu que tem pelo menos alguma chave pressionada pula
;	MOV R0, #0                   ;Não acender nenhum LED
;	BL PortQ_Output
;	BL PortB_Output
;	B MainLoop					 ;Se o teste viu que nenhuma chave está pressionada, volta para o laço principal
;Verifica_SW1	
;	CMP R0, #2_00000000			 ;Verifica se somente a chave SW1 está pressionada

;contador a partir daqui
;	MOV R1, #2					; contador proximo numero
;	
;	LDRB R10, [R11, R1]
;	AND R0, R10, #2_11110000	; Atualiza DSDP:DSE (PA7:PA4)
;	BL PortA_Output
;	AND R0, R10, #2_00001111	; Atualiza DSD:DSA (PQ3:PQ0)
;	BL PortQ_Output
;	MOV R0, #2_00110000			 ; Ativa o transistor do DS1 (PB4 e PB5)
;	BL PortB_Output

;;logica do contador


;	MOV R0, #0; -- contador;
;	MOV R1, #1; -- passo;
;	MOV R2, #0; -- sentido (1 crescente 0 decrescente) ;
;	
;;quando a chave 2 for apertada, troca o valor de R2 pra 0 se tiver 1 e 1 se tiver zero e dai dá B pra essa função
;verificaChave2
;	
;	CMP R2, #1;
;	BEQ contadorCrescente;
;	BNE contadorDecrescente;

;;quando a chave 1 for apertada, dá B pra essa função direto, ela ja faz a comparação
;verificaChave1

;	CMP R1, #9;
;	IT LT
;		ADDLT R1,#1;
;		MOVHS R1,#0;
;	B verificaChave1

;;chamado na função da chave2
;contadorCrescente
;	BL Display_Output
;	CMP R7, #99;
;	IT LT
;		ADDLT R7, R6;
;		BLT contadorCrescente;
;	
;;chamado na função da chave2	
;contadorDecrescente

;	CMP R0, #0;
;	IT HI
;		SUBHI R0, R1;
;		MOVLS R0, #99;
;		
;	B contadorDecrescente;

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
	MOV R0, #1000
	BL SysTick_Wait1ms
	MOV R0, #2_00000000
	BL PortP_Output
	MOV R0, #1000
	BL SysTick_Wait1ms
	POP {LR}
	BX LR

	
	
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
