# Temporizador em um Display LCD

Esse projeto tem por objetivo a construção de um temporizador de valores inteiros a serem exibidos em um display LCD de uma Raspberry pi w zero, sendo o controle do processador e display realizado através da linguagem de baixo nível Assembly. Abaixo você encontrará os comandos necessários para a correta aplicação e execução do código e biblioteca aqui desenvolvidos.

## Sumário
1. [Pré-requisitos](#pré-requisitos)
2. [Passo a Passo](#passo-a-passo)
3. [Debugando com o GDB](#debugando-com-o-gdb)
4. [Referências](#referências)

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
- ``l`` ou ``list`` exibe as 10 primeiras linhas do código, é possível indicar o número de linhas que se deseja visualizar após o comando
- ``b`` ou ``breakpoint`` define um ponto de parada no momento de debugar o código, é obrigatório especificar onde será o ponto de parada, usualmente se utiliza o nùmero da linha, mas também pode ser utilizado o indicador da função, macro, etc, e.x.: ``b _start``.
- ``r`` ou  ``run`` inicia a execução do programa e sua depuração
- ``s`` ou ``step`` comando que executa o código linha a linha e os pontos de parada definidos
- ``i r`` ou ``info registers`` comando que exibe o estado e valores atuais dos registradores

## Referências
[1] SMITH, Stephen. Raspberry Pi Assembly Language Programming. Apress, 2019.

[2] GNU DEBUGGER (GDB). GDB: The GNU Project Debugger. 2022. Available on [https://www.sourceware.org/gdb/](https://www.sourceware.org/gdb/)
