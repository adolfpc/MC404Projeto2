@ Este arquivo é um modelo para atividade 9/Trabalho 2
@ Você pode utilizar todo/qualquer trecho deste arquivo
@
@ Este arquivo é segmentado 4 partes (questão de legibilidade)
@   * Seção para declaração de contantes    : Onde as contantes são declaradas
@   * Seção do vetor de interrupções        : Código referente ao vetor de interrupções
@   * Seção de texto                        : Onde as rotinas são escritas
@   * Seção de dados                        : Onde são adicionadas as variáveis (.word, .skip) utilizadas neste arquivo


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção de Constantes/Defines           @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Constantes para os Modos de operação do Processador, utilizados para trocar entre modos de operação (5 bits menos significativos)
    .set MODE_USER,                 0b00010000
    @ Você pode definir as outras....
    .set MODE_IRQ,                  0b00010010
    .set MODE_SUPERVISOR,           0b00010011
    .set MODE_SYSTEM,               0b00011111

@ Constantes referentes aos endereços
	.set USER_ADDRESS,				0x77812000      @ Endereço do código de usuário
	.set STACK_POINTER_IRQ,			0x7E000000      @ Endereço inicial da pilha do modo IRQ
	.set STACK_POINTER_SUPERVISOR,	0x7F000000      @ Endereço inicial da pilha do modo Supervisor
	.set STACK_POINTER_USER, 		0x80000000      @ Endereço inicial da pilha do modo Usuário

@ Constantes Referentes ao TZIC
    .set TZIC_BASE,                 0x0FFFC000
    .set TZIC_INTCTRL,              0x00
    .set TZIC_INTSEC1,              0x84
    .set TZIC_ENSET1,               0x104
    .set TZIC_PRIOMASK,             0x0C
    .set TZIC_PRIORITY9,            0x424

@ Constantes para os enderecos do GPT
    .set GPT_CR,                    0x53FA0000
    .set GPT_PR,                    0x53FA0004
    .set GPT_SR,                    0x53FA0008
    .set GPT_IR,                    0x53FA000C
    .set GPT_OCR1,                  0x53FA0010
    .set GPT_OCR2,                  0x53FA0014
    .set GPT_OCR3,                  0x53FA0018
    .set GPT_ICR1,                  0x53FA001C
    .set GPT_ICR2,                  0x53FA0020
    .set GPT_CNT,                   0x53FA0024

@ Constantes para os endereços dos periféricos
    .set DR,                         0x53F84000
    .set GDIR,                       0x53F84004
    .set PSR,                        0x53F84008


@ Outras Constantes
    .set TIME_SZ, 8


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção do Vetor de Interrupções        @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Este vetor possui entradas das rotinas para o tratamento de cada tipo de interrupção
.align 4
.org 0x0                    @ 0x0 --> salto para rotina de tratamento do RESET
.section .iv,"a"
_start:
interrupt_vector:
	b reset_handler        @ Rotina utilizada para interrupção RESET

.org 0x08                  @ 0x8 --> salto para rotina de tratamento de syscalls (interrupções svc)
	b svc_handler          @ Rotina utilizada para interrupção SVC

.org 0x18                  @ 0x18 --> salto para rotina de tratamento de interrupções do tipo IRQ
	b irq_handler          @ Rotina utilizada para interrupção IRQ (GPT, ...)



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção de Texto                        @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.org 0x100
.text

@ Rotina de tratamento da interrupção RESET.
@ Esta rotina é unicamente invocada assim que o processador é iniciado (interrupção reset). O processador é iniciado no modo de operação de sistema, com as flags zeradas e as INTERRUPÇÕES DESABILITADAS!
@ Esta rotina é utilizada para configurar todo o sistema, antes de executar o código de usuário (ronda, segue-parede), que esta localizado em USER_ADDRESS.
@ Uma vez que o código de usuário é executado, syscalls são utilizadas para voltar aos modo de operação de sistema.
@
@ Essa rotina deve configurar:
@   1)  Inicializar o contador de tempo (variável contador) e o endereço base do vetor de interrupções no coprocessador p15    -- (OK)
@
@   2)  Inicializar as pilhas dos modos de operação
@          * Alterar o registrador sp, dos modos IRQ e SVC (cada modo tem seus próprios registradores!), com endereços definidos. Assim, sempre que chavearmos de modo, este tera um endereço para sua pilha, separadamente.
@          * Lembre-se que, o registrador CPRS (que pode ser acessado por instruções mrs/msr) contém o modo de operação atual do processador. Para trocar de modo, basta escrever os bits referentes ao novo modo, no CPRS. Apenas o modo de operação USER possui restrições quanto a escrever no CPRS. Para retornar a um modo de operação de sistema, o usuário deve realizar uma syscall (que é tratada pelo svc_handler)
@
@   3)  Configurar os dispositivos:
@          * Configurar o GPT para gerar uma interrupção do tipo IRQ (que será tratada por irq_handler) assim que o contador atingir um valor definido. O GPT é um contador de propósito geral e deve-se configurar a frequencia e o valor que será contado. Cada interrupção gerada deste contador representa uma unidade de tempo do seu sistema (quanto mais alto ou baixo o valor de contagem, seu tempo passará mais rapído ou devagar)
@          * Configurar GPIO: Definir em GDIR quais portas do GPIO são de entrada e saída.
@
@   4)  Configurar o TZIC (Controlador de Interrupções)         -- (OK)
@          * Após configurar as interrupções dos dispositivos, a configuração do TZIC deve ser realizada para permitir que as interrupções dos periféricos cheguem a CPU.
@          * Nesta parte, estamos cadastrando as interrupcões do GPT como habilitadas para o TZIC
@
@   5)  Habilitar interrupções e executar o código do usuário
@           * Uma vez que o sistema foi configurado, devemos executar (saltar para) o código do usuário (segue-parede/ronda), que esta localizado em USER_ADDRESS
@           * Lembre-se também de habilitar as interrupções antes de executar o código usuário. Para habilitar as interrupções escreva nos bits do CPRS (bit de IRQ e FIQ. Feito isso, as interrupções cadastradas no TZIC irão interromper o processador, que irá parar o que estiver fazendo, chavear de modo e executar a rotina de tratamento adequada para cada interrupção.
@           * Uma vez que o código de usuário é executado, a rotina reset_handler não é mais usada (até reinicar). Apenas as rotinas irq_handler (para interrupções do GPT) e svc_handler (para syscalls feitas pelo usuário) são utilizadas.

reset_handler:
@   ----------- Inicialização do contador e do IV -------------------------
    @ zera contador de tempo
    mov r0, #0
    ldr r1, =counter
    str r0, [r1]
    @Faz o registrador que aponta para a tabela de interrupções apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector @ carrega vetor de interrupcoes
    mcr p15, 0, r0, c12, c0, 0 @ no co-processador 15

@   ----------- Inicialização das pilhas modos de operação  ---------------
    @ Você pode inicializar as pilhas aqui (ou, pelo menos, antes de executar o código do usuário)
    ldr sp, =STACK_POINTER_SUPERVISOR
    msr CPSR_c, #MODE_IRQ
    ldr sp, =STACK_POINTER_IRQ
    msr CPSR_c, #MODE_SUPERVISOR

@   ----------- Configuração dos periféricos (GPT/GPIO) -------------------
    @ Você pode configurar os periféricos aqui....
    bl GPT_CONFIG
    bl GPIO_CONFIG
    bl TZIC_CONFIG


@   ----------- Execução de código de usuário -----------------------------
    @ Você pode fazer isso aqui....
   ldr r2, =USER_ADDRESS
   msr CPSR_c, #MODE_USER
   ldr sp, =STACK_POINTER_USER
   mov pc, r2

@   Rotina para o tratamento de interrupções IRQ
@   Sempre que uma interrupção do tipo IRQ acontece, esta rotina é executada. O GPT, quando configurado, gera uma interrupção do tipo IRQ. Neste caso, o contador de tempo pode ser incrementado (este incremento corresponde a 1 unidade de tempo do seu sistema)
irq_handler:
    push {r0-r12}
    @ Grava 1 em GPT_SR sinalizando que já estamos tratando a interrupção.
    mov r0, #1
    ldr r1, =GPT_SR
    str r0, [r1]

    @ Incrementa o contador de interrupções
    ldr r1, =counter
    ldr r0, [r1]
    add r0, r0, #1
    str r0, [r1]

    @ Subtrai 4 do registrador de lr_irq (que contém PC+8 antes da interrupção)
    mov r0, lr
    sub r0, r0, #4
    mov lr, r0

    @ Faz o retorno da interrupção alterando também o modo
    pop {r0-r12}
    movs pc, lr

GPIO_CONFIG:
@       ----------- Configuração do GPIO  -------------------------------------
    push {r0-r12}

    ldr r0, =GDIR
    ldr r1, =0b11111111111111000000000000111110
    str r1, [r0]

    pop {r0-r12}
    mov pc, lr

GPT_CONFIG:
@       ----------- Configuração do GPT  -------------------------------------
    push {r0-r12}
    @ Escrevendo o valor 0x00000041 em GPT_CR
    mov r0, #0x00000041
    ldr r1, =GPT_CR
    str r0, [r1]

    @ Zerando o prescaler(GPT_CR)
    mov r0, #0
    ldr r1, =GPT_PR
    str r0, [r1]

    @ Colocando 100 em hexadecimal(Para contar até este valor)
    mov r0, #TIME_SZ
    ldr r1, =GPT_OCR1
    str r0, [r1]

    @ Gravando 1 em GPT_IR para demostrar interesse específico nesse tipo de interrupção
    mov r0, #1
    ldr r1, =GPT_IR
    str r0, [r1]
    pop {r0-r12}
    mov pc, lr

TZIC_CONFIG:
@       ----------- Configuração do TZIC  -------------------------------------
    push {r0-r12}

    @ Liga o controlador de interrupcoes
    @ R1 <= TZIC_BASE
    ldr	r1, =TZIC_BASE

    @ Configura interrupcao 39 do GPT como nao segura
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupcao 39 (GPT)
    @ reg1 bit 7 (gpt)
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3

    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    @ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

    @ Habilita o controlador de interrupcoes
    mov	r0, #1
    str	r0, [r1, #TZIC_INTCTRL]
    pop {r0-r12}
    mov pc, lr



@   Rotina para o tratamento de chamadas de sistemas, feitas pelo usuário
@   As funções na camada BiCo fazem syscalls que são tratadas por essa rotina
@   Esta rotina deve, determinar qual syscall foi realizada e realizar alguma ação (escrever nos motores, ler contador de tempo, ....)
svc_handler:
    push {r1-r12, lr}

    cmp r7, #21
    bleq read_sonar

    cmp r7, #20
    bleq set_motor_speed

    cmp r7, #17
    bleq get_time

    cmp r7, #18
    bleq set_time

    pop {r1-r12, lr}
    movs pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@           Chamadas de sistema              @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
read_sonar:
    push {r1-r12}

    cmp r0, #15
    bgt read_sonar_err
    cmp r0, #0
    blt read_sonar_err

    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b11111111111111111111111111000001
    and r4, r4, r12
    orr r4, r4, r0, lsl #2
    ldr r3, =DR
    str r4, [r3]

    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b11111111111111111111111111111100
    and r4, r4, r12
    ldr r3, =DR
    str r4, [r3]

    @delay
    mov r4, #10
    wait:
        cmp r4, #0
        sub r4, r4, #1
        bgt wait

    ldr r2, =DR
    ldr r4, [r2]
    orr r4, r4, #0b10
    ldr r3, =DR
    str r4, [r3]

    @delay
    mov r4, #10
    wait2:
        cmp r4, #0
        sub r4, r4, #1
        bgt wait2

    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b11111111111111111111111111111100
    and r4, r4, r12
    ldr r3, =DR
    str r4, [r3]

    wait_flag:
        ldr r2, =DR
        ldr r4, [r2]
        and r4, r4, #0b01

        cmp r4, #1
        beq read_sonar_data
        @delay
        mov r4, #10
        wait3:
            cmp r4, #0
            sub r4, r4, #1
            bgt wait3
        b wait_flag

    read_sonar_data:
        ldr r2, =DR
        ldr r4, [r2]
        ldr r12, =0b111111111111000000
        and r4, r4, r12
        lsr r4, r4, #6
        mov r0, r4

    pop {r1-r12}
    b turn_back

read_sonar_err:
    mov r0, #-1
    b turn_back

@ motor 0 -> direita, motor 1 -> esquerda(em relação a imagem do lab08)
set_motor_speed:
    push {r1-r12, lr}

    @ Verifica possiveis erros nos parametros
    cmp r0, #0
    blt motor_id_err
    cmp r0, #1
    bgt motor_id_err
    cmp r1, #0
    blt speed_id_err
    cmp r1, #63
    bgt speed_id_err


    cmp r0, #0
    bne motor1

    @ Reseta as velocidades para 0, antes de fazer o set
    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b11111110000000111111111111111111
    and r4, r4, r12

    @ velocidade do motor 0
    lsl r1, r1, #19
    orr r4, r4, r1
    str r4, [r2]

    @ seta motor0 pra 0
    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b11111111111110111111111111111111
    and r4, r4, r12
    str r4, [r2]

    b end

    @ Reseta as velocidades para 0, antes de fazer o set
    motor1:
    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b00000001111111111111111111111111
    and r4, r4, r12
    @ velocidade do motor 1
    lsl r1, r1, #26
    orr r4, r4, r1
    str r4, [r2]
    @seta o motor1 para 0
    ldr r2, =DR
    ldr r4, [r2]
    ldr r12, =0b11111101111111111111111111111111
    and r4, r4, r12
    str r4, [r2]

    end:
    pop {r1-r12, lr}
    b turn_back


motor_id_err:
    mov r0, #-1
    b turn_back

speed_id_err:
    mov r0, #-2
    b turn_back

set_time:
    push {r1-r12, lr}
    ldr r12, =counter
    str r0, [r12]
    pop {r1-r12, lr}
    b turn_back

get_time:
    push {r1-r12, lr}
    ldr r0, =counter
    ldr r0, [r0]
    pop {r1-r12, lr}
    b turn_back

turn_back:
    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção de Dados                        @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.data
@ Nesta seção ficam todas as váriaveis utilizadas para execução do código deste arquivo (.word / .skip)
counter: .word 0x00000000
