// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron


#include <stdint.h>

#include "tm4c1294ncpdt.h"

extern uint8_t interrupcao;
extern uint8_t timer;
extern uint16_t angulo;
extern uint8_t sentido;

#define GPIO_PORTJ  (0x0100) //bit 8
#define GPIO_PORTN  (0x1000) //bit 12
#define GPIO_PORTA  (0x0001)
#define GPIO_PORTF  (0x20)
#define GPIO_PORTQ  (0x4000)
#define GPIO_PORTH  (0x80)
#define GPIO_PORTP  (0x2000)

#define A (0x41) //anti horario
#define H (0x48) //horario
#define C (0x43) //passo completo
#define M (0x4d) //meio passo
#define AST (0x2a) // *

// -------------------------------------------------------------------------------
// Fun??o GPIO_Init
// Inicializa os ports J e N
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: N?o tem
void GPIO_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTA | GPIO_PORTF | GPIO_PORTH | GPIO_PORTQ | GPIO_PORTP);
	SYSCTL_RCGCUART_R = 1;
	//1b.   ap?s isso verificar no PRGPIO se a porta est? pronta para uso.
	while((SYSCTL_PRGPIO_R & (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTA | GPIO_PORTF | GPIO_PORTH | GPIO_PORTQ | GPIO_PORTP) ) != 
  		(GPIO_PORTJ | GPIO_PORTN | GPIO_PORTA | GPIO_PORTF | GPIO_PORTH | GPIO_PORTQ | GPIO_PORTP) ){
		while((SYSCTL_PRUART_R & 1 ) != 1 ){};
	};
	
	// Configuração UART
	UART0_CTL_R = 0x00;
	UART0_IBRD_R = 130;      //2327325: baudrate 38400
	UART0_FBRD_R = 13;
	UART0_LCRH_R = 0xF2;     // 1111 0010 paridade impar
	UART0_CC_R = 0x00;
	UART0_CTL_R = 0x301;
	
	// 2. Limpar o AMSEL para desabilitar a anal?gica
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;
	GPIO_PORTH_AHB_AMSEL_R = 0x00;
	GPIO_PORTQ_AMSEL_R = 0x00;
	GPIO_PORTP_AMSEL_R = 0x00;
		
	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTJ_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTA_AHB_PCTL_R = 0x11;
	GPIO_PORTF_AHB_PCTL_R = 0x00;
	GPIO_PORTH_AHB_PCTL_R = 0x00;
	GPIO_PORTQ_PCTL_R = 0x00;
	GPIO_PORTP_PCTL_R = 0x00;
	
	// 4. DIR para 0 se for entrada, 1 se for sa?da
	GPIO_PORTJ_AHB_DIR_R = 0x00;
	GPIO_PORTN_DIR_R = 0x03; //BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x11, // BIT0 | BIT4
	GPIO_PORTH_AHB_DIR_R = 0x0F; //BIT0 a BIT3
	GPIO_PORTA_AHB_DIR_R = 0xF2; //
	GPIO_PORTQ_DIR_R = 0x0F; //BIT0 a BIT3
	GPIO_PORTP_DIR_R = 0x20; //BIT0 a BIT3
		
	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem fun??o alternativa	
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R = 0x00; 
	GPIO_PORTF_AHB_AFSEL_R = 0x00;
	GPIO_PORTH_AHB_AFSEL_R = 0x00;
	GPIO_PORTA_AHB_AFSEL_R = 0x03;
	GPIO_PORTQ_AFSEL_R = 0x00;
	GPIO_PORTP_AFSEL_R = 0x00;
		
	// 6. Setar os bits de DEN para habilitar I/O digital	
	GPIO_PORTJ_AHB_DEN_R = 0x03;   //Bit0 e bit1
	GPIO_PORTN_DEN_R = 0x03; 		   //Bit0 e bit1
	GPIO_PORTF_AHB_DEN_R = 0x11;	//Bit0 e bit4
	GPIO_PORTA_AHB_DEN_R = 0xF3;
	GPIO_PORTA_AHB_DATA_R = 0x00;
	GPIO_PORTH_AHB_DEN_R = 0x0F; //Bit0 a bit3
	GPIO_PORTQ_DEN_R = 0x0F; //Bit0 a bit3
	GPIO_PORTP_DEN_R = 0x20; //Bit0 a bit3
	
	// 7. Habilitar resistor de pull-up interno, setar PUR para 1
	GPIO_PORTJ_AHB_PUR_R = 0x01;   //Bit0 e bit1	
	
	// 8. Interrupções
	GPIO_PORTJ_AHB_IM_R		= 0x00;
	GPIO_PORTJ_AHB_IS_R		= 0x00;
	GPIO_PORTJ_AHB_IBE_R	= 0x00;
	GPIO_PORTJ_AHB_IEV_R	= 0x00;
	GPIO_PORTJ_AHB_ICR_R	= 0x01;
	GPIO_PORTJ_AHB_IM_R		= 0x01;
	NVIC_EN1_R						= 0x80000;		// 2_1 << 19
	NVIC_PRI12_R					= 0xA0000000;	// 2_5 << 29

}	

