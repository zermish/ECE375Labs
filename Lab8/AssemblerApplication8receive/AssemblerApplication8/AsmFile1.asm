;***********************************************************
;*
;*	Enter Name of file here
;*
;*	Enter the description of the program here
;*
;*	This is the TRANSMIT skeleton file for Lab 8 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Enter your name
;*	   Date: Enter Date
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multi-Purpose Register

.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit
; Use these action codes between the remote and robot
; MSB = 1 thus:
; control signals are shifted right by one and ORed with 0b10000000 = $80
.equ	MovFwd =  ($80|1<<(EngDirR-1)|1<<(EngDirL-1))	;0b10110000 Move Forward Action Code
.equ	MovBck =  ($80|$00)								;0b10000000 Move Backward Action Code
.equ	TurnR =   ($80|1<<(EngDirL-1))					;0b10100000 Turn Right Action Code
.equ	TurnL =   ($80|1<<(EngDirR-1))					;0b10010000 Turn Left Action Code
.equ	Halt =    ($80|1<<(EngEnR-1)|1<<(EngEnL-1))		;0b11001000 Halt Action Code
.equ	BotAddress = 0b01100111
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt
.org	$0002
		rcall MoveForward
		reti
.org	$0004
		rcall MoveBackward
		reti
.org	$0006
		rcall Turnleft
		reti
.org	$0008
		rcall Turnright
		reti
.org	$0010
		rcall Stop
		reti

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	ldi mpr, high(RAMEND)
	out SPH, mpr
	ldi mpr, low(RAMEND)
	out SPL, mpr
	;I/O Ports
	ldi mpr, 0b00000000
	out DDRD, mpr
	ldi mpr 0b11111111
	out PORTD, mpr
	;USART1
		;Set baudrate at 2400bps
	ldi mpr, high(416)
	sts UBRR1H, mpr
	ldi mpr, low(416)
	sts UBRR1L, mpr
		;Enable transmitter
	ldi mpr, (1<<TXEN1)
    sts UCSR1B, mpr
		;Set frame format: 8 data bits, 2 stop bits
	ldi mpr, (0<<UMSEL1|1<<USBS1|1<<UCSZ11|1<<UCSZ10)
	sts UCSR1C, mpr

	;set up external interrupts
	ldi mpr, 0b11111111
	sts EICRA, mpr

	ldi mpr, 0b11111111
	sts EICRB, mpr

	ldi mpr, 0b00011111
	out EIMSK, mpr
	;Other

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
	;TODO: ???
		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************
MoveForward:
	out UDR1, BotAddress
	ldi mpr, MovFwd
	out UDR1, mpr
MoveBackward:
	out UDR1, BotAddress
	ldi mpr, MovBck
	out	UDR1, mpr
Turnleft:
	out UDR1, BotAddress
	ldi mpr, TurnL
	out UDR1, mpr
Turnright:
	out UDR1, BotAddress
	ldi mpr, TurnR
	out UDR1, mpr
Stop:
	out UDR1, BotAddress
	ldi mpr, Halt
	out UDR1, mpr
;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************