
@ Temporizador em um Display LCD
@ Autores: Antony Araujo e Anderson Lima
@ Disciplina: MI - Sistemas Digitais
@ Data: 23/09/2022


@ Various macros to access the GPIO pins
@ on the Raspberry Pi.
@
@ R8 - memory map address.
@

.equ pagelen, 4096
.equ setregoffset, 28 @ SET 0x 7E20 001C = 28
.equ clrregoffset, 40 @ CLEAR 0x 7E20 0028 = 40
.equ plvlregoffset, 52 @ PIN LEVEL 0x 7E20 0034 = 52
.equ pindetectstatus, 64 @ PIN DETECT STATUS 0x 7E20 0040 = 64
.equ pindetectfalledge, 88 @ Pin Falling Edge Detect 0x 7E20 0058 = 88
.equ PROT_READ, 1
.equ PROT_WRITE, 2
.equ MAP_SHARED, 1
.equ sys_nanosleep, 162
.equ sys_mmap2, 192




@ Macro to map memory for GPIO Registers
.macro mapMem
        ldr r0, =devmem
        mov r1, #0x1b0
        orr r1, #0x006
        mov r2, r1
        @ RW access rights
        mov r7, #5
        svc 0
        movs r4, r0 @ fd for memmap
        @ check for error and print error msg if necessary
        ldr r5, =gpioaddr @ address we want / 4096
        ldr r5, [r5] @ load the address
        mov r1, #pagelen @ size of mem we want

        @ mem protection options
        mov r2, #(PROT_READ + PROT_WRITE)
        mov r3, #MAP_SHARED
        @ mem share options
        mov r0, #0 @ let linux choose a virtual address
        mov r7, #sys_mmap2 @ mmap2 service num
        svc 0 @ call service
        movs r8, r0 @ keep the returned virt addr
.endm


@ Define o pino como saída
.macro GPIODirectionOut pin
        ldr r2, =\pin @ offset of select register 
        ldr r2, [r2] @ load the value  GPFSEL0 - GPFSEL1 - GPFSEL2  
        ldr r1, [r8, r2] @ address of register -> 001 000 000 000 000 000 000 000 001 000 (Digamos que o pino1 e pino9 estejam como saidas)
        ldr r3, =\pin @ address of pin table 
        add r3, #4 @ load amount to shift from table Acessa a word para saber qual pino deve ser selecionado
        ldr r3, [r3] @ load value of shift amt FSEL0 - FSEL1 - FSEL2... FSEL25
        mov r0, #0b111 @ mask to clear 3 bits -> 111
        lsl r0, r3 @ shift into position ->        000 000 000 111 000 000 000 000 000 000 (posicao 18 - para o pino6 por exemplo)
        bic r1, r0 @ clear the three bits ->       001 000 000 000 000 000 000 000 001 000 Limpa os bits somente da posicao selecionada
        mov r0, #1 @ 1 bit to shift into pos 
        lsl r0, r3 @ shift by amount from table -> 000 000 000 001 000 000 000 000 000 000 (Coloca 1 bit na posicao certa)
        @ para definir o pino6 como saida, por exemplo.
        orr r1, r0 @ set the bit -> Define o bit no r1 001 000 000 001 000 000 000 000 001 000 (pino6 agora ativo)
        str r1, [r8, r2] @ save it to reg to do work -> Salva no registrador para executar o comando
        .ltorg
.endm

@ Author: A.L
@ Define o pino como entrada
.macro GPIODirectionIn pin
        ldr r2, =\pin @ offset of select register
        ldr r2, [r2] @ load the value
        ldr r1, [r8, r2] @ address of register
        ldr r3, =\pin @ address of pin table
        add r3, #4 @ load amount to shift from table
        ldr r3, [r3] @ load value of shift amt
        mov r0, #0b111 @ mask to clear 3 bits
        lsl r0, r3 @ shift into position
        bic r1, r0 @ clear the three bits
        str r1, [r8, r2] @ save it to reg to do work
        .ltorg
.endm

.macro GPIOTurn pin value
        mov r2, r8
        mov r0, \value
        cmp r0, #0
        addeq r2, #clrregoffset
        addne r2, #setregoffset
        mov r0, #1 @ 1 bit to shift into pos
        ldr r3, =\pin @ base of pin info table
        add r3, #8 @ add offset for shift amt
        ldr r3, [r3] @ load shift from table
        lsl r0, r3 @ do the shift
        str r0, [r2] @ write to the register
.endm


.macro GPIOTurnOn pin
         mov r2, r8 @ address of gpio regs
         add r2, #setregoffset @ off to set reg
         mov r0, #1 @ 1 bit to shift into pos
         ldr r3, =\pin @ base of pin info table
         add r3, #8 @ add offset for shift amt
         ldr r3, [r3] @ load shift from table
         lsl r0, r3 @ do the shift
         str r0, [r2] @ write to the register
.endm

