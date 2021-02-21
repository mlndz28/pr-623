	loc
;******************************************************************
;* MODO_RESUMEN - standby mode. Load the respective message on the  
;* screen for this mode and turn off the 7 segment display.
;*
;* Calling convention:
;* jsr MODO_RESUMEN
;*
;* Calls: Cargar_LCD
;* Changes: X, Y, BIN1, BIN2, POSITION
;******************************************************************
MODO_RESUMEN:
		brset POSITION,$08,skip_load`
		movb #$08,POSITION	
		movb #$08,LEDS
		ldx #MSGR_U
		ldy #MSGR_D
		jsr Cargar_LCD
		movb Veloc,BIN1
		movb Vueltas,BIN2

skip_load`:
		rts