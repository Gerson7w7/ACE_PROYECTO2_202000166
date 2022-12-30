printLinea MACRO txt, color ; macro para poder imprimir cadenas de texto 'quemadas'
    ; cargamos en memoria las variables del segmento de datos 
    mov ax, @data
    mov ds, ax
    ; imprimimos en pantalla
    mov ah, 09h
    mov bl, color
    mov cx, lengthof txt - 1
    int 10h
    lea dx, txt
    int 21h
ENDM

clearPantalla MACRO
    mov ax, 03h
    int 10h
ENDM

printMenu MACRO ; macro para imprimir el menú principal
    printLinea ln, 0d ; imprimimos un salto de línea por cada linea
    printLinea ln, 0d
    printLinea ln, 0d
    printLinea ln, 0d
    printLinea intro, 5d
    printLinea ln, 0d
    printLinea intro2, 10d
    printLinea ln, 0d
    printLinea op1, 10d
    printLinea ln, 0d
    printLinea op2, 10d
    printLinea ln, 0d
    printLinea op3, 10d
    printLinea ln, 0d
    printLinea op4, 10d
    printLinea ln, 0d
    printLinea op5, 10d
    printLinea ln, 0d
    printLinea op6, 10d
    printLinea ln, 0d
    printLinea op7, 10d
    printLinea ln, 0d
    printLinea op8, 10d
    printLinea ln, 0d
    printLinea intro3, 10d 
    printLinea ln, 0d
    printLinea intro4, 10d 
ENDM

getChar MACRO ;macro para leer un char desde el teclado
    mov ah, 01h
    int 21h
ENDM

saveCoeficiente MACRO xn, var ; aquí leeremos los coeficientes de max 2 digitos
    LOCAL LNEGATIVO, LCAPTURAR, LPOSITIVO, RESTA, SALIR, LERROR
    mov ax, @data
    mov ds, ax
    ; imprimimos el coeficiente de quien se quiere
    printLinea xn, 7d
    printLinea dosPuntos, 7d
    ; capturamos el primer dígito del número (la unidad)
    mov ah, 01h
    int 21h
    ; primero miramos si se trata de un número negativo
    cmp al, '-'
    je LNEGATIVO
    ; miramos si pone el signo positivo
    cmp al, '+'
    je LPOSITIVO
    jmp LCAPTURAR

    LPOSITIVO:
        ; capturamos el primer dígito del número (la unidad)
        mov ah, 01h
        int 21h
        jmp LCAPTURAR

    LNEGATIVO:
        ; manejaremos la virable negativo como 0 = es positivo, 1 = es negativo
        mov al, negativo
        add al, 1
        mov negativo, al
        ; capturamos el primer dígito del número (la unidad)
        mov ah, 01h
        int 21h
        jmp LCAPTURAR

    LCAPTURAR:
        ; vamos a verificar que se trate de un número
        cmp al, '0'
        jl LERROR ; si no es un número salta a la etiqueta de error
        cmp al, '9'
        jg LERROR ; si no es un número salta a la etiqueta de error

        sub al, 30h ; hacemos un ajuste al registro al
        mov d, al
        ; capturamos el segundo dígito del número (la decena)
        mov ah, 01h
        int 21h
        ; vamos a verificar que se trate de un número
        cmp al, '0'
        jl LERROR ; si no es un número salta a la etiqueta de error
        cmp al, '9'
        jg LERROR ; si no es un número salta a la etiqueta de error

        sub al, 30h ; hacemos un ajuste al registro al
        mov u, al
        ; ahora multiplicamos las decenas * 10 
        mov al, d
        mov bl, 10
        mul bl
        ; sumamos la unidad a la multiplicación anterior para tener el número completo
        add al, u
        mov var, al ; guardamos la variable en var
        ; si es negativo, le restamos el número a 0
        mov al, negativo
        cmp al, 1
        je RESTA
        printLinea ln, 0d
        jmp SALIR

    RESTA:
        ; aquí hacemos que nuestro número sea negativo
        mov al, var
        neg al  ; aquí obtenemos el número negativo
        mov var, al
        ; volvemos a poner a negativo en 0
        mov al, negativo
        sub al, 1
        mov negativo, al 
        printLinea ln, 0d
        jmp SALIR

    LERROR:
        ; aquí imprimimos el error, que no se ha ingresado un número
        clearPantalla
        printLinea ln, 0d
        printLinea msgError, 5d
        jmp MENU

    SALIR:

ENDM

