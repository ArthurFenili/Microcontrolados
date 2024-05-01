<<<<<<< HEAD
; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este programa deve esperar o usu?rio pressionar uma chave.
; Caso o usu?rio pressione uma chave, um LED deve piscar a cada 1 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instru??es do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declara??es EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Defini??es de Valores
INVALID_DIGIT			EQU 256 ; Representa um d?gito inv?lido do teclado matricial
INVALID_PW_CHAR			EQU -1	; Representa um caractere imposs�vel de estar na senha
INICIO  				EQU 0
CONFIG_SENHA 			EQU 1
COFRE_FECHANDO 			EQU 2
COFRE_FECHADO 			EQU 3



; -------------------------------------------------------------------------------
; ?rea de Dados - Declara??es de vari?veis
		AREA  DATA, ALIGN=2
		; Se alguma vari?vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari?vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari?vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi??o da RAM		
PASSWORDS SPACE 8			; 4 bytes para a senha do usu�rio e 4 bytes para a senha mestra
; -------------------------------------------------------------------------------
; ?rea de C?digo - Tudo abaixo da diretiva a seguir ser? armazenado na mem?ria de 
;                  c?digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun??o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun??o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun??o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun??o <func>
		IMPORT PLL_Init
		IMPORT SysTick_Init
		IMPORT SysTick_Wait1ms			
		
		IMPORT GPIO_Init
		IMPORT PortA_Output
		IMPORT PortP_Output
		IMPORT PortQ_Output
			
		IMPORT LCD_Init
		IMPORT LCD_Line2
		IMPORT LCD_Reset
		IMPORT LCD_PrintString
		
		IMPORT MapMatrixKeyboard

;?Cofre aberto, digite nova senha para fechar o cofre?.
cofre_aberto DCB "Cofre aberto    ", 0
cofre_abrindo DCB "Cofre abrindo   ", 0
digite_senha DCB "Digite a senha  ", 0
string_vazia DCB "                ", 0
cofre_fechando DCB "Cofre fechando  ", 0
cofre_fechado DCB "Cofre fechado   ", 0
; -------------------------------------------------------------------------------
; Fun??o main()
Start  		
	BL PLL_Init				; Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init			; Chama a subrotina para inicializar o SysTick
	BL GPIO_Init			; Chama a subrotina que inicializa os GPIO
	
	
	BL LCD_Init				; Chama a subrotina que inicializa o LCD
	MOV R6, #INVALID_DIGIT	; R6 usado para guardar o d?gito lido do teclado
	MOV R7, #0				; R7 usado para contar quantos d?gitos o usu?rio digitou
	MOV R5, #INICIO			; Seta o estado inicial para cofre aberto
	MOV R9, #0				; Contador para comparar a senha inserida com a senha na mem�ria
	MOV R10, #0				; Contador para contar a quantidade de acertos da senha
	LDR R8, =PASSWORDS		; R8 usado para apontar a posi��o da senha salva na mem�ria
	
	
MainLoop
	
	CMP R5, #INICIO
	BEQ EstadoInicial
	CMP R5, #CONFIG_SENHA
	BEQ InserirSenha
	CMP R5, #COFRE_FECHANDO
	BEQ CofreFechando
	CMP R5, #COFRE_FECHADO
	BEQ CofreFechado
	

	B MainLoop

EstadoInicial
	BL LCD_Reset
	LDR R4, =cofre_aberto ;R4 guarda as mensagens pra mostrar no display
	BL LCD_PrintString ; imprime mensagem
	MOV R0, #5000	 ;seta o tempo que vai ficar a mensagem
	BL SysTick_Wait1ms ;wait
	BL LCD_Reset ;limpa o display
	LDR R4,=digite_senha ; muda a string que vai pro display
	BL LCD_PrintString ;imprime nova string
	MOV R0, #5000		 ; seta o tempo
	BL SysTick_Wait1ms
	BL LCD_Reset ;limpa o display
	MOV R5,#CONFIG_SENHA ; muda o estado do cofre
	
	B MainLoop

