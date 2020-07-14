;start=0x3000
#include ../registers.inc
#include ../init.asm
#include ../isr.asm
#include ../lcd.asm
#include ../utilities.asm
			org $1300
MSG_U:	 	fcc "   Hello"
			db EOL
MSG_D:	 	fcc "      World!"
			db EOL
			
			org UserTimerCh4
			dw #OC4_ISR 		; set user routine for timer
	
	org $3000
	bset DDRP,$0F		; set off 7 seg display
	bset DDRK,$FF		; enable LCD
	clr PORTK
	bset TSCR1,$90		; enable the timer module
	bset TSCR2,$03		; set prescaler to 2^3
	bset TIOS,$10		; enable interruptions for channel 4
	bset TIE,$10 
	lds #STACK
	cli
	
			
	loc			
			ldx #IniDsp
loop`:		ldaa 1,X+
			beq skip`
			jsr Send_Command
			movb D60uS,Cont_Delay
			jsr DELAY
			bra loop`
skip`:	

			ldaa Clear_LCD
			jsr Send_Command
			movb D2mS,Cont_Delay
			jsr DELAY
			
			ldx #MSG_U
			ldy #MSG_D
			jsr Cargar_LCD
			swi



;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/lcd_test.s19", "r").read())
;debugger.run(0x3000)
