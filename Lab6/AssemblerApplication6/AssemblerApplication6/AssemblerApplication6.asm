;***********************************************************
;*
;*	AssemblerApplication6.asm
;*
;*	Interrupt implementation of BumpBot
;*
;*	This is the skeleton file for Lab 6 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Zhenggan Zheng and Abhishek Raol
;*	   Date: 2/16/2016
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register 
.def 	waitcnt = r17			; Wait loop counter
.def	ilcnt = r18				; Inner loop counter
.def	olcnt = r19				; Outer loop counter
.def	flag = r24				; Flag for calling hit functions
; Constants for interactions such as
.equ	WTime = 100				; Time to wait in wait loop
.equ	WskrR = 0				; Right Whisker Input Bit
.equ	WskrL = 1				; Left Whisker Input Bit
.equ	EngEnR = 4				; Right engine enable bit
.equ	EngEnL = 7				; Left engine enable bit
.equ	EngDirR = 5				; Right engine direction bit
.equ	EngDirL = 6				; Left engine direction bit
.equ	MovFwd = (1<<EngDirR|1<<EngDirL)	; Move forward command
.equ	MovBck = $00						; Move back command
.equ	TurnR = (1<<EngDirL)				; Turn right command
.equ	TurnL = (1<<EngDirR)				; Turn left command
.equ	Halt = (1<<EngEnR|1<<EngEnL)		; Stop command
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;-----------------------------------------------------------
;*	Interrupt Vectors
;-----------------------------------------------------------
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt
.org $0002						; INT0 => pin0, PORTD
		rcall HitRight			; Call HitRight
		reti					; Return from interrupt
.org $0004						; INT1 => pin1, PORTD
		rcall HitLeft			; Call HitLeft
		reti					; Return from interrupt
.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:	; The initialization routine
		; Initialize Stack Pointer
		ldi		mpr, low(RAMEND)
		out		SPL, mpr	; Load SPL with low byte of RAMEND
		ldi		mpr, high(RAMEND)
		out		SPH, mpr	; Load SPH with high byte of RAMEND
 
		; Initialize Port B for output
		ldi		mpr, (1<<EngEnL)|(1<<EngEnR)|(1<<EngDirR)|(1<<EngDirL)
		out		DDRB, mpr
		; Initialize Port D for input
		ldi		mpr, (0<<WskrL)|(0<<WskrR)
		out		DDRD, mpr
		ldi		mpr, (1<<WskrL)|(1<<WskrR)
		out		PORTD, mpr
		; Initialize external interrupts to trigger on falling edge
		ldi mpr, (1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)
		sts EICRA, mpr
		; Set external interrupt mask
		ldi mpr, (1<<INT0)|(1<<INT1)
		out EIMSK, mpr

		sei


		; Initialize external interrupts
		; Set the Interrupt Sense Control to falling edge 
		; NOTE: To be safe, initialize both EICRA and EICRB

		; Configure the External Interrupt Mask

		; Turn on interrupts
		; NOTE: This must be the last thing to do in the INIT function

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:	; The Main program
		ldi flag, $00	; Load 0 into flag
		cpi	flag, $01	; See if flag has 1
		breq CALLRIGHT	; If it does, go to CALLRIGHT
		cpi flag, $02	; See if flag has 2
		breq CALLLEFT	; If it does, go to CALLLEFT
		ldi mpr, MovFwd	; Load MovFwd command 
		out PORTB, mpr	; Ouput MovFwd to PORTB
		in mpr, PIND	; Takes input from PIND
		com mpr			; Complements it since TekBot is active low
	;	andi mpr, (1<<WskrL)|(1<<WskrR)	;Mask out other bits
		andi mpr, EIMSK
		cpi mpr, (1<<WskrR)	; See if right whisker is hit
		breq FLAG1	; If it is, go to FLAG1
		cpi mpr, (1<<WskrL)	; See if left whisker is hit
		breq FLAG2	; If it is go to FLAG2
		rjmp MAIN	; Infinite loop
FLAG1:
		ldi flag, $01 ; Set flag=1
		rjmp MAIN ; Goes back to MAIN
FLAG2:
		ldi flag, $02; Set flag=2
		rjmp MAIN; Goes back to MAIN
CALLRIGHT:
		rcall HitRight; Calls HitRight
		rjmp MAIN; Goes back to MAIN
CALLLEFT:
		rcall HitLeft; Calls HitLeft
		rjmp MAIN; Goes back to MAIN
		; TODO: ???

		rjmp MAIN			; Create an infinite while loop to signify the 
								; end of the program.

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
;	You will probably want several functions, one to handle the 
;	left whisker interrupt, one to handle the right whisker 
;	interrupt, and maybe a wait function
;------------------------------------------------------------

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
HitRight:	; Begin a function with a label
		
		push mpr	; Save mpr register
		push waitcnt; Save wait register
		in mpr, SREG; save program state
		push mpr

		ldi mpr, MovBck; Load MovBck command
		out PORTB, mpr	; Output MovBck command to PORTB
		ldi waitcnt, WTime; Load wait for 1 second
		rcall Wait		; Call Wait function

		ldi mpr, TurnL	; Load TurnL command
		out PORTB, mpr	; Output TurnL command to PORTB
		ldi waitcnt, WTime; Load wait for 1 second
		rcall Wait			; Call Wait function

		pop mpr			; Restore program state
		out SREG, mpr	
		pop waitcnt		; Restore wait register
		pop mpr			; Restore mpr
		ret				; Return from subroutine
		
HitLeft:
		
		push mpr	; Save mpr register
		push waitcnt; Save wait register
		in mpr, SREG; Save program state
		push mpr

		ldi mpr, MovBck; Load MovBck command
		out PORTB, mpr; Output MovBck command to PORTB
		ldi waitcnt, WTime; Load wait for 1 second
		rcall Wait		; Call Wait function

		ldi mpr, TurnR	; Load TurnR command
		out PORTB, mpr	; Output TurnR command to PORTB
		ldi waitcnt, WTime; Load Wait for 1 second
		rcall Wait		; Call Wait function

		pop mpr			; Restore program state
		out SREG, mpr	
		pop waitcnt		; Restore wait register
		pop mpr			; Restore mpr
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

; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
; There are no additional file includes for this program