getCoeficiente MACRO var, xn ; macro para obtener los números guardados de la función
    LOCAL MOSTRAR, POSITIVO, LNEGATIVO, PONERX, NEGAR, SALIDA
    mov al, var
    cmp al, 0
    jg POSITIVO
    jl LNEGATIVO
    jmp SALIDA

    LNEGATIVO:
        printLinea menos, 7d
        ; negamos los negativos para poder mostrarlos en pantalla
        mov al, var
        neg al
        mov var, al
        ; y ponemos negativo en 1, para saber que son negativos y volverlos negar despues
        mov al, negativo
        add al, 1
        mov negativo, al 
        jmp MOSTRAR

    POSITIVO:
        printLinea mas, 7d
        jmp MOSTRAR

    MOSTRAR:
        mov al, var
        AAM ; instruccion de desempaquetado para dividir el número en 2 partes
        mov bx, ax
        ; manejamos las decenas del número
        mov ah, 02h
        mov dl, bh
        add dl, 30h ; aquí convertimos el dígito de las decenas y lo convertimos en ascii
        int 21h
        ; manejamos las unidades del número
        mov ah, 02h
        mov dl, bl 
        add dl, 30h ; aquí convertimos el dígito de las unidades en ascii 
        int 21h
        ; verificamos si es un negativo, para devolverle su signo
        mov al, negativo
        cmp al, 1
        je NEGAR
        ; comparamos si la x^n es diferente de x^0, ya que esta solo se motrará el número
        mov al, xn
        cmp al, '-'
        jnz PONERX
        jmp SALIDA 
    
    PONERX: ; imprimimos x^n
        printLinea xn, 7d
        jmp SALIDA

    NEGAR:
        ; negamos otra vez el var para guardarlo con su signo
        mov al, var
        neg al
        mov var, al
        ; y ponemos negativo en 1, para saber que son negativos y volverlos negar despues
        mov al, negativo
        sub al, 1
        mov negativo, al 
        ; comparamos si la x^n es diferente de x^0, ya que esta solo se motrará el número
        mov al, xn
        cmp al, '-'
        jnz PONERX
        jmp SALIDA

    SALIDA:
ENDM

opcion1 MACRO ; opcion 1 que debe mostrar la función almacenada
    clearPantalla
    printLinea ln, 0d
    printLinea op1Intro, 10d
    printLinea ln, 0d
    ; ingresamos x5
    saveCoeficiente op1x5, x5
    ; ingresamos x4
    saveCoeficiente op1x4, x4
    ; ingresamos x3
    saveCoeficiente op1x3, x3
    ; ingresamos x2
    saveCoeficiente op1x2, x2
    ; ingresamos x1
    saveCoeficiente op1x1, x1
    ; ingresamos x0
    saveCoeficiente op1x0, x0
    jmp MENU
ENDM

opcion2 MACRO ; opción para mostrar la función almacenada
    clearPantalla
    printLinea ln, 0d
    printLinea op2Intro, 10d
    printLinea ln, 0d
    getCoeficiente x5, op1x5 ; imprimimos el coeficiente de x5
    getCoeficiente x4, op1x4 ; imprimimos el coeficiente de x4
    getCoeficiente x3, op1x3 ; imprimimos el coeficiente de x3
    getCoeficiente x2, op1x2 ; imprimimos el coeficiente de x2
    getCoeficiente x1, op1x1 ; imprimimos el coeficiente de x1
    getCoeficiente x0, menos ; imprimimos el coeficiente de x0
    jmp MENU
ENDM

getDerivada MACRO var, xn, dvar ; macro para obtener la derivada
    LOCAL EXP4, EXP3, EXP2, EXP1, EXP0, SALIDA
    ; var = número a multiplicar, xn = número multiplicador
    ; realizamos la multiplicacion
    mov al, var
    mov bl, xn
    mul bl 
    mov dvar, al 
    ; restamos 1 al multiplicador xn
    mov al, xn
    sub al, 1
    ; comparamos para saber que x^n le toca
    cmp al, 4
    je EXP4
    cmp al, 3
    je EXP3
    cmp al, 2
    je EXP2
    cmp al, 1
    je EXP1
    cmp al, 0
    je EXP0
    jmp SALIDA
    ; mostramos el coeficiente correspondiente
    EXP4:
        getCoeficiente dvar, op1x4
        jmp SALIDA

    EXP3:
        getCoeficiente dvar, op1x3  
        jmp SALIDA
    
    EXP2:
        getCoeficiente dvar, op1x2
        jmp SALIDA
    
    EXP1:
        getCoeficiente dvar, op1x1
        jmp SALIDA
    
    EXP0:
        getCoeficiente dvar, menos
        jmp SALIDA

    SALIDA: ; salimos del macro

