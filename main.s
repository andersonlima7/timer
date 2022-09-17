@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"
.include "display.s"
.include "digits.s"

.global _start




_start:
        mapMem @ mapemaento

        @ Definicao dos pinos como entradas
        GPIODirectionIn pin5
        GPIODirectionIn pin19
        GPIODirectionIn pin26

        @ variavel do loop
        clearLCD
        mov r6, #9
        WriteOnDisplay r6
        loop:
            nanoSleep time1s
            GPIOReadRegister pin5
            cmp r0, r3
            bne count

            @ Reinicia o programa
            GPIOReadRegister pin26
            cmp r0, r3
            bne _start

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
        WriteOnDisplay r6
        reset
        stop
        sub r6, #1
        cmp r6, #0
        bge count
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