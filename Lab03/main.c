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
void Motor_HOR_PC(uint16_t graus);
void Motor_AHO_PC(uint16_t graus);
void Motor_HOR_MP(uint16_t graus);
void Motor_AHO_MP(uint16_t graus);


uint8_t HOR_PC [4] = {0x09,0x03,0x06,0x0C};    // Matriz dos bytes das Fases do Motor - sentido Horário Full Step
uint8_t AHO_PC [4] = {0x0C,0x06,0x03,0x09}; 

uint8_t AHO_MP [8] = {0x08, 0x0C, 0x04, 0x06, 0x02, 0x03, 0x01, 0x09};    //fases meio passo
uint8_t HOR_MP [8] = {0x09, 0x01, 0x03, 0x02, 0x06, 0x04, 0x0C, 0x08};

uint32_t rxfe;
uint8_t rxdata;
uint32_t txff;
uint8_t txdata = 0x5A;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();


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

void Motor_HOR_PC(uint16_t graus) {
	int j = 0;
	int k = 1;
	int i;
	int passos = (int)(graus/(360.0/2048.0)+0.5);

	for(i = 0; i < passos; i++)  {
  
    	GPIO_PORTH_AHB_DATA_R = HOR_PC[j];
    	SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos

		if(j == 3)
			j = 0;
		else	
			j++;  

		if((i+1)*(360.0/2048.0) > k*15)
		{
			update_terminal((int)(i*(360.0/2048.0)+0.5), PC, HO);
			LED_Output(HO, (int)(i*(360.0/2048.0)+0.5));
			k++;
		}

		if(interrupt)
			return;

    }    

	if((i+1)*(360.0/2048.0)> k*15)
	{
		update_terminal((int)(i*(360.0/2048.0)+0.5),  PC, HO);
		LED_Output(HO, (int)(i*(360.0/2048.0)+0.5));
	}
}

void Motor_AHO_PC(uint16_t graus)
{
	int j = 0;
	int k = 1;
	int i;
	int passos = (int)(graus/(360.0/2048.0)+0.5);

	for(i = 0; i < passos; i++)  {
  
		GPIO_PORTH_AHB_DATA_R = AHO_PC[j];
 	    SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos

		if(j == 3)
			j = 0;
		else	
			j++;  

		if( (i+1)*(360.0/2048.0)> k*15)
		{
			update_terminal((int)(i*(360.0/2048.0)+0.5), PC, AH);
			k++;
			LED_Output(AH,(int)(i*(360.0/2048.0)+0.5));
		}

		if(interrupt)
			return;
    }    

	if((i+1)*(360.0/2048.0)> k*15)
		{
			update_terminal((int)(i*(360.0/2048.0)+0.5), PC, AH);
			LED_Output(AH,(int)(i*(360.0/2048.0)+0.5));
		}
	
}

void Motor_HOR_MP(uint16_t graus)
{
	int j = 0;
	int k = 1;
	int i;
	int passos = (int)(graus/(360.0/4096.0)+0.5);

	for(i = 0; i < passos; i++)  {
  
		GPIO_PORTH_AHB_DATA_R = HOR_MP[j];
		SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos

		if(j == 7)
			j = 0;
		else	
			j++;  

		if((i+1)*(360.0/4096.0) > k*15 || (i+1)*(360.0/4096.0) == 360)
		{
			update_terminal((int)(i*(360.0/4096.0)+0.5), MP, HO);
			LED_Output(HO,(int)(i*(360.0/4096.0)+0.5));
			k++;
		}

		if(interrupt)
			return;

    }

	if((i+1)*(360.0/4096.0)> k*15)
	{
		update_terminal((int)(i*(360.0/4096.0)+0.5), MP, HO);
		LED_Output(HO,(int)(i*(360.0/4096.0)+0.5));
	}  
	
}

void Motor_AHO_MP(uint16_t graus)
{	
	int j = 0;
	int k = 1;
	int i;
	int passos = (int)(graus/(360.0/4096.0)+0.5);

  for(i = 0; i < passos; i++)  {  
  
    	GPIO_PORTH_AHB_DATA_R = AHO_MP[j];
    	SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos

		if(j == 7)
			j = 0;
		else	
			j++;  

		if((i+1)*(360.0/4096.0) > k*15 || (i+1)*(360.0/4096.0) == 360)
		{
			update_terminal((int)(i*(360.0/4096.0)+0.5), MP, AH);
			LED_Output(AH,(int)(i*(360.0/4096.0)+0.5));
			k++;
		}

		if(interrupt)
			return;

    }     

	if((i+1)*(360.0/4096.0)> k*15)
	{
		update_terminal((int)(i*(360.0/4096.0)+0.5), MP, AH);
		LED_Output(AH,(int)(i*(360.0/4096.0)+0.5));
	}
	
}