ENDM

opcion3 MACRO ; macro para mostrar la derivada de la función
    clearPantalla
    printLinea ln, 0d
    printLinea op3Intro, 10d
    printLinea ln, 0d
    mov multiplicador, 5
    getDerivada x5, multiplicador, dx4 ; imprimimos el coeficiente de x5
    mov multiplicador, 4
    getDerivada x4, multiplicador, dx3 ; imprimimos el coeficiente de x4
    mov multiplicador, 3
    getDerivada x3, multiplicador, dx2 ; imprimimos el coeficiente de x3
    mov multiplicador, 2
    getDerivada x2, multiplicador, dx1 ; imprimimos el coeficiente de x2
    mov multiplicador, 1
    getDerivada x1, multiplicador, dx0 ; imprimimos el coeficiente de x1
    jmp MENU
ENDM

getIntegral MACRO var, xn, svar ; macro para obtener la integral
    LOCAL LOG, LOG2, EXP6, EXP5, EXP4, EXP3, EXP2, EXP1, NEGAR, NEGAR2, SALIDA
    ; revisamos si se trata de un número negativo, para pasarlo a positivo para divir
    mov al, var
    cmp al, 0
    jl NEGAR
    jmp LOG

    NEGAR:
        ; ponemos en 1 el negativo para saber que es un número negativo 
        mov al, negativo 
        add al, 1
        mov negativo, al 
        ; negamos el número para tener su positivo 
        mov al, var 
        neg al 
        mov var, al
        jmp LOG 
    
    NEGAR2:
        ; ponemos en 1 el negativo para saber que es un número negativo 
        mov al, negativo 
        sub al, 1
        mov negativo, al 
        ; negamos el número para tener su positivo 
        mov al, var 
        neg al 
        mov var, al
        ; negamos el número para tener su positivo 
        mov al, svar 
        neg al 
        mov svar, al
        jmp LOG2

    LOG:
        ; var = número a dividir, xn = número divisor + 1
        ; primero realizamos la suma del exponente
        mov al, xn
        add al, 1
        mov xn, al 
        ; realizamos la division
        xor ah, ah ; limpiamos ax
        mov bl, xn
        mov al, var
        div bl 
        mov svar, al 
        ; verificamos si es un número negativo para devolver su signo 
        mov al, negativo 
        cmp al, 1 
        je NEGAR2
        jmp LOG2

    LOG2:
        ; comparamos para saber que x^n le toca
        mov al, xn
        cmp al, 6
        je EXP6
        cmp al, 5
        je EXP5
        cmp al, 4
        je EXP4
        cmp al, 3
        je EXP3
        cmp al, 2
        je EXP2
        cmp al, 1
        je EXP1
        jmp SALIDA
    ; mostramos el coeficiente correspondiente
    EXP6:
        getCoeficiente svar, op1x6
        jmp SALIDA

    EXP5:
        getCoeficiente svar, op1x5
        jmp SALIDA
    
    EXP4:
        getCoeficiente svar, op1x4
        jmp SALIDA
    
    EXP3:
        getCoeficiente svar, op1x3
        jmp SALIDA
    
    EXP2:
        getCoeficiente svar, op1x2
        jmp SALIDA

    EXP1:
        getCoeficiente svar, op1x1
        printLinea constante, 7d
        jmp SALIDA

    SALIDA: ; salimos del macro
ENDM

opcion4 MACRO ; macro para la función 4
    clearPantalla
    printLinea ln, 0d
    printLinea op4Intro, 10d
    printLinea ln, 0d
    mov multiplicador, 5
    getIntegral x5, multiplicador, sx6 ; imprimimos el coeficiente de x5
    mov multiplicador, 4
    getIntegral x4, multiplicador, sx5 ; imprimimos el coeficiente de x4
    mov multiplicador, 3
    getIntegral x3, multiplicador, sx4 ; imprimimos el coeficiente de x3
    mov multiplicador, 2
    getIntegral x2, multiplicador, sx3 ; imprimimos el coeficiente de x2
    mov multiplicador, 1
    getIntegral x1, multiplicador, sx2 ; imprimimos el coeficiente de x1
    mov multiplicador, 0
    getIntegral x0, multiplicador, sx1 ; imprimimos el coeficiente de x1
    jmp MENU
