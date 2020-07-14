;******************************************************************
;* User interrupt service routines
;******************************************************************

TAREA_TECLADO:
			brclr Cont_Reb,$FF,TT_MT	; if(Cont_Reb!=0x00) {return;}
			rts
TT_MT:		jsr MUX_TECLADO				; mux_teclado();					(1)
			brset Tecla,$FF,NOT_PUSHED	; if(Tecla==0xFF) {not_pushed()} 	(4)
			brset Banderas+1,$02,PUSHED	; else if(TCL_LEIDA){pushed()}		(3)
			movb Tecla, Tecla_IN		; else{ Tecla_IN = Tecla;			(2)
			bset Banderas+1, $02			;   TCL_LEIDA = true;
			movb #100, Cont_Reb			; 	Cont_Reb = 100; // in ms
			rts							;   return;
										; } 
NOT_PUSHED: brset Banderas+1,$01,RELEASED	; if(!TCL_LISTA){					
			rts							;   return;
RELEASED:	bclr Banderas+1, $03			; }else{ TCL_LEIDA,TCL_LISTA = false;	(4)
			jsr FORMAR_ARRAY			;   formar_array();
			rts							;   return;
										; }
PUSHED:		ldaa Tecla_IN				; 
			cmpa Tecla					;
			beq PSHRDY					; if(Tecla_IN != Tecla){
			movb #$FF, Tecla_IN			;   Tecla_IN = 0xFF;
			movb #$FF, Tecla			;   Tecla = 0xFF;
			bclr Banderas+1, $03			;	TCL_LEIDA,TCL_LISTA = false;
			rts							; }else{							(3)
PSHRDY:		bset Banderas+1, $01			;   TCL_LISTA = true;
			rts							; } return;

MUX_TECLADO:								; void mux_teclado(){
			ldaa #$EF						;   for(i1=1; i1 < 5; i1++){
			movb #0, Patron					;     for(i2=1; i2 < 5; i2++){
			des								;       if(PORTA[i1-1][i2-1]==0){ 
MT_L1:		inc Patron					   	;         Tecla = Teclas[i1-1][i2-1];
			brset Patron,$05,NOT_PRESSED 	;   	  return; 
			staa PORTA						;       }
			ldab #$00						;     } 
			movb PORTA, 0,SP				;   }
MT_L2:										;   Tecla = 0xFF; 
			brclr 0,SP,$01,PRESSED      	;   return;
			ror 0,SP						; }
			incb
			cmpb #3
			bne MT_L2 
			rola					; next pattern, zero bit is shifted left
			bra MT_L1
PRESSED:	pshb					; save i2 index
			ldab Patron 			; index_tecla= (i1-1)*3+i2; 
			decb
			ldaa #3
			mul
			addb 0,SP
			leas 2,SP				; set back up the stack pointer 
			ldx #Teclas
			movb B,X, Tecla 		; Tecla = Teclas[index_tecla];
			rts
NOT_PRESSED:movb #$FF, Tecla		; Tecla = 0xFF	// not pressed
			ins						; set back up the stack pointer
			rts

FORMAR_ARRAY:
			ldab Tecla_IN
			addb #$30
			ldab Cont_TCL
			brset Tecla_IN,$0E,ENTER		; if(Tecla_IN == 0x0E){ enter(); }
			brset Tecla_IN,$0B,BACK			; if(Tecla_IN == 0x0B){ back(); }
											; if(Cont_TCL != MAX_TCL){
			cmpb MAX_TCL					;   save_key(Tecla_IN, Cont_TCL);
			bne SAVE_KEY					; }else{
			rts								;   return;
											; }
BACK:		brclr Cont_TCL,$FF,FA_R			; void back(){ if(Cont_TCL == 0){return;};		
			dec Cont_TCL					;   Cont_TCL--;
			decb							; if(Cont_TCL != MAX_TCL){
			ldx #Num_Array					; 
			movb #$FF, B,X					;   Num_Array[Cont_TCL] = 0xFF;
			rts								;   return;
											; }
ENTER:		brclr Cont_TCL,$FF,FA_R			; void enter(){ if(Cont_TCL == 0){return;};		
			clr Cont_TCL					;   Cont_TCL = 0;
			bset Banderas+1,$04				;   ARRAY_OK = true;
			rts								;   return;
											; }		
SAVE_KEY:	ldx #Num_Array					; void save_key(tecla, index){
			movb Tecla_IN, B,X				;   Num_Array[index] = tecla;   
			inc Cont_TCL					;   Cont_TCL++;
FA_R:		rts								; }
