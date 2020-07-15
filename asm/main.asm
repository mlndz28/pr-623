;******************************************************************
;* Main routine
;******************************************************************

			org $2000
			lds #STACK
			jsr HW_INIT
			jsr INIT
	loc
loop_c`:	
			jsr MODO_CONFIG
			tst LengthOK
			beq loop_c`
loop_m`:	brset PTH,$40,select`
			clr VELOC
			clr LONG
			bclr PIEH,$09			; disable port H and timer counter interrupts 
			bclr TIE,$20
			brset PTH,$80,config`
stop`:		jsr MODO_STOP
			bra loop_m`
select`:	
			bset PIEH,$09
			bset TIE,$20
			jsr MODO_SELECT
			bra loop_m`
config`:	jsr MODO_CONFIG
			bra loop_m`