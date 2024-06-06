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
 int sentido;
 uint32_t key;

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void GPIO_Init(void);

void estadoInicial(void) {
	velocidade = 0;
	sentido = H;
	LCD_WriteString("Motor parado    ");
	SysTick_Wait1ms(1000);
	LCD_Reset();
	estado = ESCOLHER_MODOS;
	
	
}

void escolherModos(void) {

	LCD_WriteString("1. Teclado      ");
	LCD_Line2();
	LCD_WriteString("2. Potenciometro");
	SysTick_Wait1ms(1000);
	
	
	while(key != 0xEE && key != 0xDE) {
			
		key = MatrixKeyboard_Map();
		if(key == 0xEE){
			estado = TECLADO;
			break;
		} else if(key == 0xDE) {
			estado = POTENCIOMETRO;
			break;
		}
	}
	
	LCD_Reset();
	
	
}

void escolherSentido(void) {

	LCD_WriteString("1. Anti horario ");
	LCD_Line2();
	LCD_WriteString("2. Horario");
	SysTick_Wait1ms(1000);
	
	
	while(key != 0xEE && key != 0xDE) {
			
		key = MatrixKeyboard_Map();
		if(key == 0xEE){
			sentido = AH;
			break;
		} else if(key == 0xDE) {
			sentido = H;
			break;
		}
	}

	LCD_Reset();
	
	
}

void imprimirVelocidadeSentido(void) {
	
	if(sentido == AH){
		LCD_WriteString("Anti horario    ");
	}else if(sentido == H) {
		LCD_WriteString("Horario    ");
	}
	
	LCD_Line2();
	char *str = (char *)malloc(12 * sizeof(char));
	sprintf(str, "%d", velocidade);
	LCD_WriteString(velocidade);
	SysTick_Wait1ms(1000);
		
}
int main(void)
{
PLL_Init();
	SysTick_Init();
	GPIO_Init();
	LCD_Init();
	estado = INICIO;
	
	while(1) {
			
		switch(estado){
			case INICIO:
				estadoInicial();
				break;
			
			case ESCOLHER_MODOS:
				escolherModos();
				break;
			
			case TECLADO:
				escolherSentido();
				imprimirVelocidadeSentido();
				break;
			
			case POTENCIOMETRO:
				imprimirVelocidadeSentido();
		}
			
			
	}	
}




