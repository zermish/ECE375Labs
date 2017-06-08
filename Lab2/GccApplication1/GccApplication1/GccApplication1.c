/*
 * GccApplication1.c
 *
 * Created: 1/13/2016 4:58:50 PM
 *  Author: zhengzh
 */ 

/*
This code will cause a TekBot v1.03 connected to the AVR board to 'dance' in a cool
pattern. Remember, the inputs for the v1.03 TekBot are 'active low'. This means you need
to have a '0' to activate them.

PORT MAP
Port B, Pin 4 -> Output -> Right Motor Enable
Port B, Pin 5 -> Output -> Right Motor Direction
Port B, Pin 7 -> Output -> Left Motor Enable
Port B, Pin 6 -> Output -> Left Motor Direction
*/
#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

int main(void)
{
	//pin 1 is left bumper, pin 0 is right bumper
	DDRD = 0b00000000;
	PORTD =0b11111111;
	DDRB =0b11110000;	//Setup Port B for Input/Output
	PORTB =0b11110000;	//Turn off both motors

	while (1)		//Loop Forever
	{
		PORTB=0b01100000;	//Make TekBot move forward
		if(PIND == 0b11111110){
		
			_delay_ms(500);	//Delays before turning
			PORTB=0b00000000;
			_delay_ms(500);
			PORTB=0b00100000;//turns the TekBot right
			_delay_ms(500);//time the TekBot turns for
		}
		if(PIND == 0b11111101){
			_delay_ms(500); //Delays before turning
			PORTB=0b00000000;
			_delay_ms(500);
			PORTB=0b01000000; //Turns the Tekbot left
			_delay_ms(500); //time the Tekbot turns for
		}
		if(PIND== 0b11111100){
			_delay_ms(500);	//Delays before turning
			PORTB=0b00000000;
			_delay_ms(500);
			PORTB=0b00100000;//turns the TekBot right
			_delay_ms(500);//time the TekBot turns for
			
		}
			
		
		
//		_delay_ms(500);
//		PORTB=0b00000000;	//Reverse
//		_delay_ms(500);
//		PORTB=0b00100000; //Turn Left
//		_delay_ms(1000);
//		PORTB=0b01000000;	//Turn Right
//		_delay_ms(2000);
//		PORTB=0b00100000; //Turn Left
//		_delay_ms(1000);
	};
}