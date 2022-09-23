@ Temporizador em um Display LCD
@ Autores: Antony Araujo e Anderson Lima
@ Disciplina: MI - Sistemas Digitais
@ Data: 23/09/2022

@Macros para acessar o display

.equ sys_nanosleep, 162

@ Delay
.macro nanoSleep totime
        LDR R0,=\totime
        LDR R1,=\totime
        MOV R7, #sys_nanosleep
        SWI 0
.endm

.macro enable
        GPIOTurnOff E
        nanoSleep time1ms
        GPIOTurnOn E
        nanoSleep time1ms
        GPIOTurnOff E
.endm


@ Define o tamanho da interface de dados (DL - Data Lenght)
.macro FunctionSet        
        @Quando o tamanho de 4 bits é selecionado, os dados devem ser enviados ou recebido duas vezes
        GPIOTurnOff D4 @ DL = 0 -> 4 bit length
        GPIOTurnOn D5 @ DB5 = 1
        GPIOTurnOff D6 @ DB6 = 0
        GPIOTurnOff D7 @ DB7 = 0
        GPIOTurnOff RS  @RS = 0
        enable
.endm

@ Liga o display e cursor. Pode ligar/desligar todo o display, ligar/desligar o cursor e piscar na posição do cursos com um caracter
.macro DisplayOnOff
        @ 0 0 0 0 0
        GPIOTurnOff D4 @DB4 = 0
        GPIOTurnOff D5 @ DB5 = 0
        GPIOTurnOff D6 @DB6 = 0
        GPIOTurnOff D7 @DB7 = 0
        GPIOTurnOff RS @RS = 0
        enable

        @ 0 1 1 1 0
        GPIOTurnOff D4 @B = 0 -> Blink
        GPIOTurnOn D5  @C = 1 -> Cursor
        GPIOTurnOn D6  @D = 1 -> Display
        GPIOTurnOn D7  @DB7 = 1
        GPIOTurnOff RS @RS = 0
        enable
.endm

@ Desliga o display e cursor
.macro DisplayOff
        @ 0 0 0 0 0
        GPIOTurnOff D4 @DB4 = 0
        GPIOTurnOff D5 @ DB5 = 0
        GPIOTurnOff D6 @DB6 = 0
        GPIOTurnOff D7 @DB7 = 0
        GPIOTurnOff RS @RS = 0
        enable

        @ 0 1 0 0 0
        GPIOTurnOff D4 @B = 0 -> Blink
        GPIOTurnOff D5  @C = 0 -> Cursor
        GPIOTurnOff D6  @D = 0 -> Display
        GPIOTurnOn D7  @DB7 = 1
        GPIOTurnOff RS @RS = 0
        enable
        .ltorg
.endm

@ Define a direção de movimento do cursos e especifica o deslocamento do display. Define a direção de movimento do cursor (I/D)
@ Especifica o deslocamento do display (S)
.macro ModeSet
        @ 0 0 0 0 0
        GPIOTurnOff D4 @DB4 = 0
        GPIOTurnOff D5 @ DB5 = 0
        GPIOTurnOff D6 @DB6 = 0
        GPIOTurnOff D7 @DB7 = 0
        GPIOTurnOff RS @RS = 0
        enable

        @ 0 0 1 1 0
        GPIOTurnOff D4 @S = 0 -> Not shift
        GPIOTurnOn D5  @I/D = 1 -> Right
        GPIOTurnOn D6  @DB6 = 1
        GPIOTurnOn D7 @DB7 = 0
        GPIOTurnOff RS @RS = 0
        enable
.endm

@ Controla os pinos D4, D5, D6, D7 e RS do display
.macro WriteData5bit value
        mov r9, #0b00001      @0b0001
        and r9, \value   @0001 & 0011 -> 0001
        GPIOTurn D4, r9

        @ D5
        mov r9, #0b00010    @0b0010
        and r9, \value     @ 0010 & 0011 -> 0010
        lsr r9, #1      @ Desloca o bit 1x para direita  -> 0001
        GPIOTurn D5, r9

        @ D6
        mov r9, #0b00100      @0b0100
        and r9, \value  @ 0100 & 0101 -> 0100
        lsr r9, #2      @ Desloca o bit 2x para direita  -> 0001
        GPIOTurn D6, r9

        @ D7
        mov r9, #0b01000      @0b1000
        and r9, \value   @ 01000 & 01000 -> 01000
        lsr r9, #3      @ Desloca o bit 3x para direita  -> 00001
        GPIOTurn D7, r9

        @ RS
        mov r9, #0b10000      @0b10000
        and r9, \value   @ 10000 & 10100 -> 10000
        lsr r9, #4      @ Desloca o bit 4x para direita  -> 00001
        GPIOTurn RS, r9
        enable
