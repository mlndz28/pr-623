[comment]: <> (#!/usr/bin/pandoc --filter pandoc-plant-uml)

<h2 style="text-align: right"> Fabián Meléndez Aguilar </h2>
<h2 style="text-align: right" > B34144 </h2> 

Proyecto Final
====

## Estructuras de datos

* `Banderas`: Variable tipo word. Contiene las siguientes banderas, empezando por la asignada al bit menos significativo:
    - `TCL_LISTA`: Se activa cuando se suelta una tecla. 
    - `TCL_LEIDA`: Se activa cuando se presiona una tecla. 
    - `ARRAY_OK`: Se activa cuando la secuencia de datos se ingresó correctamente. 
    - `PANT_FLAG`: Indica si las pantallas se deben refrescar en MODO_SELECT. 
    - `CALC_TICKS`: Se enciende una vez que el tubo supera el rociador. 
* `MAX_TCL`: Constante tipo byte que determina el tamaño máximo de Num_Array.
* `Tecla`: Variable tipo byte que que guarda temporalmente el valor presionado por una tecla.
* `Tecla_IN`: Variable tipo byte al cual se asigna el valor que debe ser guardado en Num_Array.
* `Cont_Reb`: Variable tipo byte. Contador para ignorar los rebotes mecánicos de los botones.
* `Cont_TCL`: Variable tipo byte. Se refiere a la cantidad de datos ingresados en Num_Array.
* `Patron`: Variable tipo byte. Se utiliza como índice de filas para barrer la matriz del teclado.
* `Num_Array`: Dirección del arreglo de bytes de salida. En este se guardan los valores digitados en el teclado.
* `BRILLO`: Variable tipo byte. Indica el brillo del display de 7 segmentos y el arreglo de LEDs.
* `POT`: Variable tipo byte.
* `TICK_EN`: Variable tipo word.
* `TICK_DIS`: Variable tipo word.
* `CONT_ROC`: Variable tipo byte.
* `VELOC`: Variable tipo byte. Indica la velocidad con la que viaja el tubo por la cinta transportadora (dado en $\frac{cm}{s}$). 
* `LONG`: Variable tipo byte. Indica la longitud del tubo (dado en $cm$). 
* `TICK_MED`: Variable tipo word. Cantidad de milisegundos desde que se detecta un tubo en el primer sensor. 
* `BIN1`: Variable tipo byte. Número sin signo. 
* `BIN2`: Variable tipo byte. Número sin signo.
* `BCD1`: Variable tipo byte. Número BCD de dos dígitos.
* `BCD2`: Variable tipo byte. Número BCD de dos dígitos.
* `BCD_L`: Variable tipo byte. Número BCD de dos dígitos. 
* `BCD_H`: Variable tipo byte. Número BCD de dos dígitos.
* `TEMP`: Variable tipo byte. 
* `LOW`: Variable tipo byte.
  
  De izquierda a derecha: 
* `DISP1`: Variable tipo byte. Representación del dígito mostrado en la pantalla de 7 segmentos.
* `DISP2`: Variable tipo byte. Representación del dígito mostrado en la pantalla de 7 segmentos. 
* `DISP3`: Variable tipo byte. Representación del dígito mostrado en la pantalla de 7 segmentos. 
* `DISP4`: Variable tipo byte. Representación del dígito mostrado en la pantalla de 7 segmentos. 
* `LEDS`: Variable tipo byte que contiene el estado de encendido/apagado de los LEDs.
* `CONT_DIG`: Variable tipo byte. Utilizado como indicador del elemento que se está multiplexando en la pantalla de 7 segmentos/LEDs. 
* `CONT_TICKS`: Variable tipo byte. 
* `DT`: Variable tipo byte. 
* `CONT_7SEG`: Variable tipo word. Este contador se utliza para convertir el valor a enviarse al display de 7 segmentos.
* `Cont_Delay`: Variable tipo byte. Contador utilizado en la interrupción del temporizador por salida por comparador en el canal 4, y se utiliza para mantener un proceso IDLE por cierta cantidad de tiempo. 
* `D2mS`: Constante tipo byte. Valor asignado a un tiempo de espera de 2 milisegundos. 
* `D260uS`: Constante tipo byte. Valor asignado a un tiempo de espera de 260 microsegundos.  
* `D60uS`: Constante tipo byte. Valor asignado a un tiempo de espera de 60 microsegundos.  
* `ADD_L1`: Constante tipo byte. Primer comando a enviarse cuando se quiere escribir a la memoria de la pantalla LCD. 
* `ADD_L2`: Constante tipo byte. Segundo comando a enviarse cuando se quiere escribir a la memoria de la pantalla LCD.
* `Teclas`: Dirección del arreglo de bytes que contiene la asignación de las teclas a los valores deseados.
* `SEGMENT`: Dirección del arreglo de bytes que contiene la asignación de numeros decimales a valores para la pantalla de 7 segmentos.
* `iniDsp`: Dirección del arreglo de bytes que contiene la secuencia de comandos para inicializar la pantalla LCD.
* `MSGMC_U,MSGMC_D`: Direcciones de los arreglo de caracteres que contienen los mensajes que se despliegan en el modo `CONFIG` en la pantalla LCD.
* `MSGS_U,MSGS_D`: Direcciones de los arreglo de caracteres que contienen los mensajes que se despliegan en el modo `STOP` en la pantalla LCD.
* `MSGMS_U,MSMS1_D,MSMS2_D`: Direcciones de los arreglo de caracteres que contienen los mensajes que se despliegan en el modo `SELECT` en la pantalla LCD.

## Inicialización de hardware

$$T_{RTI}=\frac{(N+1)\cdot2^{M+9}}{8x10^6}=1x10^{-3}s$$

$$M=4$$

(No se puede utilizar $M = 0$ ya que este valor deshabilita RTI. $2^{13}$ se acerca a 8K, entonces se facilitan los cálculos.) 

$$N=\frac{1X10^{-3} \cdot 8x10^6}{2^{13}} - 1 = 0.0234$$

$$N=0$$
$$T_{RTI}=\frac{(1)\cdot2^{13}}{8x10^6}=1.024x10^{-3}s$$

Entonces `RTICTL` = `$40`

Según los requisitos del programa, la inicialización del HW se debe hacer antes del programa principal, por lo que se encapsulará en una subrutina alojada en `$1F00`. Esta subrutina se llama desde el programa principal.

Para las interrupciones por `output compare` se escoge un valor para el pre-escalador de `8`. Cálculos posteriores se basan en este valor de `PRS`.

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=HW_INIT;
:DDRA ← $F0
PUCR.0 ← 1]
:DDRB ← $FF
DDRJ.1 ← 1
PTJ.1 ← 0
DDRP ← $0F
PTP ← $0F]
:PIEH.0 ← 1
PPSH.0 ← 0]
:RTICTL ← $40
CRGINT.7 ← 1
I ← 0]
:TSCR1 ← $90
TSCR2 ← $03
TIOS ← $0
TIE ← $10]
:LCD_INIT|
:=RETORNAR;
```
```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=LCD_INIT;
:DDRK ← $FF
PORTK ← $00]
:J ← IniDsp]
while(((J)) != 0)
  :R1 ← ((J))\nJ ← (J) + 1]
  :Send_Command|
  :(Cont_Delay) ← (D60uS)]
  :DELAY|
endwhile (NO)
:R1 ← (Clear_LCD)]
:Send_Command|
:(Cont_Delay) ← (D2mS)]
:DELAY|
:=RETORNAR;

```

## Programa principal

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=INICIO;
:SP ← $3BFF]
:HW_INIT|
repeat
  :MODO_CONFIG|    
repeat while (LengthOK == 0)
->NO;
repeat
  if(PTH.6==1)
    :PIEH.0 ← 1\nPIEH.3 ← 1\nTIE.5 ← 1]
    :MODO_SELECT|    
  else (NO)
    :PIEH.0 ← 1\nPIEH.3 ← 0\nTIE.5 ← 0\nVELOC ← 0\nLONG ← 0]
    if(PTH.7==1)
      :MODO_CONFIG|    
    else (NO)
      :MODO_STOP|    
    endif

  endif
repeat while 

```

## MODO_CONFIG

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=MODO_CONFIG;
:ARRAY_OK ← 0
TICK_EN ← 0
TICK_DIS ← 0
J ← MSGMC_U
K ← MSGMC_D]
:Cargar_LCD|
:(BIN1) ← (LengthOK)
(BIN2) ← $BB
(LEDS) ← $02]
:TAREA_TECLADO|
if(ARRAY_OK == 1) then
  :BCD_BIN|
  if((ValorLength) > 70 && (ValorLength) < 100) then
    :(LengthOK) ← (BIN1)]
  else (NO)
      :(LengthOK) ← 0]
  endif
