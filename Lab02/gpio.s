; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines

LOCKED			EQU 6
LOCKED_MASTER	EQU 7
	
; ========================
; ========================
; Defini��es dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Defini��es dos Ports
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
	
; PORT K
GPIO_PORTK_LOCK_R    		EQU    0x40061520
GPIO_PORTK_CR_R      		EQU    0x40061524
GPIO_PORTK_AMSEL_R   		EQU    0x40061528
GPIO_PORTK_PCTL_R    		EQU    0x4006152C
GPIO_PORTK_DIR_R     		EQU    0x40061400
GPIO_PORTK_AFSEL_R   		EQU    0x40061420
GPIO_PORTK_DEN_R     		EQU    0x4006151C
GPIO_PORTK_PUR_R     		EQU    0x40061510	
GPIO_PORTK_DATA_R    		EQU    0x400613FC
GPIO_PORTK_DATA_BITS_R  	EQU    0x40061000
GPIO_PORTK               	EQU    2_000001000000000 ; SYSCTL_PPGPIO_P9
	
; PORT L
GPIO_PORTL_LOCK_R    		EQU    0x40062520
GPIO_PORTL_CR_R      		EQU    0x40062524
GPIO_PORTL_AMSEL_R   		EQU    0x40062528
GPIO_PORTL_PCTL_R    		EQU    0x4006252C
GPIO_PORTL_DIR_R     		EQU    0x40062400
GPIO_PORTL_AFSEL_R   		EQU    0x40062420
GPIO_PORTL_DEN_R     		EQU    0x4006251C
GPIO_PORTL_PUR_R     		EQU    0x40062510
GPIO_PORTL_DATA_R    		EQU    0x400623FC
GPIO_PORTL               	EQU    2_000010000000000 ; SYSCTL_PPGPIO_P10
	
; PORT M
GPIO_PORTM_LOCK_R    		EQU    0x40063520
GPIO_PORTM_CR_R      		EQU    0x40063524
GPIO_PORTM_AMSEL_R   		EQU    0x40063528
GPIO_PORTM_PCTL_R    		EQU    0x4006352C
GPIO_PORTM_DIR_R     		EQU    0x40063400
GPIO_PORTM_AFSEL_R   		EQU    0x40063420
GPIO_PORTM_DEN_R     		EQU    0x4006351C
GPIO_PORTM_PUR_R     		EQU    0x40063510
GPIO_PORTM_DATA_R    		EQU    0x400633FC
GPIO_PORTM               	EQU    2_000100000000000 ; SYSCTL_PPGPIO_P11
	
; PORT N
GPIO_PORTN_AHB_LOCK_R    	EQU    0x40064520
GPIO_PORTN_AHB_CR_R      	EQU    0x40064524
GPIO_PORTN_AHB_AMSEL_R   	EQU    0x40064528
GPIO_PORTN_AHB_PCTL_R    	EQU    0x4006452C
GPIO_PORTN_AHB_DIR_R     	EQU    0x40064400
GPIO_PORTN_AHB_AFSEL_R   	EQU    0x40064420
GPIO_PORTN_AHB_DEN_R     	EQU    0x4006451C
GPIO_PORTN_AHB_PUR_R     	EQU    0x40064510	
GPIO_PORTN_AHB_DATA_R    	EQU    0x400643FC
GPIO_PORTN               	EQU    2_001000000000000	
	
; Interrup��es

; PORT J Interrup��o
GPIO_PORTJ_IS_R				EQU	   0x40060404
GPIO_PORTJ_IBE_R			EQU	   0x40060408
GPIO_PORTJ_IEV_R			EQU    0x4006040C
GPIO_PORTJ_IM_R				EQU    0x40060410
GPIO_PORTJ_ICR_R			EQU    0x4006041C
NVIC_PRI12_R				EQU    0xE000E430
NVIC_EN1_R					EQU    0xE000E104



; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		EXPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		EXPORT PortL_Input			; Permite chamar PortL_Input de outro arquivo
		EXPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo
			
		; Se chamar alguma fun��o externa
		IMPORT EnableInterrupts		; Chama EnableInterrupts do arquivo "startup.s"									

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
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
; enable clock to GPIOF at clock gating register
			LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endere�o do registrador RCGCGPIO
			MOV     R1, #GPIO_PORTJ					; Seta o bit da porta J
			ORR     R1, #GPIO_PORTK					; Seta o bit da porta K, fazendo com OR
			ORR     R1, #GPIO_PORTL					; Seta o bit da porta L, fazendo com OR
			ORR     R1, #GPIO_PORTM					; Seta o bit da porta M, fazendo com OR
            STR     R1, [R0]						;Move para a mem�ria os bits das portas no endere�o do RCGCGPIO
 
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador       
			MOV     R2, #GPIO_PORTJ                 ; Seta os bits correspondentes �s portas para fazer a compara��o - Seta o bit da porta J
			ORR     R2, #GPIO_PORTK                 ; Seta o bit da porta K, fazendo com OR
			ORR     R2, #GPIO_PORTL                 ; Seta o bit da porta L, fazendo com OR
			ORR     R2, #GPIO_PORTM                 ; Seta o bit da porta M, fazendo com OR
            TST     R1, R2							;ANDS de R1 com R2
            BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando
 
