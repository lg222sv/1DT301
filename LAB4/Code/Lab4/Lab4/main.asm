;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-30
; Author:
; Student name 1
; Student name 2
;
; Lab number: 4
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
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.org 0x00
rjmp start

.org 0x72


start:
	ldi r16,0xFF
	out DDRB, r16
	
	out PORTB,r16

	ldi r16, 12
	sts UBRR1L , r16

	ldi r16, (1<<RXEN1 | 1<<TXEN1)
	sts UCSR1B, r16

GetChar:	;Receive data
	lds r16, UCSR1A	;read UCSR1A I/0 register to r20
	sbrs r16,RXC1	;RXC1=1 -> new Character
	rjmp GetChar	;RXC1=0 -> no character received
	lds r18,UDR1	;Read character in UDR

Port_output:
	com r18
	out PORTB,r18	;Write character to PORTB 
	com r18

PutChar:
	lds r16, UCSR1A	;Read UCSR1A i/O register to r20
	sbrs r16, UDRE1	;UDRE1 =1 => buffer is empty 
	rjmp PutChar	;UDRE1 = 0 => buffer is not empty
	sts UDR1,r18	;write character to UDR1
	rjmp GetChar
