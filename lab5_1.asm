%include "asm_io.inc"

SECTION .data

arr1: dd 1,2,3,4,5,6,7,8,9,10
arr2: dd 11,12,13,14,15,16,17,18,19,20
err1: db "incorrect number of command line arguments",10,0
err2: db "incorrect command line argument",10,0

SECTION .bss

SECTION .text
   global  asm_main


; subroutine display_array
; expects one parameter on stack, either index 1 or 2
; it is assumed that the parameter is OK
; if the parameter is 1, the subroutine traverses the array
; arr1 and displays its entries separated by comma, e.g.
; 1,2,3,4,5,6,7,8,9,10
; if the parameter is 2, the subroutine traverses the array
; arr2 and displays its entries separated by comma, e.g.
; 11,12,13,14,15,16,17,18,19,20

display_array:
	enter 0, 0			; enter the subroutine 
   	pusha				; save all registers

  	mov eax, [ebp+8]		; get the parameter
	cmp eax, '1'			; check if it is 1
   	jne NOT1
	mov ebx, arr1			; if so, set ebx to point to arr1, i.e. exb=arr1
	jmp display   

	NOT1:
		mov ebx, arr2		; otherwise set ebx to proint to arr2, i.e. ebx=arr2
		jmp display

  display:
	mov ecx, dword 0		; in a counting loop 
	jmp LOOP			; traverse the first 9 items of the array pointed to by ebx

	LOOP:
		cmp ecx, dword 9
		je ENDLOOP
		mov eax, dword [ebx]	; display the item stored there using print_int
		call print_int
		mov eax, ','		; display a comman using print_char
		call print_char
		inc ecx
		add ebx, 4
		jmp LOOP

	ENDLOOP:			; when the loop is done
		mov eax, dword [ebx]	; display the 10th item of the array using print_int
		call print_int   		
		call print_nl		; and finish the print line using print_nl
   
  	 	popa 			;restore all registers
   		leave			;leave the subroutine
   		ret			;return the control to the caller

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm_main:
   	enter 0,0			; enter subroutine
   	pusha				; save all registers

   	mov eax, dword [ebp+8]		; get argc
   	cmp eax, dword 2		; check it is 2
   	jne ERR1			; it not display err1 and terminate asm_main

   	mov ebx, dword [ebp+12]		; get argv[1] 
   	mov eax, dword [ebx+4]
	mov bl, byte [eax]		; get the first byte of argv[1]

	firstTry:
		cmp bl, '1'		; if it is '1' or '2' is it OK otherwise display err2 and terminate asm_main
		jne secondTry	
		jmp OK	

	secondTry:
		cmp bl, '2'
		jne ERR2

	OK:
		mov bl, byte [eax+1]	; get the second byte of argv[2]
		cmp bl, byte 0		; if it is 0, it is OK
		jne ERR2		; otherwise display err2 and terminate asm_main

   					; hence the argument is correct
		
 	mov ecx, 0
	mov bl, byte [eax]
	mov cl, bl
	push ecx			; push the numeric value of the argument on stack (either 1 or 2)
   	call display_array		; call display_array
   	add esp, 4			; clean the parameters from the stack
	jmp asm_main_end
	
 	ERR1:
     		mov eax, err1
     		call print_string
		jmp asm_main_end

	ERR2:
		mov eax, err2
		call print_string
		jmp asm_main_end

	asm_main_end:
   		popa			; restore all registers
   		leave			; leave the subroutine
   		ret			; return control