ENDM

quintaM MACRO const 
    LOCAL CICLO1, CICLO2, PASO1, CICLO3, CICLO4, PASO2, CICLO5, CICLO6, SALIDA
    ; pasamos const a ax
    mov al, const
    cbw
    mov constAux, ax
    ; pintar un pixel (prueba)
    mov cx, 260 ; x
    mov dx, 480 ; y
    mov stopG, 252 ; stop para saber cuando parar
    mov ax, stopG
    sub ax, constAux ; aquí hacemos el ajuste de la constante para saber si arriba o abajo del origen
    mov stopG, ax
    mov aux, 470

    CICLO1:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        dec dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO2 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1
        jmp PASO1

    CICLO2: 
        inc cx ; incrementamos en x
        mov ax, aux 
        sub ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1

    PASO1:
        mov aux, cx 
        mov ax, aux 
        add ax, 3
        mov aux, ax
        mov stopG, 350

    CICLO3:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc cx ; incrementamos en x
        cmp cx, aux ; comparamos para subir en y
        je CICLO4 
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO3
        jmp PASO2

    CICLO4: 
        dec dx ; incrementamos en y
        mov ax, aux 
        add ax, 3 ; guardamos en aux, para saber cuando subir otra vez en y
        mov aux, ax
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO3

    PASO2:
        mov aux, dx 
        mov ax, aux 
        sub ax, 10
        mov aux, ax
        mov stopG, 0

    CICLO5:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        dec dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO6 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
        jmp SALIDA

    CICLO6: 
        inc cx ; incrementamos en x
        mov ax, aux 
        sub ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
    
    SALIDA:
ENDM 

cuartaM MACRO const 
    LOCAL CICLO1, CICLO2, PASO1, CICLO3, CICLO4, PASO2, CICLO5, CICLO6, SALIDA
    ; pasamos const a ax
    mov al, const
    cbw
    mov constAux, ax
    ; pintar un pixel (prueba)
    mov cx, 260 ; x
    mov dx, 0 ; y
    mov stopG, 257 ; stop para saber cuando parar
    mov ax, stopG
    sub ax, constAux ; aquí hacemos el ajuste de la constante para saber si arriba o abajo del origen
    mov stopG, ax
    mov aux, 10

    CICLO1:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO2 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1
        jmp PASO1

    CICLO2: 
        inc cx ; incrementamos en x
        mov ax, aux 
        add ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1

    PASO1:
        mov aux, cx 
        mov ax, aux 
        add ax, 3
        mov aux, ax
        mov stopG, 330

    CICLO3:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc cx ; incrementamos en x
        cmp cx, aux ; comparamos para subir en y
        je CICLO4 
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO3
        jmp PASO2

    CICLO4: 
        dec dx ; incrementamos en y
        mov ax, aux 
        add ax, 2 ; guardamos en aux, para saber cuando subir otra vez en y
        mov aux, ax
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO3

    PASO2:
        mov aux, dx 
        mov ax, aux 
        sub ax, 10
        mov aux, ax
        mov stopG, 0

    CICLO5:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        dec dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO6 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
        jmp SALIDA

    CICLO6: 
        inc cx ; incrementamos en x
        mov ax, aux 
        sub ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
    
    SALIDA:
ENDM 

terceraM MACRO const 
    LOCAL CICLO1, CICLO2, PASO1, CICLO3, CICLO4, PASO2, CICLO5, CICLO6, SALIDA
    ; pasamos const a ax
    mov al, const
    cbw
    mov constAux, ax
    ; pintar un pixel (prueba)
    mov cx, 290 ; x
    mov dx, 480 ; y
    mov stopG, 248 ; stop para saber cuando parar
    mov ax, stopG
    sub ax, constAux ; aquí hacemos el ajuste de la constante para saber si arriba o abajo del origen
    mov stopG, ax
    mov aux, 470

    CICLO1:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        dec dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO2 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1
        jmp PASO1

    CICLO2: 
        inc cx ; incrementamos en x
        mov ax, aux 
        sub ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1

    PASO1:
        mov aux, cx 
        mov ax, aux 
        add ax, 3
        mov aux, ax
        mov stopG, 327

    CICLO3:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc cx ; incrementamos en x
        dec dx ; incrementamos en y
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO3
        jmp PASO2

    PASO2:
        mov aux, dx 
        mov ax, aux 
        sub ax, 10
        mov aux, ax
        mov stopG, 0

    CICLO5:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        dec dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO6 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
        jmp SALIDA

    CICLO6: 
        inc cx ; incrementamos en x
        mov ax, aux 
        sub ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
    
    SALIDA:
ENDM

segundaM MACRO const 
    LOCAL CICLO1, CICLO2, PASO1, CICLO3, CICLO4, PASO2, CICLO5, CICLO6, SALIDA
    ; pasamos const a ax
    mov al, const
    cbw
    mov constAux, ax
    ; pintar un pixel (prueba)
    mov cx, 290 ; x
    mov dx, 0 ; y
    mov stopG, 240 ; stop para saber cuando parar
    mov ax, stopG
    sub ax, constAux ; aquí hacemos el ajuste de la constante para saber si arriba o abajo del origen
    mov stopG, ax
    mov aux, 10

    CICLO1:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO2 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1
        jmp PASO1

    CICLO2: 
        inc cx ; incrementamos en x
        mov ax, aux 
        add ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO1

    PASO1:
        mov aux, cx 
        mov ax, aux 
        add ax, 3
        mov aux, ax
        mov stopG, 325

    CICLO3:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc cx ; incrementamos en x
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO3
        jmp PASO2

    PASO2:
        mov aux, dx 
        mov ax, aux 
        sub ax, 10
        mov aux, ax
        mov stopG, 0

    CICLO5:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        dec dx ; incrementamo en y el siguiente pixel
        cmp dx, aux ; comparamos para subir en x
        je CICLO6 
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
        jmp SALIDA

    CICLO6: 
        inc cx ; incrementamos en x
        mov ax, aux 
        sub ax, 10 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp dx, stopG ; comparamos para salir del cilo
        jne CICLO5
    
    SALIDA:
ENDM 

primeraM MACRO const 
    LOCAL CICLO1, CICLO2, VERIFICAR, SALIDA
    ; pasamos const a ax
    mov al, const
    cbw
    mov constAux, ax
    ; pintar un pixel (prueba)
    mov cx, 70 ; x
    mov dx, 480 ; y
    mov stopG, 640 ; stop para saber cuando parar
    sub cx, constAux ; aquí hacemos el ajuste de la constante para saber si arriba o abajo del origen
    mov aux, 80
    mov ax, aux 
    sub ax, constAux
    mov aux, ax

    CICLO1:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc cx ; incrementamo en y el siguiente pixel
        cmp cx, aux ; comparamos para subir en x
        je CICLO2 
        cmp cx, stopG ; comparamos para salir del cilo
        jne VERIFICAR
        jmp SALIDA

    VERIFICAR:
        cmp dx, 0 ; comparamos para salir del cilo
        jne CICLO1
        jmp SALIDA

    CICLO2: 
        dec dx ; incrementamos en x
        mov ax, aux 
        add ax, 1 ; guardamos en aux, para saber cuando subir otra vez en x
        mov aux, ax
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO1
    
    SALIDA:
ENDM 

sinCeroM MACRO const 
    LOCAL CICLO1
    ; pasamos const a ax
    mov al, const
    cbw
    mov constAux, ax
    ; pintar un pixel (prueba)
    mov cx, 0 ; x
    mov dx, 240 ; y
    sub dx, constAux ; ajuste para saber si está arriba o abajo del origen 
    mov stopG, 640 ; stop para saber cuando parar

    CICLO1:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        int 10h ; aquí pintamos
        inc cx ; incrementamo en y el siguiente pixel
        cmp cx, stopG ; comparamos para salir del cilo
        jne CICLO1
ENDM 

graficando MACRO var, nx0 ; aquí graficamos coeficiente por coeficiente 
    LOCAL QUINTA, CUARTA, TERCERA, SEGUNDA, PRIMERA, SIN, SALIDA
    ; RESETEAMOS CONTADORES 
    mov xmax, 0 
    mov ymax, 0
    ; cambiamos color 
    mov color, 5
    ; vemos de que grado es
    mov al, var 
    cmp al, 6
    je CUARTA
    mov al, var 
    cmp al, 5
    je QUINTA
    cmp al, 4
    je CUARTA
    cmp al, 3
    je TERCERA
    cmp al, 2
    je SEGUNDA
    cmp al, 1
    je PRIMERA 
    cmp al, 0
    je SIN 

    QUINTA: 
        quintaM nx0
        jmp SALIDA

    CUARTA: 
        cuartaM nx0
        jmp SALIDA

    TERCERA: 
        terceraM nx0
        jmp SALIDA
    
    SEGUNDA: 
        segundaM nx0
        jmp SALIDA

    PRIMERA: 
        primeraM nx0
        jmp SALIDA
    
    SIN:
        sinCeroM nx0
        jmp SALIDA

    SALIDA:
    
