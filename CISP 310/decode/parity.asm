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
PARCT	DW	0
LOOPCT	DW	?
;==============================
	.CODE	PAR
	ASSUME	DS:PARDATA
PARITY	PROC	FAR PUBLIC USES AX DS
	PUSHF
	PUSH	AX	
	MOV		AX,SEG PARDATA		;SET ES TO POINT TO DATA SEG
	MOV		DS,AX
	POP		AX
	MOV	PARCT,0		;RESET PARCT
	MOV	LOOPCT,16	;INITIALIZE COUNTER - AX == 16 BIT REG
PAR_LOOP:
	SHR		AX,1	;SHIFT RIGHTMOST INTO CARRY
	JNC		SKIP
	INC		PARCT	;IF CARRY SET, INC PARITY CT
SKIP:
	DEC		LOOPCT
	CMP		LOOPCT,0
	JNE		PAR_LOOP
FINISH:
	MOV		CX,PARCT	;PARCT RETURNED IN CX
	
	POPF
	RET
PARITY	ENDP

EVENODD		PROC	FAR PUBLIC USES DS
	PUSHF			;PUSH FLAGS
	;RETURNS IF VALUE IS EVEN OR ODD
	;EVEN - 0 | ODD - 1
	;IN CX, OUT BX
	AND		CX,1
	MOV		BX,CX
	POPF	;RECALL FLAGS
	RET
EVENODD		ENDP


DECODE		PROC	FAR PUBLIC USES BX CX
	PUSHF
	;TAKES IN 11-BIT [PRE-CORRECTED] PACKET
	;RETURNS DECODED 7-BIT VALUE
	;IN AX, OUT AX
	;[5 LEADING 0S] P P D P D D D P D D  D
	;               1 2 3 4 5 6 7 8 9 10 11
	MOV		CL,8
	ROR		AX,CL		;SHIFT BIT 3 INTO PLACE
	
	MOV		BX,0
	
	PUSH	AX
	AND		AX,1B		;MASK
	OR		BX,AX		;PLACE VALUE
	MOV		CL,3
	SHL		BX,CL		;MAKE ROOM FOR NEXT VALUES
	POP		AX
	
	MOV		CL,4
	ROL		AX,CL		;LOAD IN NEXT 3 DATA BITS [5 6 7]
	
	PUSH	AX
	AND		AX,111B
	OR		BX,AX
	MOV		CL,3
	SHL		BX,CL
	POP		AX
	
	MOV		CL,4
	ROL		AX,CL		;LOAD LAST 3 DATA BITS [9 10 11]
	AND		AX,111B
	OR		BX,AX
	
	MOV		AX,BX		;RETURN IN AX
	POPF
	RET
DECODE		ENDP
END