; 2. Limpar o AMSEL para desabilitar a anal�gica
            MOV     R1, #0x00						; Colocar 0 no registrador para desabilitar a fun��o anal�gica
			LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R		; Carrega o R0 com o endere�o do AMSEL para a porta J
            STR     R1, [R0]					    ; Guarda no registrador AMSEL da porta J da mem�ria
			
			LDR     R0, =GPIO_PORTK_AMSEL_R			; Carrega o R0 com o endere�o do AMSEL para a porta K
            STR     R1, [R0]					    ; Guarda no registrador AMSEL da porta K da mem�ria
			
			LDR     R0, =GPIO_PORTL_AMSEL_R			; Carrega o R0 com o endere�o do AMSEL para a porta L
            STR     R1, [R0]					    ; Guarda no registrador AMSEL da porta L da mem�ria
			
			LDR     R0, =GPIO_PORTM_AMSEL_R			; Carrega o R0 com o endere�o do AMSEL para a porta M
            STR     R1, [R0]					    ; Guarda no registrador AMSEL da porta M da mem�ria
 
; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ; Colocar 0 no registrador para selecionar o modo GPIO
			LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		; Carrega o R0 com o endere�o do PCTL para a porta J
            STR     R1, [R0]                        ; Guarda no registrador PCTL da porta J da mem�ria
			
			LDR     R0, =GPIO_PORTK_PCTL_R			; Carrega o R0 com o endere�o do PCTL para a porta K
            STR     R1, [R0]                        ; Guarda no registrador PCTL da porta K da mem�ria
			
			LDR     R0, =GPIO_PORTL_PCTL_R			; Carrega o R0 com o endere�o do PCTL para a porta L
            STR     R1, [R0]                        ; Guarda no registrador PCTL da porta L da mem�ria
			
			LDR     R0, =GPIO_PORTM_PCTL_R			; Carrega o R0 com o endere�o do PCTL para a porta M
            STR     R1, [R0]                        ; Guarda no registrador PCTL da porta M da mem�ria

; 4. DIR para 0 se for entrada, 1 se for sa�da
			; O certo era verificar os outros bits da PJ para n�o transformar entradas em sa�das desnecess�rias
			LDR     R0, =GPIO_PORTJ_AHB_DIR_R		; Carrega o R0 com o endere�o do DIR para a porta J
			MOV     R1, #2_0               			; PJ0
            STR     R1, [R0]						; Guarda no registrador PCTL da porta J da mem�ria
			
			LDR     R0, =GPIO_PORTK_DIR_R			; Carrega o R0 com o endere�o do DIR para a porta K
			MOV     R1, #2_11111111					; PK7:PK0 (LCD)
            STR     R1, [R0]						; Guarda no registrador
			
			LDR     R0, =GPIO_PORTL_DIR_R			; Carrega o R0 com o endere�o do DIR para a porta L
			MOV     R1, #2_00000000					; PL3:PL0 (teclado)
            STR     R1, [R0]						; Guarda no registrador
			
			LDR     R0, =GPIO_PORTM_DIR_R			; Carrega o R0 com o endere�o do DIR para a porta M
			MOV     R1, #2_11110111					; PM7:PM4 (teclado) e PM2:PM0 (LCD)
            STR     R1, [R0]						; Guarda no registrador
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem fun��o alternativa
            MOV     R1, #0x00						; Colocar o valor 0 para n�o setar fun��o alternativa				; Escreve na porta
			
			LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     ; Carrega o endere�o do AFSEL da porta J
            STR     R1, [R0]                        ; Escreve na porta
			
			LDR     R0, =GPIO_PORTK_AFSEL_R     	; Carrega o endere�o do AFSEL da porta K
            STR     R1, [R0]                        ; Escreve na porta
			
			LDR     R0, =GPIO_PORTL_AFSEL_R     	; Carrega o endere�o do AFSEL da porta L
            STR     R1, [R0]                        ; Escreve na porta
			
			LDR     R0, =GPIO_PORTM_AFSEL_R     	; Carrega o endere�o do AFSEL da porta M
            STR     R1, [R0]                        ; Escreve na porta
