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
; Function: Write a program that change text strings on the display. 
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
#include <stdlib.h>

#define ClockSpeed 1000000// Clock Speed
#include <util/delay.h>
#define BAUD 2400 //Communication Speed Display rate 2400
#define MYUBBRR (ClockSpeed/16/BAUD-1) //UBBRR = 25 -> osc = 1MHz

void uart_int(void);
void toPutty(unsigned char);
void toDisplayOnLCD(char*);


void  toDisplayOnLCD(char* character){  //Showing data into the big display
	
	int checksum = 0;
	
	for(int i =0; i<strlen(character);i++){
		checksum += character[i];
	}
	
	checksum%=256;
	
	char sendingToDisplay [strlen(character)+3];
	sprintf(sendingToDisplay, "%s%02X\n", character, checksum); //%02x means print at least 2 digits, prepends it with 0's if there's less.
	//%02x is used to convert one character to a hexadecimal string
	
	for (int i = 0; i<strlen(character)+3;i++){
		toPutty(sendingToDisplay[i]);
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
	

	char* text = "abc";
	char* begin = "\rAO0001";
	
	for(int i =0;i<strlen(text);i++){ 	//Go through every character and add it to the string 
		char a = text[i];
		size_t length = strlen(begin);
		
		char* textToBeSent = malloc(length + 1 + 1); //Giving memory space to allocate the data to str2
		strcpy(textToBeSent, begin); // copy txt to str2
		
		textToBeSent[length] = a;  
		textToBeSent[length + 1] = '\0'; // adding the end char \0
		 toDisplayOnLCD(textToBeSent); 
		free(textToBeSent); // deallocate the memory space used by malloc()
		
		//Ending combination to tell the Display that everything was sent.
		textToBeSent = "\rZD0013C";
		 toDisplayOnLCD(textToBeSent);

		_delay_ms(4000); //wait 4s between each letter so that we actually have time to see the change.
	}

	
	return 0;
}


