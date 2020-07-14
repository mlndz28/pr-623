#include ../registers.inc
#include ../init.asm
#include ../isr.asm
#include ../utilities.asm

	org UserTimerCh4
	dw #OC4_ISR 		; set user routine for timer	

	org $3000
	bset DDRB,$FF		; configure port B for output
	bset DDRJ,$02		; configure PJ1 pin for output
	bclr PTJ,$02		; enable leds to light
	bset DDRP,$0F		; set off 7 seg display
	bset TSCR1,$90		; enable the timer module
	bset TSCR2,$07		; set prescaler to 2^7
	bset TIOS,$10		; enable interruptions for channel 4
	bset TIE,$10 
	lds #STACK
	cli
	
TEST_L1:				; the leds change every second 
	ldab #13			; (a little bit longer than that, actually)
TEST_L2:				; 13 * 2^7 * 20 * (24x10^6 / 8) * 255 [s]
	movb #$FF,Cont_Delay
	jsr DELAY
	tstb
	dbne B,TEST_L2 
	ldaa LEDS
	adda #1
	staa LEDS
	staa PORTB
	bra TEST_L1

;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/delay_test.s19", "r").read())
;debugger.run(0x3000)
;print("The LED's binary value should be incrementing by one every second")
