@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"
.include "display.s"
.include "digits.s"

.global _start


.macro Write2Digits
        mov r7, #10
        division r6, r7 
        WriteNumber r10 @ Dezena
        WriteNumber r11 @ Unidade
.endm


@ Escreve números de 3 dígitos no display, quanto mais dígitos, mais divisões temos que fazer.

.macro WriteDigits
        mov r10, r6
        bl divisions
        WriteNumber r10
.endm

.macro Write3Digits
        mov r7, #10
        division r6, r7 @ 123/10 -> r0=12 e r1=3
        mov r5, r11 @ Salva o valor da unidade
        mov r4, r10 @ Salva o r10, r4=12
        mov r7, #10
        division r4, r7 @ 12/10 -> r0=1 e r1=2
        WriteNumber r10 @ Centena
        WriteNumber r11 @ Dezena
        WriteNumber r5 @ Unidade
.endm


_start:
        mapMem @ mapemaento

        @ Definicao dos pinos como entradas
        GPIODirectionIn pin5
        GPIODirectionIn pin19
        GPIODirectionIn pin26

        @ Definicao dos pinos como saidas
        GPIODirectionOut D4
        GPIODirectionOut D5
        GPIODirectionOut D6
        GPIODirectionOut D7
        GPIODirectionOut RS
        GPIODirectionOut E
        
        Initialization

        @ variavel do loop
        clearLCD
        mov r6, #123
        mov r7, #10
        @ WriteDigits
        mov r5, #0b10010110
        @WriteChar r5        
        WriteNumber #6
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
            bne endmessage
            b loop


@ Reinicia o contador
.macro reset
       GPIOReadRegister pin26
       cmp r0, r3
       bne _start
.endm

@ Pausa o contador
.macro stop
        GPIOReadRegister pin5
        cmp r0, r3
        bne loop
.endm

@ Contador
count:
        nanoSleep time1s
        clearLCD
        sub r6, #1
        WriteDigits
        @reset
        @stop
        cmp r6, #0
        bhi count
        reset
        b loop

divisions:
        mov r7, #10
        division r10, r7         @ 123/10 -> r10=12 e r11=3  | 12/10 -> r10=1 e r11=2
        WriteNumber r11         @ escreve o 3 | escreve o 2 
        shiftDisplay
        cmp r10, #10
        bxlo lr         @r10 < 10, acabou
        b divisions


endmessage:
        nanoSleep time1s
        mov r9, #0b1010010001  @F
        WriteData10bit r9 
        mov r9, #0b1010011001  @I
        WriteData10bit r9
        mov r9, #0b1010011101  @M
        WriteData10bit r9
        mov r9, #0b1000110000  @
        WriteData10bit r9
        mov r9, #0b1001111010  @:
        WriteData10bit r9
        mov r9, #0b1001011001  @ )
        WriteData10bit r9
        nanoSleep time1s
        b _end


_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate