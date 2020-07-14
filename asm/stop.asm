;******************************************************************
;* MODO_STOP - standby mode. Load the respective message on the  
;* screen for this mode and turn off the 7 segment display.
;*
;* Calling convention:
;* jsr MODO_STOP
;*
;* Calls: Cargar_LCD
;* Changes: X, Y, BIN1, BIN2
;******************************************************************
MODO_STOP:
		ldx #MSGS_U
		ldy #MSGS_D
		jsr Cargar_LCD
		movb #$BB,BIN1
		movb #$BB,BIN2
		movb #$04,LEDS
		rts