;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2016-09-15
; Author:
; Student name 1
; Student name 2
;
; Lab number: 1
; Title: How to use the PORTs. Digital input/output. Subroutine call.
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Describe the function of the program, so that you can understand it,
; even if you're viewing this in a year from now!
;
; Input ports: Describe the function of used ports, for example on-board switches
; connected to PORTA.
;
; Output ports: Describe the function of used ports, for example on-board LEDs
; connected to PORTB.
;
; Subroutines: If applicable.
; Included files: m2560def.inc
;
; Other information:
;
; Changes in program: (Description and date)
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

; Initialize SP, Stack Pointer
ldi r20, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R20 ; SPH = high part of RAMEND address
ldi R20, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R20 ; SPL = low part of RAMEND address


ldi r16, 0xFF ;setting up the data direction register port B
out DDRB, r16 ;Set port B as output

ldi r16,0x00
out DDRA, r16

ldi r19,1
ldi r25, 0xFF
out PortB,r25
ldi r24,0b11111110

Main:
	in r17,PINA
	cp r17,r24
	breq loop
	
rjmp Main

loop:
	inc r19
	cpi r19,7
	breq reset
	in r17,PINA
	cp r17,r25
	breq RD 
rjmp loop

reset:
ldi r19,1
rjmp Main

RD:
	cpi r19,1
	breq ONE
	cpi r19,2
	breq TWO
	cpi r19,3
	breq THREE
	cpi r19,4
	breq FOUR
	cpi r19,5
	breq FIVE
	cpi r19,6
	breq SIX
rjmp RD
ONE:
ldi r18,0b11101111
out PortB,r18
rjmp Main
TWO:
ldi r18,0b10111011
out PortB,r18
rjmp Main
THREE:
ldi r18,0b10101011
out PortB,r18
rjmp Main
FOUR:
ldi r18,0b00111001
out PortB,r18
rjmp Main
FIVE:
ldi r18,0b00101001
out PortB,r18
rjmp Main
SIX:
ldi r18,0b00010001
out PortB,r18
rjmp Main