InserirSenha
	BL MapMatrixKeyboard
	BL VerificaUltimoDigito
	
	STRB R6, [R8, R7] 		; guarda a senha
	MOV R6, #INVALID_DIGIT		; Depois de contabilizado, invalida R6 para evitar erros

	CMP R7, #4					; Verifica se 4 d?gitos foram inseridos
	BLT InserirSenha			; Se n�o, volta para o inicio
	BEQ VerificaUltimoDigito
	
	B EstadoInicial			; volta para cofre aberto se n�o pressionou #
	
VerificaUltimoDigito ;verifica se foi digitado #, se n?o for, continua lendo a senha
	CMP R5, #COFRE_FECHANDO			; Verifica se o estado do cofre ? fechando 
	BNE InserirSenha				; Se ainda n?o for, volta para configurar a senha
	B MainLoop
	
CofreFechando
	BL LCD_Reset ;limpa o display
	MOV R0, #1000		 ; seta o tempo  de 1s
	BL SysTick_Wait1ms
	LDR R4,=cofre_fechando ; muda a string que vai pro display
	BL LCD_PrintString 		;imprime nova string
	MOV R0, #5000		 ; seta o tempo de 5s
	BL SysTick_Wait1ms
	BL LCD_Reset
	MOV R5, #COFRE_FECHADO
	MOV R7, #0				; R7 usado para contar quantos d?gitos o usu?rio digitou
	
	B MainLoop

CofreFechado
	BL LCD_Reset
	LDR R4,=cofre_fechado ; muda a string que vai pro display
	BL LCD_PrintString ;imprime nova string
	MOV R0, #5000		 ; seta o tempo de 5s
	BL SysTick_Wait1ms
	
PedeSenhaFechado
	BL LCD_Line2				; Coloca o cursor no come�o da segunda linha
	
	LDR R4, =digite_senha		; Imprime a mensagem de digitar a senha
	BL LCD_PrintString
	
	MOV R0, #500		 		; seta o tempo de 0,5s
	BL SysTick_Wait1ms
	
	BL LCD_Line2
	
	LDR R4, =string_vazia		; Imprime uma string vazia na segunda linha
	BL LCD_PrintString

	BL LCD_Line2			; Depois do cursor ser deslocado para o fim, posiciona de volta no come�o
	
	MOV R7, #0				; Zera R7
	MOV R10, #0				; Zera R10
	
	MOV R6, #INVALID_DIGIT	; Nenhum d�gito foi lido. Coloca R6 em estado inv�lido (reset)
	
ConferirSenha
	BL MapMatrixKeyboard	; L� o d�gito pressionado no teclado e guarda em R6
	
	LDRB R9, [R8, R7] 			; coloca em R9 os digitos a senha
	CMP R6, R9
	ADDEQ R10, R10, #1			; incrementar contador de acertos se o digito inserido for igual o da mem�ria
	
	MOV R6, #INVALID_DIGIT		; Depois de contabilizado, invalida R6 para evitar erros
	MOV R9, #INVALID_PW_CHAR
	
	CMP R10, #4
	BEQ CofreAbrindo

	CMP R7, #4					; Verifica se 4 d?gitos foram inseridos
	BLT ConferirSenha			; Se n�o, volta para o inicio
	B PedeSenhaFechado

CofreAbrindo
	BL LCD_Reset 			;limpa o display
	MOV R0, #1000		 	; seta o tempo  de 1s
	BL SysTick_Wait1ms
	LDR R4,=cofre_abrindo 	; muda a string que vai pro display
	BL LCD_PrintString 		;imprime nova string
	MOV R0, #5000		 	; seta o tempo de 5s
	BL SysTick_Wait1ms
	BL LCD_Reset
	MOV R5, #INICIO
	MOV R7, #0				; Zera R7
	MOV R10, #0				; Zera R10
	
	B MainLoop
	
	
	

; ****************************************
; Escrever c?digo que l? o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da se??o est? alinhada 
    END                          ;Fim do arquivo
=======
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
INICIO  EQU 0x0
CONFIG_SENHA EQU 0x1
COFRE_FECHANDO EQU 0x2
COFRE_FECHADO EQU 0x3



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
		IMPORT SysTick_Wait
		
		IMPORT GPIO_Init
			
		IMPORT LCD_Init
		IMPORT LCD_Line2
		IMPORT LCD_Reset
		IMPORT LCD_PrintString
		
		IMPORT MapMatrixKeyboard

