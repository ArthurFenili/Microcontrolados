// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "tm4c1294ncpdt.h"

#define A (0x41) //anti horario
#define H (0x48) //horario
#define C (0x43) //passo completo
#define M (0x4d) //meio passo
#define AST (0x2a) // *

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void GPIO_Init(void);

// Imprime a requisição do sentido, voltas e velocidade no terminal
uint8_t pedir_sentido(void);
int pedir_voltas(void);
uint8_t pedir_velocidade(void);

// Portas
uint32_t PortJ_Input(void);
void PortN_Output(uint32_t leds);
void PortP_Output(uint32_t transistor);

// Motor
void movimenta_motor(uint8_t sentido, uint8_t velocidade, int voltas);
void Motor_HOR_PC(int voltas);
void Motor_AHO_PC(int voltas);
void Motor_HOR_MP(int voltas);
void Motor_AHO_MP(int voltas);

// Transforma o número de voltas de hexadecimal para inteiro
int hex_to_int(uint8_t voltas_dezena, uint8_t voltas_unidade);

void esperar_ast(void);

// Transmitir e receber os dados
void transmitir(uint8_t txdata);
uint8_t receber(void);

// Picar leds
void LED_Output(uint8_t sentido, uint16_t angulo);
void Pisca_Transistor(void);
	
uint32_t rxfe;
uint8_t rxdata;
uint32_t txff;
uint8_t interrupcao = 0;


int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	
	uint8_t p = receber();
	transmitir(p); // imprime quebra de linha
	while(1) {
		// Definição das variaveis sentido, voltas e velocidade
		uint8_t sentido = 0x00;
		uint8_t velocidade = 0x00;
		int voltas = 0;
		
		interrupcao = 0;											//reseta a flag de interrupção
		GPIO_PORTA_AHB_DATA_R = GPIO_PORTA_AHB_DATA_R & 0x0F;	//reseta os leds
		GPIO_PORTQ_DATA_R = GPIO_PORTQ_DATA_R & 0xF0;  			//reseta os leds 
		
		sentido = pedir_sentido(); // pede o sentido de rotação (H - horário ou A - anti horário)
		
		velocidade = pedir_velocidade(); // pede a velocidade do giro (C- passo completo ou M - meio passo)
		
		voltas = pedir_voltas(); // pede o numero de voltas do giro
		
		movimenta_motor(sentido, velocidade, voltas);
		esperar_ast();
	}
}

uint16_t pedir_angulo(void){

	uint8_t unidade = 0x00;
	uint8_t dezena;
	uint8_t centena;
	uint8_t virgula = 0x00;
	
	centena = receber();
	dezena = receber();
	unidade = receber();
	

	if(unidade == 0x2C){
		unidade = dezena;
		dezena = centena;
		centena = 0x30;
	}
	else {
		while (virgula != 0x2C){
			virgula = receber();
		}
	}

	return ((centena-0x30)*100 + (dezena-0x30)*10 + (unidade-0x30));

}
void transmitir(uint8_t txdata){
	txff = UART0_FR_R & 0x20;
	while(txff){
		txff = UART0_FR_R & 0x20;}
	
	if (!txff)
		UART0_DR_R = txdata;
}

uint8_t receber(void) {
	rxfe = UART0_FR_R & 0x10;
	while(rxfe) {
		rxfe = UART0_FR_R & 0x10;
	}
	if (!rxfe){
		rxdata = UART0_DR_R;
	}
	return rxdata;
}

uint8_t pedir_sentido(void) {
	uint8_t sentido = 0x00;
	uint8_t s[]={0x53,0x65,0x6e,0x74,0x69,0x64,0x6f,0x3a}; // Guarda os hexadecimais de "Sentido:" no vetor s
 
	for(int i=0; i<sizeof(s); i++)
		transmitir(s[i]); // imprime "Sentido:" no terminal
	
	sentido = receber(); // recebe o sentido de rotação
	transmitir(sentido);
	transmitir(0x2c); // Vírgula
	transmitir(0x20); // Espaço vazio
	
	while (sentido != H && sentido != A) {
		for(int i=0; i<sizeof(s); i++)
			transmitir(s[i]); // imprime "Sentido:" no terminal
	
		sentido = receber(); // recebe o sentido de rotação
		transmitir(sentido);
		transmitir(0x2c); // Vírgula
		transmitir(0x20); // Espaço vazio
	}
	
	return sentido;
}