; 6. Setar os bits de DEN para habilitar I/O digital
            ; Escrita amig�vel - Read-modify-write
			
			LDR     R0, =GPIO_PORTJ_AHB_DEN_R		; Carrega o endere�o do DEN
			LDR     R1, [R0]						; L� para carregar o valor anterior da porta inteira
            ORR     R1, R1, #2_00000001             ; Faz o OR bit a bit para manter os valores anteriores e setar somente PJ0
            STR     R1, [R0]						; Escreve no registrador da mem�ria funcionalidade digital
			
			LDR     R0, =GPIO_PORTK_DEN_R			; Carrega o endere�o do DEN
			LDR     R1, [R0]						; L� para carregar o valor anterior da porta inteira
            ORR     R1, R1, #2_11111111           	; Faz o OR bit a bit para manter os valores anteriores e setar somente PK7:PK0
            STR     R1, [R0]						; Escreve no registrador da mem�ria funcionalidade digital
			
			LDR     R0, =GPIO_PORTL_DEN_R			; Carrega o endere�o do DEN
			LDR     R1, [R0]						; L� para carregar o valor anterior da porta inteira
            ORR     R1, R1, #2_00001111             ; Faz o OR bit a bit para manter os valores anteriores e setar somente PL3:PL0
            STR     R1, [R0]						; Escreve no registrador da mem�ria funcionalidade digital
			
			LDR     R0, =GPIO_PORTM_DEN_R			; Carrega o endere�o do DEN
			LDR     R1, [R0]						; L� para carregar o valor anterior da porta inteira
            ORR     R1, R1, #2_11110111             ; Faz o OR bit a bit para manter os valores anteriores e setar somente PM7:PM4 e PM2:PM0
            STR     R1, [R0]						; Escreve no registrador da mem�ria funcionalidade digital
			
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R		; Carrega o endere�o do PUR para a porta J
			MOV     R1, #2_0001						; Habilitar funcionalidade digital de resistor de pull-up PJ0
            STR     R1, [R0]						; Escreve no registrador da mem�ria do resistor de pull-up
			
			LDR     R0, =GPIO_PORTL_PUR_R			; Carrega o endere�o do PUR para a porta L
			MOV     R1, #2_1111						; Habilitar funcionalidade digital de resistor de pull-up PL3:PL0
            STR     R1, [R0]						; Escreve no registrador da mem�ria do resistor de pull-up
            
; 8. Interrup��es
			LDR R1, =GPIO_PORTJ_IM_R				
			MOV R0, #2_0 							; Desabilita a interrup��o na porta J0
			STR R0, [R1] 
	
			MOV R1, #2_0
			LDR R0, =GPIO_PORTJ_IS_R				; 0 para interrup��o de borda e 1 para n�vel
			STR R1, [R0]
			
			MOV R1, #2_0
			LDR R0, =GPIO_PORTJ_IBE_R				; 0 para borda �nica
			STR R1, [R0]
			
			MOV R1, #2_0
			LDR R0, =GPIO_PORTJ_IEV_R				; 0 para borda de descida
			STR R1, [R0]
			
			LDR R1, =GPIO_PORTJ_ICR_R				; Configura a interrup��o na porta PJ0
			MOV R0, #2_1
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTJ_IM_R				; Habilita a interrup��o na porta J0
			MOV R0, #2_1
			STR R0, [R1]
			
			LDR R1, =NVIC_PRI12_R					; Configura prioridade 5 nos bits 29 a 31
			MOV R0, #0xA0000000
			STR R0, [R1]
			
			LDR R1, =NVIC_EN1_R						; Habilita a interrup��o no PortJ
			MOV R0, #0x80000
			STR R0, [R1]
			
			PUSH {LR}
			BL EnableInterrupts						; Liga a chave das interrup��es
			POP {LR}
			
			BX LR

; -------------------------------------------------------------------------------
; Fun��o PortJ_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor da leitura
PortJ_Input
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    ; Carrega o valor do offset do data register
	LDR R0, [R1]                            ; L� no barramento de dados dos pinos
	BX LR									; Retorna

; Fun��o GPIOPortJ_Handler
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor a ser atualizado
GPIOPortJ_Handler
	; O certo seria testar se a interrup��o foi causada por PJ1 ou PJ0 atrav�s do GPIORIS
	LDR R1, =GPIO_PORTJ_ICR_R
	MOV R0, #0x00000001						; PJ0
	STR R0, [R1] 							; Limpa a interrup��o (ACK)
	
	CMP R5, #LOCKED_MASTER					; Verifica se a interrup��o aconteceu com o cofre travado com senha mestre
	MOVEQ R5, #LOCKED						; Se sim, baixa o estado para travado apenas
	
	BX LR 									; Retorna
	

; Fun��o PortK_Output
; Par�metro de entrada: R0
; Par�metro de sa�da:  N�o tem
PortK_Output
	LDR	R1, =GPIO_PORTK_DATA_R		    	; Carrega o valor do offset do data register
	; Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_11111111						; M�scara com bits 1 nas posi��es que queremos limpar PK7:PK0
	ORR R0, R0, R2                          ; Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ; Escreve na porta K
	BX LR									; Retorna

; Fun��o PortL_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor da leitura
PortL_Input
	LDR	R1, =GPIO_PORTL_DATA_R		    	; Carrega o valor do offset do data register
	LDR R0, [R1]                            ; L� no barramento de dados dos pinos
	BX LR									; Retorna

; Fun��o PortM_Output
; Par�metro de entrada: R0
; Par�metro de sa�da:  N�o tem
PortM_Output
	LDR	R1, =GPIO_PORTM_DATA_R		    	; Carrega o valor do offset do data register
	; Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_11110111						; M�scara com bits 1 nas posi��es que queremos limpar PM7:PM4 e PM3:PM0
	ORR R0, R0, R2                          ; Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ; Escreve na porta M
	BX LR									; Retorna




    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo