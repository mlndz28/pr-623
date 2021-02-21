;******************************************************************
;* Hardware configuration
;******************************************************************

#include registers.inc

			org UserRTI
			dw #RTI_ISR  		; set user routine for RTI interruptions
			org UserPortH
			dw #CALCULAR 		; set user routine for port H interruptions

			org UserTimerCh3
			dw #OC3_ISR 		
			
			org UserTimerCh4
			dw #OC4_ISR 		; set user routines for timer
			org UserTimerCh5
			dw #TCNT_ISR 
			org UserAtoD0
			dw #ATD_ISR 
			

			org $1F00
HW_INIT:	movb #$F0, DDRA		; configure first nibble for output and the second one for input 
			bset PUCR,$01       ; port A is set for pull up operation 
			bset DDRB,$FF		; configure port B for output
			bset DDRJ,$02		; configure PJ1 pin for output
			movb $F0,DDRP		; configure port P for output (7 seg display mux)
			bset PTP,$0F
			bclr PIEH,$09		; disable interrupts on port H (initially)
			bclr PPSH,$09		; set polarity to use falling edge
			
			movb #$40,RTICTL	; interruption check interval set to about 1ms
			bset CRGINT,$80		; enable rti
			bset TSCR1,$90		; enable the timer module
			bset TSCR2,$03		; set prescaler to 3
			bset TIOS,$38		; set timer channel 4 and 5 as output 
			bset TIE,$18 		; enable interruptions for channel 4
			
			cli

			bset ATD0CTL2,$C2	; enable ATD interruptions with automatic flag clearing
			movb D5mS,Cont_Delay
			jsr DELAY
			movb D5mS,Cont_Delay
			jsr DELAY
			movb #$28,ATD0CTL3	; 5 conversion cycles
			movb #$97,ATD0CTL4	; 8 bit resolution, 2 clock cycles per sample, minimum conversion frequency (500 kHz:PRS=23)

			bset DDRE,$04		; port E as output for relay

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