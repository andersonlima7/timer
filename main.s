@ Temporizador em um Display LCD
@ Autores: Antony Araujo e Anderson Lima
@ Disciplina: MI - Sistemas Digitais
@ Data: 23/09/2022

.include "gpiomap.s"
.include "display.s"
.include "digits.s"

.global _start

@ Exibe um número/dígito no display a partir do resto da divisão do valor informado por 10
.macro WriteDigits
        mov r5, r6
        bl divisions
        WriteNumber r10
.endm


@ Definicao dos pinos como saidas a partir da macro presente em gpiomap.s
.macro SetOutputs
        GPIODirectionOut D4
        GPIODirectionOut D5
        GPIODirectionOut D6
        GPIODirectionOut D7
        GPIODirectionOut RS
        GPIODirectionOut E
.endm


@ Definicao dos pinos como entradas a partir da macro presente em gpiomap.s
.macro SetInputs
        GPIODirectionIn pin5
        GPIODirectionIn pin19
        GPIODirectionIn pin26
.endm

_start:
        mapMem @ Chama a funcao presente em gpiomap.s responsavel por realizar o mapeamento dos pinos

        @ Define os pinos dos botões como entradas.
        SetInputs
        
        @ Define os pinos do display como saídas.
        SetOutputs

        @ Chama macro responsavel por inicializar o display LCD (presente no arquivo display.s)
        Initialization

        @ Chama macro responsavel por limpar o display LCD (presente no arquivo display.s)
        clearLCD

        ldr r6, =tempo16digitos @tempo que será contado pelo temporizador
        mov r7, #10 @valor pelo qual sera dividido o tempo atual para obter o resto e exibir na tela
        WriteDigits @ exibe o numero

@ laco principal que realiza a execucao e verificacao continua do temporizador
loop:
    @Inicia a contagem
    nanoSleep time1s
    GPIOReadRegister pin19 @Realiza a leitura do pino
    cmp r0, r3 @compara o valor capturado do botao
    bne count @se o botao nao tiver sido pressionado, segue a contagem

    @ Reinicia o programa
    GPIOReadRegister pin26 @realiza a leitura do pino
    cmp r0, r3 @compara o valor capturado do botao
    bne _start @se o botao de resetar tiver sido pressionado, o processador retorna ao comeco, saindo do laco

    @ Termina o programa
    GPIOReadRegister pin5 @Realiza a leitura do pino
    cmp r0, r3 @Compara o valor capturado
    bne endmessage @Exibe uma mensagem caso o botao para finalizar o contador tenha sido pressionado
    
    
    b loop @em nenhum dos casos, apenas repete

@laco secundario que coloca o temporizador em modo contagem (decrescente)
count:
        @ Inicia o contador

        @Carrega-se os botoes para capturar entradas
        SetInputs     

        nanoSleep time1s @Realiza a funcao do temporizador de contar a cada 1 segundo
        clearLCD @ limpa o display para exibir o valor atual do temporizador
        sub r6, #1 @subtrai um do valor a ser exibido no display
        
        @as tres instrucoes seguintes reiniciam o contador
        GPIOReadRegister pin26 @captura o valor do pino 26
        cmp r0, r3 @compara
        bne _start @ se o botao referente ao pino 26 for pressionado o timer reseta
        
        WriteDigits @exibe o valor atual do temporizador no display

        @ as 3 instrucoes seguintes pausam o cotnador
        GPIOReadRegister pin19 @captura o valor
        cmp r0, r3 @compara
        bne loop @se o botao se iniciar/pausar tiver sido pressionado o temporizador é pausado e retorna ao laco principal
        
        cmp r6, #0 @compara o valor atual do temporizador e zero
        bhi count @repete o laco se o valor atual do temporizador for maior que zero
        b loop @ senao retorna ao laco principal

@label que realiza a divisao
divisions:
        push {lr} @coloca na pilha o registrador LR (Link Register) - cria um indicador de retorno na pilha para onde o PC deve voltar após a execução
        SetOutputs
        mov r7, #10
        division r5, r7         @ realiza a divisao do valor dividendo atual por 10
        WriteNumber r11         @ escreve o 3 | escreve o 2
        cursorDisplayShift #0, #0 @Desloca o cursor para esquerda
        cursorDisplayShift #1, #1 @Desloca todo o conteudo do display para a direita (liberando a esquerda)
        cursorDisplayShift #0, #0 @Desloca o cursor para a esquerda
        
        mov r5, r10 @atualiza o dividendo atual para que seja o resultado da divisao realizada
        cmp r5, #10 @compara o dividendo com 10
        pop {lr} @remove o registrador LR da pilha
        bxlo lr         @ casoo valor  r5 < 10 entao retorna para o ponto indicado pelo link register
        b divisions @ senao continua fazendo a divisao

@exibe uma mensagem no display ao pressionar o botao de parada com a menssagem @FIM :)
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
    mov R0, #0 @ Usa o código de retorno 0
    mov R7, #1 @ Define o comando de codigo 1
    svc 0 @ Realiza a chamada de funcao do linux para finalizar