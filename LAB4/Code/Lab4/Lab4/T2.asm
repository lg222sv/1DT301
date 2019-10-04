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
; Function: Program that creates a Pulse Width Modulation using a timer interrupt. When clicking on buttons it will increase or decrease the amount of time in 1s that the LEDs will be on.
;			When the Duty cycle is 50% then the LEDs are 0.5s ON and 0.5s OFF. If the Duty cycle is 20%, then the LEDs will be ON for 0.2s and OFF 0.8s.
; 
; Input ports: PORTD to control the switches
;
; Output ports: PORTB for the LEDs 
;
; Subroutines: If applicable.
; Included files: m2560def.inc
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

.org 0x00
rjmp restart

.org OVF0addr	;Address of the Timer Interrupt number 0
rjmp timer0_int

.org INT0addr	;Address of the Interrupt number 0
rjmp PLUS

.org INT1addr ;Address of the Interrupt number 1
rjmp MINUS

.org 0x72



restart:;To initialize everything
ldi r16, LOW(RAMEND) ; initialize SP, Stackpointer
out SPL, r16
ldi r16, HIGH(RAMEND)
out SPH, r16

ldi r16, 0xFF	;Set PORTB as output
out DDRB, r16

ldi r16, 0x00	;Set PORTD as input
out DDRD, r16

ldi r18, 0b11111111	;Initialize LED state
out portb,r18

ldi r20,0b00001010 ;Setting INT0-INT1 into falling edge
sts EICRA,r20
ldi r20,0b0000011 ;Enable INT0-INT1
out EIMSK,r20

ldi r16, 0x05 ; prescaler value to TCCR0
out TCCR0B, r16 ; CS2 - CS2 = 101, osc.clock / 1024
ldi r16, 0b00000001; Timer 0 enable flag, TOIE0
sts TIMSK0, r16 ; to register TIMSK
ldi r16, 205 ; starting value for counter. Will count from 205 to 255 and therefore will take 50ms
out TCNT0, r16 ; counter register
sei ; enable global interrupt

.DEF COUNTER = r21	;Counter to counts how many times the program went into the timer interrupt
ldi COUNTER, 0
.DEF Duty = r22	;Register to change the duty cycle 
ldi Duty,10
sei	;Global interrupt enable

start:
nop	;Infinite loop that does nothing so that the timer interrupt can interruot something
rjmp start


timer0_int:	;Timer interrupt

	push r16	;Push to Stack and input to SREG, so that no other interrupt interrupts the timer interrupt
	in r16, SREG ;	
	push r16	;
	

	ldi r16, 205 ; starting value for counter.
	out TCNT0, r16
	inc COUNTER	;Increase by 1 the COUNTER

	cpi COUNTER, 20	;Checks if the COUNTER = 20
	Breq reset	;If it is, then reset
	
	cp COUNTER, Duty	;As long as the COUNTER is less than the Duty then turn ON the LEDS.
	BRLT ON				;Otherwise turn OFF the LEDs
	
	OFF:	;Routine for turning off the LEDs
		ldi r18,0xFF
		out PortB,r18
	rjmp END	;Jumps to END routine so that does not go into the ON and reset routine.

	ON:		;Rountine for turning ON the LEDs
		ldi r18,0x00
		out PORTB,r18
	rjmp END	;Jumps to END routine so that does not go into the reset routine.

	reset: 
		ldi COUNTER,0	;Reset the COUNTER

END:	
pop r16 ; restore SREG
out SREG, r16	;Enables the interrupts again. 
pop r16 ; restore register
 
reti	;Return from timer interrupt

PLUS:	;Interrupt to increase the Duty cycle
cpi Duty,20	;Checks if duty =20. Do nothing if it is because 20 should be the maximum.
breq DONE2
inc Duty	;Otherwise increase the Duty by 1

DONE2: nop	;Do nothing

RETI	;return from interrupt

MINUS:	;Interrupt to decrease the Duty Cycle 
cpi Duty,0	;Checks if duty =0. Do nothing if it is because 0 should be the minimum.
breq DONE

dec Duty	;Decrease Duty by 1

DONE: nop	;Do nothing
RETI	;return from interrupt
