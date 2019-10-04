;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-04
; Author:
; Loic GALLAND
; Leonardo PEDRO
;
; Lab number: 4
; Title: Timer and UART
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program that creates a Square Wave Generator using a timer interrupt. It will make the light turn on for 0.5s and turn off for 0.5s
;
; Input ports: No input ports
;
; Output ports: PORTB for the LEDs 
;
; Subroutines: If applicable.
; Included files: m2560def.inc
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.org 0x00
rjmp restart

.org OVF0addr	;Address of the Timer Interrupt 0
rjmp timer0_int

.org 0x72



restart:
ldi r16, LOW(RAMEND) ; initialize SP, Stackpointer
out SPL, r16
ldi r16, HIGH(RAMEND)
out SPH, r16

ldi r16, 0xFF	;Set PORTB as output
out DDRB, r16

ldi r18, 0b11111111	;Initialize LEDs (Turn OFF)
out portb,r18


ldi r16, 0x05 ; prescaler value to TCCR0
out TCCR0B, r16 ; CS2 - CS2 = 101, osc.clock / 1024
ldi r16, 0b00000001; Timer 0 enable flag, TOIE0
sts TIMSK0, r16 ; to register TIMSK
ldi r16, 5 ; starting value for counter. Will count from 5 to 255 and therefore will take 250ms
out TCNT0, r16 ; counter register
sei ; enable global interrupt

.DEF COUNTER = r21	;To count how many times the program goes into the timer interrupt
ldi COUNTER, 0

start:	;Infinite loop that does nothing so that the timer interupt interupts something 
nop
rjmp start


timer0_int:	;TIMER INTERRUPT
	push r16 ;Push to Stack and input to SREG, so that no other interrupt interrupts the timer interrupt
	in r16, SREG ; save SREG on stack
	push r16

	ldi r16, 5 ; starting value for counter, (Reset the counter)
	out TCNT0, r16
	inc COUNTER	;Increase by 1 the COUNTER(r21)

	cpi COUNTER, 2	;Checks if COUNTER = 2, therefore 500ms has passed and the LEDs needs to be switched
	BRLT continue	;If COUNTER is less than 2 then branches to "continue". otherwise it will switch the LEDs
	
	ldi COUNTER,0	;Reset COUNTER
	COM r18	;COM the LEDs so that they change state from turned on to turned off 
	out PORTB, r18

	continue: 
	pop r16 ; restore SREG
	out SREG, r16	;Open the interrupts again.
	pop r16 ; restore register

reti