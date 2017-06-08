;***********************************************************
;*
;*	AssemblerApplication7.asm
;*
;*	Controls the speed of TekBot motors
;*
;*	This is the skeleton file for Lab 7 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Zhenggan Zheng
;*			 Abhishek Raol
;*	   Date: 2/24/2016
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def	speed = r17
.def	speedinc = r18
.def	speedmode = r19
.equ	button0 = 0
.equ	button1 = 1
.equ	button2 = 2
.equ	button3 = 3
.equ	EngEnR = 4				; right Engine Enable Bit
.equ	EngEnL = 7				; left Engine Enable Bit
.equ	EngDirR = 5				; right Engine Direction Bit
.equ	EngDirL = 6				; left Engine Direction Bit
.equ	MovFwd = (1<<EngDirR|1<<EngDirL) ;Move forward command
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000
		rjmp	INIT			; reset interrupt
.org	$0002
		rcall	speedup
		reti
.org	$0004
		rcall	slowdown
		reti
.org	$0006
		rcall	maxspeed
		reti
.org	$0008	
		rcall	minspeed
		reti
		; place instructions in interrupt vectors here, if needed

.org	$0046					; end of interrupt vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
		; Initialize the Stack Pointer
		ldi r16, low(RAMEND)
		out SPL, r16
		ldi r16, high(RAMEND)
		out SPH, r16
		; Configure I/O ports
		ldi mpr, $ff
		out DDRB, mpr
		ldi mpr, $00
		out PORTB, mpr

		ldi mpr, $00
		out DDRD, mpr
		ldi mpr, $ff
		out PORTD, mpr

		; Configure External Interrupts, if needed
		ldi mpr, 0b11111111		
		sts EICRA, mpr			
		
			
		;configures masking		
		ldi mpr, 0b00001111					
		out EIMSK, mpr				
		

		; Configure 8-bit Timer/Counters for fast PWM, inverted mode. It is inverted since TekBot is active low
		ldi mpr, 0b01111001	
		out TCCR0, mpr
		ldi mpr, 0b01111001
		out TCCR2, mpr

		ldi mpr, 0
		out OCR0, mpr
		out OCR2, mpr
								
		ldi speedinc, 17	;This is the speed that it will increment or decrement by each level

		; Set initial speed, display on Port B pins 3:0
		clr speedmode
		clr speed

		ldi mpr, MovFwd		; Command to make TekBot move forwards indefinitely
		out PORTB, mpr		

		; Enable global interrupts (if any are used)
		sei
;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		
		rjmp	MAIN			; return to top of MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func:	Template function header
; Desc:	Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
maxspeed:
		ldi speed, 255	;Loads 255 into speed
		out OCR0, speed	;Outputs speed into OCR0
		out OCR2, speed ;Outputs speed into OCR2
		in mpr, PINB	;Reads input from PORTB
		andi mpr, 0b11110000	;Masks the first 4 bits of PORTB
		ori mpr, 15				;OR it with 15 to display max speed
		out PORTB, mpr			;Output that OR-ed number to PORTB
		reti					;Return from interrupt		
minspeed:
		ldi speed, 0	;Loads 0 into speed
		out OCR0, speed	;Outputs speed into OCR0
		out OCR2, speed ;Outputs speed into OCR2
		in mpr, PINB	;Reads input from PORTB
		andi mpr, 0b11110000	;Mask out the first 4 bits of PORTB
		ori mpr, 0				; OR it with 0 to display min speed
		out PORTB, mpr			;Output that OR-ed number to PORTB
		reti					;Return from interrupt
speedup:
		ldi mpr, 255	;Loads 255 into mpr
		cp speed, mpr	;compare that to speed
		breq return1	;If speed is maxed, return from interrupt
		add speed, speedinc	;Add 17 to speed
		out OCR0, speed		;Output speed to OCR0
		out OCR2, speed		;Output speed to OCR2
		inc speedmode		;Increment speed mode
		in mpr, PINB		;Read input from PORTB
		andi mpr, 0b11110000	;AND to mask out first 4 bits of PORTB
		or mpr, speedmode		;OR it with speed mode
		out PORTB, mpr			; Output it to PORTB
return1:
		reti	;Return from interrupt
slowdown:
		ldi mpr, 0		;Loads 0 into mpr
		cp speed, mpr	;Compare that to speed
		breq return2	;If already min speed, return from interrupt
		sub speed, speedinc	;Subtract 17 from speed
		out OCR0, speed		;Output speed to OCR0
		out OCR2, speed		;Output speed to OCR2
		dec speedmode		;Decrement speedmode
		in mpr, PINB		;Read input from PORTB
		andi mpr, 0b11110000	;AND to mask out 4 bits
		or mpr, speedmode		;OR it with speed mode
		out PORTB, mpr			;Output it to PORTB
return2:
		reti				;Return from interrupt
		

		
;***********************************************************
;*	Stored Program Data
;***********************************************************
		; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
		; There are no additional file includes for this program

