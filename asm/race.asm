	loc
;******************************************************************
;* MODO_CARRERA - sensing mode. Once the bike goes through both  
;* sensors, a speed can be calculated. .
;* 
;* Calling convention:
;* jsr MODO_CARRERA
;*
;* Calls: Cargar_LCD, PANT_CTRL
;* Changes: X, Y, D, BIN1, BIN2, TICK_EN, TICK_DIS, Banderas, PIEH.
;******************************************************************
MODO_COMPETENCIA:
			brset POSITION,$04,skip_load`
			movb #$04,POSITION	
			movb #$04,LEDS
			movb #$BB,BIN1
			movb #$BB,BIN2	
			ldx #MSGRM
			ldy #MSGMS1_D
			jsr Cargar_LCD
skip_load`:	tst Veloc
			beq return`
ctrl`:		jsr PANT_CTRL
return`:	rts
			
	loc
;******************************************************************
;* PANT_CTRL - logic for the information displayed on both screens
;* and enabling of the relay (for the spray paint gun). The time 
;* counters are calculated by the measures of both sensors,
;* and it goes as follows:
;*   TICK_EN[ms]: (255[m])*1000/V 
;*   TICK_DIS[ms]: (355[m])*1000/V 
;* 
;* Calling convention:
;* jsr PANT_CTRL
;*
;* Calls: Cargar_LCD
;* Changes: X, Y, D, BIN1, BIN2, TICK_EN, TICK_DIS, Banderas, PIEH.
;******************************************************************
PANT_CTRL:
			bclr PIEH,$09		; disable port H interrupts
			ldaa Veloc
			cmpa #35
			blo v_range`
			cmpa #50
			bhi v_range`

			brclr Banderas,$20,process` ; CALC_TICKS
			
			brset Banderas,$08,init_l`	; PANT_FLAG
			ldaa BIN1
			cmpa #$BB
			lbne return`


process`:	
			clra
;			todo: calc TICK_DIS and TICK_EN
			bset BANDERAS,$20		; CALC_TICKS = true
			bra return`


reset`:		ldx #MSGRM
			ldy #MSGMS1_D
			jsr Cargar_LCD
			movb #$BB,BIN1
			movb #$BB,BIN2
			ldaa Vueltas
			cmpa NumVueltas
			beq skip_en`
			bset PIEH,$09
skip_en`:	bclr Banderas,$20
			clr Veloc
			bra return`

init_l`:	ldaa BIN1
			cmpa #$BB
			bne return`
			ldx #MSGMS3_U
			ldy #MSGMS3_D
			jsr Cargar_LCD
			movb Vueltas,BIN1
			movb Veloc,BIN2
			bra return`
v_range`:	ldaa BIN1
			cmpa #$AA
			bne error`
			brclr Banderas,$08,reset`	;PANT_FLAG
			bra return`
error`:		movb #$AA,BIN1
			movb #$AA,BIN2			
			movw #0,TICK_EN
			movw #3000,TICK_DIS
			bset Banderas,$08
			ldx #MSGMSA_U
			ldy #MSGMSA_D
			jsr Cargar_LCD
			bra return`
return`:	rts
