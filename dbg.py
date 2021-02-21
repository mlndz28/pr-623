from dbug12 import Debugger
import os, time, subprocess

formatStr="%8s %8s %8s %8s %8s %8s %8s %12s %8s %s"
def printRegs(r):
  print(formatStr % (hex(r.pp), hex(r.pc), hex(r.sp), hex(r.b), hex(r.a), hex(r.x), hex(r.y), bin(r.ccr), hex(r.next.address), r.next.instruction))
  print(formatStr % ((r.pp), (r.pc), (r.sp), (r.b), (r.a), (r.x), (r.y), bin(r.ccr), (r.next.address), r.next.instruction))

debugger = Debugger()

datastructs = [
  'BANDERAS',
  'NumVueltas',
  'ValorVueltas',
  'MAX_TCL',
  'Tecla',
  'Tecla_IN',
  'Cont_Reb',
  'Cont_TCL',
  'Patron',
  'Num_Array',
  'Num_Array',
  'BRILLO',
  'POT',
  'TICK_EN',
  'TICK_EN',
  'TICK_DIS',
  'TICK_DIS',
  'Veloc',
  'Vueltas',
  'VelProm',
  'TICK_MED',
  'TICK_MED',
  'BIN1',
  'BIN2',
  'BCD1',
  'BCD2',
  'BCD_L',
  'BCD_H',
  'TEMP',
  'LOW',
  'DISP1',
  'DISP2',
  'DISP3',
  'DISP4',
  'LEDS',
  'CONT_DIG',
  'CONT_TICKS',
  'DT',
  'CONT_7SEG',
  'CONT_7SEG',
  'CONT_200',
  'Cont_Delay',
  'D2mS',
  'D240uS',
  'D60uS',
  'Clear_LCD',
  'ADD_L1',
  'ADD_L2',
  'D5MS',
  'POSITION',
  'CHECKPOINT'
]
print(formatStr % ('pp', 'pc', 'sp', 'B', '', 'x', 'y', 'SXHINZVC', 'next', 'instruction'))
# debugger.run(0x2000)
printRegs(debugger.get_registers())
print("***")
mem=debugger.read_memory(0x1000,0x1032)
print("%20s %10s %10s %10s" % ("datastructs", "Posicion", "Valor dec", "Valor hex"))
for memPos in range(0x33):
  try:
    print("%20s %10s %10s %10s" % (datastructs[memPos], hex(0x1000+memPos), mem[memPos], "0x%02X"%mem[memPos]))
    print("\t---------------------------------------------------")
  except:
    pass
# debugger.run()
