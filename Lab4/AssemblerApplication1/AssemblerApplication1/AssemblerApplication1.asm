;
; AssemblerApplication1.asm
;
; Created: 2/3/2016 4:03:52 AM
; Author : Zheng Zheng & Abhishek Raol
;			


.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register is
								; required for LCD Driver

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp INIT				; Reset interrupt

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine
		; Initialize Stack Pointer
		LDI R16, LOW(RAMEND) ; Low Byte of End SRAM Address
		OUT SPL, R16 ; Write byte to SPL
		LDI R16, HIGH(RAMEND) ; High Byte of End SRAM Address
		OUT SPH, R16 ; Write byte to SPH
		
		; Initialize LCD Display
		rcall LCDInit ;Call LCD Init Subroutine

		; Move strings from Program Memory to Data Memory
			LDI ZL, low(STRING_BEG<<1)	;Moving strings according to psuedocode in manual
			LDI ZH, high(STRING_BEG<<1)
			LDI YL, low(LCDLn1Addr)
			LDI YH, high(LCDLn1Addr)
	
		;While loop to put Z into mpr and store in Y
		loop:
			LPM	mpr, Z+
			st Y+, mpr
			CPI ZL, low(STRING_END<<1)
			brne loop
			cpi ZH, high(STRING_END<<1)
			
			
			;Repeat step of moving string from program memory to data memory for line 2
			LDI ZL, low(HELLOSTRING_BEG<<1)
			LDI ZH, high(HELLOSTRING_END<<1)
			LDI YL, low(LCDLn2Addr)
			LDI YH, high(LCDLn2Addr)
			

			;Same while loop to put Z into mpr and store in Y
		loop2:
			LPM	mpr, Z+
			st Y+, mpr
			CPI ZL, low(HELLOSTRING_END<<1)
			brne loop2
			cpi ZH, high(HELLOSTRING_END<<1)
			
			
		; NOTE that there is no RET or RJMP from INIT, this
		; is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		; Display the strings on the LCD Display

		
		rcall LCDWrite
		rjmp	MAIN			; jump back to main and create an infinite
								; while loop.  Generally, every main program is an
								; infinite while loop, never let the main program
								; just run off

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
FUNC:							; Begin a function with a label
		; Save variables by pushing them to the stack

		; Execute the function here
		
		; Restore variables by popping them from the stack,
		; in reverse order

		ret						; End a function with RET

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_BEG:
.DB			"Zheng^2 A.Raol "		; Declaring data in ProgMem
STRING_END:
HELLOSTRING_BEG:
.DB			"Hello World "
HELLOSTRING_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver
