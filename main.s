@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"

.global _start

_start:
        mapMem @ mapemaento f

        @ Definicao dos pinos como saidas
        GPIODirectionOut pin6
        GPIODirectionOut pin12
        GPIODirectionOut pin16
        GPIODirectionOut pin20
        GPIODirectionOut pin21
        GPIODirectionOut pin25

        @ variavel do while loop
        mov r1, #0
        loop:
            nanoSleep
            GPIOTurnOff pin6
            nanoSleep
            GPIOTurnOn pin6
            add r1, #1
            CMP r1, #10
            BLE loop


_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate

