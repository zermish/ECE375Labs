;***********************************************************
;*
;*	AssemblerApplication8.asm
;*
;*	Receives input via USART1 and runs a robot accordingly. Can also issue freeze commands to 
;*	to other robots nearby.
;*
;*	This is the RECEIVE skeleton file for Lab 8 of ECE 375
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
.def	waitcnt = r20			; Register to store count
.def	ilcnt = r18				; Register to store inner loop
.def	olcnt = r19				; Register to store outer loop

.equ	WTime = 100				; Wait time
.equ	WskrR = 0				; Right Whisker Input Bit
.equ	WskrL = 1				; Left Whisker Input Bit
.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit
.equ	BotAddress = $2A;(Enter your robot's address here (8 bits));7F

;/////////////////////////////////////////////////////////////
;These macros are the values to make the TekBot Move.
;/////////////////////////////////////////////////////////////
.equ	MovFwd =  (1<<EngDirR|1<<EngDirL)	;0b01100000 Move Forward Action Code
.equ	MovBck =  $00						;0b00000000 Move Backward Action Code
.equ	TurnR =   (1<<EngDirL)				;0b01000000 Turn Right Action Code
.equ	TurnL =   (1<<EngDirR)				;0b00100000 Turn Left Action Code
.equ	Halt =    (1<<EngEnR|1<<EngEnL)		;0b10010000 Halt Action Code

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
		rcall HitRight			; Interrupt to trigger HitRight routine
		reti
.org	$0004 
		rcall HitLeft			; Interrupt to trigger HitLeft Routine
		reti
.org	$003C
		rcall Receive			;Interrupt that triggers when receives a command from USART
		reti

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	ldi mpr, high(RAMEND)
	out sph, mpr
	ldi mpr, low(RAMEND)
	out spl, mpr
	;I/O Ports
	ldi mpr, $ff
	out DDRB, mpr
	ldi mpr, $00
	out PORTB, mpr

	ldi mpr, $00
	out DDRD, mpr

	ldi mpr, $00
	out DDRE, mpr
	ldi r24, 0
	ldi r26, 0
	;USART1
	;Set baudrate at 2400bps
	ldi mpr, (1<<U2X1)
	sts UCSR1A, mpr

	ldi mpr, high(832)
	sts UBRR1H, mpr
	ldi mpr, low(832)
	sts UBRR1L, mpr
	;Enable receiver and enable receive interrupts
	ldi mpr, (1<<TXEN1|1<<RXEN1|1<<RXCIE1)
	sts UCSR1B, mpr
	;Set frame format: 8 data bits, 2 stop bits
	ldi mpr, (0<<UMSEL1|1<<USBS1|1<<UCSZ11|1<<UCSZ10)
	sts UCSR1C, mpr
	;External Interrupts
	;Set the External Interrupt Mask
	ldi mpr, (1<<INT0)|(1<<INT1)
	out EIMSK, mpr
	;Set the Interrupt Sense Control to falling edge detection
	ldi mpr, (1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)
	sts EICRA, mpr

	;Other
	sei
;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
	;TODO: ???
		
		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************
Receive:				;Subroutine to recieve USART
		lds r17, UDR1	; Loads USART into register 17
		mov mpr, r17	; Move it to MPR
		andi mpr, 0b10000000	;AND it to mask out the other bits
		tst mpr					; If mpr is 0
		brne Testflag			; Branch to Testflag if it is not
		cpi r17, BotAddress		; Compare r17 to BotAddress
		breq Setflag			; If it is then set flag
		cpi r17, 0b01010101		; Compare r17 to freeze command, if it is then go to freeze
		breq Frozen
		
		
Testflag:		;Subroutine to test if r27 is set
		tst r21	;If r17 is set go to Run
		brne Run
		ret
Run:			;Subroutine that actually runs the robot
	cpi r17, 0b10110000	;Runs through every posibility of commands received from the remote
	BREQ Moveforward	;Then breaks to the subroutine that corresponds to that command
	cpi r17, 0b10000000
	BREQ Movebackward
	cpi r17, 0b10100000
	BREQ Turnright
	cpi	r17, 0b10010000
	BREQ Turnleft
	cpi r17, 0b11001000
	BREQ Stop
	cpi r17, 0b11111000
	BREQ ReceiveFreeze
	reti
Setflag:	;Subroutine to set flag
	ldi r21, 1		;Loads 1 into r21
	ret
Moveforward:		;Subroutine to move forward
	ldi mpr, MovFwd	; Loads MovFwd into r25 and outputs to PORTB
	ldi r25, MovFwd	;Backs up MovFwd to r25 for later
	out PORTB, mpr
	clr r21			;Clear the flag
	ret
Movebackward:		;The other subroutines are identical to Moveforward except they have their own
	ldi mpr, MovBck	;corresponding commands
	ldi r25, MovBck
	out PORTB, mpr
	clr r21
	ret
Turnright:
	ldi mpr, TurnR
	out PORTB, mpr
	ldi r25, TurnR
	clr r21
	ret
Turnleft:
	ldi mpr, TurnL
	out PORTB, mpr
	ldi r25, TurnL
	clr r21
	ret
ReceiveFreeze:	;Receives freeze command and outputs the command to freeze other robots
	ldi mpr, 0b01010101
	sts UDR1, mpr ;Outputs freeze robot command to UDR1
	ret
Frozen:
	sbrs r21, 0	;Freeze the robot when register 21 is not set and it receives a freeze signal
	rcall Freeze
	ret
	;rcall Freeze
	;ret
	;rcall Freeze
Freeze:	;The subrountine happens when the robot is frozen
	ldi mpr, 0b00000001	;Loads LED display into mpr
	out PORTB, mpr		;Outputs that display to PORTB
	ldi mpr, EIMSK		;Back up EIMSK
	ldi r22, UCSR1B		;Back up UCSR1B
	out EIMSK, r26		;Outputs 0 to EIMSK to prevent interrupts
	sts UCSR1B, r26		;Outputs 0 to USCR1B to prevent USART signals
	ldi waitcnt, WTime	;Loads WTime into Waitcnt
	rcall Wait			;Wait for 5 seconds
	rcall Wait
	rcall Wait
	rcall Wait
	rcall Wait
	out EIMSK, mpr	;Restore EIMSK
	sts UCSR1B, r22	;Restore UCSR1B
	inc r24			;increment counter to see how many times robot has been frozen
	cpi r24, 3		;If counter reaches 3, go to Dead
	breq Dead
	out PORTB, r25	;Output original content of r25 before it was frozen

	ret
Dead:
	out EIMSK, r26	;Write 0s to EIMSK
	sts UCSR1B, r26	;Write 0s to UCSR1B
	ret
Stop:	;Subroutine for stop
	ldi mpr, Halt	;Loads halt into mpr
	out PORTB, mpr	;Output to PORTB
	clr r21			;Clears the flag

HitLeft:
		push	mpr			; Save mpr register
		push	waitcnt		; Save wait register
		in		mpr, SREG	; Save program state
		push	mpr			;

		; Move Backwards for a second
		ldi		mpr, MovBck	; Load Move Backward command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 1 second
		rcall	Wait			; Call wait function

		; Turn right for a second
		ldi		mpr, TurnR	; Load Turn Left Command 
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 1 second
		rcall	Wait			; Call wait function

		; Move Forward again	
		ldi		mpr, MovFwd	; Load Move Forward command
		out		PORTB, mpr	; Send command to port

		pop		mpr		; Restore program state
		out		SREG, mpr	;
		pop		waitcnt		; Restore wait register
		pop		mpr		; Restore mpr
		ret				; Return from subroutine

HitRight:
		push	mpr			; Save mpr register
		push	waitcnt			; Save wait register
		in		mpr, SREG	; Save program state
		push	mpr			;

		; Move Backwards for a second
		ldi		mpr, MovBck	; Load Move Backward command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 1 second
		rcall	Wait			; Call wait function

		; Turn left for a second
		ldi		mpr, TurnL	; Load Turn Left Command
		out		PORTB, mpr	; Send command to port
		ldi		waitcnt, WTime	; Wait for 1 second
		rcall	Wait			; Call wait function

		; Move Forward again	
		ldi		mpr, MovFwd	; Load Move Forward command
		out		PORTB, mpr	; Send command to port

		pop		mpr		; Restore program state
		out		SREG, mpr	;
		pop		waitcnt		; Restore wait register
		pop		mpr		; Restore mpr
		ret				; Return from subroutine

Wait:
	push	waitcnt			; Save wait register
		push	ilcnt			; Save ilcnt register
		push	olcnt			; Save olcnt register

Loop:	ldi		olcnt, 224		; load olcnt register
OLoop:	ldi		ilcnt, 237		; load ilcnt register
ILoop:	dec		ilcnt			; decrement ilcnt
		brne	ILoop			; Continue Inner Loop
		dec		olcnt		; decrement olcnt
		brne	OLoop			; Continue Outer Loop
		dec		waitcnt		; Decrement wait 
		brne	Loop			; Continue Wait loop	

		pop		olcnt		; Restore olcnt register
		pop		ilcnt		; Restore ilcnt register
		pop		waitcnt		; Restore wait register
		ret				; Return from subroutine
;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************


