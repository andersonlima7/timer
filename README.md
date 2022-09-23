# Temporizador em um Display LCD

Esse projeto tem por objetivo a construção de um temporizador de valores inteiros a serem exibidos em um display LCD de uma Raspberry pi w zero, sendo o controle do processador e display realizado através da linguagem de baixo nível Assembly. Abaixo você encontrará os comandos necessários para a correta aplicação e execução do código e biblioteca aqui desenvolvidos.

## Sumário
1. [Pré-requisitos](#pre-requisitos)


## Pré-requisitos
- Raspberry Pi W Zero
- Cliente SSH

## Passo a passo
1. Acessar a raspberry pi w zero via ssh (em caso de já estar configurada)
2. Realizar git-clone deste repositório com o comando:
                git clone git@github.com:andersonlima7/timer.git
3. Acesse a pasta contendo o temporizador:
                cd timer
4. Realize a montagem da main.s com:
                make
5. Se tudo ocorrer corretamente, insira o comando:
                sudo ./main