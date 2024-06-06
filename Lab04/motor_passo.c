#include <stdint.h>


#include "tm4c1294ncpdt.h"

#define A (0x41) //anti horario
#define H (0x48) //horario
#define C (0x43) //passo completo
#define M (0x4d) //meio passo


uint8_t HOR_PC [4] = {0x09,0x03,0x06,0x0C};    // Matriz dos bytes das Fases do Motor - sentido Horário Full Step
uint8_t AHO_PC [4] = {0x0C,0x06,0x03,0x09}; 

uint8_t AHO_MP [8] = {0x08, 0x0C, 0x04, 0x06, 0x02, 0x03, 0x01, 0x09};    //fases meio passo
uint8_t HOR_MP [8] = {0x09, 0x01, 0x03, 0x02, 0x06, 0x04, 0x0C, 0x08};

void SysTick_Wait1ms(uint32_t delay);
void PortH_Output(uint32_t degrees);
void fim(void);

void transmitir(uint8_t txdata);
uint8_t receber(void);

void atualizar_terminal(int voltas, uint8_t velocidade, uint8_t sentido);
extern uint8_t interrupcao;
extern uint8_t timer;
uint16_t angulo;
uint16_t sentido;

// Gira o motor no sentido horário com passo completo
void Motor_HOR_PC(int voltas) {
	int j = 0;
	int count_voltas = 1;
	int count_angulo = 1; // contador para setar os 45°, 90°, 135° e assim por diante
	int passos = voltas*2048; // 2048 passos por revolução no motor 28BYJ-48
	int num_voltas;

	for(int i = 0; i < passos; i++)  {
    GPIO_PORTH_AHB_DATA_R = HOR_PC[j];
    SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos
	
		if(j == 3)
			j = 0;
		else	
			j++;  
		
		if (count_voltas > 1)
			angulo = ((i+1)*(360.0/2048.0)) - (360 * (count_voltas-1));
		else
			angulo = ((i+1)*(360.0/2048.0));
		num_voltas = (i+1)/2048;
		sentido = H;

		if (num_voltas == count_voltas) {
			atualizar_terminal(num_voltas, C, H);
			count_voltas++;
		}
		if(angulo > count_angulo*15)
		{
			count_angulo++;
		}
		
		if(interrupcao)
			return;

	}
	fim();
}

// Gira o motor no sentido anti horário com passo completo
void Motor_AHO_PC(int voltas)
{
	int j = 0;
	int count_voltas = 1;
	int count_angulo = 1; // contador para setar os 45°, 90°, 135° e assim por diante
	int passos = voltas*2048; // 2048 passos por revolução no motor 28BYJ-48
	int num_voltas;

	for(int i = 0; i < passos; i++)  {
    GPIO_PORTH_AHB_DATA_R = AHO_PC[j];
    SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos
	
		if(j == 3)
			j = 0;
		else	
			j++;  
		
		if (count_voltas > 1)
			angulo = ((i+1)*(360.0/2048.0)) - (360 * (count_voltas-1));
		else
			angulo = ((i+1)*(360.0/2048.0));
		num_voltas = (i+1)/2048;
		sentido = A;

		if (num_voltas == count_voltas) {
			atualizar_terminal(num_voltas, C, A);
			count_voltas++;
		}
		if(angulo > count_angulo*15)
		{
			count_angulo++;
		}
		
		if(interrupcao)
			return;

	}
	fim();
	
}

// Gira o motor no sentido horário com meio completo
void Motor_HOR_MP(int voltas)
{
	int j = 0;
	int count_voltas = 1;
	int count_angulo = 1; // contador para setar os 45°, 90°, 135° e assim por diante
	int passos = voltas*4096; // 2048 passos por revolução no motor 28BYJ-48
	int num_voltas;

	for(int i = 0; i < passos; i++)  {
		GPIO_PORTH_AHB_DATA_R = HOR_MP[j];
		SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos

		if(j == 7)
			j = 0;
		else	
			j++;  
		
		if (count_voltas > 1)
			angulo = ((i+1)*(360.0/4096.0)) - (360 * (count_voltas-1));
		else
			angulo = ((i+1)*(360.0/4096.0));
		num_voltas = (i+1)/4096;
		sentido = H;

		if (num_voltas == count_voltas) {
			atualizar_terminal(num_voltas, M, H);
			count_voltas++;
		}
		if(angulo > count_angulo*15)
		{
			count_angulo++;
		}
		
		if(interrupcao)
			return;
	}
	fim();
}

// Gira o motor no sentido anti horário com meio completo
void Motor_AHO_MP(int voltas)
{	
	int j = 0;
	int count_voltas = 1;
	int count_angulo = 1; // contador para setar os 45°, 90°, 135° e assim por diante
	int passos = voltas*4096; // 2048 passos por revolução no motor 28BYJ-48
	int num_voltas;

  for(int i = 0; i < passos; i++)  {  
  
    	GPIO_PORTH_AHB_DATA_R = AHO_MP[j];
    	SysTick_Wait1ms (10);          // Atraso de tempo entre as fases em milisegundos

		if(j == 7)
			j = 0;
		else	
			j++;  
		
		if (count_voltas > 1)
			angulo = ((i+1)*(360.0/4096.0)) - (360 * (count_voltas-1));
		else
			angulo = ((i+1)*(360.0/4096.0));
		num_voltas = (i+1)/4096;
		sentido = A;

		if (num_voltas == count_voltas) {
			atualizar_terminal(num_voltas, M, A);
			count_voltas++;
		}
		if(angulo > count_angulo*15)
		{
			count_angulo++;
		}
		
		if(interrupcao)
			return;
	}
	fim();
}