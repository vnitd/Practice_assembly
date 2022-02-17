;;
;; bootSector.asm: the prolouge of the OS
;;

use16
	org 0x7c00
	mov byte [drive_num], dl
	
	xor ax, ax
	mov es, ax	
	
	mov bl, 0x01
	mov di, 0x500

	mov dx, 0x1f2
	mov al, 0x02
	out dx, al

	mov dx, 0x1f3
	mov al, 0x05
	out dx, al

	call load_sectors

	mov bl, 0x02
	mov di, 0x7e00

	mov dx, 0x1f2
	mov al, 0x03
	out dx, al

	mov dx, 0x1f3
	mov al, 0x02
	out dx, al

	call load_sectors
	
	mov bl, 0x1F
	mov di, 0x900

	mov dx, 0x1f2
	mov al, 0x20
	out dx, al

	mov dx, 0x1f3
	mov al, 0x07
	out dx, al

	call load_sectors

	mov dl, [drive_num]
	jmp 0x0:7e00h
load_sectors:
	mov dx, 0x1f6
	mov al, [drive_num]
	and al, 0xf
	or  al, 0xa0
	out dx, al

	mov dx, 0x1f4
	xor al, al
	out dx, al

	mov dx, 0x1f5
	xor al, al
	out dx, al

	mov dx, 0x1f7
	mov al, 0x20
	out dx, al

	.loop:
		in  al, dx
		test al, 8
		jz  .loop

		mov cx, 256
		mov dx, 0x1f0
		rep insw

		; 400ns delay - Read alternate status register
		mov dx, 0x3f6
		in  al, dx
		in  al, dx
		in  al, dx
		in  al, dx

		cmp bl, 0
		je  .return

		dec bl
		mov dx, 0x1f7
		jmp .loop
	.return:
		ret


drive_num: db 0
	times 510-($-$$) db 0
	dw 0xaa55