#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



#define F_CPU 1000000// Clock Speed
#include <util/delay.h>
#define BAUD 2400 //Communication Speed Display rate 2400
#define MYUBBRR (F_CPU/16/BAUD-1) //UBBRR = 25 -> osc = 1MHz and UBRR = 47 -> osc = 1,843200MHz

#define TOTAL_LINES 3 // change this to 8 for Task 5
#define TOTAL_CHARS	24

#define SEL_LINE '>' // Char for line selection


#define Valid_Digits "12"


// "Global" variables
int current_line = 0;
char line_selection = 0;
char lines[8][TOTAL_CHARS] = { "", "", "", "", "", "", "", "" };

// Forward declaration
void initialize(void);
void uart_int(void);
void toPutty(unsigned char data);
char getChar();
void toDisplayOnLCD(char address, char* specialCommand, char* stringChar);
char string_contains(char*, char);
void refresh_display(void);
void change_line(int);

// Entry point
int main(void)
{
	uart_int();
	refresh_display();
	
	while (1) {
		char in = getChar(); // Get input

		// Pharse the input - if selecting line, anticipate a [vaild] digit
		if (line_selection) {
			if (in < '1') continue; // if smaller than 0, ignore

			// Does 'in' exist in VAILD_DIGITS? (Is 'in' a vaild digit?)
			if (string_contains(Valid_Digits, in)) {
				change_line((in - '1')); // turn the input into a sterile integer before passing to function
				line_selection = 0;
			}
		}
		else {
			// Select line
			if (in == SEL_LINE)
			line_selection = 1;
			// End of line
			else if (in == 13 )// increment
			change_line(-1); // increment
			// Normal appending
			else {
				// Else add character to end of selected line
				char* line = lines[current_line];
				sprintf(line, "%s%c", line, in);
			}
		}

		refresh_display(); // Update the screen
	}

	return 0;
}


//INITALIZATION OF THE DISPLAY

void toPutty(unsigned char data){
	//WAIT FOR DATA TO BE RECEIVED and SHOW IT
	while(!(UCSR1A & (1<<UDRE1)));
	UDR1 = data;
}

void uart_int(void) {
	UBRR1L = MYUBBRR; //25 because we are setting the board at 1MHz
	/*Enable receiver and transmitter*/
	UCSR1B = (1<<RXEN1|1<<TXEN1); // Receive Enable (RXEN) bit // Transmit Enable (TXEN) bit
}

char getChar(){
	
	while(!(UCSR1A & (1<<RXC1)));
	return UDR1;
}


//METHOD TO DISPLAY ON THE SCREEN
void toDisplayOnLCD(char address, char* specialCommand, char* stringChar)
{
	// Get lengths
	int cmd_length = sizeof(specialCommand);
	int msg_length = sizeof(stringChar);

	// Calculate and allocate memory for buffer string
	int buffer_size = 1 + cmd_length + msg_length + 3;
	char* buffer = malloc(buffer_size*sizeof(char));

	// Assemble the frame (payload)
	sprintf(buffer, "\r%c%s%s", address, specialCommand, stringChar);

	// Calculate the checksum
	unsigned int checksum = 0;
	for (int i = 0; (buffer[i] != 0); i++){
		checksum += buffer[i];
	}
	
	
	checksum %= 256;

	// Final assembly of string
	sprintf(buffer, "%s%02X\n", buffer, checksum);

	// Send all chars in string
	for (int i = 0; buffer[i]; i++){
		toPutty(buffer[i]);
	}
	

	free(buffer); // we are done with the buffer
}

//
// string_contains
// Checks string for target char 'c', returns 1 (true) if found, otherwise 0 (false)
//
char string_contains(char* string, char c)
{
	char t;
	while ((t = *string++))
	if (t == c) return 1;
	return 0;
}

//TO UPDATE
void refresh_display()
{
	// Set up lines to show
	int display_line = current_line;
	if (display_line < 1)
	display_line++;
	
	// Set up variables necessary for the first & second display line
	char memory_space_A[48] = "";
	char line_selected = line_selection ? '_' : (current_line + '1');

	// Assemble the header line then copy line 1 to end
	//			 ******** - 24 char limit
	sprintf(memory_space_A, "Choose input: %c         %s", line_selected, lines[display_line-1]);

	// Set up the third display line, then copy chars from memory to it
	char memory_space_B[48] = " ";
	if (lines[display_line][0]) // Is selected string just a '\0'? If true; do nothing
	for (int i = 0; i < 48; i++)
	memory_space_B[i] = lines[display_line][i];

	// Boardcast all changes and then update the screen
	toDisplayOnLCD('A', "O0001", memory_space_A);
	toDisplayOnLCD('B', "O0001", memory_space_B);
	toDisplayOnLCD('Z', "D001", 0);
}

//
// change_line
// Increments (when target is -1) or sets current_line to 'target' line
//
void change_line(int target)
{
	// increment
	if (target == -1) {
		current_line++;
		if (current_line >= TOTAL_LINES)
		current_line = 0;
	}
	else // change to selection
	current_line = target;
}