.macro GPIOTurnOff pin
         mov r2, r8 @ address of gpio regs
         add r2, #clrregoffset @ off set of clr reg
         mov r0, #1 @ 1 bit to shift into pos
         ldr r3, =\pin @ base of pin info table
         add r3, #8 @ add offset for shift amt
         ldr r3, [r3] @ load shift from table
         lsl r0, r3 @ do the shift
         str r0, [r2] @ write to the register
.endm



@ Ler o valor de um pino utilizando operações de deslocamento.
.macro GPIOReadRegisterSlower pin
        mov r2, r8              @ Endereço dos registradores da GPIO
        add r2, #plvlregoffset  @ offset para acessar o registrador de pinlvl
        ldr r2, [r2]            @ pinos5, 19 e 26 ativos, por exemplo -> 000 000 100 000 010 000 000 000 000 100 000 
        ldr r3, =\pin           @ base dos dados do pino
        add r3, #8              @ offset para acessar a segunda word  
        ldr r3, [r3]            @ carrega o valor de deslocamento -> queremos saber o valor no pino5 = 5, por exemplo.
        mov r0, #1              @ 1 bit para fazer o deslocamento
        lsl r0, r3              @ desloca esse bit para esquerda n vezes, n = r3 ->  000 000 000 000 000 000 000 000 000 100 000 
        and r0, r2              @ Filtramos os outros bits, sobrando só o do pino5 -> 000 000 000 000 000 000 000 000 000 100 000 
        lsr r0, r3              @ Desloca o bit do pino para direita -> 000 000 000 000 000 000 000 000 000 000 001 = 1 
.endm


@ Ler o valor de um pino utilizando comparações.
.macro GPIOReadRegister pin
        mov r2, r8              @ Endereço dos registradores da GPIO
        add r2, #plvlregoffset  @ offset para acessar o registrador de pinlvl
        ldr r2, [r2]            @ pinos5, 19 e 26 desativados, por exemplo -> 000 001 000 000 100 000 000 000 000 100 000
        ldr r3, =\pin           @ base dos dados do pino
        add r3, #8              @ offset para acessar a segunda word 
        ldr r3, [r3]            @ carrega a posicao do pino -> ex queremos saber o valor no pino5 = 2^5 = 
                                @ 32 = 000 000 000 000 000 000 000 100 000, por exemplo.
        and r0, r2, r3          @ -> 000 000 000 000 000 000 000 000 000 100 000 (Filtramos os outros bits, sobrando só o do pino5)
        @ cmp r0, r3            @ Compara r0 com r3, para saber se o pino esta ativo
        @  Se r0 == r3, o pino está desativo
        @ Se r0 !=r3, o pino está ativo
.endm


.macro print 
    mov r0, #1 @ 1 = StdOut
    ldr r1, =string @ string to print
    mov r2, #13 @ length of our string
    mov r7, #4 @ linux write system call
    svc 0 @ Call linux to print
.endm



.data
timesec: .word 4
timenano: .word 000000000
devmem: .asciz "/dev/mem"
string: .ascii "Entrou no loop \n "


@ mem address of gpio register / 4096

gpioaddr: .word 0x20200

@ GPIO Function Select Registers

@GPFSEL0 = 0000 = 0
@GPFSEL1 = 0004 = 4
@GPFSEL2 = 0008 = 8
@GPFSEL3 = 000C = 12
@GPFSEL4 = 0010 = 16
@GPFSEL5 = 0014 = 20


@ Entradas

@ Dip Switchs

pin4: .word 0 @GPFSEL0
        .word 12 @FSEL4
        @.word 4 @ Pino 4 para pin Level
        .word 16 @ Pino 4 para pin Level, 2^4=16 00000000000000000000000000001000

pin17: .word 4 @GPFSEL1
        .word 21 @FSEL17
        @.word 17 @Pino 17 para pin Level
        .word 131072 @ Pino 17 para pin Level, 2^17=131072

pin27: .word 8 @GPFSEL2
        .word 21 @FSEL27
        @.word 27 @Pino 27 para pin Level
        .word 134217728 @ Pino 27 para pin Level, 2^27=134217728

pin22: .word 8 @GPFSEL2
        .word 6 @FSEL22
        @.word 22 @Pino 22 para pin Level
        .word 4194304 @ Pino 22 para pin Level, 2^22=4194304



@ Push-buttons

@ Botão para iniciar/parar a contagem
pin5: .word 0  @ GPFSEL0
        .word 15 @FSEL5
        @.word 5 @Pino 5 para pin Level 
        .word 32 @Pino 5 para pin Level, 2^5 = 32 

@ Botão para resetar a contagem
pin19: .word 4  @ GPFSEL1
        .word 27 @FSEL19
        @.word 19 @Pino 19 para pin Level 
        .word 524288 @Pino 19 para pin Level, 2^19 = 524288 

pin26: .word 8  @ GPFSEL2
        .word 18 @FSEL26
        @.word 26 @ Pino 26 para pin Level
        .word 67108864 @ Pino 26 para pin Level, 2^26 = 67108864



@ Saidas

@ LED
pin6: .word 0 @ GPFSEL0
        .word 18 @FSEL6
        .word 6 @ pino 1 para SET e CLEAR
@ Display LCD





