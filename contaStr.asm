.model small

.stack 100H

.data
	
	string db 256 dup(0)
	cont db 256 dup (0)
	
.code

	include "stdio.asm"

	

	INICIO:
		MOV AX, @DATA
		MOV DS, AX
		
		CALL ESC_CHAR
		
		
             
end INICIO