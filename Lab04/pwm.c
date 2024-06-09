// pwm.c

#include <stdint.h>

#include "tm4c1294ncpdt.h"

#define HORARIO 1
#define ANTI_HORARIO 2


// Declarations
void LCD_WriteString (char* str);
void LCD_Line2 (void);
void LCD_Reset(void);
void PortF_Output (uint32_t data);
void PortE_Output (uint32_t data);



// Global Flags (external)
extern int pwm_high;
extern int estado_timer;
extern int sentido;


void PWM (int duty_cycle)
{
	pwm_high = 80000 * duty_cycle/4096;
	
	LCD_Reset();
	
	if (pwm_high < 8000) {LCD_WriteString("10% velocidade "); }
	else if (pwm_high < 16000) {LCD_WriteString("20% velocidade ");}
	else if (pwm_high < 24000) {LCD_WriteString("30% velocidade ");}
	else if (pwm_high < 32000) {LCD_WriteString("40% velocidade ");}
	else if (pwm_high < 40000) {LCD_WriteString("50% velocidade ");}
	else if (pwm_high < 48000) {LCD_WriteString("60% velocidade ");}
	else if (pwm_high < 56000) {LCD_WriteString("70% velocidade ");}
	else if (pwm_high < 64000) {LCD_WriteString("80% velocidade ");}
	else if (pwm_high < 72000) {LCD_WriteString("90% velocidade ");}
	else {LCD_WriteString("100% velocidade ");}
	
	LCD_Line2();
	
	if (sentido == HORARIO) {
		LCD_WriteString("Horario         ");
	} else {
		LCD_WriteString("Anti Horario    ");
	}
	
}


// Fun??o Timer_Init
// Inicializa o Timer 0
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: N?o tem
void Timer_Init (void)
{
	// 1. Habilitar o clock do timer 0 e esperar at? estar pronto para uso.
	SYSCTL_RCGCTIMER_R |= 0x1;
	
	while((SYSCTL_PRTIMER_R & 0x1) != 0x1)
	{
		//
	}
	
	// 2. Desabilita o timer 0 para configura??o
	TIMER0_CTL_R &= 0x0;
	
	// 3. Configura??o do timer 0
	TIMER0_CFG_R |= 0x00;				// Quantos bits ser? a contagem do temporizador (32 bits: 0x00)
	TIMER0_TAMR_R |= 0x2;				// Modo de opera??o do timer (0x02: Peri?dico)
	TIMER0_TAILR_R = pwm_high;	// Valor da contagem
	TIMER0_ICR_R  |= 0x1;				// Limpa a flag de interrup??o do timer
	TIMER0_IMR_R |= 0x1;				// Habilita a interrup??o do timer
	NVIC_PRI4_R |= 3 << 29;			// Seta prioridade 3 para a interrup??o
	NVIC_EN0_R |= 1 << 19;			// Habilita a interrup??o do timer no NVIC
	
	// 4. Habilita o timer 0 ap?s a configura??o
	TIMER0_CTL_R |= 0x1;
}

void Timer0A_Handler (void)
{
	TIMER0_ICR_R  |= 0x1;				// Limpa a flag de interrup??o do timer 0
	
	if (estado_timer == 1)					// Alto
	{
		estado_timer = 0;
		PortE_Output(0x00);
		TIMER0_TAILR_R = 80000 - pwm_high;
	}
	else												// Baixo
	{
		if (sentido == HORARIO){PortE_Output(0x02);}
		if (sentido == ANTI_HORARIO){PortE_Output(0x01);}
		TIMER0_TAILR_R = pwm_high;
		estado_timer = 1;
	}
}