int pedir_voltas(void) {
	uint8_t voltas_dezena = 0x00;
	uint8_t voltas_unidade = 0x00;
	int voltas = 1;
	uint8_t v[]={0x56,0x6f,0x6c,0x74,0x61,0x73,0x3a}; // Guarda os hexadecimais de "Voltas:" no vetor s
 
	for(int i=0; i<sizeof(v); i++)
		transmitir(v[i]); // imprime "Voltas:" no terminal
	
	voltas_dezena = receber(); // recebe o numero de voltas do giro
	voltas_unidade = receber(); // recebe o numero de voltas do giro
	transmitir(voltas_dezena);
	transmitir(voltas_unidade);
	voltas = hex_to_int(voltas_dezena, voltas_unidade);
	transmitir(0x0a); // Quebra de linha
	transmitir(0x0d); // proxima linha
	
	while (voltas < 1 || voltas > 10) {
		for(int i=0; i<sizeof(v); i++)
			transmitir(v[i]); // imprime "Voltas:" no terminal
		voltas_dezena = receber(); // recebe o numero de voltas do giro
		voltas_unidade = receber(); // recebe o numero de voltas do giro
		transmitir(voltas_dezena);
		transmitir(voltas_unidade);
		voltas = hex_to_int(voltas_dezena, voltas_unidade);
		transmitir(0x0a); // Quebra de linha
		transmitir(0x0d); // proxima linha
	}
	
	return voltas;
}

uint8_t pedir_velocidade(void) {
	uint8_t velocidade = 0x00;
	uint8_t ve[]={0x56,0x65,0x6c,0x6f,0x63,0x69,0x64,0x61,0x64,0x65,0x3a}; // Guarda os hexadecimais de "Valocidade:" no vetor s
 
	for(int i=0; i<sizeof(ve); i++)
		transmitir(ve[i]); // imprime "Velocidade:" no terminal
	
	velocidade = receber(); // recebe a velocidade do giro
	transmitir(velocidade);
	transmitir(0x2c); // Vírgula
	transmitir(0x20); // Espaço vazio
	
	while (velocidade != C && velocidade != M) {
		for(int i=0; i<sizeof(ve); i++)
			transmitir(ve[i]); // imprime "Velocidade:" no terminal
		velocidade = receber(); // recebe a velocidade do giro
		transmitir(velocidade);
		transmitir(0x2c); // Vírgula
		transmitir(0x20); // Espaço vazio
	}

	return velocidade;
}

int hex_to_int(uint8_t voltas_dezena, uint8_t voltas_unidade) {
	if(voltas_dezena == 0x31 && voltas_unidade == 0x30) { // 0x31 é 1 em hex e 0x30 é 0 em hex, devolve inteiro 10 caso o numero de voltas seja 10
		return 10;
	}
	else {
		return voltas_unidade - '0'; // se não retorna o numero de voltas como inteiro
	}
}


void movimenta_motor(uint8_t sentido, uint8_t velocidade, int voltas) {
	if(sentido == H && velocidade == C)				// Sentido horário e passo completo
		Motor_HOR_PC(voltas);
	else if(sentido == H && velocidade == M)	// Sentido horário e meio completo
		Motor_HOR_MP(voltas);
	else if(sentido == A && velocidade == M)	// Sentido anti horário e meio completo
		Motor_AHO_MP(voltas);
	else if(sentido == A && velocidade == C)	// Sentido anti horário e passo completo
		Motor_AHO_PC(voltas);
}

