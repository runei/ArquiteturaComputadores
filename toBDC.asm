.model small

.stack 100H

.data
	
.code

	include "stdio.asm"

	TOBCD PROC
		PUSH BX
		
		MOV BL, 10
		DIV BL
		
		MOV BX, AX
		MOV AL, BH
		MOV AH, BL		
		       
		POP BX
		RET
	ENDP

	INICIO:
		MOV AX, @DATA
		MOV DS, AX
		
		CALL LER_UINT16
		
		CALL TOBCD
		
		CALL ESC_UINT16
		
		MOV AL, AH
		
		CALL ESC_UINT16
		
		MOV AH, 04CH
		INT 21H
             
end INICIO