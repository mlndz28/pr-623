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
			tst NumVueltas
			beq loop_c`
loop_m`:	
			brset PTH,$C0,race`
			bclr PIEH,$09
			brset PTH,$80,overview`
			bclr TIE,$20
			clr Veloc
			clr Vueltas
			clr VelProm 
			brset PTH,$40,config`
idle`:		jsr MODO_LIBRE
			bra loop_m`
race`:		bset PIEH,$09
			bset TIE,$20
			jsr MODO_COMPETENCIA
			bra loop_m`
overview`:	jsr MODO_RESUMEN
			bra loop_m`
config`:	jsr MODO_CONFIG
			bra loop_m`