; -----------------------------------------------------------
; Microcontroller Based Systems homework example
; Author name: Erbasi Türker
; Neptun code: NVT5RE
; -------------------------------------------------------------------
; Task description: 
;   Convert a 4 digit unsigned packed BCD number to 16-bit binary format. 
;   Input: The BCD number in 2 registers (upper 2 digits in the first, lower 2 digits in the second register)
;   Output: Converted binary number in 2 registers
;   Hint: Create an auxiliary subroutine for multiplication by 10.
; -------------------------------------------------------------------
; Definitions
; -------------------------------------------------------------------

; Address symbols for creating pointers
BCD_NUMBER EQU 0x9999

; Test data for input parameters
; (Try also other values while testing your code.)

; Interrupt jump table
ORG 0x0000;
    SJMP  MAIN              ; Reset vector

; Beginning of the user program
ORG 0x0033

; -------------------------------------------------------------------
; MAIN program
; -------------------------------------------------------------------
; Purpose: Prepare the inputs and call the subroutines
; -------------------------------------------------------------------

MAIN:

    ; Prepare input parameters for the subroutine
	MOV R6,#HIGH(BCD_NUMBER)
	MOV R7,#LOW(BCD_NUMBER)
	
; Infinite loop: Call the subroutine repeatedly
LOOP:

    CALL BCD2BIN 			; Call BCD to (binary) number subroutine

    SJMP  LOOP

; ===================================================================           
;                           SUBROUTINE(S)
; ===================================================================           

; -------------------------------------------------------------------
; 	BCD2BIN
; -------------------------------------------------------------------
; Purpose: Converts packet 16-bit BCD number to a 16-bit (binary) number
; -------------------------------------------------------------------
; INPUT(S):
;   R6 - Higher 2 BCD digits
;   R7 - Lower 2 BCD digits
; OUTPUT(S): 
;   R4 - High byte of the parsed 16-bit number
;   R5 - Low byte of the parsed 16-bit number
; MODIFIES:
;   Accumulator, B-register, R4, R5, R6, R7 registers
; -------------------------------------------------------------------

BCD2BIN:
    
	MOV R0, #02h			; Move the address of the R2 for the seperated decimal digits to R0
	
	MOV A, R6				; Move the higher 2 BCD digits to the Accumulator
	
	CALL ISOLATE_NIBBLES	; ISOLATE_NIBBLES subroutine is called
	
	MOV A, R7				; Move the lower 2 BCD digits to the Accumulator
	
	CALL ISOLATE_NIBBLES	; ISOLATE_NIBBLES subroutine is called
	
	MOV R0, #02h			; Move the address of the R2 for the seperated decimal digits to R0

	CALL MUL10				; MUL10 subroutine is called
	
	MOV B, #064h			; Move 100d (0x064h) to the B-register for the multiplication

	MUL AB					; Multiplication - After the MUL AB, B stroes the higher byte of the result and A stores the lower byte
	
	MOV R6, B				; Move the high byte of the parsed 16-bit number to the R6
	
	MOV R7, A				; Move the low byte of the parsed 16-bit number to the R7
	
	INC R0					; Incrementing the address on the R0 to get the next value
	
	CALL MUL10				; MUL10 subroutine is called
	
	MOV B, R7				; Move the low byte at R7 to the B-register
	
	ADD A, B				; ADD the high and the low bytes
	
	MOV R5, A				; Move the low byte to the R5 register
	
	MOV A, R6				; Move the high byte located at R6 register to the Accumulator
	
	ADDC A, #00h			; ADD the Carry bit to the high byte stored at the Accumulator (plus 0x00h as well)
	
	MOV R4, A				; Move the high byte of the parsed 16-bit number to the R5
	
	RET

; -------------------------------------------------------------------
; 	ISOLATE_NIBBLES
; -------------------------------------------------------------------
; Purpose: Isolation of the half bytes of the BCD
; -------------------------------------------------------------------
; INPUT(S):
;   A - Input number high/low byte of a BCD number
; OUTPUT(S):
;   @R0(R2, R3, R4, R5)- Output number isolated 4-bit (nibble) binary numbers of the BCD
; MODIFIES:
;   Accumulator, B-register, R2, R3, R4, R5 registers
; -------------------------------------------------------------------

ISOLATE_NIBBLES:
	
	MOV B, A				; Move the same value of Accumulator to B-register in order to prepare them for MASKING

	ANL A, #0F0h			; AND instruction with and 1111 0000 binary number would mask the right side of the number at the Accumulator
	
	SWAP A					; SWAP instruction exchanges the low-order and high-order nibbles within the Accumulator so we get our 4 digit binary number on the LSB side
	
	ANL B, #00Fh			; AND instruction with and 0000 1111 binary number would mask the left side of the number at the Accumulator
	
	MOV @R0, A				; Indirect move the value of the Accumulator to the address at R0 (R2, R4)
	
	INC R0					; Incrementing the address on the R0
	
	MOV @R0, B				; Indirect move the value of the B-register to the address at R0 (R3, R5)
	
	INC R0					; Incrementing the address at R0

	RET

; -------------------------------------------------------------------
; 	MUL10
; -------------------------------------------------------------------
; Purpose: Multiplies a 16-bit unsigned number by 10 and adds the ones digit
; -------------------------------------------------------------------
; INPUT(S):
;   @R0 - Input 4-bit binary number of higher/lower nibbles of the higher/lower byte
; OUTPUT(S): 
;   A - Output 8-bit binary number sum of the higher multiplied by 10 and lower nibbles
; MODIFIES:
;   Accumulator, B-register, R0 register
; -------------------------------------------------------------------

MUL10:

	MOV B, #0Ah				; Move 10d (0x0Ah) to the B-register for the multiplication

	MOV A, @R0				; Move the value at the address on the R0
	
	MUL AB					; Multiplication by 10
	
	INC R0					; Incrementing the address on the R0 to get the next value
	
	ADD A, @R0				; Addition of the value at the Accumulator and the value at the address on R0 in order to create the high and low bytes
	
	RET

END							; End of the source file