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

ldi r16, 0xFF ;setting up the data direction register port B
out DDRB, r16 ;Set port B as output

ldi r16,0x00
out DDRA, r16

ldi r25, 0
ldi r24,0

ldi r17, 0b11111111
out PORTB, r17

ldi r18, 0b11111110

my_loop:
	in r19, PINA
	cp r18,r19
	breq counter
rjmp my_loop

counter:
inc r25
mov r20,r25
com r20
out portB,r20
	loop:
		in r19,PINA
		cp r19,r17
		breq counter2
	rjmp loop

counter2:
inc r25
mov r20,r25
com r20
out portB,r20
rjmp my_loop