; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
; ========================
; ========================
; Defini��es dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Defini��es dos Ports

; PORT A
GPIO_PORTA_AHB_LOCK_R    	EQU    0x40058520
GPIO_PORTA_AHB_CR_R      	EQU    0x40058524
GPIO_PORTA_AHB_AMSEL_R   	EQU    0x40058528
GPIO_PORTA_AHB_PCTL_R    	EQU    0x4005852C
GPIO_PORTA_AHB_DIR_R     	EQU    0x40058400
GPIO_PORTA_AHB_AFSEL_R   	EQU    0x40058420
GPIO_PORTA_AHB_DEN_R     	EQU    0x4005851C
GPIO_PORTA_AHB_PUR_R     	EQU    0x40058510	
GPIO_PORTA_AHB_DATA_R    	EQU    0x400583FC
GPIO_PORTA_AHB_DATA_BITS_R  EQU    0x40058000
GPIO_PORTA               	EQU    2_000000000000001 ; SYSCTL_PPGPIO_P0
	
; PORT J
GPIO_PORTJ_AHB_LOCK_R    	EQU    0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU    0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU    0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU    0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU    0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU    0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU    0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU    0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU    0x400603FC
GPIO_PORTJ               	EQU    2_000000100000000
	
; PORT Q
GPIO_PORTQ_LOCK_R    		EQU    0x40066520
GPIO_PORTQ_CR_R      		EQU    0x40066524
GPIO_PORTQ_AMSEL_R   		EQU    0x40066528
GPIO_PORTQ_PCTL_R    		EQU    0x4006652C
GPIO_PORTQ_DIR_R     		EQU    0x40066400
GPIO_PORTQ_AFSEL_R   		EQU    0x40066420
GPIO_PORTQ_DEN_R     		EQU    0x4006651C
GPIO_PORTQ_PUR_R     		EQU    0x40066510	
GPIO_PORTQ_DATA_R    		EQU    0x400663FC
GPIO_PORTQ               	EQU    2_100000000000000	
	
; PORT B
GPIO_PORTB_AHB_LOCK_R    	EQU    0x40059520
GPIO_PORTB_AHB_CR_R      	EQU    0x40059524
GPIO_PORTB_AHB_AMSEL_R   	EQU    0x40059528
GPIO_PORTB_AHB_PCTL_R    	EQU    0x4005952C
GPIO_PORTB_AHB_DIR_R     	EQU    0x40059400
GPIO_PORTB_AHB_AFSEL_R   	EQU    0x40059420
GPIO_PORTB_AHB_DEN_R     	EQU    0x4005951C
GPIO_PORTB_AHB_PUR_R     	EQU    0x40059510	
GPIO_PORTB_AHB_DATA_R    	EQU    0x400593FC
GPIO_PORTB_AHB_DATA_BITS_R  EQU    0x40059000
GPIO_PORTB               	EQU    2_000000000000010 ; SYSCTL_PPGPIO_P1
	
; PORT P
GPIO_PORTP_LOCK_R       	EQU    0x40065520
GPIO_PORTP_CR_R        	    EQU    0x40065524
GPIO_PORTP_AMSEL_R      	EQU    0x40065528
GPIO_PORTP_PCTL_R       	EQU    0x4006552C
GPIO_PORTP_DIR_R        	EQU    0x40065400
GPIO_PORTP_AFSEL_R      	EQU    0x40065420
GPIO_PORTP_DEN_R        	EQU    0x4006551C
GPIO_PORTP_PUR_R        	EQU    0x40065510
GPIO_PORTP_DATA_R       	EQU    0x400653FC
GPIO_PORTP_DATA_BITS_R  	EQU    0x40065000
GPIO_PORTP					EQU	   2_010000000000000

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortB_Output			; Permite chamar PortB_Output de outro arquivo
		EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		EXPORT PortP_Output
		EXPORT LED_Output
		EXPORT Display_Output
			
			
		IMPORT Pisca_Transistor_PP5
		IMPORT Pisca_Transistor_PB4
		IMPORT Pisca_Transistor_PB5
		IMPORT SysTick_Wait1ms

		
; Mapeamento dos 7 segmentos (0 a F)
MAPEAMENTO_7SEG DCB	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F								

