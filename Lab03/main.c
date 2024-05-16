// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "tm4c1294ncpdt.h"

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void GPIO_Init(void);
uint32_t PortJ_Input(void);
void PortN_Output(uint32_t leds);
void Pisca_leds(void);

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	uint32_t rxfe;
	uint8_t rxdata;
	uint32_t txff;

	while (1)
	{
		rxfe = UART0_FR_R & 0x10;
		if (!rxfe){
			rxdata = UART0_DR_R;
			
		}
		
		txff = UART0_FR_R & 0x20;
		if (!txff){
			UART0_DR_R = rxdata;
		}	
	
	}
}
