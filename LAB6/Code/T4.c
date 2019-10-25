
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <avr/io.h>

#define Card_CPU 1000000// Clock Speed of the CPU

#define BAUDRATE 2400 //Display rate of 2400
#define MY_UBBRR (Card_CPU/16/BAUDRATE-1) //Baud Rate = 25 -> osc = 1MHz -> Display rate speed = 2400
#define Valid_Digits "123"
#define SELECT_LINE '>' // Char for line selection
#define TOTAL_AMOUNT_CHARS	24
#define TOTAL_AMOUNT_LINES 3 // change this to 8 for Task 5


int line = 0; //To keep track of the current line
char line_selection = 0;
char text[8][TOTAL_AMOUNT_CHARS] = { "", "", "", "", "", "", "", "" };

//Declaration of the differents methods that will be used
void toPutty(unsigned char);
void uart_int(void);
void line_switch(int);
char getChar();
char contains_character(char*, char);
void refresh_text(void);
void toSendToDisplay(char, char*, char*);


int main(void)
{
	uart_int(); //Method to initialize the display
	refresh_text();
	
	while (1) {
		//Get the input from PuTTY
		char input = getChar(); 

		
		if (line_selection) {//If the line selection is selected then do nothing and wait for a line number
			if (input < '1') {
				//if the input is lower than 1 than do nothing and wait for another input
				continue; 
			}
			//Check if the input is included in the valid digits if it is then go inside if otherwise skip the if statement
			if (contains_character(Valid_Digits, input)) {

				line_selection = 0;
				line_switch((input - '1')); // turn the input into sterile int
				
			}
		} //if there is no line selection then the code goes here
		else {
			//if the input is equal to '>' then change the line_selection to 1 (true)
			if (input == SELECT_LINE){

				line_selection = 1;

			}else if (input == 13 ){ //Otherwise if the input is the carriage return(ENTER) then switch line
			
				line_switch(-1);
			
			}else {
				//Otherwise add the character to the corresponding lane
				char* line = text[line];
				sprintf(line, "%s%c", line, input);
			}
		}
		//Update the screen with with the corresponding changes 
		refresh_text();
	}

	return 0;
}

//
void toPutty(unsigned char data){
	
	while(!(UCSR1A & (1<<UDRE1))){
		//Do nothing while no data has been sent
	}
	UDR1 = data; 
}

//To initialize the display
void uart_int(void) {
	UBRR1L = MY_UBBRR; //Set the Baud Rate to 25. 

	UCSR1B = (1<<RXEN1|1<<TXEN1); //Enable Receive and Transmit bit
}

char getChar(){
	
	while(!(UCSR1A & (1<<RXC1))){
		//While no data has been receive, do nothing
	}
	return UDR1; //return the received char.
}


//Method to send the characters to the Display
void toSendToDisplay(char address, char* command, char* message)
{
	// Get the lengths of the command characters and of the message
	int command_length = sizeof(command);
	int message_length = sizeof(message);

	// Calculate how big the buffer needs to be depending on the message, command. 
	int buffer_length = 1 + command_length + message_length + 3;

	//Will add the adress + command + message + checksum, together to then send it to the screen 
	char* buffer_message = malloc(buffer_length);

	//Create the buffer with all the info needed
	sprintf(buffer_message, "\r%c%s%s", address, command, message);

	//Checksum calculation 
	unsigned int checksum = 0;
	for (int i = 0; (buffer_message[i] != 0); i++){
		checksum += buffer_message[i];
	}
	
	
	checksum %= 256;

	//Add the checksum to the buffer
	sprintf(buffer_message, "%s%02X\n", buffer_message, checksum);

	//
	for (int i = 0; buffer_message[i]; i++){
		toPutty(buffer_message[i]);
	}
	
	//To free the space from memory
	free(buffer_message); 
}

//Method to check if the char "character" is in the "string". If it is return 1 otherwise return 0.
char contains_character(char* string, char character)
{
	char t;
	while ((t = *string++)){
		if (t == character) {
			return 1;
		}
	}
	return 0;
}

//Method to change between each line. if "-1" is sent then it will change the line. 
void line_switch(int number)
{
	//if numver =-1 then increment the current line
	if (number == -1) {
		line++;
		if (line >= TOTAL_AMOUNT_LINES)
		line = 0;
	}else {
		line = number;
	}
	
}

//TO UPDATE
void refresh_text()
{
	//To have the line to display
	int lineToDisplay = line;
	if (lineToDisplay < 1){
	lineToDisplay++;
	}
	// variable to set up the first and second line 
	char memory_ligne1_2[48] = "";
	char line_selected = line_selection ? '_' : (line + '1');

	
	sprintf(memory_ligne1_2, "Choose line: %c          %s", line_selected, text[lineToDisplay-1]);

	// Creates the third ligne 
	char memory_ligne3[48] = " ";
	if (text[lineToDisplay][0]){ //if the character is "0" do nothing otherwise send to "toSendToDisplay"
		//DO nothing
	}else { 
		for (int i = 0; i < 48; i++){
			memory_ligne3[i] = text[lineToDisplay][i];
		}
	}
	// Updates all the lignes of the screen. 
	toSendToDisplay('A', "O0001", memory_ligne1_2);
	toSendToDisplay('B', "O0001", memory_ligne3);
	toSendToDisplay('Z', "D001", 0);
}
