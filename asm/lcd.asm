
;******************************************************************
;* Send_Command - send a command to the LCD screen through port K.  
;*
;* Calling convention:
;* ldaa <command>
;* jsr Send_Command
;*
;* Calls: SEND
;* Changes: CCR.C, A, PORTK
;******************************************************************
Send_Command:
			clc
			bra SEND

;******************************************************************
;* Send_Data - send data to the LCD screen through port K.  
;*
;* Calling convention:
;* ldaa <data>
;* jsr Send_Data
;*
;* Calls: SEND
;* Changes: CCR.C, A, PORTK
;******************************************************************
Send_Data:
			orcc #$01
			bra SEND
	loc
;******************************************************************
;* SEND - send a byte (one nibble at the time) through port K to  
;* the LCD screen.
;*
;* Calling convention:
;* orcc #$01 (to send data) / andcc #$FE (to send a command)
;* ldaa <argument>
;* jsr SEND
;*
;* Calls: SEND_NIBB
;* Changes: A, PORTK
;******************************************************************
SEND:
			pshc					; since the carry flag is affected by the shifting instructions
			psha
			anda #$F0				; mask upper byte
			bcc skip`
			ora #$04				; set command/data switch before shifting
skip`:		lsra
			lsra
			jsr SEND_NIBB
			pula					; do the same for lower byte
			anda #$0F
			lsla
			pulc
			rola
			jsr SEND_NIBB
			rts

;******************************************************************
;* SEND_NIBBLE - send a nibble through port K to the LCD screen. 
;*
;* Calling convention:
;* ldaa <centered nibble>
;* jsr SEND_NIBBLE
;*
;* Calls: DELAY
;* Changes: PORTK, Cont_Delay
;******************************************************************
SEND_NIBB:	
			staa PORTK
			bset PORTK,$02
			movb D260uS,Cont_Delay
			jsr DELAY
			bclr PORTK,$02
			rts

;******************************************************************
;* Cargar_LCD - change the current message at the LCD screen,  
;* which has to be initialized (LCD_INIT does the job). The char 
;* arrays that are taken as parameters must end with $00, as an
;* end of line marker.
;*
;* Calling convention:
;* ldx #<upper char array address>
;* ldy #<lower char array address>
;* jsr SEND_NIBBLE
;*
;* Calls: Send_Command, Send_Data, DELAY
;* Changes: CCR.C, A, PORTK, X, Y
;******************************************************************
	loc
Cargar_LCD:
			ldaa ADD_L1
			jsr Send_Command
			movb D60uS,Cont_Delay
			jsr DELAY
loop`:		ldaa 1,X+
			beq skip`
			jsr Send_Data
			movb D60uS,Cont_Delay
			jsr DELAY
			bra loop`
skip`:		ldaa ADD_L2
			jsr Send_Command
			movb D60uS,Cont_Delay
			jsr DELAY
	loc
loop`:		ldaa 1,Y+
			beq skip`
			jsr Send_Data	
			movb D60uS,Cont_Delay
			jsr DELAY
			bra loop`
skip`:		rts