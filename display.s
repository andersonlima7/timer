@Macros to access the display

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
        nanoSleep time5ms
        GPIOTurnOn E
        nanoSleep time5ms
        GPIOTurnOff E
.endm


@ Sets interface data length (DL)
.macro FunctionSet
        @ When 4-bit length is selected, data must be sent or received twice.
        GPIOTurnOff D4 @ DL = 0 -> 4 bit length 
        GPIOTurnOn D5 @ DB5 = 1
        GPIOTurnOff D6 @ DB6 = 0
        GPIOTurnOff D7 @ DB7 = 0
        GPIOTurnOff RS  @RS = 0
        enable
.endm


@ Turns on display and cursor. Sets On/Off of all display (D), cursor On/Off (C) and blink of cursor position character (B)
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

@ Turns off display and cursor. Sets On/Off of all display (D), cursor On/Off (C) and blink of cursor position character (B)
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
.endm


@ Sets cursor move direction and specifies display shift. Sets cursor move direction (I/D), specifies to shift the display (S).
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
        GPIOTurnOff D7 @DB7 = 0
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
        .ltorg
.endm

@ Controla os pinos D4, D5, D6, D7 e RS do display.
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

.macro WriteNumber value
        @ r1 - Pino
        @ r2 - Bit que determina se deve ligar ou desligar o pino.
        @ value - 4 bits menos significativos do Código do char.

        
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


@ Clears display and returns cursor to the home position 
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


@ Inicialização do display em interface 4bits.
.macro Initialization
        WriteData5bit #0b00011 @Function set
        nanoSleep time5ms
        WriteData5bit #0b00011 @Function set
        nanoSleep time100us
        WriteData5bit #0b00011 @Function set

        WriteData5bit  #0b00010
        WriteData10bit #0b0001000100 @00010 001XX 
        WriteData10bit #0b00000001000 @00000 001000 
        DisplayOff 
        clearLCD
        ModeSet 
        DisplayOnOff
.endm
.data

time5ms: .word 0 
         .word 5000000
time1ms: .word 0 
         .word 1000000
time100us:.word 0 
          .word 150000
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