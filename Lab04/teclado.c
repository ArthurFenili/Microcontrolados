// matrix_keyboard.c

#include <stdint.h>

// Declarations
void PortM_Output (uint32_t data);
uint32_t PortL_Input (void);

// Fun??o MatrixKeyboard_Map
// Identifica qual tecla est? sendo pressionada no teclado matricial
// Par?metro de entrada: N?o tem
// Par?metro de sa?da: A tecla pressionada
uint32_t MatrixKeyboard_Map (void)
{
	uint32_t temp, line, col;
	
	// Mapeia as 4 colunas do teclado matricial
	for (int i = 0; i < 4; i++)
	{
		temp = 0x0F;						// 0x0F = 2_00001111
		
		if (i == 0)							// Primeira coluna
		{
			col = 0xE0;						// 0x0E = 2_11100000 
			PortM_Output(col);
		}
		
		if (i == 1)							// Segunda coluna
		{
			col = 0xD0;						// 0xD0 = 2_11010000
			PortM_Output(col);
		}
		
		if (i == 2)							// Terceira coluna
		{
			col = 0xB0;						// 0xB0 = 2_10110000
			PortM_Output(col);
		}
		
		if (i == 3)							// Quarta coluna
		{
			col = 0x70;						// 0xB0 = 2_01110000
			PortM_Output(col);
		}
		
		// Valor lido na linha
		line = PortL_Input();
		temp = temp & line;
		
		if (temp != 0x0F)				// Alguma tecla foi pressionada
		{
			col = col | temp;			// Realiza um OR para casar a coluna com a linha e encontrar a tecla
			return col;						// Retorna a tecla pressionada
		}
	}
	
	return 0xFF;							// Nenhuma tecla foi pressionada
}