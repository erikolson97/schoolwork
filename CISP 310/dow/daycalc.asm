;==============================
;	parity finder
;
;	returns # of 1 bits
;		in a value
;	    input - AX
;	   output - CX
;==============================
	.MODEL	SMALL,BASIC
;==============================
;DATA SEG
.FARDATA PARDATA
IN_MO DW	?
IN_DA DW	?
IN_YR DW	?
MLENG DW	31,28,31,30,31,30,31,31,30,31,30,31
LEAPF DB	0
;==============================
	.CODE	PAR
	ASSUME	DS:PARDATA
VALIDATE	PROC	FAR PUBLIC USES DS BX CX, MO:WORD, DA:WORD, YR:WORD
	PUSHF
	MOV		AX,SEG PARDATA		;SET ES TO POINT TO DATA SEG
	MOV		DS,AX
	
	;YEAR CHECK
	.IF		YR < 1901 || YR > 2099
		MOV		AX,-1
		JMP		BAD
	.ENDIF
	;ELSE SAVE
	MOV		AX,YR
	MOV		IN_YR,AX
	
	;LEAP YEAR BLOCK
	;IF DIVISIBLE BY 4
	;UNLESS DIVISIBLE BY 100
	;EXCEPT IF DIV. BY 400
	;2000 IS THE ONLY YEAR
	;WHICH RAISES THIS ISSUE
	;(WITHIN OUR RANGE)
	SUB		DX,DX
	MOV		CX,4
	MOV		AX,YR
	DIV		CX
	.IF		YR == 2000
		MOV		LEAPF,0
	.ELSEIF DX == 0	;IF YR%4 == 0
		MOV		LEAPF,1
	.ENDIF
	;END LEAP YEAR BLOCK
	
	;MONTH CHECK
	.IF		MO < 1 || MO > 12
		MOV		AX,-2
		JMP		BAD
	.ENDIF
	;ELSE VALID INPUT
	MOV		AX,MO
	MOV		IN_MO,AX
	
	;DAY CHECK
	MOV		DI,MO
	DEC		DI
	MOV		BX,[MLENG+DI]
	
	.IF		MO == 2 && DA == 29
		.IF LEAPF == 1
			JMP LEAPLEAP
		.ELSE
			MOV AX,-29
			JMP BAD
		.ENDIF
	.ELSEIF	DA > BX || DA < 1
		MOV		AX,-3
		JMP		BAD
	.ENDIF
LEAPLEAP:
	MOV		AX,DA
	MOV		IN_DA,AX
	
	MOV		AX,35	;SUCCESS CODE
BAD:
	POPF
	RET
VALIDATE	ENDP

CALCOFF	PROC	FAR PUBLIC USES BX CX DS
	PUSHF
	MOV		AX,SEG PARDATA		;SET ES TO POINT TO DATA SEG
	MOV		DS,AX
	
	MOV		AX,IN_YR
	SUB		AX,1901
	MOV		BX,AX
	
	MOV		CL,4	
	DIV		CL		;GET LEAP YEARS
	;QUOTIENT IN AL
	MOV		AH,0
	
	ADD		AX,BX
	.IF		LEAPF == 1 && IN_MO > 2 ;ADD 1 IF LEAP YEAR
		INC AX						;AND PAST FEB
	.ENDIF
	
	
	MOV		CL,7
	DIV		CL	;MODULO 7	
	;REMAINDER IN AH
	
	MOV		AL,AH
	MOV		AH,0

	POPF
	RET
CALCOFF	ENDP
END