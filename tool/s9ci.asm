; SiS900 check IOPL dll

include	..\sis900.inc

extern	DosIODelayCnt : far16

.386

seg_r	segment	use16 word AT 'RGST'
	org	0
Reg	SIS900_Register <>
seg_r	ends

seg_i	segment	public use16 word 'CODE'
	assume	cs:seg_i, ds:nothing, ss:nothing

; USHORT _s9c_eepRead(USHORT IOaddr, UCHAR reg);
_s9c_eepRead	proc	far
	enter	4,0		; 0:bp, 2:ip, 4:cs, 6:IOaddr, 8:reg

	mov	dx,[bp+6]
	add	dx,offset Reg.MEAR

	pushf
	cli

	in	eax,dx
	and	al,-10h		; reserved bitmask
	mov	[bp-4],eax

	out	dx,eax		; chip select - low
	push	4
	call	__IODelayCnt
	or	al,EECLK
	out	dx,eax
	call	__IODelayCnt

	mov	bl,[bp+8]
	mov	bh,0
	and	bl,3fh
	mov	cx,(1 + 2 + 6) -1
	or	bx,110b shl 6
loc_1:
	bt	bx,cx
	setc	al
	or	al,EESEL
	or	al,[bp-4]
	out	dx,eax
	call	__IODelayCnt
	or	al,EECLK
	out	dx,eax
	call	__IODelayCnt
	dec	cx
	jge	short loc_1

	mov	cx,16
	xor	bx,bx
loc_2:
	mov	eax,[bp-4]
	or	al,EESEL
	out	dx,eax
	call	__IODelayCnt
	or	al,EECLK
	out	dx,eax
	call	__IODelayCnt
	in	eax,dx
	bt	ax,1			; EEDO
	rcl	bx,1
	dec	cx
	jnz	short loc_2

	mov	eax,[bp-4]
	out	dx,eax
	call	__IODelayCnt
	or	al,EECLK
	out	dx,eax
	call	__IODelayCnt
	pop	cx
	pop	ax
	test	ah,2
	jz	short loc_3
	sti
loc_3:
	mov	ax,bx
	leave
	retf	4
_s9c_eepRead	endp



; void _IODelayCnt( USHORT count )
__IODelayCnt	proc	near
	push	bp
	mov	bp,sp
	push	cx
	mov	bp,[bp+4]
loc_1:
	mov	cx,offset DosIODelayCnt
	dec	bp
	loop	$
	jnz	short loc_1
	pop	cx
	pop	bp
	retn
__IODelayCnt	endp


; pre-requested eeprom read
; rc _s9c_peeprom(USHORT IOaddr, far *MACaddr);
_s9c_peeprom	proc	far
	enter	4,0	; 0:bp, 2:ip, 4:cs, 6:IOaddr, 8:*MACaddr

	mov	dx,[bp+6]
	add	dx,offset Reg.MEAR

	pushf
	cli

	in	eax,dx
	or	eax,EEREQ
	out	dx,eax
	mov	cx,200
loc_1:
	push	20
	call	__IODelayCnt
	pop	ax
	in	eax,dx
	test	eax,EEGNT
	jnz	short loc_2
	dec	cx
	jnz	short loc_1
	mov	ax,1		; timeout
	jmp	short loc_ex

loc_2:
	push	8
	push	word ptr [bp+6]
	call	_s9c_eepRead
	mov	[bp-4],ax

	push	9
	push	word ptr [bp+6]
	call	_s9c_eepRead
	mov	[bp-2],ax

	push	10
	push	word ptr [bp+6]
	call	_s9c_eepRead

	mov	cx,[bp-4]
	mov	dx,[bp-2]
	les	bx,[bp+8]
	mov	es:[bx],cx
	mov	es:[bx+2],dx
	mov	es:[bx+4],ax

	mov	dx,[bp+6]
	add	dx,offset Reg.MEAR
	in	eax,dx
	or	eax,EEDONE
	out	dx,eax

	xor	ax,ax		; success
loc_ex:
	pop	cx
	test	ch,2
	jz	short loc_3
	sti
loc_3:
	leave
	retf	6
_s9c_peeprom	endp

; direct eeprom read
; rc _s9c_eeprom(USHORT IOaddr, far *MACaddr);
_s9c_eeprom	proc	far
	enter	4,0	; 0:bp, 2:ip, 4:cs, 6:IOaddr, 8:*MACaddr

	push	8
	push	word ptr [bp+6]
	call	_s9c_eepRead
	mov	[bp-4],ax

	push	9
	push	word ptr [bp+6]
	call	_s9c_eepRead
	mov	[bp-2],ax

	push	10
	push	word ptr [bp+6]
	call	_s9c_eepRead

	mov	cx,[bp-4]
	mov	dx,[bp-2]
	les	bx,[bp+8]
	mov	es:[bx],cx
	mov	es:[bx+2],dx
	mov	es:[bx+4],ax

	xor	ax,ax
	leave
	retf	6
