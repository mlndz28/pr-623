# Modo Libre

- No hace ni picha
- Mensaje de modo libre
- 7-seg display off
- Interrupciones deshabilitadas después de desplegar el mensaje

# Modo Configuración

- 3 > NumVueltas > 23
- se pueden realizar cambios a numVueltas
- numVueltas sale siempre en la pantalla
- Disp1 y Disp2 apagados

# Modo Competencia

- Msj Runmeter esperando
- 7seg display inicia apagado
- después de calcular la velocidad, se muestra la velocidad en la pantalla 100m antes ->  t_100 = 200m / Vel_prom 

- Desplegar velocidad y numVueltas en 7seg
- solo 1 ciclista: la lectura de los sensores tiene que estar inactiva desde que el ciclista pasa enfrente , hasta que se termina de desplegar la velocidad.
-  7seg disp se tiene que apagar luego de que se termina de presentar la velocidad del ciclista y mientras se calcula su velocidad en la sig vuelta
- despues de que el ciclista pasa la pantalla, mientras no se detecte nada en S1, se mantiene MSJ Inicial
- Cuando se detecta en S1, se pone CALCULANDO
- no se toma en cuenta ciclistas en sentido opuesto
- si se sale del rango la velocidad, el 7seg disp se pone Mensaje de Alerta
- para velocidades fuera de rango no se incrementa NumVueltas
- se debe habilitar de nuevo despues los sensores para seguir leyendo y hacer mas calculos de vueltas
- Después de calcular la cantidad definida de vueltas, se deshabilitan los sensores y no se hacen mas calculos de velocidad
- La última vuelta se completará cuando se haya terminado de desplegar el Mensaje de Competencia en el LCD, dicho mensaje deberá ser cambiado por el Mensaje Inicial. El operador deberá cambiar de modo y luego regresar a Modo Competencia si desea iniciar un nuevo ciclo de mediciones.
- Se puede suspender el modo competencia en antes de detectar S1, o antes de que el acumulador llegue a su max, y pasar a otro modo y se deben mantener guardados los datos hasta que se regrese al modo competencia
- Cada vez que el RunMeter 623 pase de Modo Competencia a cualquier otro modo se debe suspender cualquier cálculo en curso
- Además al ingresar a Modo Competencia se deben borrar todas las variables de cálculo que se utilizan en este modo.

# Modo Resumen

- despliega la velocidad promedio del ciclo de competencia
- Con el fin de que la variable VelProm sea de 1 byte la velocidad promedio debe ser actualizada en cada vuelta utilizando el contador de vueltas y la velocidad calculada.

