@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"
.include "display.s"
.include "digits.s"

.global _start


.macro Write2Digits
        division r6, r7
        WriteOnDisplay r0 @ Dezena
        WriteOnDisplay r1 @ Unidade
.endm


@ Escreve números de 3 dígitos no display, quanto mais dígitos, mais divisões temos que fazer.

.macro Write3Digits
        division r6, r7 @ 123/10 -> r0=12 e r1=3
        mov r5, r1 @ Salva o valor da unidade
        mov r4, r0 @ Salva o r0, r4=12
        division r4, r7 @ 12/10 -> r0=1 e r1=2
        WriteOnDisplay r0 @ Centena
        WriteOnDisplay r1 @ Dezena
        WriteOnDisplay r5 @ Unidade
.endm


_start:
        mapMem @ mapemaento

        @ Definicao dos pinos como entradas
        GPIODirectionIn pin5
        GPIODirectionIn pin19
        GPIODirectionIn pin26

        @ variavel do loop
        clearLCD
        mov r6, #99
        mov r7, #10
        Write2Digits
        loop:
            nanoSleep time1s
            GPIOReadRegister pin5
            cmp r0, r3
            bne count

            @ Reinicia o programa
            reset

            @ Termina o programa
            GPIOReadRegister pin19
            cmp r0, r3
            bne loopdone
            b loop


@ Reinicia o contador
.macro reset
       GPIOReadRegister pin26
       cmp r0, r3
       bne _start
.endm

.macro stop
        GPIOReadRegister pin5
        cmp r0, r3
        bne loop
.endm

@ Contador
count:
        nanoSleep time1s
        clearLCD
        Write2Digits
        reset
        stop
        sub r6, #1
        cmp r6, #0
        bhi count
        b loop
@ Pausa o contador


loopdone:
        nanoSleep time1s
        GPIOTurnOff pin6
        nanoSleep time1s
        GPIOTurnOn pin6
        b _end


_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate