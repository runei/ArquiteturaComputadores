.model small

.stack 100H

.data
	
	NUM EQU 5H
	
.code

	include "stdio.asm"

	FATPILHA PROC
		PUSH CX
		
		MOV CX, [SI - 1]
		MOV CX, BX
		MOV AX, 1
		
		MULTP:
			MUL CX
			LOOP MULTP		
		
		MOV [BP + 4], AX
		
		POP CX			
		
		
		RET
	ENDP
	
	FATAX PROC
		PUSH CX
		
		MOV CX, [BP + 4]
		MOV CX, BX
		MOV AX, 1
		
		MULTAX:
			MUL CX
			LOOP MULTAX		
			
		POP CX
				
			
		RET
	ENDP
	
	INICIO:
		MOV AX, @DATA
		MOV DS, AX

		MOV BX, NUM
		PUSH BX 
		
		;CALL FATAX
		;CALL ESC_UINT16
		
		MOV AX, 0
		PUSH AX
		
		CALL FATPILHA
		POP AX
		CALL ESC_UINT16
		
		MOV AH, 04CH
		INT 21H
		
             
end INICIO