void atualizar_terminal(int voltas, uint8_t velocidade, uint8_t sentido){
	uint8_t velocidade_string[] = {0x56,0x65,0x6c,0x6f,0x63,0x69,0x64,0x61,0x64,0x65,0x3a,0x20}; // Salva a string "Velocidade: "
	uint8_t sentido_string[] = {0x53,0x65,0x6e,0x74,0x69,0x64,0x6f,0x3a,0x20}; // Salva a string "Sentido: "
	uint8_t voltas_string[] = {0x56,0x6f,0x6c,0x74,0x61,0x73,0x3a,0x20}; // Salva a string "Voltas: "
	
	uint8_t horario_string[] = {0x68,0x6f,0x72,0x61,0x72,0x69,0x6f};	// Salva a string "horario"
	uint8_t anti_hor_string[] = {0x61,0x6e,0x74,0x69,0x2d,0x68,0x6f,0x72,0x61,0x72,0x69,0x6f};	// Salva a string "anti-horario"
	uint8_t passo_comp_string[] = {0x70,0x61,0x73,0x73,0x6f,0x2d,0x63,0x6f,0x6d,0x70,0x6c,0x65,0x74,0x6f};	// Salva a string "passo-completo"
	uint8_t meio_passo_string[] = {0x6d,0x65,0x69,0x6f,0x2d,0x70,0x61,0x73,0x73,0x6f};	// Salva a string "meio-passo"
	
	uint8_t volta = voltas + '0';
	
	transmitir(0x0A); // Quebra de linha (/n)
	transmitir(0x0d);	// Enter (/r)
	
	// Imprime a velocidade (P - passo completo ou M - meio passo)
	for (int i = 0; i< sizeof(velocidade_string); i++) {
		transmitir(velocidade_string[i]);
	}
	if (velocidade == C) {
		for (int i = 0; i< sizeof(passo_comp_string); i++) {	// Imprimir passo completo
			transmitir(passo_comp_string[i]);
		}
	} else {
		for (int i = 0; i< sizeof(meio_passo_string); i++) {	// Imprimir meio passo 
			transmitir(meio_passo_string[i]);
		}
	}
	transmitir(0x0A); // Quebra de linha (/n)
	transmitir(0x0d);	// Enter (/r)
	
	// Imprime o sentido (H - horário ou A - anti horário)
	for (int i = 0; i< sizeof(sentido_string); i++) {
		transmitir(sentido_string[i]);
	}
	if (sentido == H) {
		for (int i = 0; i< sizeof(horario_string); i++) {		// Imprimir sentido horario
			transmitir(horario_string[i]);
		}
	} else {
		for (int i = 0; i< sizeof(anti_hor_string); i++) {	// Imprimir sentido anti horario
			transmitir(anti_hor_string[i]);
		}
	}
	transmitir(0x0A); // Quebra de linha (/n)
	transmitir(0x0d);	// Enter (/r)
	
	// Imprime o número de voltas 
	for (int i = 0; i< sizeof(voltas_string); i++) {
		transmitir(voltas_string[i]);
	}
	transmitir(volta);
	transmitir(0x0A); // Quebra de linha (/n)
	transmitir(0x0d);	// Enter (/r)
}

void LED_Output(uint8_t sentido, uint16_t angulo){

	uint16_t led47 = GPIO_PORTA_AHB_DATA_R;
	uint16_t led03 = GPIO_PORTQ_DATA_R;

	if(sentido == H){
		if(angulo == 45){
			led47 = led47 | 0x80;
			led03 = led03 | 0x00;
		}
		else if(angulo == 90){
			led47 = led47 | 0xC0;
			led03 = led03 | 0x00;
		}
		else if(angulo == 135){
			led47 = led47 | 0xE0;
			led03 = led03 | 0x00;
		}
		else if(angulo == 180){
			led47 = led47 | 0xF0;
			led03 = led03 | 0x00;
		}
		else if(angulo == 225){
			led47 = led47 | 0xF0;
			led03 = led03 | 0x08;
		}
		else if(angulo == 270){
			led47 = led47 | 0xF0;
			led03 = led03 | 0x0C;
		}
		else if(angulo == 315){
			led47 = led47 | 0xF0;
			led03 = led03 | 0x0E;
		}
		else if(angulo == 360){
			led47 = led47 | 0xF0;
			led03 = led03 | 0x0F;
		}
	}
	else if(sentido == A){
		if(angulo == 45){
			led47 = led47 | 0x00;
			led03 = led03 | 0x01;
		}
		else if(angulo == 90){
			led47 = led47 | 0x00;
			led03 = led03 | 0x03;
		}
		else if(angulo == 135){
			led47 = led47 | 0x00;
			led03 = led03 | 0x07;
		}
		else if(angulo == 180){
			led47 = led47 | 0x00;
			led03 = led03 | 0x0F;
		}
		else if(angulo == 225){
			led47 = led47 | 0x10;
			led03 = led03 | 0x0F;
		}
		else if(angulo == 270){
			led47 = led47 | 0x30;
			led03 = led03 | 0x0F;
		}
		else if(angulo == 315){
			led47 = led47 | 0x70;
			led03 = led03 | 0x0F;
		}
		else if(angulo == 360){
			led47 = led47 | 0xF0;
			led03 = led03 | 0x0F;
		}
	}

	GPIO_PORTA_AHB_DATA_R = led47;
	GPIO_PORTQ_DATA_R = led03;
	Pisca_Transistor();

	return;

}


void Pisca_Transistor(void){
	PortP_Output(0x20);
	SysTick_Wait1ms(1);

	return;
}

// Espera ser digito * ao terminal o número de voltas passado, se for digitado *, volta para o começo do loop da main
void esperar_ast(void) {
	uint8_t ast = receber();
	transmitir(ast);
	while (ast != AST){
		ast = receber();
		transmitir(ast);
	}
	transmitir(0x0a);
	transmitir(0x0d);
}

void fim(void) {
	uint8_t f[]={0x46,0x69,0x6d,0x21,0x0a,0x0d}; // Guarda os hexadecimais de "Fim!/n/r" no vetor f
	for(int i=0; i<6; i++)
			transmitir(f[i]); // imprime "Fim!/n/r" no terminal
}

