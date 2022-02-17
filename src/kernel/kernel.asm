extern _Z8get_charw
global kernel_loader
use32
kernel_loader:
	mov edi, mode_info_block
	mov esi, 0x8200
	mov ecx, 64
	rep movsd

	push dword 100				; x
	push dword 100				; y
	push dword 0x00ff0000		; color
	call drawPixel

	jmp $

;;; drawPixel FUNCTION
; Paragrams:
; - x
; - y
; - color
drawPixel:
	push ebp
	mov ebp, esp
	sub esp, 4

	mov ecx, [ebp + 8]	; color
	mov eax, [ebp + 12] ; y
	mul dword [width]
	add eax, [ebp+16]
	mul dword[bpp]
	mov edi, [mode_info_block.physical_base_pointer]
	add edi, eax
	mov dword [edi], ecx

	mov esp, ebp
	sub esp, 12
	pop ebp
	ret
	
	


width: dd 800
height: dd 600
bpp:	dd 4
	times 1024-($-$$) db 0
mode_info_block:
	; Mandatory info for all VBE revisions
	.mode_attributes:			dw 0	; 2
	.window_a_attributes:		db 0	; 1
	.window_b_attributes:		db 0	; 1
	.window_granularity:		dw 0	; 2
	.window_size:				dw 0	; 2
	.window_a_segment:			dw 0	; 2
	.window_b_segment:			dw 0	; 2
	.window_function_pointer:	dd 0	; 4
	.bytes_per_scanline:		dw 0	; 2
										; 18
	; Mandatory info for VBE 1.2 and above
	.x_resolution:				dw 0	; 2
	.y_resolution:				dw 0	; 2
	.x_charsize:				db 0	; 1
	.y_charsize:				db 0	; 1
	.number_of_planes:			db 0	; 1
	.bits_per_pixel:			db 0	; 1
	.number_of_banks:			db 0	; 1
	.memory_model:				db 0	; 1
	.bank_size:					db 0	; 1
	.number_of_image_pages:		db 0	; 1
	.reversed1:					db 0	; 1
										; 13

	; Direct color fields (required for direct/6 and YUV/7 memory models)
	.red_mask_size:				db 0	; 
	.red_field_position:		db 0
	.green_mask_size:			db 0
	.green_field_position:		db 0
	.blue_mask_size:			db 0
	.blue_field_position:		db 0
	.reserved_mask_size:		db 0
	.reserved_field_position:	db 0
	.direct_color_mode_info:	db 0

	;; Mandatory info for VBE 2.0 and above
	.physical_base_pointer: 	dd 0 		; Physical address for flat memory frame buffer
	.reserved2: 				dd 0
	.reserved3: 				dw 0

	;; Mandatory info for VBE 3.0 and above
	.linear_bytes_per_scan_line:dw 0
	.bank_number_of_image_pages:db 0
	.linear_numberofimage_pages:db 0
	.linear_red_mask_size: 		db 0
	.linear_red_field_position:	db 0
	.linear_green_mask_size:	db 0
	.linear_greenfield_position:db 0
	.linear_blue_mask_size:		db 0
	.linear_blue_field_position:db 0
	.linear_reserved_mask_size: db 0
	.linear_res_field_position: db 0
	.max_pixel_clock:			dd 0

	.reserved4: 	  times 190 db 0		; Remainder of mode info block

	times 1536-($-$$) db 0