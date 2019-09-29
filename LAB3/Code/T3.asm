;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-29
; Author:
; Loic GALLAND
; Leonardo PEDRO
;
; Lab number: 3
; Title: How to use interrupts
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program that acts like the rear lights of a car. Either blinking right, left or just normal
;
; Input ports: PORTD
;
; Output ports: PORTB
;
; Subroutines: If applicable.
; Included files: m2560def.inc
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.org 0x00
rjmp start

.org INT0addr	;Address of Interrupt 0
rjmp BlinkRight	

.org INT1addr  ;Address of Interrupt 1
rjmp normal

.org INT2addr	;Address of Interrupt 2
rjmp BlinkLeft

.org 0x72

start:
; Initialize SP, Stack Pointer
ldi r20, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R20 ; SPH = high part of RAMEND address
ldi R20, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R20 ; SPL = low part of RAMEND address

ldi r20,0b00101010 ;Setting INT0-INT1-INT2 into falling edge
sts EICRA,r20
ldi r20,0b00000111 ;Enable INT0-INT1-INT2
out EIMSK,r20

ldi r17,0xFF	;Set PORTB as output
out DDRB, r17

ldi r17,0x00	;Set PORTD as input
out DDRD,r17

ldi r16, 0xFF	;Initialized LED state
out PORTB, r16

.def LED = r16	;Give the name "LED" to the register number 16
.def Normal_Right = r22	;Give the name "Normal_Right" to the register number 22, will be used to simulate the left rear light
ldi Normal_Right, 0b11000000
.def Normal_Left = r21	;Give the name "Normal_Left" to the register number 21 will be used to simulate the right rear light
ldi Normal_Left,0b00000011
sei	;Global interrupt enable


ldi r23, 1	;Variable to know in which configuration we are in.


Main:
	cpi r23, 1	;If r23 = 1 then branch to NLED which is the normal LEDs:
	breq NLED			

	cpi r23, 2	;If r23 = 2 then branch to BLeft which is the blinking to left.
	breq BLeft

	cpi r23, 3 ;If r23 = 3 then branch to BLeft which is the blinking to left.
	breq BRight


rjmp Main

NLED:	;Routine for turning on the both rear lights, for the "normal" configuration
ldi LED, 0b00111100
out PORTB, LED
rjmp Main	;Jumps back to "Main" loop 

BLeft: ;RING COUNTER

	SBIS PORTB,PINB7 ;If the LED7 is on then reset the LEDs otherwise skip the next line
		ldi LED,0b00010000
	SBIC PORTB,PINB7	;If the LED7 is not on then Rotate otherwise skip the next line 
		rol LED	;Rotate to the left 
	mov r17,LED	;Copy the info of "LED" and load it into r17
	add r17,Normal_Left	;Add the 0b00000011 to r17 to make it become like that: 00010011 for the first round 
	COM r17	;One's Complement of r17 to switch the 0s into 1s to output the correct binary code for the LEDs
	out PORTB,r17	;output to PORTB to show the LEDs
	call Delay	;Delay of 0.5 sec
rjmp main


BRight:
	SBIS PORTB,PINB0 ;If the LED0 is on then reset the LEDs otherwise skip the next line
		ldi LED,0b00001000
	SBIC PORTB,PINB0	;If the LED0 is not on then Rotate otherwise skip the next line 
		ror LED	;Rotate to the left 
	mov r17,LED	;Copy the info of "LED" and load it into r17
	add r17,Normal_Right	;Add the 0b00000011 to r17 to make it become like that: 00010011 for the first round 
	COM r17	;One's Complement of r17 to switch the 0s into 1s to output the correct binary code for the LEDs
	out PORTB,R17	;output to PORTB to show the LEDs
	call Delay	;Delay of 0.5 sec
rjmp main


normal:	;Interupt for the normal lights
ldi r23, 1	;Load 1 into r23 to know later on which program we are in
RETI	;Return to where the interrupt interrupted the code 

BlinkLeft:	;Interrupt for when we need to blink left 
ldi r23, 2	;Load 2 into r23 to know later on which program we are in
ldi LED,0b00010000	;Initial state of the LEDs 
RETI	;Return to where the interrupt interrupted the code 

BlinkRight:	;Interrupt for when we need to blink left 
ldi r23, 3	;Load 3 into r23 to know later on which program we are in
ldi LED,0b00001000	;Initial state of the LEDs
RETI	;Return to where the interrupt interrupted the code 

Delay:
; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
; Delay 500 000 cycles
; 500ms at 1 MHz
    ldi  r18, 3
    ldi  r19, 138
    ldi  r20, 86
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1
RET