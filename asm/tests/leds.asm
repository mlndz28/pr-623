;start=0x3000
#include ../registers.inc
#include ../init.asm
#include ../isr.asm
#include ../utilities.asm
				
	org $3000
	bset DDRB,$FF		; set port b for output
	bset DDRJ,$02		; enable leds
	bclr PTJ,$02
	bset DDRP,$FF		; set off 7 seg display
	lds #STACK
	movb #$FF,PORTB
			
	swi


;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/leds_test.s19", "r").read())
;debugger.run(0x3000)
