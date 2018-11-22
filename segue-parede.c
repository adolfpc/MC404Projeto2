// Trabalho 2 - Sistema de software do Uóli
// Adolf Pereira da Costa - RA164933 - Engenharia de Computação - Unicamp
// Marcelo Martins Vilela Filho - RA202619 - Engenharia de Computação - Unicamp

#include "api_robot.h"

void busca_parede(motor_cfg_t *m1, motor_cfg_t *m2);
void segue_parede(motor_cfg_t *m1, motor_cfg_t *m2);

// Variaveis de controle de distancia:
// LIMIAR_DE_BUSCA: define a distancia que robô vai parar quando estiver buscando a parede;
int LIMIAR_DE_BUSCA;

// LIMIAR_PARALELO: define uma distancia de referencia que o robô manterá,
// enquanto fica paralelo á parede.
int LIMIAR_PARALELO;

int _start(){

    //Inicializa os motores
    motor_cfg_t m1, m2;
    m1.id = 0;
    m2.id = 1;
    m1.speed = 0;
    m2.speed = 0;
    set_motor_speed(&m1);
    set_motor_speed(&m2);

    //Inicializa variáveis de controle de distâncias
    LIMIAR_DE_BUSCA = 350;
    LIMIAR_PARALELO = 550;

    busca_parede(&m1, &m2);
    segue_parede(&m1, &m2);

    return 0;
}

// Funcao que forca o robo a andar paralelamente a parede de tal forma que
// esta fique sempre a direita (referencia da atividade 8) do robô
void segue_parede(motor_cfg_t *m1, motor_cfg_t *m2){

    //Variaveis para controle de velocidade(uma roda é mais rapida do que a outra em cada caso)
    //fazendo um zig-zag

    int higher_speed = 4;
    int slower_speed =  1;

    int s7 = 0;
    int s7_2 = 0;

    while(1){
    	//Loop utilizado para auxiliar na execucao de giros acentuados
    	//como em quinas ou paredes muito proximas
        while(read_sonar(3)<700 && read_sonar(8)<600){
            	m1->speed = 8;
           		m2->speed = 0;
            	set_motor_speed(m1);
            	set_motor_speed(m2);
        }

        s7 = read_sonar(7);
        //Se a distancia do sensor 8 for maior que o sensor 7
    	//Se afasta da parede girando no sentido anti-horario
        if(read_sonar(8) > s7){
            m1->speed = 4;
            m2->speed = 1;
            set_motor_speed(m1);
            set_motor_speed(m2);
        }
        //Se a distancia do sensor 7 for maior que o sensor 8
		//Se aproxima da parede girando no sentido horario com intensidade de aproximacao
		//que varia de acordo com o grau de afastamento anterior
        else{

            //Faz o controle dinamico de velocidade (quando se aproxima da parede),
            //fazendo com que o robô na se afaste da parede.
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

//Funcao que inicializa o robo e em seguida busca uma parede
//conforme a aproximação da parede ocorre o robo para e gira até que essa parede
//fique a sua direita
void busca_parede(motor_cfg_t *m1, motor_cfg_t *m2){

	//Loop que faz o robo andar para frente ate que uma parede seja encontrada
    while(1){
        // Anda para frente até encontrar a parede.
        while((read_sonar(3) > LIMIAR_DE_BUSCA && read_sonar(4) > LIMIAR_DE_BUSCA)){
            m1->speed = 10;
            m2->speed = 10;
            set_motor_speed(m1);
            set_motor_speed(m2);
        }
        //Depois de encontrada para.
        m1->id = 0;
        m2->id = 1;
        m1->speed = 0;
        m2->speed = 0;
        set_motor_speed(m1);
        set_motor_speed(m2);
        break;
    }

    //Loop que quando uma parede eh encontrada, o robo gira ate que esta fique paralela
    //ao seu lado direito
	while(1){
        //Deixa o robô paralelo
    	while(read_sonar(7) > LIMIAR_PARALELO && read_sonar(8) > LIMIAR_PARALELO){
            m1->speed = 0;
            m2->speed = 25;
            set_motor_speed(m1);
            set_motor_speed(m2);
    	}
        //Para o robo depois de te-lo deixado paralelo.
        m1->speed = 0;
        m2->speed = 0;
        set_motor_speed(m1);
        set_motor_speed(m2);
        break;
    }

}