;--------------------------------------------------------------------------------
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
GPIO_Init
;=====================
; ****************************************
; Escrever fun��o de inicializa��o dos GPIO
; Inicializar as portas J e N
; ****************************************
			LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endere�o do registrador RCGCGPIO
			MOV		R1, #GPIO_PORTQ                 ;Seta o bit da porta Q
			ORR     R1, #GPIO_PORTJ					;Seta o bit da porta J, fazendo com OR
			ORR     R1, #GPIO_PORTB					;Seta o bit da porta B, fazendo com OR
			ORR     R1, #GPIO_PORTA					;Seta o bit da porta A, fazendo com OR
			ORR     R1, #GPIO_PORTP					;Seta o bit da porta P, fazendo com OR
            STR     R1, [R0]						;Move para a mem�ria os bits das portas no endere�o do RCGCGPIO
 
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador
			MOV     R2, #GPIO_PORTQ                 ;Seta os bits correspondentes �s portas para fazer a compara��o
			ORR     R2, #GPIO_PORTJ                 ;Seta o bit da porta J, fazendo com OR
			ORR     R2, #GPIO_PORTB                 ;Seta o bit da porta B, fazendo com OR
			ORR     R2, #GPIO_PORTA                 ;Seta o bit da porta A, fazendo com OR
			ORR     R2, #GPIO_PORTP					;Seta o bit da porta P, fazendo com OR
            TST     R1, R2							;ANDS de R1 com R2
            BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando
 
; 2. Limpar o AMSEL para desabilitar a anal�gica
            MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a fun��o anal�gica
            LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endere�o do AMSEL para a porta J
            STR     R1, [R0]						;Guarda no registrador AMSEL da porta J da mem�ria
			
            LDR     R0, =GPIO_PORTQ_AMSEL_R			;Carrega o R0 com o endere�o do AMSEL para a porta Q
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta Q da mem�ria
			
			LDR     R0, =GPIO_PORTB_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta B
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta B da mem�ria
 
			LDR     R0, =GPIO_PORTA_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta B
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta B da mem�ria
			
			LDR		R0, =GPIO_PORTP_AMSEL_R			;Carrega o R0 com o endere�o do AMSEL para a porta P
			STR 	R1, [R0]						;Guarda no registrador AMSEL da porta P da mem�ria
; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
            LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere�o do PCTL para a porta J
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta J da mem�ria
			
            LDR     R0, =GPIO_PORTQ_PCTL_R      	;Carrega o R0 com o endere�o do PCTL para a porta Q
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta Q da mem�ria
			
			LDR     R0, =GPIO_PORTB_AHB_PCTL_R      ;Carrega o R0 com o endere�o do PCTL para a porta B
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta B da mem�ria
			
			LDR     R0, =GPIO_PORTA_AHB_PCTL_R      ;Carrega o R0 com o endere�o do PCTL para a porta A
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta A da mem�ria
			
			LDR		R0, =GPIO_PORTP_PCTL_R			;Carrega o R0 com o endere�o do PCTL para a porta P
			STR		R1, [R0]						;Guarda no registrador PCTL da porta P da mem�ria
; 4. DIR para 0 se for entrada, 1 se for sa�da
            LDR     R0, =GPIO_PORTQ_DIR_R			; Carrega o R0 com o endere�o do DIR para a porta Q
			MOV     R1, #2_00001111					; PQ0:PQ3
            STR     R1, [R0]						;Guarda no registrador
			; O certo era verificar os outros bits da PF para n�o transformar entradas em sa�das desnecess�rias
            LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta J
            MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com sa�da
            STR     R1, [R0]						;Guarda no registrador PCTL da porta J da mem�ria
			
			LDR     R0, =GPIO_PORTB_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta B
            MOV     R1, #2_00110000               	;PB4 e PB5
            STR     R1, [R0]						;Guarda no registrador
			
			LDR     R0, =GPIO_PORTA_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta A
            MOV     R1, #2_11110000               	;PA4:PA7
            STR     R1, [R0]						;Guarda no registrador
			
			LDR		R0, =GPIO_PORTP_DIR_R			;Carrega o R0 com o endere�o do DIR para a porta P
			MOV 	R1, #2_00100000					;PP5
			STR		R1, [R0]						;Guarda no registrador
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem fun��o alternativa
            MOV     R1, #0x00						;Colocar o valor 0 para n�o setar fun��o alternativa
            LDR     R0, =GPIO_PORTQ_AFSEL_R			;Carrega o endere�o do AFSEL da porta Q
            STR     R1, [R0]						;Escreve na porta
			
            LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta J
            STR     R1, [R0]                        ;Escreve na porta
			
			LDR     R0, =GPIO_PORTB_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta B
            STR     R1, [R0]                        ;Escreve na porta
			
			LDR     R0, =GPIO_PORTA_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta A
            STR     R1, [R0]                        ;Escreve na porta
			
			LDR 	R0, =GPIO_PORTP_AFSEL_R			;Carrega o endere�o do AFSEL na porta P
			STR		R1, [R0]						;Escreve na porta
; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTQ_DEN_R				;Carrega o endere�o do DEN
            MOV     R1, #2_00001111                     ;Ativa os pinos PQ0:PQ3 como I/O Digital
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
 
            LDR     R0, =GPIO_PORTJ_AHB_DEN_R			;Carrega o endere�o do DEN
			MOV     R1, #2_00000011                     ;Ativa os pinos PJ0  como I/O Digital      
            STR     R1, [R0]                            ;Escreve no registrador da mem�ria funcionalidade digital
			
			LDR     R0, =GPIO_PORTB_AHB_DEN_R			;Carrega o endere�o do DEN
            MOV     R1, #2_00110000                     ;Setar os pinos PB4 e PB5
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
			
			LDR     R0, =GPIO_PORTA_AHB_DEN_R			;Carrega o endere�o do DEN
            MOV     R1, #2_11110000                     ;Setar os pinos PA0:PA3
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
			
			LDR		R0, =GPIO_PORTP_DEN_R				;Carrega o endere�o do DEN
			MOV 	R1, #2_00100000						;Setar o pino PP5
			STR		R1, [R0]							;Escreve no registrador de mem�ria funcionalidade digital
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R			;Carrega o endere�o do PUR para a porta J
			MOV     R1, #2_00000011						;Habilitar funcionalidade digital de resistor de pull-up 
                                                        ;nos bits 0 e 1
            STR     R1, [R0]							;Escreve no registrador da mem�ria do resistor de pull-up
            
;retorno            
			BX LR

; -------------------------------------------------------------------------------

PortB_Output
	LDR	R1, =GPIO_PORTB_AHB_DATA_R		    ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00110000                     ;Limpar bits lidos da porta 11001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta B o barramento de dados dos pinos N1
	BX LR									;Retorno
	
; -------------------------------------------------------------------------------

PortP_Output
	LDR	R1, =GPIO_PORTP_DATA_R		    ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00100000                     ;Limpar bits lidos da porta 11001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta B o barramento de dados dos pinos N1
	BX LR

; -------------------------------------------------------------------------------

; Fun��o PortJ_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor da leitura
PortJ_Input
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    ;Carrega o valor do offset do data register
    LDR R8, [R1]                            ;L� no barramento de dados dos pinos [J1-J0]
	PUSH {LR}
	MOV R0, #15
	BL SysTick_Wait1ms
	POP {LR}
	LDR R12, [R1]
	CMP R12, R8
	IT HI
		MOVHI R0, R8
	BX LR									;Retorno

; -------------------------------------------------------------------------------

