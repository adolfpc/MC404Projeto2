@ Trabalho 2 - Sistema de software do Uóli
@ Adolf Pereira da Costa - RA164933 - Engenharia de Computação - Unicamp
@ Marcelo Martins Vilela Filho - RA202619 - Engenharia de Computação - Unicamp

.global set_motor_speed
.global read_sonar
.global get_time
.global set_time

.text
.align 4

@ Função set_motor_speed
@ Parametro 1: r0 - Endereço do struct motor_cfg_t
@ Retorno 1: Sem retorno
@ OBS: mapeado para a syscall 20.
@ OBS¹: o struct contém dois endereços de unsigned char(1 byte cada)
@ o primeiro indicando o id, e o segundo indicando a velocidade
@ OBS²: a função ldrb carrega meio byte de cada endereço - á direita
set_motor_speed:
    push {r7, lr}

    ldrb r1, [r0, #1] @ Carrega velocidade em r1
    ldrb r0, [r0] @ Carrega id em r0

    mov r7, #20 @ Coloca em r7 o numero da syscall(definida no enunciado)
    svc 0x0

    pop {r7, pc}

@ Função read_sonar
@ Parametros 1: r0 - id do sonar a ser lido (0 a 15)
@ Retorno 1: distancia ou sonar invalido -1
@ OBS: mapeado para a syscall 21
read_sonar:
    push {r7, lr}

    mov r7, #21 @ Coloca em r7 o numero da syscall(definida no enunciado)
    svc 0x0

    pop {r7, pc}




@ Função set_time
@ Parametros 1: r0 - valor a ser setado na velocidade
@ Retorno 1: Sem retorno
@ OBS: mapeado para a syscall 18
set_time:
    push {r4, r7, lr}

    mov r4, r0 @ guarda valor setado na velocidade

    mov r7, #18 @ Coloca em r7 o numero da syscall(definida no enunciado)
    svc 0x0

    str r0, [r4] @ guarda o retorno no endereco do parametro

    pop {r4, r7, pc}

@ Função get_time
@ Parametro 1: sem parametros
@ Retorno 1: r0 - tempo atual do sistema
@ OBS: mapeado para a syscall 17
get_time:
    push {r7, lr}

    mov r7, #17 @ Coloca em r7 o numero da syscall(definida no enunciado)
    svc 0x0

    pop {r7, pc}
