;=====================================================================
;			HAMMING PARITY ENCODER
;	DESCRIPTION:
;	ENCODES 7-BIT INPUT TO 11-BIT HAMMING PARITY VALUE
;	
;=====================================================================

	DOSSEG
	.MODEL  LARGE,BASIC

							;PROCEDURES TO
	EXTRN	CLEAR:FAR		;CLEAR SCREEN
	EXTRN	GETDEC$:FAR		;GET 16-BIT DECIMAL INTEGER
	EXTRN	NEWLINE:FAR		;DISPLAY NEWLINE CHARACTER
	EXTRN	PUTBIN:FAR
	EXTRN	PUTOCT:FAR
	EXTRN	PUTSTRNG:FAR	;DISPLAY CHARACTER STRING
	EXTRN	PAUSE:FAR		;DISPLAY CHARACTER STRING
	EXTRN	PARITY:FAR
	EXTRN	EVENODD:FAR
;===================================================================
;
; S T A C K   S E G M E N T   D E F I N I T I O N
;
	.STACK  256

;===================================================================
;
; C O N S T A N T   S E G M E N T   D E F I N I T I O N
;
.CODE
.DATA
HEADER		DB	'INPUT NUMBER TO ENCODE: '
REP_B		DB	'BINARY: '
REP_Q		DB	'OCTAL:            '
B			DB	'B'
Q			DB	'Q'
REP_O		DB	'-- ORIGINAL VALUES --'
REP_E		DB	'-- ENCODED  VALUES --'
;REP_BUG		DB	'            tttttppdpdddpddd'
OVERBIT		DB	'ERROR - VALUE IS GREATER THAN 7 BITS.'
;DEBUG		DB	'EXECUTED PAST THIS LINE'	;23 CHARS
PAUMSG		DB	'PRESS ANY KEY TO CONTINUE ... '
NAME_IR		DB	' ENCODE PROGRAM BY IAN ROSNER '
;===============================================================
;
; D A T A   S E G M E N T   D E F I N I T I O N
;
ENCVAL		DW	0B
;===============================================================
;
; C O D E   S E G M E N T   D E F I N I T I O N
;
	.CODE
	;ASSUME DS:NOTHING,ES:DGROUP
STARTUP:
	MOV		AX,DGROUP		;SET ES TO POINT TO DATA SEG
	MOV		ES,AX
	MOV		DS,AX
	
	LEA		DI,HEADER
	MOV		CX,24
	CALL	PUTSTRNG

	MOV		AX,0
	CALL	GETDEC$		;GET USER INPUT
	
CHECK_VALID:
	;IS INPUT # MORE THAN 7 BITS?
	PUSH	AX	
	MOV		CL,7
	SHR		AX,CL
	AND		AX,1111H
	.IF		AX > 0
		CALL	NEWLINE
		LEA		DI,OVERBIT
		MOV		CX,37
		CALL	PUTSTRNG
		CALL	NEWLINE
		JMP		STARTUP
	.ENDIF
	POP		AX
REP_BEGIN:
	;ORIGINAL VALUE REPORTING BLOCK
	MOV		BL,1	;USE 16 BIT FOR PUTBIN/OCT
	CALL	NEWLINE
	LEA		DI,REP_O
	MOV		CX,21
	CALL	PUTSTRNG
	CALL	NEWLINE
	LEA		DI,REP_B
	MOV		CX,8
	CALL	PUTSTRNG
	LEA		DI,B
	MOV		CX,1
	CALL	PUTBIN
	CALL	PUTSTRNG
	CALL	NEWLINE
	LEA		DI,REP_Q
	MOV		CX,18
	CALL	PUTSTRNG
	LEA		DI,Q
	MOV		CX,1
	CALL	PUTOCT
	CALL	PUTSTRNG
	CALL	NEWLINE
	
EXPAND:
	;SET 7-BIT VALUE TO 11-BIT SPACING
	;FIRST 3 DATA BITS DO NOT NEED ADJUSTMENT
	;NEXT BIT IS PARITY - SHIFT DATA
	;NEXT 3 BITS GOOD
	;SHIFT LAST BIT OVER
	MOV		ENCVAL,0
	PUSH	AX
	AND		AX,111B
	OR		ENCVAL,AX
	POP		AX
	
	PUSH	AX
	MOV		CL,3 ;3
	SHR		AX,CL
	AND		AX,111B
	INC		CL
	ROR		ENCVAL,CL ;4
	OR		ENCVAL,AX
	POP		AX
	
	PUSH	AX
	MOV		CL,6
	SHR		AX,CL ;6
	AND		AX,1B
	MOV		CL,4
	ROR		ENCVAL,CL ;4
	OR		ENCVAL,AX
	POP		AX
	MOV		CL,8
	ROR		ENCVAL,CL ;8

SETPARBITS:
	;SETS PARITY BITS FOR 11-BIT HAMMING VALUE
	;BIT 1 - 1 3 5 7 9 11
	;BIT 2 - 2 3 6 7 10 11
	;BIT 4 - 4 5 6 7
	;BIT 8 - 8 9 10 11	
	;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
	;BIT 1
	MOV		AX,ENCVAL
	AND		AX,10101010101B
	CALL	PARITY
	CALL	EVENODD
	MOV		CL,6
	ROL		ENCVAL,CL	;SET 1ST BIT AS ACTIVE BIT
	OR		ENCVAL,BX	;SET BIT
	ROR		ENCVAL,CL	;ROTATE BACK
	
	;BIT 2
	MOV		AX,ENCVAL
	AND		AX,01100110011B
	CALL	PARITY
	CALL	EVENODD
	MOV		CL,7
	ROL		ENCVAL,CL	;2ND BIT ACTIVE
	OR		ENCVAL,BX
	ROR		ENCVAL,CL	;ROLL BACK
	
	;BIT 4
	MOV		AX,ENCVAL
	AND		AX,11110000B
	CALL	PARITY
	CALL	EVENODD
	MOV		CL,9
	ROL		ENCVAL,CL
	OR		ENCVAL,BX
	ROR		ENCVAL,CL
	
	;BIT 8
	MOV		AX,ENCVAL
	AND		AX,1111B
	CALL	PARITY
	MOV		AX,CX
	CALL	EVENODD
	MOV		CL,13
	ROL		ENCVAL,CL
	OR		ENCVAL,BX
	ROR		ENCVAL,CL
	
RESULT:
	MOV		AX,ENCVAL
	MOV		BL,1	;USE 16 BIT FOR PUTBIN/OCT
	CALL	NEWLINE
	LEA		DI,REP_E
	MOV		CX,21
	CALL	PUTSTRNG
	CALL	NEWLINE
	LEA		DI,REP_B
	MOV		CX,8
	CALL	PUTSTRNG	
	LEA		DI,B
	MOV		CX,1
	CALL	PUTBIN
	CALL	PUTSTRNG
	CALL	NEWLINE
	LEA		DI,REP_Q
	MOV		CX,18
	CALL	PUTSTRNG
	LEA		DI,Q
	MOV		CX,1
	CALL	PUTOCT
	CALL	PUTSTRNG
	CALL	NEWLINE
	
DONE:
	CALL	NEWLINE
	CALL	NEWLINE
	LEA		DI,NAME_IR
	MOV		CX,30
	CALL	PUTSTRNG
	CALL	NEWLINE
	LEA		DI,PAUMSG
	CALL PAUSE

	.EXIT
END STARTUP