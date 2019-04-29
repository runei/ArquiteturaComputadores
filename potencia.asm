.model small

.stack 100h

.data

	CR EQU 13
	LF EQU 10

.code

	POTENCIA PROC ; X^n - X = AL, n = AH
		PUSH DX
		PUSH CX
		
		XOR DX, DX
		XOR CX, CX
		
		MOV CL, AH
		MOV DL, AL
		XOR AX, AX
		MOV AL, 1H
		
		CMP CX, 0H
		JZ FIMPOTENCIA
		
		CALCULAPOTENCIA:
			MUL DL
			LOOP CALCULAPOTENCIA	
		
		FIMPOTENCIA:
			POP CX
			POP DX
			RET
	ENDP

	INICIO:
		MOV AX, @DATA
		MOV DS, AX
		
		CALL LER_UINT16 ; le X
		
		MOV BL, AL
		
		CALL LER_UINT16 ; n
		
		MOV AH, AL
		MOV AL, BL
		
		CALL POTENCIA
		
		CALL ESC_UINT32
		
		MOV AH, 04CH
		INT 21H


	ESC_UINT32 PROC 
		PUSH AX
		PUSH DX
		
		MOV DX, AX
		CMP DH, 0H
		JZ PRINTULTBITS
		
		MOV AL, DH
		CALL ESC_UINT16
		
		PRINTULTBITS:
			MOV AL, DL
			CALL ESC_UINT16
		
		POP DX
		POP AX
		RET
	ENDP
		
;=================================================================================================================

	ESC_UINT16 PROC
			PUSH AX
			PUSH CX ; Contador
			PUSH BX
			PUSH DX

			XOR CX, CX ; Zerar variavel															;		 ---
			MOV BX, 10 ; Divisor																;		|'2'|
	LACO:	XOR DX, DX ; Zerar parte alta da divisao DX:AX										;		| 0 |
																								;	SP	|'5'|
			DIV BX ; 16 bits																	;		| 0 |
				   ; DIV BX -> AX = [DX AX] / BX ; "DX = [DX AX] % BX" DX recebe resto			;		|'6'|
				   ; 8 bits																		;		| 0	|
				   ; DIV BL -> AH = AX / BL ; "AH = AX % BL" recebe resto						;		 ---

			ADD DL, '0' ; '0' é 8 bits, tem que adicionar com um registrador de 8 bits
			PUSH DX
			INC CX
			OR AX, AX
			JNZ LACO
	ESCREVE:POP DX
			CALL ESC_CHAR		;LOOP ESCREVE = DEC CX
			LOOP ESCREVE		;				JNZ ESCREVE

			POP DX
			POP CX
			POP BX
			POP AX
			RET
	ENDP
	
	LER_UINT16 PROC
		
		PUSH BX
		PUSH CX
		PUSH DX
		
		XOR CX, CX
		MOV BX, 10
		XOR AX, AX
	PROXCHAR:
		PUSH AX ; SALVAR AX
	SOLEITURA:
		CALL LER_CHAR
		CMP AL, CR
		JZ FIM
		CMP AL, '0'
		JB SOLEITURA
		CMP AL, '9'
		JA SOLEITURA
		
		MOV DL, AL		;	Escreve na 
		CALL ESC_CHAR	;	tela
		
		SUB AL, '0'		; 	transforma em num
		MOV CL, AL
		POP AX
		PUSH AX			;	se der overflow 
		MUL BX
		JO FIM
		ADD AX, CX
		JO FIM
		POP CX			; 	pop pra tirar lixo da pilha
		JMP PROXCHAR
	
	FIM:
		CALL NOVALINHA
		POP AX
		POP DX
		POP CX
		POP BX	
	
		RET
	ENDP
	
	ESC_CHAR PROC ; DL = caracter de entrada
			
		PUSH AX
		MOV AH, 02
		INT 21H
		POP AX
		RET				; small, ip
	ENDP
	
	NOVALINHA PROC
		
		PUSH DX
		
		MOV DL, CR
		CALL ESC_CHAR

		MOV DL, LF
		CALL ESC_CHAR
		
		POP DX
		
		RET
	ENDP

	LER_CHAR PROC
	
		MOV AH, 07
		INT 21H
	
		RET
	ENDP
	
end INICIO