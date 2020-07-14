;start=0x3000
#include ../registers.inc 
#include ../init.asm 
#include ../keypad.asm 
	
	org $3000

	movb #0,Cont_TCL
	movb #1,TECLA_IN
	jsr FORMAR_ARRAY
	movb #4,TECLA_IN
	jsr FORMAR_ARRAY
	movb Cont_TCL, $3100
	movw Num_Array, $3101
	swi

;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/formar_array_test.s19", "r").read())
;debugger.run(0x3000)
;cont = debugger.read_memory(0x3100)
;entero = debugger.read_memory(0x3101,0x3102)
;assert cont==2, 'Wrong CONT result'
;for i in range(len(entero)): assert entero[i]==[1,4][i], 'Wrong ENTERO result'  
;print("SUCCESSFUL")