#include "api_robot.h"
#define WARNING_UPPER 1000
#define WARNING_BOUND 800

void busca_parede(motor_cfg_t *m1, motor_cfg_t *m2);
void segue_parede(motor_cfg_t *m1, motor_cfg_t *m2);

int LIMIAR_DE_BUSCA;
int LIMIAR_PARALELO;
int _start(){

    motor_cfg_t m1, m2;
    m1.id = 0;
    m2.id = 1;
    m1.speed = 0;
    m2.speed = 0;
    set_motor_speed(&m1);
    set_motor_speed(&m2);

    LIMIAR_DE_BUSCA = 350;
    LIMIAR_PARALELO = 550;
    busca_parede(&m1, &m2);
    segue_parede(&m1, &m2);

    return 0;
}

void segue_parede(motor_cfg_t *m1, motor_cfg_t *m2){

    int average = 0;
    int higher_speed = 4;
    int slower_speed =  1;
    int s2 = 0;

    int s4 = 0;
    int s7 = 0;
    int s8 = 0;
    int s7_2 = 0;
    int s8_2 = 0;
    int average_2 = 0;

    while(1){
    	s8 = read_sonar(8);
        while(read_sonar(3)<700 && read_sonar(8)<600){
            	m1->speed = 8;
           		m2->speed = 0;
            	set_motor_speed(m1);
            	set_motor_speed(m2);
        }

        s7 = read_sonar(7);

    	//sentido anti-horario
        if(read_sonar(8) > read_sonar(7)){
            m1->speed = 4;
            m2->speed = 1;
            set_motor_speed(m1);
            set_motor_speed(m2);
        }
		//sentido horario
        else{

            if(s7 - s7_2 < 0){
                higher_speed=6;
                slower_speed=2;
            }else{
                higher_speed=4;
                slower_speed=1;
            }

            m1->speed = slower_speed;
            m2->speed = higher_speed;
            set_motor_speed(m1);
            set_motor_speed(m2);
        }



        s7_2 = read_sonar(7);
    }

}

void busca_parede(motor_cfg_t *m1, motor_cfg_t *m2){

    while(1){
        while((read_sonar(3) > LIMIAR_DE_BUSCA && read_sonar(4) > LIMIAR_DE_BUSCA)){
            m1->speed = 10;
            m2->speed = 10;
            set_motor_speed(m1);
            set_motor_speed(m2);
        }
        m1->id = 0;
        m2->id = 1;
        m1->speed = 0;
        m2->speed = 0;
        set_motor_speed(m1);
        set_motor_speed(m2);
        break;
    }

	while(1){
    	while(read_sonar(7) > LIMIAR_PARALELO && read_sonar(8) > LIMIAR_PARALELO){
            m1->speed = 0;
            m2->speed = 25;
            set_motor_speed(m1);
            set_motor_speed(m2);
    	}
        m1->speed = 0;
        m2->speed = 0;
        set_motor_speed(m1);
        set_motor_speed(m2);
        break;
    }

}