ENDM

opGraph1 MACRO ; aqui graficamos la funcion normal
    LOCAL GCINCO, GCUATRO, GTRES, GDOS, GUNO, GCERO, SALIDA
    mov al, x5
    cmp al, 0
    jne GCINCO
    mov al, x4
    cmp al, 0
    jne GCUATRO
    mov al, x3
    cmp al, 0
    jne GTRES
    mov al, x2
    cmp al, 0
    jne GDOS
    mov al, x1
    cmp al, 0
    jne GUNO
    jmp GCERO

    GCINCO:
        graficando 5, x0
        jmp SALIDA

    GCUATRO:
        graficando 4, x0
        jmp SALIDA

    GTRES:
        graficando 3, x0
        jmp SALIDA

    GDOS:
        graficando 2, x0
        jmp SALIDA

    GUNO:
        graficando 1, x0
        jmp SALIDA

    GCERO:
        graficando 0, x0
        jmp SALIDA

    SALIDA:
ENDM

opGraph2 MACRO
    LOCAL GCUATRO, GTRES, GDOS, GUNO, GCERO, SALIDA
    mov al, dx4
    cmp al, 0
    jne GCUATRO
    mov al, dx3
    cmp al, 0
    jne GTRES
    mov al, dx2
    cmp al, 0
    jne GDOS
    mov al, dx1
    cmp al, 0
    jne GUNO
    jmp GCERO

    GCUATRO:
        graficando 4, dx0
        jmp SALIDA

    GTRES:
        graficando 3, dx0
        jmp SALIDA

    GDOS:
        graficando 2, dx0
        jmp SALIDA

    GUNO:
        graficando 1, dx0
        jmp SALIDA

    GCERO:
        graficando 0, dx0
        jmp SALIDA

    SALIDA:
ENDM

opGraph3 MACRO
    LOCAL GSEIS, GCINCO, GCUATRO, GTRES, GDOS, GUNO, SALIDA
    mov al, sx6
    cmp al, 0
    jne GSEIS
    mov al, sx5
    cmp al, 0
    jne GCINCO
    mov al, sx4
    cmp al, 0
    jne GCUATRO
    mov al, sx3
    cmp al, 0
    jne GTRES
    mov al, sx2
    cmp al, 0
    jne GDOS
    mov al, sx1
    cmp al, 0
    jne GUNO

    GSEIS:
        graficando 6, 0
        jmp SALIDA

    GCINCO:
        graficando 5, 0
        jmp SALIDA

    GCUATRO:
        graficando 4, 0
        jmp SALIDA

    GTRES:
        graficando 3, 0
        jmp SALIDA

    GDOS:
        graficando 2, 0
        jmp SALIDA

    GUNO:
        graficando 1, 0
        jmp SALIDA

    SALIDA:
ENDM

modoGrafico MACRO var
    LOCAL HORIZONTAL, VERTICAL, GUNO, GDOS, GTRES, SALIDA
    clearPantalla
    ; RESETEAMOS CONTADORES 
    mov xmax, 0 
    mov ymax, 0
    mov color, 14
    ; cambiamos a modo gráfico
    mov ah, 00
    mov al, 12h
    int 10h ; interrupcion bios

    ; pintar un pixel (prueba)
    mov cx, 0 ; columna del pixel x
    HORIZONTAL:
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        mov dx, y ; renglon y
        int 10h
        inc cx 
        inc xmax 
        cmp xmax, 640
        jne HORIZONTAL

    mov dx, 0
    VERTICAL: 
        mov ah, 0ch ; ppinta un pixel
        mov al, color ; color
        mov bh, 0h ; pagina 0
        mov cx, x ; renglon y
        int 10h
        inc dx 
        inc ymax 
        cmp ymax, 480
        jne VERTICAL

    mov al, var 
    cmp al, 1
    je GUNO 
    cmp al, 2
    je GDOS
    cmp al, 3
    je GTRES 

    GUNO:
        opGraph1
        jmp SALIDA

    GDOS: 
        opGraph2
        jmp SALIDA

    GTRES:
        opGraph3 
        jmp SALIDA

    SALIDA:
ENDM

