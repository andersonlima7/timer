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

@ Controla os pinos D4, D5, D6, D7 e RS do display
.macro WriteLCD value
        mov r9, #0b00001      
        and r9, \value          @0001 & 0011 -> 0001
        GPIOTurn D4, r9

        @ D5
        mov r9, #0b00010   
        and r9, \value          @ 0010 & 0011 -> 0010
        lsr r9, #1              @ Desloca o bit 1x para direita  -> 0001
        GPIOTurn D5, r9

        @ D6
        mov r9, #0b00100      
        and r9, \value          @ 0100 & 0101 -> 0100
        lsr r9, #2              @ Desloca o bit 2x para direita  -> 0001
        GPIOTurn D6, r9

        @ D7
        mov r9, #0b01000      
        and r9, \value          @ 01000 & 01000 -> 01000
        lsr r9, #3              @ Desloca o bit 3x para direita  -> 00001
        GPIOTurn D7, r9

        @ RS
        mov r9, #0b10000       
        and r9, \value          @ 10000 & 10100 -> 10000
        lsr r9, #4              @ Desloca o bit 4x para direita  -> 00001
        GPIOTurn RS, r9
        enable
        .ltorg
.endm

@Escreve um número no display a partir do valor informado deste mesmo número
.macro WriteNumber value
        @ value - 4 bits do número em binário.

        @ Seleciona as colunas de dígito do display
        WriteLCD #0b10011 

        mov r4, #0b10000 @ Deixa o bit correspondente ao pino do RS ligado, isto é, deixa o LCD em modo dados.
        orr r4, \value          @ 10000 OR 10110 (exemplo) = 10110 
        WriteLCD r4
        .ltorg
.endm

@ Limpa o display e retorna o cursor para a posição inicial
.macro clearLCD
        @ 0 0 0 0 0
        GPIOTurnOff D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable

        @ 0 0 0 0 1
        GPIOTurnOn D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable

        @WriteLCD #0b00000
        @WriteLCD #0b00001
.endm

@ Desloca o cursor ou o display para esquerda/direita.
@ SC - Display (1)  Cursor (0)
@ RL - Direita (1)  Esquerda (0)
.macro cursorDisplayShift SC RL
        GPIOTurnOn D4
        GPIOTurnOff D5
        GPIOTurnOff D6
        GPIOTurnOff D7
        GPIOTurnOff RS
        enable
        @WriteLCD #0b00001

        GPIOTurnOff D4 @ Não importa
        GPIOTurnOff D5 @ Não importa
        GPIOTurn D6, \RL @D6 - R/L Direita ou Esquerda
        GPIOTurn D7, \SC @D7 - Display ou Cursor
        GPIOTurnOff RS
        enable
.endm



@ Inicialização do display em interface 4bits.
.macro Initialization
        WriteLCD #0b00011 @Function set
        nanoSleep time5ms
        WriteLCD #0b00011 @Function set
        nanoSleep time100us
        WriteLCD #0b00011 @Function set

        @ Function Set
        WriteLCD #0b00010

        @ Function Set
        WriteLCD #0b00010
        WriteLCD #0b00000

        @ Display Off
        WriteLCD #0b00000
        WriteLCD #0b01000

        @ Clear
        clearLCD

        @ Entry Mode Set
        WriteLCD #0b00000
        WriteLCD #0b00110

        @Display On
        WriteLCD #0b00000
        WriteLCD #0b01110

        @ Entry Mode Set
        WriteLCD #0b00000
        WriteLCD #0b00110
        .ltorg
.endm
.data

tempoInicial:
        .word 999
        @4294967295

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



@ E - Enable 
@ Esse pino é usado para habilitar o LCD quando um pulso de nível lógico alto para baixo é dado por ele.
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
@ Definimos como 1 se estivermos mandando dados para ser escrito no display.
@ Definimos como 0 se estivermos mandando alguma instução de comando como limpar o display.
RS: .word 8 @ GPFSEL2
        .word 15 @FSEL25
        .word 25 @ pino 25 para SET e CLEAR

.text