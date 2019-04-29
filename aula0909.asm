.model small

.stack 100H

.data

	CR EQU 13
	LF EQU 10
	VETOR DW 5 DUP (0)

.code

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
	
	NOVALINHA PROC
		
		PUSH DX
		
		MOV DL, CR
		CALL ESC_CHAR

		MOV DL, LF
		CALL ESC_CHAR
		
		MOV DL, '*'
		CALL ESC_CHAR
		
		MOV DL, '/'
		CALL ESC_CHAR

		MOV DL, '*'
		CALL ESC_CHAR

		MOV DL, CR
		CALL ESC_CHAR

		MOV DL, LF
		CALL ESC_CHAR

		POP DX
		
		RET
	ENDP

	ESC_CHAR PROC ; DL = caracter de entrada
			
		PUSH AX
		MOV AH, 02
		INT 21H
		POP AX
		RET				; small, ip
	ENDP				; large, ip e code segment

	LER_CHAR PROC
	
		MOV AH, 07
		INT 21H
	
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
		
	ESCREVEEMVETOR PROC 
			MOV CX, 5
			MOV SI, OFFSET VETOR
			
		INILEITURA:
				CALL LER_UINT16
				MOV [SI], AX
				ADD SI, 2 ;2 É O TAMANHO OCUPADO NA MEMORIA
			LOOP INILEITURA

			MOV CX, 5
			MOV SI, OFFSET VETOR
			
		INIESCREVE:
				CALL ESC_UINT16
				MOV [SI], AX
				ADD SI, 2
			LOOP INIESCREVE
			RET
	ENDP
		
	INTERRUPCAO6FH PROC
		STI ;ATIVA INTERRUPCAO
		MOV DL, 'A'
		CALL ESC_CHAR
		IRET
	ENDP
	
	CHAMAINTERRUP6FH PROC
		MOV DX, OFFSET INTERRUPCAO6FH
		MOV AX, @CODE
		PUSH DS
		MOV DS, AX
		MOV AH, 25H
		MOV AL, 6FH ; INT
		INT 21H
		POP DS
		
		RET
	ENDP
	
	INICIO:
		MOV AX, @DATA
		MOV DS, AX
		
		CALL CHAMAINTERRUP6FH
		
		INT 6FH
		
		MOV AH, 04CH
		INT 21H
end INICIO