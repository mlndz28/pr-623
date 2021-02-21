#include ../registers.inc
#include ../init.asm
#include ../isr.asm
#include ../utilities.asm

	org UserTimerCh4
	dw #OC4_ISR 		; set user routine for timer	

	org $3000
	bset DDRB,$FF		; configure port B for output
	bset DDRJ,$02		; configure PJ1 pin for output
	bclr PTJ,$02		; enable			
	
	
	bset DDRP,$0F		; set off 7 seg display
	bset TSCR1,$90		; enable the timer module
	bset TSCR2,$03		; set prescaler to 2^3
	bset TIOS,$10		; enable interruptions for channel 4
	bset TIE,$10 

	cli
	
	bset ATD0CTL2,$C2	; enable ATD interruptions with automatic flag clearing		
	movb D5mS,Cont_Delay
	jsr DELAY
	movb D5mS,Cont_Delay
	jsr DELAY
	movb #$28,ATD0CTL3	; 5 conversion cycles
	movb #$97,ATD0CTL4	; 8 bit resolution, 2 clock cycles per  leds to light


	lds #STACK
	movb #$B9,BIN1
	movb #$BB,BIN2
	movb #99,BRILLO
	clr LEDS
	
TEST_L1:				; the leds change every second 
	;ldd #$13			; (a little bit longer than that, actually)
	ldd #$83			; (a little bit longer than that, actually)
TEST_L2:				; 13 * 255 *2^3 * 20 / (24x10^6 ) [s]
	movb #$FF,Cont_Delay
	jsr DELAY
	cpd #0 
	dbne D,TEST_L2
	inc LEDS
	;movb #$FF,LEDS
	;movb LEDS,PORTB
	bra TEST_L1


;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/delay_test.s19", "r").read())
;debugger.run(0x3000)
;print("The LED's binary value should be incrementing by one every second")