void TIMER_Init(void)
{
	SYSCTL_RCGCTIMER_R = 0x04;
	while (SYSCTL_PRTIMER_R != 0x04) {};
	TIMER2_CTL_R = 0x00;
	TIMER2_CFG_R = 0x00;
	TIMER2_TAMR_R = 0x02;
	TIMER2_TAILR_R = 0x7A11FF;
	TIMER2_TAPR_R = 0x00;
	TIMER2_ICR_R = 0x01;
	TIMER2_IMR_R = 0x01;
	NVIC_PRI5_R = 4 << 29;
	NVIC_EN0_R = 1 << 23;
	TIMER2_CTL_R = 0x01;
	
}

// -------------------------------------------------------------------------------
// Fun??o PortJ_Input
// L? os valores de entrada do port J
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: o valor da leitura do port
uint32_t PortJ_Input(void)
{
	return GPIO_PORTJ_AHB_DATA_R;
}

// Função GPIOPortJ_Handler
// Trata a interrupção no PJ0
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Não tem
void GPIOPortJ_Handler(void)
{
		uint32_t chave1 = GPIO_PORTJ_AHB_RIS_R;
		if (chave1 == 0x1) {
				GPIO_PORTJ_AHB_ICR_R = 0x1;
				interrupcao = 1;
				timer = 0;
				//TIMER2_CTL_R = 0x1;
		}
		else if (chave1 == 0x2) {
				GPIO_PORTJ_AHB_ICR_R = 0x2;
		}
}

// -------------------------------------------------------------------------------
// Fun??o PortN_Output
// Escreve os valores no port N
// Par?metro de entrada: Valor a ser escrito
// Par?metro de sa?da: n?o tem
void PortN_Output(uint32_t valor)
{
    uint32_t temp;
    //vamos zerar somente os bits menos significativos
    //para uma escrita amig?vel nos bits 0 e 1
    temp = GPIO_PORTN_DATA_R & 0xFC;
    //agora vamos fazer o OR com o valor recebido na fun??o
    temp = temp | valor;
    GPIO_PORTN_DATA_R = temp; 
}



// Função PortH_Output
// Escreve no Port H
// Parâmetro de entrada: Quais fases do motor deve acionar
// Parâmetro de saída: Não tem
void PortH_Output(uint32_t phases)
{
	uint32_t temp;
	temp = GPIO_PORTH_AHB_DATA_R & 0x00;
	
	temp = temp | phases;
	
	GPIO_PORTH_AHB_DATA_R = temp;
}

void PortP_Output(uint32_t transistor)
{
	GPIO_PORTP_DATA_R = transistor;

	return;
}

void Pisca_Transistor(void);

void invertePino0() {
	uint16_t led47 = GPIO_PORTA_AHB_DATA_R;
	uint16_t led03 = GPIO_PORTQ_DATA_R;

	if(sentido == H){
		if(angulo < 45){
			if (led47 != 0x00)
				led47 = 0x00;
			else
				led47 = 0x80;
			led03 = 0x00;
		}
		else if(angulo < 90){
			led47 = 0xC0;
			led03 = 0x00;
		}
		else if(angulo < 135){
			led47 = 0xE0;
			led03 = 0x00;
		}
		else if(angulo < 180){
			led47 = 0xF0;
			led03 = 0x00;
		}
		else if(angulo < 225){
			led47 = 0xF0;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x08;
		}
		else if(angulo < 270){
			led47 = 0xF0;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0C;
		}
		else if(angulo < 315){
			led47 = 0xF0;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0E;
		}
		else if(angulo < 360){
			led47 = 0xF0;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0F;
		}
	}
	else if(sentido == A){
		if(angulo < 45){
			led47 = 0x00;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x01;
		}
		else if(angulo < 90){
			led47 = 0x00;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x03;
		}
		else if(angulo < 135){
			led47 = 0x00;
			if (led03 != 0x00)
				led03 = 0x00;
			else	
				led03 = 0x07;
		}
		else if(angulo < 180){
			led47 = 0x00;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0F;
		}
		else if(angulo < 225){
			led47 = 0x10;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0F;
		}
		else if(angulo < 270){
			led47 = 0x30;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0F;
		}
		else if(angulo < 315){
			led47 = 0x70;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0F;
		}
		else if(angulo < 360){
			led47 = 0xF0;
			if (led03 != 0x00)
				led03 = 0x00;
			else
				led03 = 0x0F;
		}
	}

	GPIO_PORTA_AHB_DATA_R = led47;
	GPIO_PORTQ_DATA_R = led03;
	Pisca_Transistor();
}

void Timer2A_Handler() {
	TIMER2_ICR_R = 0x01;
	if(timer)
		invertePino0();
}
