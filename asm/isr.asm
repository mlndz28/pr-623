;******************************************************************
;* User interrupt service routines
;******************************************************************


	loc
;******************************************************************
;* RTI_ISR - real time interrupt service routine. Called every
;* 1 ms or so. Used to handle time counters that don't need  
;* extreme accuracy.
;*
;* Enabling convention:
;*   org UserRTI
;*   dw #RTI_ISR
;*   movb #$40,RTICTL	; interruption check interval set to about 1ms
;*   bset CRGINT,$80
;*   cli			
;* 
;* Changes: Cont_Reb, CONT_ROC, CONT_200, CRGFLAG
;******************************************************************
RTI_ISR:
			brclr Cont_Reb,$FF,skip_reb`
			dec Cont_Reb
skip_reb`:	brclr CONT_ROC,$FF,skip_roc`
			dec CONT_ROC
skip_roc`:	brclr CONT_200,$FF,start_atd`
			dec CONT_200
			bra return`
start_atd`:	movb #$87,ATD0CTL5	; right justified result,unsigned, single-channel scan (channel 7)
			movb #200,CONT_200
return`:	bset CRGFLG,$80
			rti


	loc
;******************************************************************
;* CALCULAR - port H interrupt service routine for inputs 0 and 3.  
;* pth0 calculates the speed of the pipe, given that: 
;*   VELOC[cm/s] = 50000[10^-5 m]/TICK_MED[10^-3 s]   
;* while pth3 reset the TICK_MED counter when on, and calculates
;* the length when off:
;*   LENGTH[cm] = VELOC[cm/s] * (TICK_MED/1000)[s]   
;*
;* Enabling convention:
;*   org UserPortH
;*   dw #CALCULAR
;*   bset PIEH,$09
;*   bclr PPSH,$09
;*   cli
;*
;* Changes: VELOC, TICK_MED, LONG, PIFH. 
;******************************************************************
CALCULAR:	
			brclr Cont_Reb,$FF,skip`	; if(Cont_Reb!=0x00) {return;}
			rti
skip`:		brset PIFH,$01,pth0`
			brset PIFH,$08,pth3_on`
			brclr PIFH,$08,pth3_off`
			bclr PIFH,$0F
			bra return`
pth0`:		ldx TICK_MED
			ldd #50000
			idiv
			exg D,X
			stab VELOC
			bclr PIFH,$01
			bra return`
pth3_on`:	movw #0,TICK_MED
			ldaa PIFH
			swi
			bclr PIFH,$08
			bra return`
pth3_off`:	ldx TICK_MED
			swi
			ldd #1000
			idiv
			ldaa VELOC
			mul 
			stab LONG
			bclr PIFH,$08

return`:	rti


	loc
;******************************************************************
;* OC4_ISR - time output compare interrupt service routine for  
;* channel 4. Called every 20 us. Switches the on state between  
;* each of the 7 segment display digit/leds array every 2 ms.
;*
;* Enabling convention:
;*   org UserTimerCh4
;*   dw #OC4_ISR
;*   bset TSCR1,$90
;*   bset TSCR2,$03
;*   bset TIOS,$10
;*   bset TIE,$10 
;*   cli
;*
;* Arguments:
;*   DISP[1-4]: 7 segment display state
;*   LEDS: LED array state
;* Calls: CONV_BIN_BCD, BCD_7SEG
;* Changes: CONT_TICKS, CONT_DIG, PORTB, DDRP, PTP, TC4
;******************************************************************
OC4_ISR:
			ldaa CONT_7SEG
			cmpa #10
			bne skip_7s`
			jsr CONV_BIN_BCD	
			jsr BCD_7SEG	
			clr CONT_7SEG
skip_7s`:	ldaa CONT_TICKS
			cmpa #100
			bne skip_d`				; if(CONT_TICKS == 100){
			clr CONT_TICKS			;   CONT_TICKS = 0
			lsl CONT_DIG			;   CONT_DIG++ 
			inc CONT_7SEG			;	CONT_7SEG
			bra skip_t`				; }
skip_d`:	inc CONT_TICKS			; CONT_TICKS++
skip_t`:	tst Cont_Delay
			beq skip_del`
			dec Cont_Delay
skip_del`:	cmpa BRILLO
			beq set_off`
			cmpa #0
			beq set_on`
			bra return`
set_off`:	bset PTJ,$02			; disable leds
			bset PTP,$0F			; disable 7seg
			bset DDRP,$0F			; disable 7seg
			bra return`
set_on`:	brset CONT_DIG,$01,set_seg0	
			brset CONT_DIG,$02,set_seg1
			brset CONT_DIG,$04,set_seg2
			brset CONT_DIG,$08,set_seg3
			bra set_leds`
set_seg0:	movb DISP1,PORTB
			bra mux_p
set_seg1:	movb DISP2,PORTB
			bra mux_p
set_seg2:	movb DISP3,PORTB
			bra mux_p
set_seg3:	movb DISP4,PORTB
mux_p:		ldaa CONT_DIG
			coma
			staa PTP				; enable 7seg separately
			bra return`
set_leds`:	ldaa LEDS
			movb LEDS,PORTB
			bclr PTJ,$02			; enable leds to light
			movb #1,CONT_DIG		; reset counters
			clr CONT_TICKS
return`:	ldd TCNT
			addd #20*24/8			; 20us*24MHz/PRS
			std TC4
			rti

	loc
;******************************************************************
;* TCNT_ISR - time output compare interrupt service routine for  
;* channel 5. Called every 1 ms. Manages time counters for the 
;* selection subroutine. 
;*
;* Enabling convention:
;*   org UserTimerCh5
;*   dw #TCNT_ISR
;*   bset TSCR1,$90
;*   bset TSCR2,$03
;*   bset TIOS,$20
;*   bset TIE,$20 
;*   cli
;*
;* Arguments:
;*   TICK_MED: counter used to calculate speed and length
;*   TICK_EN: counter used to trigger a screen refresh
;*   TICK_DES: counter used to stop a screen refresh
;* Changes: TICK_MED, TICK_EN, TICK_DES, BANDERAS[3], PTP, TC5
;******************************************************************
TCNT_ISR:
			ldx TICK_MED
			inx
			stx TICK_MED
			ldx TICK_EN
			beq enable`
			dex
			stx TICK_EN
			bra skip_e`
enable`:	bset BANDERAS+1,$08		; PANT_FLAG = 1
skip_e`:	ldx TICK_DIS
			beq disable`
			dex
			stx TICK_DIS
			bra return`
disable`:	bclr BANDERAS+1,$08		; PANT_FLAG = 0
return`:	ldd TCNT
			addd #1000*24/8			; 1000us*24MHz/PRS
			std TC5
			rti

	loc
;******************************************************************
;* ATD_ISR - AD converter interrupt service routine for channel 7. 
;* Called every time it's enabled by writing to ATD0CTL5. Read
;* from 5 reads of the trimmer input and normalize the value to 
;* [0,100].
;*
;* Enabling convention:
;*   org UserAtoD0
;*	 dw #ATD_ISR
;*   bset ATD0CTL2,$C2
;*   *wait 100 ms*
;*   movb #$28,ATD0CTL3
;*	 movb #$97,ATD0CTL4
;* 	 cli
;*
;* Calling convention:
;*	 movb #$87,ATD0CTL5
;*
;* RETURNS: trimmer value in POT [0,255] and BRILLO [0,100]
;* Changes: POT, BRILLO.
;******************************************************************
ATD_ISR:
			ldd ADR00H
			addd ADR01H
			addd ADR02H
			addd ADR03H
			addd ADR04H
			ldx #5
			idiv
			exg D,X
			stab POT
			ldaa #100
			mul
			ldx #255
			idiv
			exg D,X
			stab BRILLO
			rti

