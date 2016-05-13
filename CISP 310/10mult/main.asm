;=====================================================================
;			10 DIGIT MULTIPLIER
;	DESCRIPTION:
;	MULTIPLIES TWO 10 DIGIT NUMBERS
;=====================================================================

	DOSSEG
	.MODEL  LARGE,BASIC
							;PROCEDURES TO
	EXTRN	NEWLINE:FAR		;DISPLAY NEWLINE CHARACTER
	EXTRN	PUTDEC$:FAR		;DISPLAY 16-BIT DECIMAL INTEGER
	EXTRN	PUTSTRNG:FAR	;DISPLAY CHARACTER STRING
	EXTRN	PAUSE:FAR		;DISPLAY CHARACTER STRING
	EXTRN	CLEAR:FAR
	
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
HEADER		DB	'--10 DIGIT MULT--';17, 3
SYMBOLS		DB	' * ',' = ';3, +3
;DEBUG		DB	'EXECUTED PAST THIS LINE'	;23 CHARS
PAUMSG		DB	'PRESS ANY KEY TO CONTINUE ... '
NAME_IR		DB	'PROGRAM BY IAN ROSNER';21
;===============================================================
;
; D A T A   S E G M E N T   D E F I N I T I O N
;
NUM1			DB	1,2,3,4,5,6,7,8,9,9
NUM2			DB	9,9,8,7,6,5,4,3,2,1
PROD			DB	20 DUP(0)
;COUNTERS
PLACE			DW	0	;WHERE WE PUT ELEMENTS IN THE ARRAY
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
		MOV		CX,17
		CALL	PUTSTRNG
		CALL	NEWLINE
		
	MOV		AX,0
	;WHAT ARE WE MULTIPLYING?
	MOV		DI,-1
	PRINTN1:
		INC		DI
		MOV		AL,NUM1[DI]
		CALL	PUTDEC$
		CMP		DI,9
		JL		PRINTN1
	;END PRINTN1
	;PRINT ASTERISK
	LEA		DI,SYMBOLS
	MOV		CX,3
	CALL	PUTSTRNG
	
	MOV		DI,-1
	PRINTN2:
		INC		DI
		MOV		AL,NUM2[DI]
		CALL	PUTDEC$
		CMP		DI,9
		JL		PRINTN2
	;END PRINTN2
	;PRINT EQUALS
	LEA		DI,SYMBOLS+3
	MOV		CX,3
	CALL	PUTSTRNG
	
MAIN:
	;DX STORES ITERATION OF OUTERLOOP
	;DI STORES ITERATION OF INNERLOOP
	;AX STORES VALUES FOR ARITHMETIC
	;CX STORES NUM2 MULTIPLY VALUE
	MOV		DX,9	;START AT LAST ELEMENT
	;BOTTOM DIGITS
	MOV		AH,0
	OUTERLOOP:
		MOV		DI,DX
		MOV		CL,NUM2[DI]
		MOV		DI,9		;DI IS COUNTER
		;TOP DIGITS
		INNERLOOP:
			;MULTIPLY TOP VALUE BY BOTTOM VALUE (CX)
			MOV		AL,NUM1[DI]
			MUL		CL				;MULTIPLY
			CALL	PLACEMENT		;PUTS AL VALUE IN CORRECT PLACE
			PUSH	DI
			;CHECK IF VALUES ARE OVERFLOWING
			MOV		DI,PLACE
			CARRYOUT:
				CMP		PROD[DI],9
				JLE		SKIPCARRY
				
				;CARRY OUT WHILE VALUE > 9
				SUB		PROD[DI],10
				INC		PROD[DI+1]
				JMP		CARRYOUT
			
			SKIPCARRY:
			POP		DI
			DEC		DI
			CMP		DI,0		;REPEAT 9 TIMES
			JGE		INNERLOOP
		;END INNER
		;PROCEED TO OUTER
			
		DEC		DX		;IF OUTER IS COMPLETE
		CMP		DX,0	;DROP DOWN
		JGE		OUTERLOOP
	;END OUTER

PRINTRESULT:
	;CHECK LEADING 0S
	MOV		DI,20
	ZCHECK:
		DEC		DI
		CMP		PROD[DI],0
		JE		ZCHECK
	;END ZCHECK
	;DI NOW CONTAINS 1ST NON-ZERO ELEMENT
	
	;FOR I = DI TO 0, PRINT
	PRINTLOOP:
		MOV		AL,PROD[DI]
		CALL	PUTDEC$
		DEC		DI
		CMP		DI,0
		JGE		PRINTLOOP
	;END PRINTLOOP

DONE:
	CALL	NEWLINE
	CALL	NEWLINE
	LEA		DI,NAME_IR
	MOV		CX,21
	CALL	PUTSTRNG
	CALL	NEWLINE
	LEA		DI,PAUMSG
	MOV		CX,30
	CALL 	PAUSE

	.EXIT

PLACEMENT		PROC		NEAR PUBLIC USES AX DX DI
	;PUTS VALUE IN AL IN CORRECT SPOT
	;DX CONTAINS OUTER, DI CONTAINS INNER
	;PLACE = 9 - OUTER + 9 - INNER
		PUSH	AX
		MOV		AX,18		;9 + 9
		SUB		AX,DI			;MINUS INNER
		MOV		DI,DX
		SUB		AX,DI			;MINUS OUTER
		;AX NOW CONTAINS PLACE
		MOV		DI,AX
		POP		AX
		ADD		PROD[DI],AL
		MOV		PLACE,DI	;SAVE THIS VALUE

	RET
PLACEMENT		ENDP
END STARTUP