else (NO)
endif
:=RETORNAR;
```

## MODO_STOP

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=MODO_CONFIG;
:J ← MSGS_U
K ← MSGS_D]
:Cargar_LCD|
:(BIN1) ← $BB
(BIN2) ← $BB
(LEDS) ← $04]
:=RETORNAR;

```

## MODO_SELECT

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=MODO_CONFIG;
:J ← MSGMS_U
K ← MSGMS1_D]
:Cargar_LCD|
:(BIN1) ← $BB
(BIN2) ← $BB
(LEDS) ← $02]
if(VELOC!=0) then
  :PANT_CTRL|
else (NO)
endif 
:=RETORNAR;

```

## BCD_BIN

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=BCD_BIN;
:(Valor_Length) ← (Num_Array) x 10 + (Num_array + 1)]

:=RETORNAR;

```

## RTI_ISR

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=RTI_ISR;
if(Cont_Reb =! 0) is (SI) then
  :(Cont_Reb) ← (Cont_Reb) - 1]
elseif(TIMER_CUENTA != 0) then
  :(TIMER_CUENTA) ← (TIMER_CUENTA) - 1]
else (NO)
endif
:CRGFLAG.7 ← 1]
:=RETORNAR;
```


## OC4_ISR

$$TC4 = \frac{T_{interrupcion} \cdot BusClk }{PRS}$$
$$TC4 = \frac{20\mu s \cdot 24MHz}{2^3} = 60$$

Además, CONT_DIG se utliza como una máscara, y no como un contador, por eso se hacen desplazamientos lógicos.

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=OC4_ISR;
if((CONT_TICKS)==100) then
  :(CONT_TICKS) ← 0\n C ← CONT_DIG ← 0]
else (NO)
endif
:(CONT_TICKS) ← (CONT_TICKS) +1]
if(Cont_Delay != 0) then
  :(Cont_Delay) ← (Cont_Delay) - 1]
else (NO)
endif
if((CONT_DIG) == $01) then
  -> SI;
  :(PORTB) ← (DISP1)
elseif((CONT_DIG) == $02) then
  -> SI;
  :(PORTB) ← (DISP2)
elseif((CONT_DIG) == $04) then
  -> SI;
  :(PORTB) ← (DISP3)
elseif((CONT_DIG) == $08) then
  -> SI;
  :(PORTB) ← (DISP1)
else (NO)
  :(PORTB) ← (LEDS);
  :(CONT_DIG) ← $01;
endif

:PTP ← !(CONT_DIG)]

:TC5 ← (TCNT) + 60]
:=RETORNAR;
```

## CONV_BIN_BCD

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=CONV_BIN_BCD;
if(BIN1 < 100) then
else (NO)
endif
:R1 ← (BIN1)]
:BIN_BCD|
:(BCD1) ← (R1)\nR1 ← (BIN2)]
:BIN_BCD|
:(BCD2) ← (R1)]
:=RETORNAR;
```

## BIN_BCD

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=BCD_BIN;
:↑(RR1)\nJ ← 8\nK ← BCD_L\n(BCD_L) ← 0]
repeat
  :C ← R1 ← 0\nC ← BCD_L ← C\n↑(R1)\nK ← BCD_L\nR2 ← $03\nR1 ← $0F $$ ((K))]
  if((R1)>=5) then
    :((K)) ← ((K)) + (R2)]
  else (NO)
  endif
  :R2 ← $30\nR1 ← $F0 $$ ((K))]
  if((R1)>=50) then
    :((K)) ← ((K)) + (R2)]
  else (NO)
  endif
:R1↓]
repeat while((J) == 0) is (NO)
:RR1↓]
:=RETORNAR;
```

