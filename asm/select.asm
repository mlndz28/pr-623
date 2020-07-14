	loc
MODO_SELECT:	
			ldx #MSGMS_U
			ldy #MSGMS1_D
			jsr Cargar_LCD
			movb #$BB,BIN1
			movb #$BB,BIN2
			movb #$02,LEDS
			tst VELOC
			bne return`
			jsr PANT_CTRL
			
return`:	rts
			
	loc
PANT_CTRL:
			bclr PIEH,$0F
			; to do
			rts
