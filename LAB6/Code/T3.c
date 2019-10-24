/*
 * LAB6.c
 *
 * Created: 2019-10-14 14:04:09
 * Author : lg222sv
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define F_CPU 1000000// Clock Speed
#include <util/delay.h>
#define BAUD 2400 //Communication Speed Display rate 2400
#define MYUBBRR (F_CPU/16/BAUD-1) //UBBRR = 25 -> osc = 1MHz and UBRR = 47 -> osc = 1,843200MHz

void uart_int(void);
void toPutty(unsigned char data);
void  toDisplayOnLCD(char* stringChar);


void  toDisplayOnLCD(char* stringChar){  //Showing data into the big display
	
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
	UBRR1L = MYUBBRR; //25 --> board at 1MHz
	/*Enable receiver and transmitter*/
	UCSR1B = (1<<RXEN1|1<<TXEN1); // Receive Enable (RXEN) bit // Transmit Enable (TXEN) bit
}

int main(void)
{
	uart_int();
	

	char* data = "abc";
	char *txt = "\rAO0001";
	
	for(int i =0;i<strlen(data);i++){ 	//Go through every character and add it to the string 
		char a = data[i];
		size_t len = strlen(txt);
		
		char *str2 = malloc(len + 1 + 1); //Giving memory space to allocate the data to str2
		strcpy(str2, txt); // copy txt to str2
		
		str2[len] = a;  
		str2[len + 1] = '\0'; // adding the end char \0
		 toDisplayOnLCD(str2); 
		free(str2); // deallocate the memory space used by malloc()
		
		str2 = "\rZD0013C";
		 toDisplayOnLCD(str2);
		_delay_ms(5000); //wait 5s
	}

	
	return 0;
}


