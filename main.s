@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"

.global _start

_start:
        mapMem @ mapemaento 

        @ Definicao dos pinos como saidas
        GPIODirectionOut pin6
        GPIODirectionOut pin12
        GPIODirectionOut pin16
        GPIODirectionOut pin20
        GPIODirectionOut pin21
        GPIODirectionOut pin25

        @ Definicao dos pinos como entradas
        GPIODirectionIn pin5
        GPIODirectionIn pin19
        GPIODirectionIn pin26

        @ variavel do while loop
        mov r0, #2
        loop:
            GPIOReadRegister pin5
            GPIOReadRegister pin19
            GPIOReadRegister pin26

            cmp r0, #1
            beq loopdone
            bne loop


        
loopdone:
        nanoSleep
        GPIOTurnOff pin6
        nanoSleep
        GPIOTurnOn pin6
        b _end


_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate

