@ Vários macros

@ Acessa a coluna dos digitos no display
.macro digits 
    @ 0 0 1 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOn D5 @ DB5 = 1
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

@ Divisão de inteiros
@ N - Numerador
@ D - Denominador
.macro division N D
    @ r0 - resultado
    @ r1 - resto
    @ r2 - denominador
    mov r10, #0 
    mov r11, \N
    mov r12, \D 
    bl loopDivision
.endm

loopDivision:
        cmp r11, r12
        bxlo lr @ Condição de parada -> r1 = resto < r2 = denominador
        sub r11, r12
        add r10, #1
        b loopDivision
        