LED_Output
	PUSH {LR}
	LDR	R1, =GPIO_PORTA_AHB_DATA_R		    ;Carrega o valor do offset do data register
	LDR	R2, =GPIO_PORTQ_DATA_R		    	;Carrega o valor do offset do data register
                        
	LDR R3, [R1]
	LDR R0, [R2]


	CMP R4, #0								; verifica se � a vez da primeira dupla de leds piscar
	ITT EQ
		MOVEQ R3, #2_10000000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00000001
		
	CMP R4, #1								; verifica se � a vez da segunda dupla de leds piscar
	ITT EQ
		MOVEQ R3, #2_01000000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00000010
		
	CMP R4, #2								; verifica se � a vez da terceira dupla de leds piscar
	ITT EQ
		MOVEQ R3, #2_00100000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00000100
		
	CMP R4, #3								; verifica se � a vez da quarta dupla de leds piscar
	ITT EQ		
		MOVEQ R3, #2_00010000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00001000
	
	CMP R4, #4								; verifica se � a vez da quarta dupla de leds piscar
	ITT EQ		
		MOVEQ R3, #2_00010000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00001000
		
	CMP R4, #5								; verifica se � a vez da quarta dupla de leds piscar
	ITT EQ		
		MOVEQ R3, #2_00100000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00000100
		
	CMP R4, #6								; verifica se � a vez da quarta dupla de leds piscar
	ITT EQ		
		MOVEQ R3, #2_01000000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00000010
		
	CMP R4, #7								; verifica se � a vez da quarta dupla de leds piscar
	ITT EQ		
		MOVEQ R3, #2_10000000				; se sim, carrega em R3 e R4 os bits dos leds que devem piscar
		MOVEQ R0, #2_00000001
	STR R3, [R1]							; carrega no DATA do portA o bit do led da esquerda que deve piscar
	STR R0, [R2]							; carrega no DATA do portQ o bit do led da direita que deve piscar
	
	BL Pisca_Transistor_PP5					; chama a subrotina para piscar o transistor dos leds
	POP {LR}
	BX LR		

; -------------------------------------------------------------------------------
	
Display_Output
	PUSH {LR}
	
	MOV R10, #10
	UDIV R11, R7, R10        ; divide o valor total por 10, resultando no algarismo da dezena no R11
	MLS R12, R11, R10, R7    ; multiplica o algarismo da dezena por 10, e diminui isso do valor total, resultando no algarismo da unidade no R12
    LDR R0, =MAPEAMENTO_7SEG

; -------------- display das dezenas ---------------
	; faz a fun��o do PortA_Output
	LDR	R1, =GPIO_PORTA_AHB_DATA_R		    ; carrega o valor do offset do data register	 
	LDRB R3, [R0, R11]						; carrega em R3 o valor mapeado para o display das dezenas
	LDR R2, [R1]							; carrega em R2 o valor DATA do portA
	BIC R2, #2_11110000						; AND negado bit a bit para manter os valores anteriores e limpar somente os bits necessarios
	ORR R3, R3, R2							; OR bit a bit para manter os valores anteriores e setar somente os bits necessarios
	STR R3, [R1]							; carrega em R3 o valor atualizado do DATA do portA
	
	; faz a fun��o do PortQ_Output
	LDR R1, =GPIO_PORTQ_DATA_R				; carrega o valor do offset do data register
	LDRB R3, [R0, R11]						; carrega em R3 o valor mapeado para o display das dezenas
	LDR R2, [R1]							; carrega em R2 o valor DATA do portQ
	BIC R2, #2_00001111						; AND negado bit a bit para manter os valores anteriores e limpar somente os bits necessarios
	ORR R3, R3, R2							; OR bit a bit para mantes os valores anteriores e setar somente os bits necessarios
	STR R3, [R1]							; carrega em R3 o valor atualizado do DATA do portQ
	
	BL Pisca_Transistor_PB4					; chama a subrotina para piscar o transistor do DS1
	POP {LR}
	
; -------------- display das unidades (mesma coisa do display das dezenas) ---------------
	PUSH {LR}
	; faz a fun��o do PortA_Output
	LDR R0, =MAPEAMENTO_7SEG
	LDR	R1, =GPIO_PORTA_AHB_DATA_R		    ;Carrega o valor do offset do data register	 
	LDRB R3, [R0, R12]
	LDR R2, [R1]
	BIC R2, #2_11110000
	ORR R3, R3, R2
	STR R3, [R1]
	
	; faz a fun��o do PortQ_Output
	LDR R1, =GPIO_PORTQ_DATA_R
	LDRB R3, [R0, R12]
	LDR R2, [R1]
	BIC R2, #2_00001111
	ORR R3, R3, R2
	STR R3, [R1]
	
	BL Pisca_Transistor_PB5					; chama a subrotina para piscar o transistor do DS2
	POP {LR}
	
	BX LR

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo