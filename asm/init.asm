;********************************************************************************************
;* Title: selector.asm 
;********************************************************************************************
;* Author: Fabian Melendez
;*
;* Description: PVC pipes length verifier
;*
;* Include Files: registers.inc
;*
;* Assembler: Karl Lunt - as12 (v1.2h, Linux port taken from 
;* https://github.com/mlndz28/68hc12-linux)
;*
********************************************************************************************


				org $1000
Banderas:		ds 2		; $XX:X:X:X:CambMod:ModActual:ARRAY_OK:TCL_LEIDA:TCL_LISTA
LengthOK:		ds 1		
ValorLength:	ds 1		; 
MAX_TCL:		dc.b $02	; max number of elements in sequence
Tecla:			ds 1		; temporal holder for key values
Tecla_IN:		ds 1		; final value for a key press
Cont_Reb:		ds 1		; delay counter to ignore mechanical bounces on buttons
Cont_TCL:		ds 1
Patron:			ds 1		; keypad column switcher
Num_Array:		ds 2
BRILLO:			ds 1
POT:			ds 1
TICK_EN:		ds 2
				;org $1010
TICK_DIS:		ds 2
CONT_ROC:		ds 1
VELOC:			ds 1
LONG:			ds 1
TICK_MED:		ds 2
BIN1:			ds 1
BIN2:			ds 1
BCD1:			ds 1
BCD2:			ds 1
BCD_L:			ds 1
BCD_H:			ds 1
TEMP:			ds 1
LOW:			ds 1
DISP1:			ds 1
				;org $1020
DISP2:			ds 1
DISP3:			ds 1
DISP4:			ds 1
LEDS:			ds 1
CONT_DIG:		ds 1
CONT_TICKS:		ds 1
DT:				ds 1
CONT_7SEG:		ds 2
CONT_200:		ds 1
Cont_Delay:		ds 1
D2mS:			dc.b 100
D260uS:			dc.b 13
D60uS:			dc.b 3
Clear_LCD:		dc.b $01
ADD_L1:			dc.b $80
				org $1030
ADD_L2:			dc.b $C0
D5mS:			dc.b 250
POSITION:		ds 1
				
				org $1040
Teclas:			dc.b $01, $02, $03, $04, $05, $06, $07, $08, $09, $0B, $00, $0E 
				org $1050
SEGMENT:		dc.b $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $40, $00

				org $1060
IniDsp:			dc.b $28		; function_set(0,0,1,bus=4bit[DL=0], screen_lines=dual[N=1], font=5x8[F=0],0,0)
				dc.b $28		; issuing function_set again usually fixes some bugs 
				dc.b $06		; entry_mode_set(0x0,0,1, move_cursor=right[I/D=1], shift_display=no[SH=0])
				dc.b $0C		; display_control(0x0,1,display=on[D=1],cursor=off[C=0],blink=off[B=0])
				dc.b $00
EOL:			equ $00			
				org $1070
MSGMC_U: 		fcc "   MODO CONFIG  "
				dc.b EOL
MSGMC_D: 		fcc "    LengthOK    "
				dc.b EOL
MSGMS_U: 		fcc "   MODO SELECT  "
				dc.b EOL
MSGMS1_D: 		fcc "   Esperando... "
				dc.b EOL
MSGMS2_D: 		fcc "  Calculando... "
				dc.b EOL
MSGMSA_U: 		fcc "   VELOCIDAD    "
				dc.b EOL
MSGMSA_D: 		fcc " FUERA DE RANGO "
				dc.b EOL
MSGMSV_U: 		fcc "   *LONGITUD*   "
				dc.b EOL
MSGMSV_D: 		fcc "   *CORRECTA*   "
				dc.b EOL
MSGMSNV_U: 		fcc "   -LONGITUD-   "
				dc.b EOL
MSGMSNV_D: 		fcc "  -DEFICIENTE-  "
				dc.b EOL
MSGS_U:	 		fcc "    SELECTOR    "
				dc.b EOL
MSGS_D:	 		fcc "      623       "
				dc.b EOL

STACK:			equ $3BFF
VMAX:			equ 100

;******************************************************************
;* Variables that must be initialized on reset.
;******************************************************************
INIT:
		movw #0,Banderas
		clr LengthOK
		movb #$FF,Tecla
		movb #$FF,Tecla_IN
		movw #$FFFF,Num_Array
		movb #50,BRILLO
		clr CONT_ROC
		clr VELOC
		movb #$BB,BIN1
		movb #$BB,BIN2
		clr DISP1
		clr DISP2
		clr DISP3
		clr DISP4
		clr LEDS
		movb #1,CONT_DIG
		clr CONT_TICKS
		clr DT
		movw #0,CONT_7SEG
		clr CONT_200
		clr Cont_Delay
		clr POSITION
		rts