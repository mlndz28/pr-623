;******************************************************************
;* Hardware configuration
;******************************************************************

#include registers.inc

			org UserRTI
			dw #RTI_ISR  		; set user routine for RTI interruptions
			org UserPortH
			dw #CALCULAR 		; set user routine for port H interruptions
			org UserTimerCh4
			dw #OC4_ISR 		; set user routines for timer
			org UserTimerCh5
			dw #TCNT_ISR 
			

			org $1F00
HW_INIT:	movb #$F0, DDRA		; configure first nibble for output and the second one for input 
			bset PUCR,$01       ; port A is set for pull up operation 
			bset DDRB,$FF		; configure port B for output
			bset DDRJ,$02		; configure PJ1 pin for output
			bclr DDRP,$0F		; configure port P for output (7 seg display mux)
			bset PTP,$0F
			bclr PIEH,$09		; disable interrupts on port H (initially)
			bclr PPSH,$09		; set polarity to use falling edge
			
			movb #$40,RTICTL	; interruption check interval set to about 1ms
			bset CRGINT,$80		; enable rti
			bset TSCR1,$90		; enable the timer module
			bset TSCR2,$03		; set prescaler to 3
			bset TIOS,$30		; set timer channel 4 and 5 as output 
			bset TIE,$10 		; enable interruptions for channel 4

			cli
			jsr LCD_INIT								

			rts

LCD_INIT:	
			bset DDRK,$FF		; enable LCD screen ports
			clr PORTK
			ldx #IniDsp
	loc
loop`: 		ldaa 1,X+
			beq continue`
			jsr Send_Command
			movb D60uS,Cont_Delay
			jsr DELAY
			bra loop`
continue`:	ldaa Clear_LCD
			jsr Send_Command
			movb D2mS,Cont_Delay
			jsr DELAY
			rts