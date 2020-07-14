;start=0x3000
#include ../registers.inc
#include ../init.asm
#include ../isr.asm
#include ../utilities.asm
			
			org UserTimerCh4
			dw #OC4_ISR 		; set user routine for timer
	
	org $3000
	bset DDRB,$FF		; set port b for output
	bset DDRJ,$02		; enable leds
	bclr DDRK,$FF		; disable LCD
	bset DDRP,$0F		; 7 seg ports disabled by default
	bset PTP,$0F		; initially set on 7 seg display
	
	bset TSCR1,$90		; enable the timer module
	bset TSCR2,$03		; set prescaler to 2^3
	bset TIOS,$10		; enable interruptions for channel 4
	bset TIE,$10 
	lds #STACK
	cli

	movb SEGMENT+1,DISP1
	movb SEGMENT+2,DISP2
	movb SEGMENT+3,DISP3
	movb SEGMENT+4,DISP4
	movb #$FF,LEDS
	movb #100,BRILLO
			
	bra *


;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/7seg_test.s19", "r").read())
;regs,so = debugger.run(0x3000)
;print("PC: %X Next: %s"%(regs.pc,regs.next.instruction))
;print("A: %X"%(regs.a))