.endm

@ Controla os pinos D4, D5, D6, D7 e RS do display em dois pulsos de 5bits.
.macro WriteData10bit value
        @ r1 - Pino
        @ r2 - Bit que determina se deve ligar ou desligar o pino
        @ value - Código de 10 bits do char.

        @ RS D7 D6 D5 D4
        @ ENABLE
        @ RS D7 D6 D5 D4

        @ D4
        mov r9, #0b0000100000
        and r9, \value   @0b00010000 & 01010000 -> 00010000
        lsr r9, #5      @ Desloca o bit 5x para direita  -> 00000001/00000000
        GPIOTurn D4, r9

        @ D5
        mov r9, #0b0001000000
        and r9, \value    @0b0001000000 & 0001100010 -> 0001000000
        lsr r9, #6      @ Desloca o bit 6x para direita  -> 0000000001/0000000000
        GPIOTurn D5, r9

        @ D6
        mov r9, #0b0010000000
        and r9, \value  @0b0010000000 & 0101000100 -> 0010000000
        lsr r9, #7     @Desloca o bit 7x para direita  -> 0000000001/0000000000
        GPIOTurn D6, r9

        @ D7
        mov r9, #0b0100000000
        and r9, \value   @0b0100000000 & 0110100010 -> 010000000
        lsr r9, #8      @ Desloca o bit 8x para direita  -> 000000001/000000000
        GPIOTurn D7, r9

         @ RS
        mov r9, #0b1000000000
        and r9, \value   @ 1000000000 & 1010000000 -> 1000000000
        lsr r9, #9      @ Desloca o bit 9x para direita  -> 0000000001
        GPIOTurn RS, r9

        @ D7 D6 D5 D4
        enable

        mov r9, #0b0000000001
        and r9, \value   @0001 & 0011 -> 0001
        GPIOTurn D4, r9

        @ D5
        mov r9, #0b0000000010
        and r9, \value     @ 0010 & 0011 -> 0010
        lsr r9, #1      @ Desloca o bit 1x para direita  -> 0001
        GPIOTurn D5, r9

        @ D6
        mov r9, #0b0000000100      @0b0100
        and r9, \value  @ 0100 & 0101 -> 0100
        lsr r9, #2      @ Desloca o bit 2x para direita  -> 0001
        GPIOTurn D6, r9

        @ D7
        mov r9, #0b0000001000      @0b1000
        and r9, \value   @ 01000 & 01000 -> 01000
        lsr r9, #3      @ Desloca o bit 3x para direita  -> 00001
        GPIOTurn D7, r9

        @ RS
        mov r9, #0b0000010000      @0b10000
        and r9, \value   @ 10000 & 10100 -> 10000
        lsr r9, #4      @ Desloca o bit 4x para direita  -> 00001
        GPIOTurn RS, r9
        enable
        .ltorg
.endm

@Escreve um número no display a partir do valor informado deste mesmo número
.macro WriteNumber value
        @ r1 - Pino
        @ r2 - Bit que determina se deve ligar ou desligar o pino.
        @ value - 4 bits menos significativos do Código do número.


        @ Seleciona as colunas de dígito do display
        digits

        @ D7 D6 D5 D4

        @ D4

        mov r9, #0b0001      @0b0001
        and r9, \value   @0001 & 0011 -> 0001
        GPIOTurn D4, r9

        @ D5
        mov r9, #0b0010    @0b0010
        and r9, \value     @ 0010 & 0011 -> 0010
        lsr r9, #1      @ Desloca o bit 1x para direita  -> 0001
        GPIOTurn D5, r9

        @ D6
        mov r9, #0b0100      @0b0100
        and r9, \value  @ 0100 & 0101 -> 0100
        lsr r9, #2      @ Desloca o bit 2x para direita  -> 0001
        GPIOTurn D6, r9

        @ D7
        mov r9, #0b1000      @0b1000
        and r9, \value   @ 1000 & 1000 -> 1000
        lsr r9, #3      @ Desloca o bit 3x para direita  -> 0001
        GPIOTurn D7, r9

        @ RS
        GPIOTurnOn RS
        enable
        .ltorg

.endm

@ Limpa o display e retorna o cursor para a posição inicial
.macro clearLCD
        @ 0 0 0 0 0
        @WriteData5bit #0b00000
        GPIOTurnOff D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable

        @ 0 0 0 0 1
        @WriteData5bit #0b00001
        GPIOTurnOn D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable
