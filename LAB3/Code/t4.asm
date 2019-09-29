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
; Function: Same program as Task 3, but now there is another Interrupt to simulate the brakes. When breaking all the lights needs to be turned on.
;			When blinking right LED7-4 light up and LED3-0 do Ring Counter to the right.
;			When blinking left LED3-0 light up & LED7-4 do Ring Counter to the left.
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

.org INT0addr	;Address of Interrupt 0, used for blinking right.
rjmp BlinkRight	

.org INT1addr	;Address of Interrupt 1, used for normal lights.
rjmp Normal_Interrupt

.org INT2addr	;Address of Interrupt 2, used for the break lights.
rjmp Press_Break

.org INT3addr	;Address of Interrupt 3, used for blinking left.
rjmp BlinkLeft

.org 0x72

start:
; Initialize SP, Stack Pointer
ldi r20, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R20 ; SPH = high part of RAMEND address
ldi R20, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R20 ; SPL = low part of RAMEND address

ldi r20,0b10101010 ;Setting INT0-INT1-INT2-INT3 into falling edge
sts EICRA,r20
ldi r20,0b00001111 ;Enable INT0-INT1-INT2-INT3
out EIMSK,r20

ldi r17,0xFF	;Set PORTB as output
out DDRB, r17

ldi r17,0x00	;Set PORTD as input
out DDRD,r17

ldi r16, 0xFF	;Iniatialize the LEDs
out PORTB, r16

.def LED = r16	;Give the name "LED" to the register number 16
.def Normal_Right = r22	;Give the name "Normal_Right" to the register number 22, will be used to simulate the left rear light
ldi Normal_Right, 0b11000000
.def Normal_Left = r21	;Give the name "Normal_Left" to the register number 21 will be used to simulate the right rear light
ldi Normal_Left,0b00000011

sei	;Global interrupt enable


ldi r23, 1	;Variable to know in which configuration we are in.


Main:
	cpi r23,1	;If r23 = 1 then branch to NLED which is the normal LEDs:
	breq NLED

	cpi r23, 2	;If r23 = 2 then branch to BLeft which is the blinking to right.
	breq BRight

	cpi r23, 3	;If r23 = 3 then branch to BLeft which is the blinking to left.
	breq BLeft
rjmp Main

NLED:
	ldi LED, 0b00000000	;Load 0x00 into "LED", to "reset" it
	ADD LED,Normal_Right	;Add both side of the rear lights with binary code
	add LED,Normal_Left		; 0b11000011
	mov r17,LED	;Copy the info from LED
	COM r17
	out PORTB, r17
rjmp Main

BLeft: ;RING COUNTER
	SBIS PORTB,PINB7 ;If the LED7 is on then reset the LEDs otherwise skip the next line
		ldi LED,0b00010000
	SBIC PORTB,PINB7	;If the LED7 is not on then Rotate otherwise skip the next line 
		rol LED;Rotate to the left 
	call Out_LED_Left
	call Delay	;Delay of 0.5 sec
rjmp main


BRight:
	SBIS PORTB,PINB0 ;If the LED0 is on then reset the LEDs otherwise skip the next line
		ldi LED,0b00001000
	SBIC PORTB,PINB0	;If the LED0 is not on then Rotate otherwise skip the next line 
		ror LED	;Rotate to the left 
	call Out_LED_Right
	call Delay	;Delay of 0.5 sec
rjmp main

Out_LED_Right:
	mov r17,LED
	add r17,Normal_Right
	com r17
	out PORTB,r17
RET
Out_LED_Left:
	mov r17,LED
	add r17,Normal_Left
	com r17
	out PORTB,r17
RET
Normal_Interrupt:
ldi r23,1
ldi Normal_Right, 0b11000000
ldi Normal_Left,0b00000011
RETI

BlinkRight:
ldi r23, 2
ldi LED,0b00001000
ldi Normal_Right, 0b11000000
ldi Normal_Left,0b00000011
RETI

BlinkLeft:
ldi r23, 3
ldi LED,0b00010000
ldi Normal_Right, 0b11000000
ldi Normal_Left,0b00000011
RETI
	
Press_Break:
	ldi Normal_Left,0b00001111
	ldi Normal_Right,0b11110000
RETI
		


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