;***********************************************************
;*
;*	AssemblerApplication8Transmitbackup.asm
;*
;*	
;*
;*	This is the TRANSMIT file for Lab 8 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Zhenggan Zheng and Abhishek Raol
;*	   Date: 3/11/2016
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
.equ	Frze = 0b11111000
.equ	BotAddress = $2A
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

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
	ldi mpr, 0b11111111
	out PORTD, mpr

	ldi		mpr, $FF		; Set Port B Data Direction Register
	out		DDRB, mpr		; for output
	ldi		mpr, $00		; Initialize Port B Data Register
	out		PORTB, mpr		; so all Port B outputs are low		

	;USART1
		;Set baudrate at 2400bps

	ldi mpr, (1<<U2X1)
	sts UCSR1A, mpr
	ldi mpr, high(832)
	sts UBRR1H, mpr
	ldi mpr, low(832)
	sts UBRR1L, mpr
		;Enable transmitter
	ldi mpr, (1<<TXEN1)
    sts UCSR1B, mpr
		;Set frame format: 8 data bits, 2 stop bits
	ldi mpr, (0<<UMSEL1|1<<USBS1|1<<UCSZ11|1<<UCSZ10)
	sts UCSR1C, mpr

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:	;Main subroutine which polls PORTD for input
		in mpr, PIND	;Reads input from PORTD and compares to each possible command and calls the subroutine accordingly
		cpi mpr, 0b11111110
		brne Checkback
		rcall MoveForward
		jmp MAIN
CheckBack:
		cpi mpr, 0b11111101	;All these subroutines do the same thing which is basically call their respective routine when
		brne Checkleft		;Their command is read
		rcall MoveBackward
		rjmp MAIN
Checkleft:
		cpi mpr, 0b11101111
		brne Checkright
		rcall Turnleft
		rjmp MAIN
Checkright:
		cpi mpr, 0b11011111
		brne Checkfreeze
		rcall Turnright
		rjmp MAIN
Checkfreeze:
		cpi mpr, 0b01111111
		brne Checkstop
		rcall Freeze
		rjmp MAIN
Checkstop:
		cpi mpr, 0b10111111
		brne MAIN 
		rcall Stop
		rjmp MAIN
		;cpi r19, 0b00000010
		;breq MoveBackward
		;cpi r19, 0b00000100
		;breq Turnleft
		;cpi r19, 0b00001000
		;breq Turnright
		;cpi r19, 0b00010000
		;breq Stop
	;TODO: ???
		;rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************
MoveForward:   ;Move Forward subroutine
	out PORTB, mpr       ;Outputs to LED to display button press       
	ldi mpr, BotAddress		;Loads Address to transmit
	sts UDR1, mpr			;Transmits
	ldi mpr, MovFwd			;Loads MovFwd
	sts UDR1, mpr			;Transmits
	ret
MoveBackward:
	out PORTB, mpr			;The rest of the subroutines are basically the same as MoveForward
	ldi mpr, BotAddress		;except they load their own commands into UDR1
	sts UDR1, mpr
	ldi mpr, MovBck
	sts UDR1, mpr
	ret
Turnleft:
	out PORTB, mpr
	ldi mpr, BotAddress
	sts UDR1, mpr
	ldi mpr, TurnL
	sts UDR1, mpr
	ret
Turnright:
	out PORTB, mpr
	ldi mpr, BotAddress
	sts UDR1, mpr
	ldi mpr, TurnR
	sts UDR1, mpr
	ret
Stop:
	out PORTB, mpr
	ldi mpr, BotAddress
	sts UDR1, mpr
	ldi mpr, Halt
	sts UDR1, mpr
	ret
Freeze:
	out PORTB, mpr		
	ldi mpr, BotAddress
	sts UDR1, mpr
	ldi mpr, Frze
	sts UDR1, mpr
	ret

;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************


