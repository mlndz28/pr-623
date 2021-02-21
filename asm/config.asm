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

			brset POSITION,$02,skip_load`
			movb #$02,POSITION
			movb #$02,LEDS
			ldx #MSGMC_U
			ldy #MSGMC_D
			jsr Cargar_LCD
			movb NumVueltas,BIN1
			movb #$BB,BIN2


skip_load`:	bclr Banderas,$04 ; ARRAY_OK = 0
			movw #0,TICK_EN
			movw #0,TICK_DIS
			jsr TAREA_TECLADO
			brclr Banderas,$04,return`	; if(!ARRAY_OK){ return }
			; swi
			jsr BCD_BIN
			ldaa ValorVueltas
			cmpa #5
			blo return`
			cmpa #25
			bhi return`
			movb ValorVueltas,NumVueltas		
			movb NumVueltas,BIN1
			bra return`
return`:	clr ValorVueltas
			; reset keypad data structures
			rts