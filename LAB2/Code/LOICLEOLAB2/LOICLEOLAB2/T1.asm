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
ldi r16, 0x00
out DDRA, r16

ldi r24, 0b11111110
;ldi r25, 0b11111110

RC:
	ldi r21, 0b11111111; inital LED state
	out portB, r21
	mov r17, r21
	ldi r22, 0xFF
	ldi r23, 0b11111110
 
	RC_loop:
		out portB, r17
		rol r17
		CALL Delay1
		in r25, PINA
		cp r25,r24
		breq JC
		cp r17, r22
		breq RC_light
	rjmp RC_loop
	RC_light:
		rol r17
		out portB, r17
		rjmp RC_loop
rjmp RC

JC:
	ldi r21, 0b11111110
	ldi r22, 0b11111111 ;desired one 
	ldi r23, 0b00000000

	my_loop1:
		out portB, r21
		LSL r21
		CALL Delay1
		in r25, PINA
		cp r25,r24
		breq RC
		cp r21, r23 ;compare  info with desired one 
		breq light
	rjmp my_loop1

	light:
		out portB, r23
		CALL Delay1
		ldi r21, 0b10000000
		out portB, r21
		Second_loop:
			in r25, PINA
			cp r25,r24
			breq RC
			out portB, r21
			ASR r21
			CALL Delay1
			cp r21, r22 ;compare  info with desired one 
			breq my_loop
		rjmp Second_loop
rjmp JC

Delay1:
; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
;
; Delay 1 950 500 cycles
; 500ms at 3.901 MHz

    ldi  r18, 10
    ldi  r19, 230
    ldi  r20, 22
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
RET


