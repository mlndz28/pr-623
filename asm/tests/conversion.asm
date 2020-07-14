#include ../registers.inc
#include ../init.asm
#include ../utilities.asm

	org $3000
	
	sei
	lds #STACK
	ldaa #28
	jsr BIN_BCD
	movb BCD_L,$3100
	movw #$0208,Num_Array
	jsr BCD_BIN
	movb ValorLength,$3101

	swi

;test
;from dbug12 import Debugger
;import os
;print(os.getcwd())
;debugger = Debugger()
;debugger.load(open("asm/bin/conversion_test.s19", "r").read())
;debugger.run(0x3000)
;res = debugger.read_memory(0x3100,0x3101)
;print(res)
;assert res[0]==0x28, 'Wrong number to bcd result'  
;assert res[1]==28, 'Wrong bcd to number result'   
;#for i in range(len(res)): assert res[i]==[0xaa,0x28,0xaa][i], 'Wrong number to bcd result'   
;print("SUCCESSFUL")