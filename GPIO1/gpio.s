; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 19/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
; ========================
; Defini��es dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Defini��es dos Ports
; PORT J
GPIO_PORTJ_AHB_DR12R_R   EQU    0x4006053C
GPIO_PORTJ_AHB_SI_R      EQU    0x40060538
GPIO_PORTJ_AHB_DMACTL_R  EQU    0x40060534
GPIO_PORTJ_AHB_ADCCTL_R  EQU    0x40060530
GPIO_PORTJ_AHB_PCTL_R    EQU    0x4006052C
GPIO_PORTJ_AHB_AMSEL_R   EQU    0x40060528
GPIO_PORTJ_AHB_CR_R      EQU    0x40060524
GPIO_PORTJ_AHB_LOCK_R    EQU    0x40060520
GPIO_PORTJ_AHB_DEN_R     EQU    0x4006051C
GPIO_PORTJ_AHB_SLR_R     EQU    0x40060518
GPIO_PORTJ_AHB_PDR_R     EQU    0x40060514
GPIO_PORTJ_AHB_PUR_R     EQU    0x40060510
GPIO_PORTJ_AHB_ODR_R     EQU    0x4006050C
GPIO_PORTJ_AHB_DR8R_R    EQU    0x40060508
GPIO_PORTJ_AHB_DR4R_R    EQU    0x40060504
GPIO_PORTJ_AHB_DR2R_R    EQU    0x40060500
GPIO_PORTJ_AHB_AFSEL_R   EQU    0x40060420
GPIO_PORTJ_AHB_ICR_R     EQU    0x4006041C
GPIO_PORTJ_AHB_MIS_R     EQU    0x40060418
GPIO_PORTJ_AHB_RIS_R     EQU    0x40060414
GPIO_PORTJ_AHB_IM_R      EQU    0x40060410
GPIO_PORTJ_AHB_IEV_R     EQU    0x4006040C
GPIO_PORTJ_AHB_IBE_R     EQU    0x40060408
GPIO_PORTJ_AHB_IS_R      EQU    0x40060404
GPIO_PORTJ_AHB_DIR_R     EQU    0x40060400
GPIO_PORTJ_AHB_DATA_R    EQU    0x400603FC
GPIO_PORTJ               	EQU    2_000000100000000
; PORT N
GPIO_PORTN_AHB_LOCK_R    	EQU    0x4005D520
GPIO_PORTN_AHB_CR_R      	EQU    0x4005D524
GPIO_PORTN_AHB_AMSEL_R   	EQU    0x4005D528
GPIO_PORTN_AHB_PCTL_R    	EQU    0x4005D52C
GPIO_PORTN_AHB_DIR_R     	EQU    0x4005D400
GPIO_PORTN_AHB_AFSEL_R   	EQU    0x4005D420
GPIO_PORTN_AHB_DEN_R     	EQU    0x4005D51C
GPIO_PORTN_AHB_PUR_R     	EQU    0x4005D510	
GPIO_PORTN_AHB_DATA_R    	EQU    0x4005D3FC
GPIO_PORTN              	EQU    2_000000000100000	

NVIC_EN1_R                  EQU    0xE000E104
NVIC_PRI12_R                EQU    0xE000E430

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		       ; Permite chamar PortJ_Input de outro arquivo
		EXPORT GPIOPortJ_Handler
		EXPORT PortJ_Input
									

;--------------------------------------------------------------------------------
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
GPIO_Init
;=====================
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
; enable clock to GPIOF at clock gating register
            LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endere�o do registrador RCGCGPIO
			MOV		R1, #GPIO_PORTJ                 ;Seta o bit da porta J
			ORR     R1, #GPIO_PORTN					;Seta o bit da porta N, fazendo com OR
            STR     R1, [R0]						;Move para a mem�ria os bits das portas no endere�o do RCGCGPIO
 
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador
			MOV     R2, #GPIO_PORTJ                 ;Seta os bits correspondentes �s portas para fazer a compara��o
			ORR     R2, #GPIO_PORTN                ;Seta o bit da porta J, fazendo com OR
            TST     R1, R2							;ANDS de R1 com R2
            BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando
 
; 2. Limpar o AMSEL para desabilitar a anal�gica
            MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a fun��o anal�gica
            LDR     R0, =GPIO_PORTN_AHB_AMSEL_R     ;Carrega o R0 com o endere�o do AMSEL para a porta J
            STR     R1, [R0]						;Guarda no registrador AMSEL da porta J da mem�ria
            LDR     R0, =GPIO_PORTN_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta F
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta F da mem�ria
 
; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
            LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere�o do PCTL para a porta J
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta J da mem�ria
            LDR     R0, =GPIO_PORTN_AHB_PCTL_R      ;Carrega o R0 com o endere�o do PCTL para a porta F
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta F da mem�ria
; 4. DIR para 0 se for entrada, 1 se for sa�da
            LDR     R0, =GPIO_PORTN_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta F
			MOV     R1, #2_00001001					;PF4 & PF0 para LED
            STR     R1, [R0]						;Guarda no registrador
			; O certo era verificar os outros bits da PF para n�o transformar entradas em sa�das desnecess�rias
            LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta J
            MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com sa�da
            STR     R1, [R0]						;Guarda no registrador PCTL da porta J da mem�ria
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem fun��o alternativa
            MOV     R1, #0x00						;Colocar o valor 0 para n�o setar fun��o alternativa
            LDR     R0, =GPIO_PORTN_AHB_AFSEL_R		;Carrega o endere�o do AFSEL da porta F
            STR     R1, [R0]						;Escreve na porta
            LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta J
            STR     R1, [R0]                        ;Escreve na porta
; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTN_AHB_DEN_R			;Carrega o endere�o do DEN
            MOV     R1, #2_00001001                     ;Ativa os pinos PF0 e PF4 como I/O Digital
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
 
            LDR     R0, =GPIO_PORTJ_AHB_DEN_R			;Carrega o endere�o do DEN
			MOV     R1, #2_00000011                     ;Ativa os pinos PJ0 e PJ1 como I/O Digital      
            STR     R1, [R0]                            ;Escreve no registrador da mem�ria funcionalidade digital
			
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R			;Carrega o endere�o do PUR para a porta J
			MOV     R1, #2_00000011						;Habilitar funcionalidade digital de resistor de pull-up 
                                                        ;nos bits 0 e 1
            STR     R1, [R0]							;Escreve no registrador da mem�ria do resistor de pull-up
;interrup��o
;8. Desabilitar a interrup��o no registrador IM
			
			LDR		R0, =GPIO_PORTJ_AHB_IM_R
			MOV 	R1, #2_00
			STR		R1,[R0]
;9. Configurar o tipo de interrup��o por borda no registrador IS

			LDR		R0, =GPIO_PORTJ_AHB_IS_R
			MOV 	R1, #2_00
			STR		R1,[R0]
			
;10. Configurar borda unica no registrador IBE

			LDR		R0, =GPIO_PORTJ_AHB_IBE_R
			MOV 	R1, #2_00
			STR		R1,[R0]
			
;11. Configurar borda de descida para o J0 e borda de subida para J1 no registrador GPIOIEV

			LDR		R0, =GPIO_PORTJ_AHB_IEV_R
			MOV 	R1, #2_10
			STR		R1,[R0]
			
;12. Garantir que a interrup��o ser� atendida limpando GPIORIS e GPIOMIS setando o GPIOICR

			LDR		R0, =GPIO_PORTJ_AHB_ICR_R
			MOV 	R1, #2_11
			STR		R1,[R0]

;13. Habilitar a interrup��o no registrador IM
			
			LDR		R0, =GPIO_PORTJ_AHB_IM_R
			MOV 	R1, #2_11
			STR		R1,[R0]

;14 Setar prioridade no NVIC 

			LDR R0,=NVIC_PRI12_R
			MOV R1, #5
			LSL R1, #29
			STR R1,[R0]
			
;15 Setar o bit para habilitar interrup��o

			LDR R0,=NVIC_EN1_R
			MOV R1, #1
			LSL R1, #19
			STR R1,[R0]




GPIOPortJ_Handler

	LDR R1,=GPIO_PORTJ_AHB_ICR_R
	MOV R0,#2_000000001
	STR R0,[R1]
	
	EOR R10,R10,#2_1
	


		
		
;retorno            
			BX      LR

; -------------------------------------------------------------------------------
; Fun��o PortF_Output
; Par�metro de entrada: R0 --> se os BIT4 e BIT0 est�o ligado ou desligado
; Par�metro de sa�da: N�o tem
PortN_Output
	LDR	R1, =GPIO_PORTN_AHB_DATA_R		    ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00001001                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11101110
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados dos pinos F4 e F0
	BX LR									;Retorno

; -------------------------------------------------------------------------------
; Fun��o PortJ_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor da leitura
PortJ_Input
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;L� no barramento de dados dos pinos [J1-J0]
	BX LR									;Retorno



    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo