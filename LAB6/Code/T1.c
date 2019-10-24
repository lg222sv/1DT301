/*
 * LAB6.c
 *
 * Created: 2019-10-14 14:04:09
 * Author : lg222sv
 */ 

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
	char* temp = "\rAO0001LOIC&LEO";
	int length = 15;
	int checksum = 0;
	
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
	
	temp = "\rZD0013C\n";
	
	for (int k=0;k<strlen(temp);k++)
	{
		toPutty(temp[k]);
	}
	
    
    
}
void USART_Unit(unsigned int ubrr){
	UBRR1L = ubrr;
	
	/*	Enable receiver and transmitter	*/
	UCSR1B = (1<<RXEN1)|(1<<TXEN1);
}


void toPutty(unsigned char data){
	// Wait for data to be received
	while ( !(UCSR1A & (1 << UDRE1))); //Receive Complete
	//(RXCn) flag //Return received data from buffer
	UDR1 = data;
}