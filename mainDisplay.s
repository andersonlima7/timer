.include "gpiomap.s"
.include "display.s"
.include "digits.s"

.global _start


_start:
        mapMem @ mapemaento

        @ Definicao dos pinos como saidas
        GPIODirectionOut pin6
        GPIODirectionOut E
        GPIODirectionOut D4
        GPIODirectionOut D5
        GPIODirectionOut D6
        GPIODirectionOut D7
        GPIODirectionOut RS

        @ Inicia o display
        Initialization

        Write7
        b _end



_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate