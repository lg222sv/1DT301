;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2015-09-03
; Author:
; Student name 1
; Student name 2
;
; Lab number: 3
; Title: How to use interrupts
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

.org 0x00	;Location where the program will start
rjmp start

.org INT0addr	;INT0 interrupt address
rjmp interrupt_0

.org 0x72

start:
.def LIGHT =r21	;Give a name to r21
; Initialize SP, Stack Pointer
ldi r20, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R20 ; SPH = high part of RAMEND address
ldi R20, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R20 ; SPL = low part of RAMEND address

ldi r16,0xFF	;Load 0xFF into r16 to initialize PORTB
out DDRB,r16	
ldi r16,0x00	;Load 0x00 into r16 and initialize PORTD
out DDRD,r16

ldi r18, 0xFF	;initiliaze the LEDs (turn them off)
out PORTB, r18

mov LIGHT,r18	;Copy the r18 into "LIGHT"
;Initialised the Interrupts
ldi r16, 0b00000010	;INT0 falling edge
sts EICRA, r16	;Setup internal 

ldi r16, 0b00000001	;INT0 enable, pin 0 of PORT D
out EIMSK, r16
sei	;Global interrupt enable

main:
	out PORTB, LIGHT	;Turn on the LEDs
rjmp main

interrupt_0:
com LIGHT	;Change the 0s into 1s, to show the lights on
RETI	
