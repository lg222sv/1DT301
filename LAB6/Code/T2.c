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
#define FCPU 1000000// Clock Speed
#define BAUD 2400 //Communication Speed Display rate 2400
#define MYUBBRR (FCPU/16/BAUD-1) //UBBRR = 25 -> osc = 1MHz and UBRR = 47 -> osc = 1,843200MHz

void uart_int(void);
void toPutty(unsigned char data);
void toDisplayOnLCD(char* stringChar);

int main(void)
{
	uart_int();
	
	char* txt = "\rAO0001First Line              Second Line";
	
	toDisplayOnLCD(txt);
	

	
	txt = "\rBO0001Third Line";
	toDisplayOnLCD(txt);
	
	txt = "\rZD0013C\n";
	toDisplayOnLCD(txt);
	
	return 0;
}

void toDisplayOnLCD(char* stringChar){
	
	int checksum = 0;
	
	for(int i =0; i<strlen(stringChar);i++){
		checksum += stringChar[i];
	}
	
	checksum%=256;
	
	char toDisplay [strlen(stringChar)+3];
	sprintf(toDisplay, "%s%02X\n", stringChar, checksum); //%02x means print at least 2 digits, prepends it with 0's if there's less.
	//%02x is used to convert one character to a hexadecimal string
	
	for (int i = 0; i<strlen(stringChar)+3;i++){
		toPutty(toDisplay[i]);
	}
}

void toPutty(unsigned char data){

	while(!(UCSR1A & (1<<UDRE1)));
	UDR1 = data;
}

void uart_int(void) {
	UBRR1L = MYUBBRR; //25 because we are setting the board at 1MHz
	/*Enable receiver and transmitter*/
	UCSR1B = (1<<RXEN1|1<<TXEN1); // Receive Enable (RXEN) bit // Transmit Enable (TXEN) bit
}