;�Cofre aberto, digite nova senha para fechar o cofre�.
cofre_aberto DCB "Cofre aberto    ", 0
digite_senha DCB "digite novasenha", 0
para_fechar  DCB "parafecharocofre", 0
string_vazia DCB "                ", 0
cofre_fechando DCB "Cofre fechando..", 0
cofre_fechado DCB "Cofre fechado   ", 0
; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init				; Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init			; Chama a subrotina para inicializar o SysTick
	BL GPIO_Init			; Chama a subrotina que inicializa os GPIO
	
	MOV R5, #INICIO
	

Reiniciar
	BL LCD_Init				; Chama a subrotina que inicializa o LCD
	MOV R6, #INVALID_DIGIT	; R6 usado para guardar o d�gito lido do teclado
	MOV R7, #0				; R7 usado para contar quantos d�gitos o usu�rio digitou
	
	
MainLoop
	
	CMP R5, #INICIO
	BEQ EstadoInicial
	CMP R5, #CONFIG_SENHA
	BEQ InserirSenha
	CMP R5, #COFRE_FECHANDO
	BEQ CofreFechando
	CMP R5, #COFRE_FECHADO
	BEQ CofreFechado
	

	B MainLoop

EstadoInicial
	
	BL LCD_Reset
	LDR R4, =cofre_aberto ;R4 guarda as mensagens pra mostrar no display
	BL LCD_PrintString ; imprime mensagem
	MOV R0, #5000	 ;seta o tempo que vai ficar a mensagem
	BL SysTick_Wait1ms ;wait
	BL LCD_Reset ;limpa o display
	LDR R4,=digite_senha ; muda a string que vai pro display
	BL LCD_PrintString ;imprime nova string
	BL LCD_Line2 ; muda pra segunda linha do display
	LDR R4,=para_fechar ;coloca string pra imprimir
	BL LCD_PrintString ; imprime na segunda linha
	MOV R0, #5000		 ; seta o tempo
	BL SysTick_Wait1ms
	BL LCD_Line2 ; muda pra segunda linha do display
	LDR R4,=string_vazia ; muda a string que vai pro display
	BL LCD_PrintString ;imprime nova string
	MOV R5,#CONFIG_SENHA ; muda o estado do cofre
	
	B MainLoop

	

InserirSenha

	BL LCD_Reset
	BL MapMatrixKeyboard
	BL VerificaUltimoDigito
	
	STRB R6, [R8, R7] ; guarda a senha

	CMP R7, #4					; Verifica se 4 d�gitos foram inseridos
	BLT InserirSenha			; Se n�o, volta para o inicio
	

	BL LCD_Reset				; Se sim, reseta o display
	
	
VerificaUltimoDigito ;verifica se foi digitado #, se n�o for, continua lendo a senha
	CMP R5, #COFRE_FECHANDO			; Verifica se o estado do cofre � fechando 
	BNE InserirSenha				; Se ainda n�o for, volta para configurar a senha
	B MainLoop
	
CofreFechando

	MOV R0, #1000		 ; seta o tempo  de 1s
	BL SysTick_Wait1ms
	LDR R4,=cofre_fechando ; muda a string que vai pro display
	BL LCD_PrintString ;imprime nova string
	MOV R0, #5000		 ; seta o tempo de 5s
	BL SysTick_Wait1ms
	BL LCD_Reset
	MOV R5, #COFRE_FECHADO
	
	B MainLoop

CofreFechado

	BL LCD_Reset
	LDR R4,=cofre_fechado ; muda a string que vai pro display
	BL LCD_PrintString ;imprime nova string
	MOV R0, #5000		 ; seta o tempo de 5s
	BL SysTick_Wait1ms
	
	B MainLoop


	
	
	

; ****************************************
; Escrever c�digo que l� o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da se��o est� alinhada 
    END                          ;Fim do arquivo
>>>>>>> 037dea806ab2a983dcd97aeded5462d131ec5c5b
