;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-20
; Author:
; Loic GALLAND
; Leonardo PEDRO
;
; Lab number: 6
; Title: CyberTech Wall Display
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Write a program that writes a character on the CyberTech Display
;			
; Input ports: Port0 (RS232) VGA 
;
; Output ports: Port0 (RS232) VGA
;
; Subroutines: If applicable.
; Included files: m2560def.inc
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#include <avr/io.h>
#include <stdio.h>
#include <string.h>
//#include <util/delay.h>
#define F_CPU 1843200 //Clock Speed
#define BAUD 2400
#define MYUBRR (F_CPU/16/BAUD-1)

	
void USART_Unit(unsigned int ubrr);
void toPutty(unsigned char data);




int main(void)
{
	USART_Unit(MYUBRR);
	char* temp = "\rAO0001LOIC&LEO"; //Begiining code to send to the display + actual text.
	int length = 15;
	int checksum = 0;
	
	//Use checksum to make sure that what was sent and was received is the same.
	for (int i=0;i<strlen(temp);i++ )
	{
		checksum+=temp[i];
	}
	
	checksum%=256;
	

	char toPrint[strlen(temp)+3];
	
	sprintf(toPrint,"%s%02X\n",temp,checksum);
	
	for(int j=0;j<length+4;j++){
		toPutty(toPrint[j]);
	}
	
	temp = "\rZD0013C\n";//End code to be sent to the display to say that what needed to be sent has been sent.
	
	for (int k=0;k<strlen(temp);k++)
	{
		toPutty(temp[k]);
	}
	
    
    
}
//TO INITIALIZE THE USART CONNECTION
void USART_Unit(unsigned int ubrr){
	UBRR1L = ubrr;
	
	/*	Enable receiver and transmitter	*/
	UCSR1B = (1<<RXEN1)|(1<<TXEN1);
}

//To send to the the display the character
void toPutty(unsigned char data){
	// Wait for data to be received
	while ( !(UCSR1A & (1 << UDRE1))); //Receive Complete
	//(RXCn) flag //Return received data from buffer
	UDR1 = data;
}