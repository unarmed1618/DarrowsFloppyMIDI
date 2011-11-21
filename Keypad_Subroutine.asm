; This is a subroutine designed by John Darrow as part of the floppy midi project at ECU
; This segment is a routine for polling a 4x3 keypad. It is designed for a input devoted chip.
; It needs: Testing
; It has: Successfully built. 
; Features: 1-12 on 7 pins to keypad and 4 pins out. 0x1-0x9 are accurate, 0xA=*, 0xB=keypad 0, 0xC=# 
; 			Will send a zero after an input, and wait until a new input to send more.
; Started:	11/20/2011
; Last edit:11/20/2011
;
		
		list		p=16F84
		#include 	<p16f84a.inc>  ;initialization
		org 		0x00
		goto 		start			;avoid interrupt bit
		org 		0x05	
start	
keybuf	equ			0x0C
lbz		equ			0x0D			;last bit zero?
		clrf		keybuf
fart	btfsc		keybuf,5  		;is there a sent bit in the buffer? if not, go poll again
		goto		send
		goto		keylup
sendz	movwf		PORTB			;send full zero
		bsf			lbz,0			;set last bit zero flag
		goto 		keylup

send	btfss		lbz,0
		goto 		keylup
		bcf			lbz,0
		swapf		keybuf,0
		andlw		0xF0	
		movwf		PORTB	
		goto		keylup

keylup	btfss		keybuf,6
		bcf			keybuf,6
		bsf			STATUS, RP0		;initialize ports for polling
		clrf		TRISA
		movlw		0x0F
		movwf		TRISB
		bcf			STATUS, RP0
		
		bsf			PORTA,0
		clrf		keybuf
		movlw		0x14			; Method for setting w-f in one line- set W before each polling test to the appropriate f value, then for the bit test skip value, 
		btfsc		PORTB,0
		movwf		keybuf
		movlw		0x17
		btfsc		PORTB,1
		movwf		keybuf
		movlw		0x1A
		btfsc		PORTB,2
		movwf		keybuf
		movlw		0x11
		btfsc		PORTB,3
		movwf		keybuf
		btfsc		keybuf,5
		goto		fart 			; next row
		bcf			PORTA,0
		bsf			PORTA,1
		movlw		0x15
		btfsc		PORTB,0
		movwf		keybuf
		movlw		0x18
		btfsc		PORTB,1
		movwf		keybuf
		movlw		0x1B
		btfsc		PORTB,2
		movwf		keybuf
		movlw		0x12
		btfsc		PORTB,3
		movwf		keybuf
		btfsc		keybuf,5
		goto		fart			; next row
		bcf			PORTA,2
		bsf			PORTA,3
		movlw		0x16
		btfsc		PORTB,0
		movwf		keybuf
		movlw		0x19
		btfsc		PORTB,1
		movwf		keybuf
		movlw		0x1C
		btfsc		PORTB,2
		movwf		keybuf
		movlw		0x13
		btfsc		PORTB,3
		movwf		keybuf
		btfsc		keybuf,5
		goto		fart	
		btfsc		lbz,0
		goto		keylup
		movf		keybuf,0			;next row
		iorlw		0x00  		;z= 1 if w= 0x00 z= 0 elsewise
		btfsc		STATUS,Z
		goto 		sendz
		btfss		keybuf,5
		goto		keylup
		end