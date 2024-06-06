// lcd.c

#include <stdint.h>
#include <string.h>

// Declarations
void SysTick_Wait1ms(uint32_t delay);
uint32_t PortL_Input (void);
void PortK_Output (uint32_t data);
void PortM_Output (uint32_t data);

void LCD_Instruction (uint32_t inst);

// Fun??o LCD_Init
// Inicializa o LCD
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: N?o tem
void LCD_Init (void)
{
	LCD_Instruction(0x38);	// Inicializar no modo 2 linhas/caracter matriz 5x7
	LCD_Instruction(0x06);	// Cursor com autoincremento para direita
	LCD_Instruction(0x0E);	// Configurar o cursor (habilitar o display + cursor + n?o-pisca)
	LCD_Instruction(0x01);	// Resetar: Limpar o display e levar o cursor para o home
}

// Escreve no barramento de dados no modo instrucao
// Par?metro de entrada: Instrucao a ser escrita
// Par?metro de sa?da: N?o tem
void LCD_Instruction (uint32_t inst)
{
	PortM_Output(0x04); 	// Ativa o modo de instru??o (EN=1, RW=0, RS=0)
	
	PortK_Output(inst);		// Instru??o
	SysTick_Wait1ms(10); 	// Delay de 10ms para executar
	
	PortM_Output(0x00);		// Desativa o modo de instru??o (EN=0, RW=0, RS=0)
}

// Fun??o LCD_Data
// Escreve no barramento de dados no modo de dados
// Par?metro de entrada: Dado a ser escrito
// Par?metro de sa?da: N?o tem
void LCD_Data (uint32_t data)
{
	PortM_Output(0x05); 	// Ativa o modo de dados (EN=1, RW=0, RS=1)
	
	PortK_Output(data);		// Dado
	SysTick_Wait1ms(10); 	// Delay de 10ms para executar
	
	PortM_Output(0x00);		// Desativa o modo de dados (EN=0, RW=0, RS=0)
}

// Fun??o LCD_Reset
// Limpa o display e leva o cursor para o home
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: N?o tem
void LCD_Reset (void)
{
	LCD_Instruction(0x01);	// Resetar: Limpar o display e levar o cursor para o home
}

// Fun??o LCD_Line2
// Coloca o cursor no endere?o da primeira posi??o - Segunda Linha
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: N?o tem
void LCD_Line2 (void)
{
	LCD_Instruction(0xC0);	// Endere?o da primeira posi??o - Segunda Linha
}

// Fun??o LCD_WriteString
// Imprime uma string no LCD atrav?s de um loop
// Par?metro de entrada: String a ser escrita
// Par?metro de sa?da: N?o tem
void LCD_WriteString (char* str)
{
	for (int i = 0; i < strlen(str); i++)
	{
		LCD_Data(str[i]);
	}
}