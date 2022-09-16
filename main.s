@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"

.global _start


_start:
        mapMem @ mapemaento 

        @ Definicao dos pinos como entradas
        GPIODirectionIn pin5
        GPIODirectionIn pin19
        GPIODirectionIn pin26

        @ variavel do loop
        mov r6, #10
        loop:
            GPIOReadRegister pin5
            cmp r0, r3
            bne count

            @ Termina o programa
            GPIOReadRegister pin19
            cmp r0, r3
            bne loopdone


@ Contador
count:
        print
        reset
        stop
        sub r6, #1
        cmp r6, #0
        bge count
        b loop

@ Pausa o contador
stop:
        GPIOReadRegister pin5
        cmp r0, r3  
        bne loop


resetCounter:
       mov r6, #10
       b loop


@ Reinicia o contador
reset:
       GPIOReadRegister pin26
       cmp r0, r3  
       bne resetCounter




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