opcion5 MACRO ; macro para la función 5
    LOCAL GUNO, GDOS, GTRES, GNOOP, GMENU, SALIDA 
    clearPantalla
    GMENU:
        printLinea ln, 0d
        printLinea graph, 10d
        printLinea ln, 0d
        printLinea graph2, 10d
        printLinea ln, 0d
        printLinea graph3, 10d
        printLinea ln, 0d
        printLinea graph4, 10d
        printLinea ln, 0d
        printLinea graph5, 10d
        printLinea ln, 0d
        getChar
        cmp al, '1' ; grafica 1
        je GUNO
        cmp al, '2' ; grafica 2
        je GDOS
        cmp al, '3' ; grafica 3
        je GTRES
        cmp al, '4' ; grafica 4
        je SALIDA
        jne GNOOP

    GUNO: ; nos vamos a la opcion uno
        mov multiplicador, 1 
        modoGrafico multiplicador
        jmp GMENU
    GDOS: ; nos vamos a la opcion dos
        mov multiplicador, 2
        modoGrafico multiplicador
        jmp GMENU
    GTRES: ; nos vamos a la opcion tres
        mov multiplicador, 3
        modoGrafico multiplicador
        jmp GMENU
    SALIDA: ; nos vamos a la opcion cuatro (salida)
        clearPantalla
        jmp MENU
    GNOOP:
        clearPantalla
        printLinea ln, 0d
        printLinea opErr, 3d
        jmp MENU ; loop para regresar a MENU
ENDM

.model small 
.stack ; segmento de pila
.data ; segmento de datos
    ; variables que usaremos para mostrar texto en la consola
    ln      db 0ah, '$' ;salto de línea
    opErr   db "No se ha reconocido la opcion ingresada, intente de nuevo.", "$"
    ; menú principal
    intro   db "================ CALCULADORA ================","$"
    intro2  db "Gerson Ruben Quiroa del Cid  - Carnet: 202000166 ", "$"
    op1     db "     (1) Ingresar funcion", "$"
    op2     db "     (2) Imprimir la funcion almacenada", "$"
    op3     db "     (3) Imprimir derivada de la funcion", "$"
    op4     db "     (4) Imprimir integral de la funcion", "$"
    op5     db "     (5) Graficar funcion", "$"
    op6     db "     (6) Ceros por metodo de Newton", "$"
    op7     db "     (7) Ceros por metodo de Steffensen", "$"
    op8     db "     (8) Salir de la aplicacion", "$"
    intro3  db "Ingrese el numero de la opcion que desea.", "$"
    intro4  db "    >", "$"
    
    graph   db "================ GRAFICAR FUNCION ================","$"
    graph2  db "     (5.1) Funcion original", "$"
    graph3  db "     (5.2) Funcion derivada", "$"
    graph4  db "     (5.3) Funcion integral", "$"
    graph5  db "     (5.4) Salir al menu principal", "$"

    op1Intro    db "Ingrese la funcion que desee guardar por coeficintes. Ingresar solo numero enteros", "$"
    op1x6       db "X^6 ", "$"
    op1x5       db "X^5 ", "$"
    op1x4       db "X^4 ", "$"
    op1x3       db "X^3 ", "$"
    op1x2       db "X^2 ", "$"
    op1x1       db "X^1 ", "$"
    op1x0       db "X^0 ", "$"
    dosPuntos   db ": ", "$"

    op2Intro    db "La funcion almacenada es la siguiente f(x) = ", "$"
    mas         db "+", "$"
    menos       db "-", "$"

    op3Intro    db "La derivada de la funcion almacenada es la siguiente (d/dx)f(x) = ", "$"

    op4Intro    db "La integral de la funcion almacenada es la siguiente SF(x) = ", "$"
    constante   db " + C", "$"

    graf1Intro  db "Funcion original: ", "$"

    graf2Intro  db "Funcion derivada:", "$"

    graf3Intro  db "Funcion integral:", "$"

    msgIteracionMax     db "Ingrese el numero de iteraciones maximo", "$"
    msgCoefTolerancia   db "Ingrese el coeficiente de la tolerancia", "$"
    msgGradTolerancia   db "Ingrese el grado de la tolerancia", "$"
    msgLimSuperior      db "Ingrese el limite superior", "$"
    msgLimInferior      db "Ingrese el limite inferior", "$"
    limError            db "ERROR. El limite inferior deberia de ser mas pequenio que el limite superior.", "$"
    op6Intro        db "================ Ceros por metodo de Newton ================", "$"
    op7Intro        db "================ Ceros por metodo de Steffensen ================", "$"
    apartado        db "================================================================", "$"
    msgIteracion    db "ITERACION no.: ", "$"
    msgValInicial   db "VALOR INICIAL Xn: ", "$"
    msgErrorT       db "ERROR: ", "$"
    msgCero         db "Xn+1: ", "$"
    

    outro       db "Presione la tecla r para regresar.", "$"

    msgError    db "ERROR. Se esperaba que ingrese un numero de 0 a 9, por favor intente de nuevo.", "$"
    enProceso   db "Estamos en proceso de construccion :D", "$"

    u           db 0 ; unidad del número
    d           db 0 ; decena del número
    negativo    db 0 ; 0 = numero positivo, 1 = numero negativo
    multiplicador db 0
    ; funcion normal
    x5          db 0 ; coeficiente para x^5
    x4          db 0 ; coeficiente para x^4
    x3          db 0 ; coeficiente para x^3
    x2          db 0 ; coeficiente para x^2
    x1          db 0 ; coeficiente para x^1
    x0          db 0 ; coeficiente para x^0
    ; derivada
    dx4          db 0 ; coeficiente para x^5
    dx3          db 0 ; coeficiente para x^4
    dx2          db 0 ; coeficiente para x^3
    dx1          db 0 ; coeficiente para x^2
    dx0          db 0 ; coeficiente para x^1
    ; integral
    sx6          db 0 ; coeficiente para x^5
    sx5          db 0 ; coeficiente para x^4
    sx4          db 0 ; coeficiente para x^3
    sx3          db 0 ; coeficiente para x^2
    sx2          db 0 ; coeficiente para x^1
    sx1          db 0 ; coeficiente para x^0
    ; params método numérico
    iteracionMax    db 0 ; iteraciones máxima
    coefTolerancia  db 0 ; Coeficiente -> 5x10^-3
    gradTolerancia  db 0 ; 5x10^-3 <- grado
    getError        db 0
    limSuperior     db 0 ; límite superior
    limInferior     db 0 ; límite inferior
    cero            db 0 ; solución por los métodos 
    divAux          db 0 
    potencia        db 0
    valFn           db 0 ; valor de la funcion normal
    valDfn          db 0 ; valor de la función derivada
    errorIt         db 0 ; error de la iteracion
    iteracion       db 0 ; número de la iteracion
    ; MODO GRAFICO
    x        dw (320) ; pos en x 
    y        dw (240) ; pos en y
    xmax     dw (0) ; 640 max anchura
    ymax     dw (0) ; 480 max alto
    color    db (14) ; color amarillo
    aux      dw (0) 
    constAux dw (0)
    stopG    dw (0) ; para saber cuando parar en cada ciclo
    vid      db ?	; Salvamos el modo de video :) 

