@ Macros para mandar para o display os dígitos de 0 a 9

.include "display.s"

@ Acessa a coluna dos digitos no display
.macro digits 
    @ 0 0 1 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOn D5 @ DB5 = 1
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write0
    digits
    @ 0 0 0 0
    GPIOTurnOff D4 @DB4 = 0
    GPIOTurnOff D5 @ DB5 = 0
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm


.macro Write1
    digits
    @ 0 0 0 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOff D5 @ DB5 = 0
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write2
    digits
    @ 0 0 1 0
    GPIOTurnOff D4 @DB4 = 0
    GPIOTurnOn D5 @ DB5 = 1
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write3
    digits
    @ 0 0 1 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOn D5 @ DB5 = 1
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write4
    digits
    @ 0 1 0 0
    GPIOTurnOff D4 @DB4 = 0
    GPIOTurnOff D5 @ DB5 = 0
    GPIOTurnOn D6 @DB6 = 1
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write5
    digits
    @ 0 1 0 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOff D5 @ DB5 = 0
    GPIOTurnOn D6 @DB6 = 1
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write6
    digits
    @ 0 1 1 0
    GPIOTurnOff D4 @DB4 = 0
    GPIOTurnOn D5 @ DB5 = 1
    GPIOTurnOn D6 @DB6 = 1
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write7
    digits
    @ 0 1 1 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOn D5 @ DB5 = 1
    GPIOTurnOn D6 @DB6 = 1
    GPIOTurnOff D7 @DB7 = 0
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write8
    digits
    @ 1 0 0 0
    GPIOTurnOff D4 @DB4 = 0
    GPIOTurnOff D5 @ DB5 = 0
    GPIOTurnOff D6 @DB6 = 1
    GPIOTurnOn D7 @DB7 = 1
    GPIOTurnOn RS @RS = 1
    enable
.endm

.macro Write9
    digits
    @ 1 0 0 1
    GPIOTurnOn D4 @DB4 = 1
    GPIOTurnOff D5 @ DB5 = 0
    GPIOTurnOff D6 @DB6 = 0
    GPIOTurnOn D7 @DB7 = 1
    GPIOTurnOn RS @RS = 1
    enable
.endm
