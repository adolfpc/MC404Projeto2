// Trabalho 2 - Sistema de software do Uóli
// Adolf Pereira da Costa - RA164933 - Engenharia de Computação - Unicamp
// Marcelo Martins Vilela Filho - RA202619 - Engenharia de Computação - Unicamp

.global set_motor_speed
.global read_sonar
.global get_time
.global set_time

.text
.align 4

@ set_motor_speed
@ Parametros:
@ r0: ponteiro para struct "motor_cfg_t" (2 bytes)
@ Retorno:
@ -
set_motor_speed:
    push {r7, lr}

    @ Parametros da syscall 20
    ldrb r1, [r0, #1] @ carrega byte 2 da struct no r1
    ldrb r0, [r0] @ carrega byte 1 da struct no r0

    mov r7, #20
    svc 0x0 @ chama a syscall 20, definida pelo enunciado

    pop {r7, pc}

@ read_sonar
@ Parametros:
@ r0: identificador do sonar (0 a 15)
@ Retorno:
@ r0: distancia / -1: sonar invalido
read_sonar:
    push {r7, lr}

    mov r7, #21
    svc 0x0 @ chama a syscall 21, definida pelo enunciado

    pop {r7, pc}




@ get_time
@ Parametros:
@ r0: ponteiro para variavel que recebera o tempo do sistema
@ Retorno:
@ -
set_time:
    push {r4, r7, lr}

    mov r4, r0 @ guarda parametro da syscall 18

    mov r7, #18
    svc 0x0 @ chama a syscall 18, definida pelo enunciado

    str r0, [r4] @ guarda o retorno no endereco do parametro

    pop {r4, r7, pc}

@ get_time
@ Parametros:
@ r0: tempo do sistema
@ Retorno:
@ r0: tempo de sistema
get_time:
    push {r7, lr}

    mov r7, #17
    svc 0x0 @ chama a syscall 17, definida pelo enunciado

    pop {r7, pc}