## BCD_7SEG

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center
:=BCD_7SEG;
:J ← SEGMENT]
:R1 ← (BCD1) && $0F
(DISP4) ← ((J) + (R1))]
:R1 ← (BCD1)
0 → R1 → C
0 → R1 → C
0 → R1 → C
0 → R1 → C]
:(DISP3) ← ((J) + (R1))]
:R1 ← (BCD2) && $0F
(DISP2) ← ((J) + (R1))]
:R1 ← (BCD2)
0 → R1 → C
0 → R1 → C
0 → R1 → C
0 → R1 → C]
:(DISP1) ← ((J) + (R1))]
:=RETORNAR;
```

## Cargar_LCD

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=Cargar_LCD;
:R1 ← (ADD_L1)]
:Send_Command|
:(Cont_Delay) ← (D60uS)]
:Delay|
while(((J)+1)==0) is (NO)
  :R1 ← ((J))\nJ ← (J) + 1]
  :Send_Data|
  :(Cont_Delay) ← (D60uS)]
  :Delay|
endwhile
:R1 ← (ADD_L2)]
:Send_Command|
:(Cont_Delay) ← (D60uS)]
:Delay|
while(((K)+1)==0) is (NO)
  :R1 ← ((K))\nK ← (K) + 1]
  :Send_Data|
  :(Cont_Delay) ← (D60uS)]
  :Delay|
endwhile
:=RETORNAR;
```

## DELAY

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=DELAY;
repeat
repeat while(Cont_Delay == 0) is (NO)
:=RETORNAR;
```

## Send_Command

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=Send_Command;
:C ← 0]
:SEND|
:=RETORNAR;
```

## Send_Data

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=Send_Data;
:C ← 1]
:SEND|
:=RETORNAR;
```

## SEND

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=SEND;
:↑(R1)\n↑(CCR)\nR1 ← (R1) && $F0]
if(C == 1) then
  :R1 ← (R1) || $04]
endif
:0 → R1 → C\n0 → R1 → C]
:SEND_NIBB|
:R1↓\nR1 ← (R1) && $0F\nC ← R1 ← 0\nCCR↓\nC ← R1 ← C]
:SEND_NIBB|
:=RETORNAR;
```


```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=SEND_NIBB;
:PORTK ← (R1)\nPORTK.1 ← 1\nCont_Delay ← D260uS]
:DELAY|
:PORTK.1 ← 0]
:=RETORNAR;
```

## TAREA_TECLADO

Se cambia el valor de contador de rebotes a 100 (ms), ya que con 10 aún no se suprimen todos los rebotes (al menos en esta tarjeta).

```plantuml
@startuml
skinparam monochrome true

:=TAREA_TECLADO;
if(Cont_Reb == 0) then
  :MUX_TECLADO|
  if((Tecla) == $FF) then (SI)
    if(TCL_LISTA == 1) then
      :TCL_LEIDA ← 0\nTCL_LISTA ← 0]
      :FORMAR_ARRAY|
    else (NO)
    endif
  elseif(TCL_LEIDA == 1) then
      if((Tecla_IN) == (Tecla)) then
        :TCL_LISTA ← 1]
      else (NO)
        :(Tecla_IN) ← $FF\n(Tecla) ← $FF\nTCL_LEIDA ← 0\nTCL_LISTA ← 0]
      endif
  else (NO)
    :(Tecla_IN) ← (Tecla)\nTCL_LEIDA ← 1\n(Cont_Reb) ← 100]
  endif
else(NO)
endif
:=RETORNAR;
```
## MUX_TECLADO

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=MUX_TECLADO;
:R1 ← $EF\n(Patron) ← 0]
repeat
  :(Patron) ← (Patron) + 1]
  :(PORTA) ← (R1)\n(R2) ← 0\n↑(PORTA)]
  repeat
    if(((SP)) == 0) then
      :J ← Teclas\n(Tecla) ← ((Patron)*3 - 3 + (R2) + (J))\n↓R1]
      :=RETORNAR;
      detach
    endif
    -> NO;
    :0 → ((SP)) → C\nR2 ← (R2) + 1]
  repeat while((R2) == 3) is (NO)
  :↓R1\nC ← (R1) ← 0]
repeat while((Patron) == 5) is (NO)
:(Tecla) ← $FF]
:=RETORNAR;
```
## FORMAR_ARRAY

```plantuml
@startuml
skinparam monochrome true
skinparam defaultTextAlignment center

:=FORMAR_ARRAY;
if((Tecla_IN) == $0E) then
  if(Cont_TCL != 0) then
    :(Cont_TCL) ← 0\nARRAY_OK ← 1] 
  endif
elseif((Tecla_IN) == $0B) then
  if(Cont_TCL != 0) then
    :J ← Num_Array\n(Cont_TCL) ← (Cont_TCL) - 1\n((J) + (Cont_TCL)) ← $FF]
  endif
else
  :J ← Num_Array\n((J) + (Cont_TCL)) ← (Tecla_IN)\n(Cont_TCL) ← (Cont_TCL) + 1]
endif
:=RETORNAR;
```

