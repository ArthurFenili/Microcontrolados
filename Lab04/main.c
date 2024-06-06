// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "lcd.h"
#include "teclado.h"

#define AH 0 //anti horario
#define H 1 //horario
#define INICIO 2
#define ESCOLHER_MODOS 3
#define TECLADO 4
#define POTENCIOMETRO 5

 uint8_t timer;
 int velocidade;
 int estado;
 char key;

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void GPIO_Init(void);


int main(void)
{
PLL_Init();
	SysTick_Init();
	GPIO_Init();
	LCD_Init();
	Timer_Init();
	estado = INICIO;
	
	while(1) {
			
		switch(estado){
			case INICIO:
				estadoInicial();
				break;
			
			case ESCOLHER_MODOS:
				escolherModos();
		}
			
			
	}
		
	
	
	
	
}

void estadoInicial(void) {
	velocidade = 0;
	key =
	LCD_WriteString("Motor parado    ");
	SysTick_Wait1ms(1000);
	estado = ESCOLHER_MODOS;
	
	
}

void ecolherModos(void) {

	LCD_WriteString("1. Teclado      ");
	LCD_Line2();
	LCD_WriteString("2. Potenciometro");
	SysTick_Wait1ms(1000);
	
	
	while(key != 1 && key != 2) {
		key = keyboard_read();
		
		if(key == 1){
			estado = 4;
			break;
		} else if(key == 2) {
			estado = 5
			break;
		}
	}
	
	
}





