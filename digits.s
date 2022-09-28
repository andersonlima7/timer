@ Temporizador em um Display LCD
@ Autores: Antony Araujo e Anderson Lima
@ Disciplina: MI - Sistemas Digitais
@ Data: 23/09/2022

@ Vários macros
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

@ Realiza a divisão como o dividendo atual
loopDivision:
        cmp r11, r12
        bxlo lr @ Condição de parada -> r1 = resto < r2 = denominador
        sub r11, r12
        add r10, #1
        b loopDivision
        

