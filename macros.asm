; getParams MACRO ; parámetros para realizar los métodos numéricos
;     LOCAL LERROR, SALIDA
;     mov ax, @data
;     mov ds, ax
;     ; primero pediremos el númerom máximo de iteraciones
;     saveCoeficiente msgIteracionMax, iteracionMax
;     ; primero pediremos el coeficiente de tolerancia
;     saveCoeficiente msgCoefTolerancia, coefTolerancia
;     ; primero pediremos el grado de tolerancia
;     saveCoeficiente msgGradTolerancia, gradTolerancia
;     ; primero pediremos el límite superior
;     saveCoeficiente msgLimSuperior, limSuperior
;     ; primero pediremos el límite inferior
;     saveCoeficiente msgLimInferior, limInferior
;     ; ahora verificamos que el límite superior sea mayor al límite inferior
;     mov al, limSuperior
;     cmp al, limInferior
;     jl LERROR
;     ; negamos el exponente 
;     mov gradTolerancia, al 
;     mov multiplicador, 1
;     potenciaM multiplicador, gradTolerancia
;     mov al, coefTolerancia
;     mov bl, potencia 
;     mul bl 
;     mov getError, al
;     jmp SALIDA

;     LERROR:
;         clearPantalla
;         printLinea limError, 5d
;         jmp SALIDA

;     SALIDA:
; ENDM

; potenciaM MACRO base, exp ; macro para realizar las potencias de las funciones
;     LOCAL CICLO
;     mov al, base 
;     mov potencia, al 
;     ; creamos un ciclo para representar la potencia
;     CICLO:
;         ; aquí realizamos la multiplicacion y la guardamos en la variable potencia
;         mov al, potencia
;         mov bl, base
;         mul bl
;         mov potencia, al
;         ; restamos en 1 al exp 
;         mov al, exp 
;         sub al, 1 
;         mov exp, al
;         ; si llega a 0 el exponente, salimos del loop
;         mov al, exp 
;         cmp al, 0
;         jg CICLO
; ENDM

; fxn MACRO exp, xn ; macro para calcular la funcion f(x)
;     ; Cnx^n
;     potenciaM limInferior, exp ; aquí caculamos x^n
;     mov al, xn 
;     mov bl, potencia 
;     imul bl ; aquí multiplicamos el coeficiente por el x correspondient
;     add al, valFn
;     mov valFn, al
; ENDM

; dfxn MACRO exp, xn ; macro para calcular la funcion f'(x)
;     ; Cnx^n
;     potenciaM limInferior, exp ; aquí caculamos x^n
;     mov al, xn 
;     mov bl, potencia 
;     imul bl ; aquí multiplicamos el coeficiente por el x correspondient
;     add al, valDfn
;     mov valDfn, al
; ENDM

; printMetodo MACRO ; macro para los métodos numéricos por cada iteracion
;     ; ITERACION NO: 
;     printLinea ln, 0d
;     printLinea msgIteracion, 10d
;     getCoeficiente iteracion, menos
;     ; VALOR INICIAL Xn:
;     printLinea ln, 0d
;     printLinea msgValInicial, 10d
;     getCoeficiente limInferior, menos
;     ; ERROR
;     printLinea ln, 0d
;     printLinea msgErrorT, 10d
;     getCoeficiente errorIt, menos
;     ; CERO ACTUAL
;     printLinea ln, 0d
;     printLinea msgCero, 10d
;     getCoeficiente cero, menos
;     ; SEPARACION: 
;     printLinea ln, 0d
;     printLinea apartado, 10d
; ENDM

; metodoNewton MACRO 
;     LOCAL CICLO, VERIFICACION, SALIDA

;     CICLO:  
;         ; obtenemos f(xn)
;         ; llevamos la cuenta de las iteracion
;         mov al, iteracion 
;         add al, 1
;         mov iteracion, al
;         ; aquí efectuamos la op de C5x^5
;         mov multiplicador, 4
;         fxn multiplicador, x5
;         ; aquí efectuamos la op de C4x^4
;         mov multiplicador, 3
;         fxn multiplicador, x4
;         ; aquí efectuamos la op de C3x^3
;         mov multiplicador, 2
;         fxn multiplicador, x3
;         ; aquí efectuamos la op de C2x^2
;         mov multiplicador, 1
;         fxn multiplicador, x2
;         ; aquí efectuamos la op de C1x^1
;         mov multiplicador, 0
;         fxn multiplicador, x1
;         ; aquí ya solo sumamos el termino independiente
;         mov al, valFn
;         add al, x0
;         mov valFn, al 
;         ; obtenemos f'(xn)
;         ; aquí efectuamos la op de C4x^4
;         mov multiplicador, 3
;         dfxn multiplicador, dx4
;         ; aquí efectuamos la op de C3x^3
;         mov multiplicador, 2
;         dfxn multiplicador, dx3
;         ; aquí efectuamos la op de C2x^2
;         mov multiplicador, 1
;         dfxn multiplicador, dx2
;         ; aquí efectuamos la op de C1x^1
;         mov multiplicador, 0
;         dfxn multiplicador, dx1
;         ; aquí ya solo sumamos el termino independiente
;         mov al, valDfn
;         add al, dx0
;         mov valDfn, al 
;         ; ahora tenemos que dividir f(x)/f'(x)
;         xor ah, ah
;         mov bl, valDfn
;         mov al, valFn
;         idiv bl
;         mov divAux, al
;         ; ahora lo restamos x - f(x)/f'(x)
;         mov al, cero 
;         sub al, divAux
;         mov cero, al 
;         ; ahora calculamos el error
;         mov bl, cero 
;         sub bl, limInferior
;         mov errorIt, al 
;         ; ahora imprimimos la iteracion actual
;         printMetodo
;         ; capturamos un caracter solamente para que pase a la siguiente iteracion
;         mov ah, 01h
;         int 21h
;         ; ponemos el nuevo valor al limite inferior
;         mov al, cero
;         mov limInferior, al
;         ; ahora comparamos el lim superior para ver si volvemos a iterar o ya no
;         mov al, limInferior
;         cmp al, limSuperior
;         je SALIDA
;         jg SALIDA
;         ; ahora comparamos el error para ver si volvemos a iterar o ya no
;         mov al, iteracion
;         cmp al, iteracionMax
;         je SALIDA
;         jg SALIDA 
;         jmp CICLO

;     SALIDA:
; ENDM

; opcion6 MACRO ; macro para la función 6
;     mov valFn, 0
;     mov valDfn, 0
;     mov errorIt, 0
;     mov iteracion, 0
;     mov cero, 0
;     clearPantalla
;     printLinea ln, 0d
;     printLinea op6Intro, 10d
;     printLinea ln, 0d
;     ; obtenemos los parámetros
;     getParams
;     clearPantalla
;     ; ahora procedemos con el método
;     metodoNewton
;     jmp MENU
; ENDM