.code ; segmento de código
    main PROC ; proceso main
    clearPantalla ; limpiamos la consola
    MENU:
        printMenu
        getChar
        cmp al, '1' ; comparamos si se seleccionó la op 1
        je UNO
        cmp al, '2' ; comparamos si se seleccionó la op 2
        je DOS
        cmp al, '3' ; comparamos si se seleccionó la op 3
        je TRES
        cmp al, '4' ; comparamos si se seleccionó la op 4
        je CUATRO
        cmp al, '5' ; comparamos si se seleccionó la op 5
        je CINCO
        cmp al, '6' ; comparamos si se seleccionó la op 6
        je SEIS
        cmp al, '7' ; comparamos si se seleccionó la op 7
        je SIETE
        cmp al, '8' ; comparamos si se seleccionó la op 8
        je SALIDA
        jne NOOP

    UNO: ; nos vamos a la opcion uno
        opcion1
    
    DOS: ; nos vamos a la opcion dos
        opcion2
    
    TRES: ; nos vamos a la opcion tres
        opcion3
    
    CUATRO: ; nos vamos a la opcion cuatro
        opcion4
    
    CINCO: ; nos vamos a la opcion cinco
        opcion5

    SEIS: ; nos vamos a la opcion seis
        ;opcion6

    SIETE: ; nos vamos a la opcion siete
        clearPantalla
        printLinea ln, 0d
        printLinea enProceso, 10d
        jmp MENU
    
    SALIDA: ; salimos del programa
        .exit

    NOOP:
        clearPantalla
        printLinea ln, 0d
        printLinea opErr, 3d
        jmp MENU ; loop para regresar a MENU

    main ENDP ; finaliza proceso
END main ; termina programa