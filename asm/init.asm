;********************************************************************************************
;* Proyecto Final: Runmeter 623
;********************************************************************************************
;* Author: Fabian Melendez ^ Leonel Sanchez
;* 
;* Include Files: registers.inc
;*
;* Assembler: Karl Lunt - as12 (v1.2h, Linux port taken from 
;* https://github.com/mlndz28/68hc12-linux)
;*
;* Descripcion General: El codigo a continuación es un programa para la tarjeta Dragon 12
;* disenado para simular en el dispositivo un sistema para desplegar informacion de un 
;* velodromo. El velodromo a simular cuenta con una pantalla de 7 segmentos de 4 digitos
;* una pantalla LCD y 2 sensores foto reflectivos (simulados con botones de la tarjeta).
;* El sistema cuenta con 4 modos.
;* MODO CONFIG: en este se puede configurar la cantidad de vueltas a procesar
;* MODO LIBRE: permite tener el sistema en modo ocioso
;* MODO COMPETENCIA: se miden la cantidad de vueltas hechas por el ciclista, y se despliega
;* la informacion de vueltas y velocidad para que este las pueda visualizar.
;* MODO RESUMEN: muestra al ciclista un resumen de su rendimiento al calcular la velocidad
;* promedio en las vueltas realizadas.
;*
********************************************************************************************

********************************************************************************************
;* Data Structures
********************************************************************************************
				org $1000
Banderas:		ds 1		; X:X:CALC_TICKS:X:PANT_FLAG:ARRAY_OK:TCL_LEIDA:TCL_LISTA
	; * Modo config *
NumVueltas:		ds 1		
ValorVueltas:	ds 1		; 
	; * Tarea teclado *
MAX_TCL:		dc.b $02	; max number of elements in sequence
Tecla:			ds 1		; temporal holder for key values
Tecla_IN:		ds 1		; final value for a key press
Cont_Reb:		ds 1		; delay counter to ignore mechanical bounces on buttons
Cont_TCL:		ds 1		; idx used to write in the keys pressed array
Patron:			ds 1		; keypad column switcher
Num_Array:		ds 2		; array used to store the pressed keys
	; * ATD_ISR *
BRILLO:			ds 1		; variable used to increase or decrease the LCD screen brightness
POT:			ds 1		; potenciometer variable
	; * PANT_CTRL *
TICK_EN:		ds 2		; defines time the diplay is on
TICK_DIS:		ds 1		; defines time the display is off
				;org $1010
				ds 1
	; * CALCULAR *
Veloc:			ds 1		; speed calculated (actual measurement)
Vueltas:		ds 1		; amount of laps
VelProm:		ds 1		; average speed calculates
	; * TCNT_ISR *
TICK_MED:		ds 2		; ticks used to calculate the speed
	; * CONV_BIN_BCD *
BIN1:			ds 1		; used for Valorvueltas, input for CONV_BIN_BCD 
BIN2:			ds 1		; input for CONV_BIN_BCD
BCD1:			ds 1		; used for ValorVueltas, output for BIN_BCD, input for BCD_7SEG
BCD2:			ds 1		; output for BIN_BCD, input for BCD_7SEG
	; * BIN_BCD *
BCD_L:			ds 1		; stores output of BIN_BCD, used for CONV_BIN_BCD
BCD_H:			ds 1		; for conversion
TEMP:			ds 1		; temporary variable for conversions
LOW:			ds 1		; used for BIN_BCD algorithm
	; * BCD_7SEG *
DISP1:			ds 1		; value written on the 7 seg diplay
DISP2:			ds 1		; BCD2 uses DISP1 and DISP2
				;org $1020
DISP3:			ds 1		; value written on the 7 seg display
DISP4:			ds 1		; BCD1 uses DISP3 and DISP4
	; * OC4_ISR *
LEDS:			ds 1		; current state of the LEDS
CONT_DIG:		ds 1		; counts which digit of the 7 seg diplay should be enabled. Changes when CONT_TICKS reaches 100
CONT_TICKS:		ds 1		; ticks counter
DT:				ds 1		; work cycle DT = N-K
CONT_7SEG:		ds 2		; ticks counter for OC4. For LED refreshing 
	; * RTI_ISR *
CONT_200:		ds 1		; 200ms counter for RTI
	; * LCD *
Cont_Delay:		ds 1		; it is loaded with D2ms, D260uS, or D60uS por temp delays
D2mS:			dc.b 100	; 100 ticks @ 50kHz -> 2 ms
D260uS:			dc.b 13		; 13 ticks @ 50kHz -> 260 us
D60uS:			dc.b 3		; 3 ticks @ 50kHZ -> 60 us
Clear_LCD:		dc.b $01	; clears LCD display
ADD_L1:			dc.b $80	; start address for line 1
ADD_L2:			dc.b $C0	; start address for line 2
				;org $1030
	; * Other *
D5mS:			dc.b 250	; 250 ticks @ 50kHz -> 5ms
POSITION:		ds 1
CHECKPOINT:		ds 1
				
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
MSGMC_D: 		fcc "   NUM VUELTAS  "
				dc.b EOL
MSGRM: 			fcc "   RunMeter 623 "
				dc.b EOL
MSGML: 			fcc "    MODO LIBRE  "
				dc.b EOL
MSGMS1_D: 	   	fcc "   ESPERANDO... "
				dc.b EOL
MSGMS2_D: 		fcc "  CALCULANDO... "
				dc.b EOL
MSGMS3_U: 		fcc " M.COMPETENCIA  "
				dc.b EOL
MSGMS3_D: 		fcc "VUELTA    VELOC "
				dc.b EOL
MSGMSA_U: 		fcc "** VELOCIDAD  **"
				dc.b EOL
MSGMSA_D: 		fcc "*FUERA DE RANGO*"
				dc.b EOL
MSGMSV_U: 		fcc "   *LONGITUD*   "
				dc.b EOL
MSGMSV_D: 		fcc "   *CORRECTA*   "
				dc.b EOL
MSGMSNV_U: 		fcc "   -LONGITUD-   "
				dc.b EOL
MSGMSNV_D: 		fcc "  -DEFICIENTE-  "
				dc.b EOL
MSGR_U:	 		fcc "  MODO RESUMEN  "
				dc.b EOL
MSGR_D:	 		fcc "VUELTAS    VELOC"
				dc.b EOL

STACK:			equ $3BFF
VMAX:			equ 100

;******************************************************************
;* Variables that must be initialized on reset.
;******************************************************************
INIT:
		clr Banderas
		clr NumVueltas
		clr ValorVueltas
		movb #$FF,Tecla
		movb #$FF,Tecla_IN
		movw #$FFFF,Num_Array
		clr Veloc
		clr Vueltas
		clr VelProm
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
		movb #$02,CHECKPOINT
		rts