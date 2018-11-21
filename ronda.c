// Trabalho 2 - Sistema de software do Uóli
// Adolf Pereira da Costa - RA164933 - Engenharia de Computação - Unicamp
// Marcelo Martins Vilela Filho - RA202619 - Engenharia de Computação - Unicamp

#include "api_robot.h"
#define LIMIAR_EVITA_PAREDE 1200


int _start(){

    motor_cfg_t m1, m2;


    m1.id = 0;
    m2.id = 1;
    int barrier = 1;
    int delay = 0;
    while(1){
        while(get_time() < barrier){
            m1.speed = 8;
            m2.speed = 8;
            set_motor_speed(&m1);
            set_motor_speed(&m2);

            if(read_sonar(4) < LIMIAR_EVITA_PAREDE || read_sonar(3) < LIMIAR_EVITA_PAREDE){
            	m1.speed = 0;
            	m2.speed = 25;
           		set_motor_speed(&m1);
            	set_motor_speed(&m2);
            }

        }
        m1.speed = 0;
        m2.speed = 21;
        set_motor_speed(&m1);
        set_motor_speed(&m2);

       	set_time(0);
        while(get_time() < 5200){

        }
        //curva

        set_time(0);
        barrier++;
		if(barrier >= 50){
			barrier = 1;
		}


    }

    return 0;
}
