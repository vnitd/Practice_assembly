use16
	org 0x7e00					; 512 bytes after the bootsector in memory
	mov [loader_drivenum], dl

	mov ah, 0x00
	mov al, 0x02			; 80x25 text mode
	int 0x10				; reset the screen
	; setup vbe info structure
	xor ax, ax
	mov es, ax
	mov ah, 0x4f
	mov di, vbe_info_block
	int 0x10

	cmp al, 0x4f
	jne error

	mov ax, word [vbe_info_block.video_mode_pointer]
	mov [offset], ax
	mov ax, word [vbe_info_block.video_mode_pointer+2]
	mov [t_segment], ax

	mov fs, ax
	mov si, [offset]

	.find_mode:
		mov dx, [fs:si]
		add si, 2
		mov [offset], si
		mov [mode], dx

		cmp dx, word 0xffff
		je  end_of_modes

		mov ax, 0x4f01
		mov cx, [mode]
		mov di, mode_info_block
		int 0x10

		cmp ax, 0x4f
		jne error

		; mov dx, [mode_info_block.x_resolution]
		; call print_hex
		; mov ax, 0E20h	; Print a space
		; int 10h

		; mov dx, [mode_info_block.y_resolution]
		; call print_hex
		; mov ax, 0E20h	; Print a space
		; int 10h

		; xor dh, dh
		; mov dl, [mode_info_block.bits_per_pixel]
		; call print_hex	; Print bpp
		; mov ax, 0E0Ah	; Print a newline
		; int 10h
		; mov al, 0Dh
		; int 10h

		;; Compare values with desired values
		mov ax, [width]
		cmp ax, [mode_info_block.x_resolution]
		jne .next_mode

		mov ax, [height]					
		cmp ax, [mode_info_block.y_resolution]
		jne .next_mode

		mov ax, [bpp]
		cmp al, [mode_info_block.bits_per_pixel]
		jne .next_mode

		mov ax, 4F02h	; Set VBE mode
		mov bx, [mode]
		or bx, 4000h	; Enable linear frame buffer, bit 14
		xor di, di
		int 10h

		cmp ax, 4Fh
		jne error
		
		jmp load_GDT
	.next_mode:
		mov ax, [t_segment]
		mov fs, ax
		mov si, [offset]
		jmp .find_mode

error:
	mov ax, 0x0e45
	int 0x10
	cli
	hlt
end_of_modes:
	mov ax, 0x0e4e
	int 0x10
	cli
	hlt

GDT_Start:
	;; Offset 0x00
	dq 0x00				; 1st descriptor required to be NULL descriptor

	;; Offset 0x08
	.code:
		dw 0xffff		; Segment limit 1 - 2 bytes
		dw 0x0000		; Segment base 1 - 2 bytes
		db 0x00			; Segment base 1 - 2 byte
		db 10011010b	; Access byte - bits: 7 - Present, 6-5 - privelege level (0 = kernel),
						; 4 - descriptor type (code/data), 3 - executable y/n, 2 - direction/conforming
						; (grow up from base to limit), 1 - read/write, 0 - accessed (CPU sets this)
		db 11001111b	; bits: 7 - granularity (4KiB), 6 - size (32bit protected mode), 3-0 - segment
						; limit 2 - 4 bits
		db 0x00			; Segment base 3-1 byte
	;; Offset 0x10
	.data:
		dw 0xffff		; Segment limit 1 - 2 bytes
		dw 0x00			; Segment base 1 - 2 bytes
		db 0x00			; Segment base 1 - 2 byte
		db 10010010b	; Access byte
		db 11001111b	; bits: 7 - granularity (4KiB), 6 - size (32bit protected mode), 3-0 - segment
						; limit 2 - 4 bits
		db 0h			; Segment base 3-1 byte

GDT_Desc:
	dw ($-GDT_Start-1)
	dd GDT_Start

load_GDT:
	mov dl, [loader_drivenum]
	cli						; Clear interrupts first
	lgdt [GDT_Desc]			; Load the GDT to the CPU

	mov eax, cr0
	or  eax, 1				; Set protected mode bit
	mov cr0, eax			; Turn on protected mode

	jmp 0x08:set_segments

use32
set_segments:
	mov ax, 10h				; Set to data segment desciptor
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, 0x90000		; Set up stack pointer

	jmp 0x08:0x900

loader_drivenum: db 0

width: dw 0x320
height: dw 0x258
bpp: db 32
mode: dw 0
offset: dw 0
t_segment: dw 0

	times 512-($-$$) db 0
;; Sector 2
vbe_info_block:								; total 512 bytes
	.vbe_signature: 			db 'VBE2'
	.vbe_version:				dw 0
	.oem_string_pointer:		dd 0
	.capabilities:				dd 0
	.video_mode_pointer:		dd 0
	.total_memory:				dw 0
	.oem_software_version:		dw 0
	.oem_vendor_name_pointer:	dd 0
	.oem_product_name_pointer:	dd 0
	.oem_product_rev_pointer:	dd 0
	.reseved:		  times 222 db 0
	.oem_data:		  times 256 db 0

;; Sector 3
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

	;; Sector padding
	times 1536-($-$$) db 0