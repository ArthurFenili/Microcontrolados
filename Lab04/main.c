// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "lcd.h"
#include "teclado.h"
#include "gpio.h"
#include "conversor_ad.h"

#define HORARIO 1
#define ANTI_HORARIO 2


typedef enum estadoAtual
{
	INICIO,
	ESCOLHER_MODOS,
	TECLADO,
	POTENCIOMETRO,
} estadosAtuais;

estadosAtuais estado = INICIO;

uint8_t timer;
int velocidade;
uint32_t modo = 0xFF;
int sentido = 0;
int pwm_high = 80000;
int estado_timer = 0;
int resetar = 0;
int adc = 0;

// pwm e timer
void PWM (int duty_cycle);
void Timer_Init (void);
void Timer0A_Handler (void);


void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void GPIO_Init(void);

void estadoInicial(void) {
	velocidade = 0;
	LCD_Reset();
	LCD_WriteString("Motor parado    ");
	SysTick_Wait1ms(1000);
	estado = ESCOLHER_MODOS;
}

void escolherModos(void) {
	LCD_Reset();
	LCD_WriteString("1. Teclado      ");
	LCD_Line2();
	LCD_WriteString("2. Potenciometro");
	SysTick_Wait1ms(1000);
	
	
	while(modo != 0xEE && modo != 0xDE) {
		modo = MatrixKeyboard_Map();
		if(modo == 0xEE){
			estado = TECLADO;
			break;
		} else if(modo == 0xDE) {
			estado = POTENCIOMETRO;
			break;
		}
	}
	
}

void modoTeclado(void) {
	LCD_Reset();
	LCD_WriteString("Sentido:        ");
	SysTick_Wait1ms(1000);
	
	LCD_Reset();
	LCD_WriteString("1. Horario      ");
	LCD_Line2();
	LCD_WriteString("2. Anti Horario ");
	SysTick_Wait1ms(1000);
	
	
	modo = MatrixKeyboard_Map();
	
	while(modo != 0xEE && modo != 0xDE) {
		modo = MatrixKeyboard_Map();
		if(modo == 0xEE){
			sentido = HORARIO;
		} else if(modo == 0xDE) {
			sentido = ANTI_HORARIO;
		}
	}
	
	PortF_Output(0x04);
	
	while (!resetar)
	{
		modo = MatrixKeyboard_Map();
		if (modo == 0xEE) {
			sentido = HORARIO;
			LCD_Reset();
			LCD_WriteString("Horario         ");
			SysTick_Wait1ms(100);
		}
		if (modo == 0xDE) {
			sentido = ANTI_HORARIO;
			LCD_Reset();
			LCD_WriteString("Anti Horario    ");
			SysTick_Wait1ms(100);
		}
						
		adc = AD_Convert();
		PWM(adc);
						
		SysTick_Wait1ms(100);
	}
	
	resetar = 0;
	modo = 0xFF;
	estado = INICIO;
	PortF_Output(0x00);

}

void modoPotenciometro(void) {
	LCD_Reset();
	
	
	PortF_Output(0x04);
	
	while (!resetar)
	{		
		adc = AD_Convert();
		
		if (adc <= 2048){
			sentido = HORARIO;
			adc = 4096 * (2049 - adc)/2048;
		} else {
			sentido = ANTI_HORARIO;
			adc = 2*(adc-2048);
		}
		
		PWM(adc);
						
		SysTick_Wait1ms(100);
	}
	
	resetar = 0;
	modo = 0xFF;
	estado = INICIO;
	PortF_Output(0x00);
}

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	LCD_Init();
	AD_Converter_Init();
	Timer_Init();
	PortF_Output(0x04);
	
	
	while(1) {
		if(resetar)
			resetar = 0;
		switch(estado){
			case INICIO:
				estadoInicial();
			break;
			
			case ESCOLHER_MODOS:
				escolherModos();
			break;
			
			case TECLADO:
				modoTeclado();
			break;
			
			case POTENCIOMETRO:
				modoPotenciometro();
			break;
			
		}
	}	
}



