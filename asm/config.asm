	loc
;******************************************************************
;* MODO_CONFIG - standby mode. Load the respective message on the  
;* screen for this mode and turn off the two upper 7 segment
;* display segments. The other two display the parameter to be 
;* configured (LengthOK). The parameter is configured with the 
;* button array and won't change until the value is validated.
;*
;* Calling convention:
;* jsr MODO_CONFIG
;*
;* Calls: Cargar_LCD, TAREA_TECLADO, BCD_BIN
;* Changes: X, Y, BIN1, BIN2, TICK_EN, TICK_DIS, Banderas
;******************************************************************
MODO_CONFIG:
			bclr Banderas+1,$04
			movw #0,TICK_EN
			movw #0,TICK_DIS
			ldx #MSGMC_U
			ldy #MSGMC_D
			jsr Cargar_LCD
			movb LengthOK,BIN1
			movb #$BB,BIN2
			movb #$01,LEDS
			jsr TAREA_TECLADO
			brclr Banderas+1,$04,return`	; if(!ARRAY_OK){ return }
			jsr BCD_BIN
			ldaa ValorLength
			cmpa #70
			bls return`
			cmpa #100
			bhs return`
			movb ValorLength,LengthOK		
			bra return`
return`:	clr ValorLength
			; reset keypad data structures
			rts