// Trabalho 2 - Sistema de software do Uóli
// Adolf Pereira da Costa - RA164933 - Engenharia de Computação - Unicamp
// Marcelo Martins Vilela Filho - RA202619 - Engenharia de Computação - Unicamp

#include "api_robot.h"
#define LIMIAR_EVITA_PAREDE 1200


int _start(){

    motor_cfg_t m1, m2;

    // Seta os id's dos motores
    m1.id = 0;
    m2.id = 1;

    // Variavel barrier: implementa a lógica do robó para sempre andar mais tempo de sistema.
    //É uma variavel de controle.
    int barrier = 1;

    while(1){

        // Faz o robo andar para frente enquanto o tempo é menor que nossa variavel de controle(barrrier).
        while(get_time() < barrier){
            m1.speed = 8;
            m2.speed = 8;

            // Caso encontre uma parede no meio do processo de andar para frente
            if(read_sonar(4) < LIMIAR_EVITA_PAREDE || read_sonar(3) < LIMIAR_EVITA_PAREDE){
            	m1.speed = 0;
            	m2.speed = 25;

            }

       		set_motor_speed(&m1);
        	set_motor_speed(&m2);

        }

        //Caso já tenha passado a quantidade de tempos de sistema determinada por barrier vira noventa
        // graus.
        m1.speed = 0;
        m2.speed = 21;
        set_motor_speed(&m1);
        set_motor_speed(&m2);

        //Delay para virar continuar virando, calibrar para o computador que está executando.
       	set_time(0);
        while(get_time() < 5200){

        }

        // Zera o tempo que decorrido(get _time) e incrementa a variavel de controle(barrier)
        set_time(0);
        barrier++;
		if(barrier >= 50){
			barrier = 1;
		}


    }

    return 0;
}