.endm

@ Desloca os caracteres do display para a esquerda
.macro cursorDisplayShift SC RL
        GPIOTurnOn D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable
        GPIOTurnOff D4 @ Não importa
        GPIOTurnOff D5 @ Não importa
        GPIOTurn D6, \RL @D6 - R/L Direita ou Esquerda
        GPIOTurn D7, \SC @D7 - Display ou Cursos
        GPIOTurnOff RS
        enable
.endm

@ Desloca os caracteres do display para a direita
.macro shiftRightDisplay
        GPIOTurnOn D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable
        GPIOTurnOff D4 @ Não importa
        GPIOTurnOff D5 @ Não importa
        GPIOTurnOn D6@D6 - R/L Direita ou Esquerda
        GPIOTurnOn D7 @D7 - Display ou Cursos
        GPIOTurnOff RS
        enable
.endm

@ Retorna o cursos para o inicio
.macro CursorHome
        GPIOTurnOff D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable
        GPIOTurnOff D4 @ Não importa
        GPIOTurnOn D5 @
        GPIOTurnOff D6@D6 - R/L Direita ou Esquerda
        GPIOTurnOff D7 @D7 - Display ou Cursos
        GPIOTurnOff RS
        enable

.endm

@ Exibe a mensagem: "Temporizador:"
.macro showMessage
        nanoSleep time1ms
        mov r9,  #0b1010010101 @ T
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1010110110 @ e
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1110110110 @ m
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1000010111 @ p
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1111110110 @ o
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1001010111 @ r
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1100110110 @ i
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1101010111 @ z
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1000110110 @ a
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1010010110 @ d
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1111110110 @ o
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1001010111 @ r
        WriteData10bit r9
        nanoSleep time1ms
        mov r9,  #0b1001111010  @:
        WriteData10bit r9
.endm

@ Inicialização do display em interface 4bits.
.macro Initialization
        WriteData5bit #0b00011 @Function set
        nanoSleep time5ms
        WriteData5bit #0b00011 @Function set
        nanoSleep time100us
        WriteData5bit #0b00011 @Function set

        WriteData5bit #0b00010


        WriteData5bit #0b00010
        WriteData5bit #0b00000
        mov r9, #0b0000001000 @00010 001XX
        WriteData10bit r9
        mov r9, #0b0000000000 @00010 001XX
        WriteData10bit r9
        mov r9, #0b0000000110 @00010 001XX
        WriteData10bit r9
        mov r9, #0b0000001110 @00000 001000
        WriteData10bit r9
        mov r9, #0b0000000110 @00010 001XX
        WriteData10bit r9
        @DisplayOff
        @clearLCD
        @ModeSet
        @DisplayOnOff
.endm
.data

tempo16digitos:
        .word 0x3FFFFFF

time5ms: .word 0
         .word 5000000
time1ms: .word 0
         .word 1000000
time100us:.word 0
          .word 150000
time450ns:
        .word 0
        .word 450
time1s: .word 1
        .word 000000000


@ E - Enable, a high to low pulse need to enable the LCD
@ This pin is used to enable the module when a high to low pulse is given to it. A pulse of 450 ns should be given.
@ That transition from HIGH to LOW makes the module ENABLE.
E: .word 0 @ GPFSEL0
        .word 3 @FSEL1
        .word 1 @ pino 1 para SET e CLEAR


@ Data Pins, Stores the Data to be displayed on LCD or the command instructions

@ D4
D4: .word 4 @ GPFSEL1
        .word 6 @FSEL12
        .word 12 @ pino 12 para SET e CLEAR

@ D5
D5: .word 4 @ GPFSEL1
        .word 18 @FSEL16
        .word 16 @ pino 16 para SET e CLEAR

@ D6
D6: .word 8 @ GPFSEL2
        .word 0 @FSEL20
        .word 20 @ pino 20 para SET e CLEAR

@ D7
D7: .word 8 @ GPFSEL2
        .word 3 @FSEL21
        .word 21 @ pino 21 para SET e CLEAR

@RS - Register Select Pin, RS=0 Command mode, RS=1 Data mode
@ We need to set it to 1, if we are sending some data to be displayed on LCD.
@ And we will set it to 0 if we are sending some command instruction like clear the screen (hex code 01).
RS: .word 8 @ GPFSEL2
        .word 15 @FSEL25
        .word 25 @ pino 25 para SET e CLEAR

.text