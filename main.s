@ Programa para receber uma entrada de um botão (pino 5) e ligar um led (pino 12)

.include "gpiomap.s"

.global _start

_start: 
        mapMem @ mapemaento

        @ Definicao dos pinos como entradas - Teste
        GPIODirectionIn pin4
        GPIODirectionIn pin5
        GPIODirectionIn pin17
        GPIODirectionIn pin19
        GPIODirectionIn pin22
        GPIODirectionIn pin26
        GPIODirectionIn pin27

        @ Definicao dos pinos como saidas
        GPIODirectionOut pin1
        GPIODirectionOut pin12
        GPIODirectionOut pin16
        GPIODirectionOut pin20
        GPIODirectionOut pin21
        GPIODirectionOut pin25
        
        @ variavel do while loop
        mov r1, #0
        loop: 
            CMP r1, #0
            BNE loopdone            @ condicao de parada
            GPIOReadRegister pin5   @ ler o pino 5
            B loop                  @ continua o loop

        loopdone:
            GPIOTurnOn pin12    @ se quebrar o loop, ligue o led no pino12
            mov r0, #1          @stdout - escrita no terminal
            ldr r1, =worked 
            mov r2, #20         @tamanho da frase
            mov R7, #4          @ funcao de escrever no linux
	        svc 0               @ da o controle pro linux chamar a funcao


_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate

.data worked: .ascii "Botao pressionado! \n"





