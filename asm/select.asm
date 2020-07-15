	loc
;******************************************************************
;* MODO_SELECT - selector mode. Once the pipe goes through both  
;* sensors, a speed and a length can be specified. When this is 
;* calculated (by port H interrupts), PANT_CTRL is called.
;* 
;* Calling convention:
;* jsr MODO_SELECT
;*
;* Calls: Cargar_LCD, PANT_CTRL
;* Changes: X, Y, D, BIN1, BIN2, TICK_EN, TICK_DIS, Banderas, PIEH.
;******************************************************************
MODO_SELECT:	
			tst VELOC
			beq init`
			tst LONG
			bne ctrl`
init`:		ldx #MSGMS_U
			brset Banderas,$01,s1`
			ldy #MSGMS1_D
			bra skip`
s1`:		ldy #MSGMS2_D
skip`:		jsr Cargar_LCD
			movb #$BB,BIN1
			movb #$BB,BIN2
			movb #$02,LEDS
			bra return`
ctrl`:		jsr PANT_CTRL
			
return`:	rts
			
	loc

;******************************************************************
;* PANT_CTRL - logic for the information displayed on both screens
;* and enabling of the relay (for the spray paint gun).
;* 
;* Calling convention:
;* jsr PANT_CTRL
;*
;* Calls: Cargar_LCD
;* Changes: X, Y, D, BIN1, BIN2, TICK_EN, TICK_DIS, Banderas, PIEH.
;******************************************************************
PANT_CTRL:
			bclr PIEH,$09		; disable port H interrupts
			ldaa VELOC
			cmpa #10
			blo v_range
			cmpa #50
			bhi v_range

			brclr Banderas+1,$20,t_spray
			brset Banderas+1,$08,init_l`
			ldaa BIN1
			cmpa #$BB
			lbne return`
			movb LONG,BIN1
			movb VELOC,BIN2
			ldaa LONG
			cmpa LengthOK
			blo less`
			ldx #MSGMSV_U
			ldy #MSGMSV_D
			bset PORTE,$04		; activate spray
			movb #200,CONT_ROC
			bra load`
less`:		ldx #MSGMSNV_U
			ldy #MSGMSNV_D
load`:		jsr Cargar_LCD
			bra return`


init_l`:	ldaa BIN1
			cmpa #$BB
			beq return`
			bra reset`

v_range:	ldaa BIN1
			cmpa #$AA
			bne error`
			brclr Banderas+1,$08,reset`
			bra return`
			
error`:		movb #$AA,BIN1
			movb #$AA,BIN2			
			movw #0,TICK_EN
			movw #2000,TICK_DIS
			bset Banderas+1,$08
			ldx #MSGMSA_U
			ldy #MSGMSA_D
			jsr Cargar_LCD
			bra return`
			
t_spray:	clra
			ldab VELOC
			tfr D,X
			ldab LONG		
			lsrb
			ldaa #250
			sba
			tab
			clra
			idiv
			tfr X,D
			ldy #1000
			emul
			std TICK_EN
			
			clra
			ldab VELOC
			tfr D,X
			ldd #250
			idiv
			tfr X,D 
			ldy #1000
			emul
			std TICK_DIS
			
			bset BANDERAS+1,$20		; CALC_TICKS = true
			bra return`


reset`:		bclr Banderas+1,$20	;	CALC_TICKS = false

			clr VELOC
			clr LONG
			bra return`

return`:	rts
