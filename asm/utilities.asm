;******************************************************************
;* Utility subroutines
;******************************************************************

;******************************************************************
;* DELAY - wait until Cont_Delay turns zero. Cont_Delay is  
;* decremented by a timer interruption every 20 us.
;*
;* Calling convention:
;*   movb <20us multiplier>,Cont_Delay
;*   jsr DELAY
;******************************************************************
DELAY:	
		tst Cont_Delay
		bne DELAY
		rts

	loc
;******************************************************************
;* BIN_BCD - converts an unsigned number (99 or less) into its BCD
;* notation.
;*
;* Calling convention:
;* ldaa <number>
;* jsr BIN_BCD
;* 
;* Arguments:
;*   A: unsigned number
;*
;* Returns: BCD number in BCD_L
;* Changes: X, Y, BCD_L.
;******************************************************************

BIN_BCD:	
			pshd
			ldx #8
			ldy #BCD_L
			movb #0,BCD_L
loop`:		lsla
			rol BCD_L
			dbeq X,return`
			psha
			ldy #BCD_L
			ldab #$03
			ldaa #$0F
			anda 0,Y
			cmpa #$05
			blt skipL`
			addb 0,Y
			stab 0,Y
skipL`:		ldab #$30
			ldaa #$F0
			anda 0,Y
			cmpa #$50
			blt skipR`
			addb 0,Y
			stab 0,Y
skipR`:		pula
			bra loop`
return`: 	puld
			rts			 

	loc
;******************************************************************
;* CONV_BIN_BCD - converts two unsigned numbers (99 or less each) 
;* into their BCD notation.
;*
;* Calling convention:
;* movb <unsigned number>,BIN1
;* movb <unsigned number>,BIN2
;* jsr CONV_BIN_BCD
;* 
;* Arguments:
;*   BIN1: unsigned number
;*   BIN2: unsigned number
;*
;* Returns:
;*   BCD1: BIN1 converted to BCD
;*   BCD2: BIN2 converted to BCD
;*
;* Calls: BIN_BCD
;* Changes: X, Y, BCD1, BCD2, BCD_L.
;******************************************************************
CONV_BIN_BCD:
			ldaa BIN1
			cmpa #100
			blo dec_r
			staa BCD1
			bra skip`
dec_r:		jsr BIN_BCD
			movb BCD_L,BCD1
skip`:		ldaa BIN2
			cmpa #100
			blo dec_l
			staa BCD2
			bra return`
dec_l:		jsr BIN_BCD
			movb BCD_L,BCD2
return`:	rts

;******************************************************************
;* BCD_7SEG - loads into DISP[1-4] the segments that should be on
;* by associating 4 BCD numbers with the contents of SEGMENT.
;*
;* Calling convention:
;* movb <BCD number>,BCD1
;* movb <BCD number>,BCD2
;* jsr BCD_7SEG
;* 
;* Arguments:
;*   BCD1: BCD number
;*   BCD2: BCD number
;*
;* Returns:
;*   DISP[1-4]: segments of the 7 segments display that will be on
;*
;* Changes: X, Y, BCD1, BCD2, BCD_L.
;******************************************************************
BCD_7SEG:
		ldx #SEGMENT
		ldaa BCD1
		anda #$0F
		movb A,X,DISP4
		ldaa BCD1
		lsra
		lsra
		lsra
		lsra
		movb A,X,DISP3
		ldaa BCD2
		anda #$0F
		movb A,X,DISP2
		ldaa BCD2
		lsra
		lsra
		lsra
		lsra
		movb A,X,DISP1
		rts

;******************************************************************
;* BIN_BCD - converts two bcd digits (in a byte each) into 
;* a number.

;* Calling convention:
;* movb <First digit [0-9]>,Num_Array
;* movb <Second digit [0-9]>,Num_Array+1
;* jsr BCD_7SEG
;* 
;* Arguments:
;*   Num_Array: Upper BCD digit
;*   Num_Array+1: Lower BCD digit
;*
;* Returns:
;*   ValorLength: converted number
;*
;* Changes: D, ValorLength.
;******************************************************************
BCD_BIN:			
		ldd Num_Array
		pshb
		ldab #10
		mul
		addb 1,SP+
		stab ValorVueltas
		rts 