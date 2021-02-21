	loc
;******************************************************************
;* MODO_LIBRE - standby mode. Load the respective message on the  
;* screen for this mode and turn off the 7 segment display.
;*
;* Calling convention:
;* jsr MODO_LIBRE
;*
;* Calls: Cargar_LCD
;* Changes: X, Y, BIN1, BIN2, POSITION
;******************************************************************
MODO_LIBRE:
		brset POSITION,$01,return`
		movb #$01,POSITION	
		movb #$01,LEDS
		ldx #MSGRM
		ldy #MSGML
		jsr Cargar_LCD
		movb #$BB,BIN1
		movb #$BB,BIN2
return`:
		rts