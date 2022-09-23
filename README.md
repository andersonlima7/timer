# Temporizador em um Display LCD

Esse projeto tem por objetivo a construção de um temporizador de valores inteiros a serem exibidos em um display LCD de uma Raspberry pi w zero, sendo o controle do processador e display realizado através da linguagem de baixo nível Assembly. Abaixo você encontrará os comandos necessários para a correta aplicação e execução do código e biblioteca aqui desenvolvidos.

## Sumário


- [Pré-requisitos](#pré-requisitos)
- [Passo a passo](#passo-a-passo)
- [Execução](#execução)
  - [Espera](#espera)
  - [Temporizador](#temporizador)
  - [Pausa](#pausa)
  - [Reset](#reset)
  - [Finalizar](#finalizar)
- [Debugando com o GDB](#debugando-com-o-gdb)
- [Referências](#referências)

## Pré-requisitos

- Raspberry Pi W Zero
- Cliente SSH

## Passo a passo

1. Acessar a raspberry pi w zero via ssh (em caso de já estar configurada)
2. Realizar git-clone deste repositório com o comando:

```
git clone git@github.com:andersonlima7/timer.git
```

3. Acesse a pasta contendo o temporizador:

```
cd timer
```

4. Realize a montagem da main.s com:

```
make
```

5. Se tudo ocorrer corretamente, insira o comando:

```
sudo ./main
```

## Execução

**botão5** = Botão do pino 5

**botão19** = Botão do pino 19

**botão26** = Botão do pino 26

### Espera

Ao executar o código, o display é inicializado e o número inicial definido é exibido, o código então entra no modo espera, aguardando a interação do usuário.

A partir daí o usuário possui três escolhas:

1. Pressionar o botão5 e finalizar a execução do código.
2. Pressionar o botão19 e iniciar o temporizador.
3. Pressionar o botão26 e reiniciar o temporizador.

<hr/>

### Temporizador

O temporizador funciona a cada 1 segundo, ou seja, a cada 1 segundo o número definido será subtraído uma unidade até que chegue a 0. No modo temporizador, o usuário possui duas escolhas:

1. Pressionar o botão19 e pausar o temporizador.
2. Pressionar o botão26 e reiniciar o temporizador.

<hr/>

### Pausa

Após pressionar o botão19 enquanto o código estava em modo temporizador, o código volta para o modo espera, pausando o a contagem regressiva, aguardando a interação com o usuário.

<hr/>

### Reset

Após pressionar o botão26 enquanto o código estava em modo temporizador ou no modo espera, a execução é reiniciada, fazendo com que o contador decrescente volte ao seu valor original e o código então volta para o modo espera aguardando a interação com o usuário novamente.

<hr/>

### Finalizar

Após pressionar o botão5 enquanto o código estava em modo espera, a execução do programa é finalizada.

<hr/>

## Debugando com o GDB

GDB ou GNU Debugger é uma ferramenta utilizada na depuração de código de diversas linguagens que são rodadas no compilador GNU e permiite a visualização do comportamento do código linha a linha para verificar seu funcionamento e identificar possíveis erros. Para utilizar o gdb é necessário seguir os seguintes passos:

```
make -B DEBUG=-g
```

Esse comando além de realizar a compilação do código em assembly para a sua execução o deixa utilizável para a depuração pelo GDB. Se tudo tiver ocorrido corretamente com o passo anterior já podemos utilizar o GDB propriamente dito:

```
sudo gdb ./main
```

Após esse comando o GDB irá inicializar, para fazer uso do mesmo há um conjunto de comandos básicos importantes nesse processo, tais como:

- `l` ou `list` exibe as 10 primeiras linhas do código, é possível indicar o número de linhas que se deseja visualizar após o comando
- `b` ou `breakpoint` define um ponto de parada no momento de debugar o código, é obrigatório especificar onde será o ponto de parada, usualmente se utiliza o nùmero da linha, mas também pode ser utilizado o indicador da função, macro, etc, e.x.: `b _start`.
- `r` ou `run` inicia a execução do programa e sua depuração
- `s` ou `step` comando que executa o código linha a linha e os pontos de parada definidos
- `i r` ou `info registers` comando que exibe o estado e valores atuais dos registradores

## Referências

[1] SMITH, Stephen. Raspberry Pi Assembly Language Programming. Apress, 2019.

[2] GNU DEBUGGER (GDB). GDB: The GNU Project Debugger. 2022. Available on [https://www.sourceware.org/gdb/](https://www.sourceware.org/gdb/)