_s9c_eeprom	endp

; reload pmatch filter
; rc _s9c_reload(USHORT IOaddr, far *MACaddr);
_s9c_reload	proc	far
	enter	16,0	; 0:bp, 2:ip, 4:cs, 6:IOaddr, 8:*MACaddr

	pushf
	cli

				; backup filter mode
	mov	dx,[bp+6]
	add	dx,offset Reg.RFCR
	in	eax,dx
	mov	[bp-16],eax

				; backup and clear pmatch filter data
	xor	eax,eax
	out	dx,eax
	add	dx,offset Reg.RFDR - offset Reg.RFCR
	in	eax,dx
	mov	[bp-12],ax
	xor	eax,eax
	out	dx,eax

	add	dx,offset Reg.RFCR - offset Reg.RFDR
	mov	eax,10000h
	out	dx,eax
	add	dx,offset Reg.RFDR - offset Reg.RFCR
	in	eax,dx
	mov	[bp-10],ax
	xor	eax,eax
	out	dx,eax

	add	dx,offset Reg.RFCR - offset Reg.RFDR
	mov	eax,20000h
	out	dx,eax
	add	dx,offset Reg.RFDR - offset Reg.RFCR
	in	eax,dx
	mov	[bp-8],ax
	xor	eax,eax
	out	dx,eax

				; reload pmatch data
	mov	dx,[bp+6]
	add	dx,offset Reg.CR
	in	eax,dx
	mov	ecx,eax
	or	eax,RELOAD
	out	dx,eax
	in	eax,dx
	mov	eax,ecx
	out	dx,eax

				; read and restore pmatch data
	mov	dx,[bp+6]
	add	dx,offset Reg.RFCR
	xor	eax,eax
	out	dx,eax
	add	dx,offset Reg.RFDR - offset Reg.RFCR
	in	eax,dx
	mov	[bp-6],ax
	movzx	eax,word ptr [bp-12]
	out	dx,eax

	add	dx,offset Reg.RFCR - offset Reg.RFDR
	mov	eax,10000h
	out	dx,eax
	add	dx,offset Reg.RFDR - offset Reg.RFCR
	in	eax,dx
	mov	[bp-4],ax
	movzx	eax,word ptr [bp-10]
	out	dx,eax

	add	dx,offset Reg.RFCR - offset Reg.RFDR
	mov	eax,20000h
	out	dx,eax
	add	dx,offset Reg.RFDR - offset Reg.RFCR
	in	eax,dx
	mov	[bp-2],ax
	movzx	eax,word ptr [bp-8]
	out	dx,eax

				; restore filter mode
	add	dx,offset Reg.RFCR - offset Reg.RFDR
	mov	eax,[bp-16]
	out	dx,eax

	mov	cx,[bp-6]
	mov	dx,[bp-4]
	mov	ax,[bp-2]
	les	bx,[bp+8]
	mov	es:[bx],cx
	mov	es:[bx+2],dx
	mov	es:[bx+4],ax

	pop	ax
	test	ah,2
	jz	short loc_1
	sti
loc_1:
	xor	ax,ax
	leave
	retf	6
_s9c_reload	endp

; rc _s9c_bridge(USHORT BusDevFunc, UCHAR far *MACaddr);
_s9c_bridge	proc	far
	enter	18,0	; 0:bp 2:bp 4:cs 6:BusDevFunc 8:MACaddr
	push	di
	pushf
	cli
	mov	dx,0cf8h
	in	eax,dx
	mov	[bp-10],eax	; Config Mech #1 backup

	mov	al,[bp+6]	; Bus
	mov	ah,80h
	shl	eax,16
	mov	al,48h		; register
	mov	ah,[bp+7]	; DevFunc
	mov	[bp-14],eax	; cf8
	out	dx,eax
	mov	dl,0fch
	in	eax,dx
	mov	[bp-18],eax	; cfc
	or	al,40h
	out	dx,eax

	mov	di,9
loc_1:
	mov	ax,di
	out	70h,al
	in	al,71h
	mov	[bp-6+di-9],al
	inc	di
	cmp	di,9+6
	jc	short loc_1

	mov	dx,0cf8h
	mov	eax,[bp-14]
	out	dx,eax
	mov	dl,0fch
	mov	eax,[bp-18]
	out	dx,eax
	mov	dx,0f8h
	mov	eax,[bp-10]
	out	dx,eax

	pop	ax
	test	ah,2
	jz	short loc_2
	sti
loc_2:
	mov	ax,[bp-6]
	mov	cx,[bp-4]
	mov	dx,[bp-2]
	les	di,[bp+8]
	mov	es:[di],ax
	mov	es:[di+2],cx
	mov	es:[di+4],dx

	pop	di
	xor	ax,ax
	leave
	retf	6
_s9c_bridge	endp

seg_i	ends
end
