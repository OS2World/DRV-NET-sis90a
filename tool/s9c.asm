; SiS900 check

cr	equ	0dh
lf	equ	0ah

extern	Dos16Open : far16
extern	Dos16Close : far16
extern	Dos16DevIOCtl : far16
extern	Dos16PutMessage : far16
extern	Dos16Exit : far16

extern	_s9c_eeprom : far16
extern	_s9c_peeprom : far16
extern	_s9c_reload : far16
extern	_s9c_bridge : far16

.386

seg_d	segment	public word use16 'DATA'

public	name_OEMHLP, handle_OEMHLP
public	IOaddr, BusDevFunc, ChipRev, pindex
name_OEMHLP	db	'OEMHLP$',0
handle_OEMHLP	dw	?
IOaddr		dw	?
BusDevFunc	dw	?
ChipRev		db	?
pindex		db	0

public	MACaddr
MACaddr		db	6 dup(0)

public	TransTable, msg_crlf
TransTable	db	'0123456789ABCDEF'
msg_crlf	db	cr,lf

msg_ChipRev	db	'Chip Revision is '
len_ChipRev	equ	$ - offset msg_ChipRev
msg_d		db	'Direct serial EEPROM access',cr,lf
len_d		equ	$ - offset msg_d
msg_p		db	'Pre-requested serial EEPROM access',cr,lf
len_p		equ	$ - offset msg_p
msg_r		db	'Reload pmatch filter contents',cr,lf
len_r		equ	$ - offset msg_r
msg_b		db	'Query to ISA bridge',cr,lf
len_b		equ	$ - offset msg_b
msg_timeout	db	'timeout... ',cr,lf
len_timeout	equ	$ - offset msg_timeout
msg_nobridge	db	'ISA Bridge 0x1039/0x0008 was not found.',cr,lf
len_nobridge	equ	$ - offset msg_nobridge
msg_nf		db	'SiS900 device was not found...',cr,lf
len_nf		equ	$ - offset msg_nf

msg_title	db	'SiS900 MAC address query tool',cr,lf
len_title	equ	$ - offset msg_title

seg_d	ends

seg_s	segment	stack word use16 'STACK'
seg_s	ends

seg_c	segment	public word use16 'CODE'
	assume	cs:seg_c, ds:seg_d

; rc _OpenOEMHLP(void);
_OpenOEMHLP	proc	near
	push	ax
	mov	ax,sp

	push	ds
	push	offset name_OEMHLP
	push	ds
	push	offset handle_OEMHLP
	push	ss			; action taken
	push	ax
	push	0			; file size
	push	0
	push	0			; file attribute
	push	1			; open flag. open if exist
	push	40h			; open mode
	push	0			; reserve
	push	0
	call	Dos16Open
	pop	cx
	retn
_OpenOEMHLP	endp

_CloseOEMHLP	proc	near
	push	[handle_OEMHLP]
	call	Dos16Close
	retn
_CloseOEMHLP	endp

; __IOCtlOEMHLP(far *parm, far *data);
__IOCtlOEMHLP	proc	near
	push	bp
	mov	bp,sp
	mov	ax,[bp+4]
	mov	cx,[bp+6]
	mov	dx,[bp+8]
	mov	bx,[bp+10]

	push	bx
	push	dx
	push	cx
	push	ax
	push	0bh
	push	80h
	push	[handle_OEMHLP]
	call	Dos16DevIOCtl

	leave
	retn
__IOCtlOEMHLP	endp

; BusDevFunc _FindDevice(USHORT vendor, USHORT device, UCHAR index);
_FindDevice	proc	near
	enter	10,0
	mov	ax,[bp+4]	; vendor
	mov	cx,[bp+6]	; device
	mov	dx,[bp+8]	; index
	mov	byte ptr [bp-10],1
	mov	[bp-9],cx
	mov	[bp-7],ax
	mov	[bp-5],dl
	lea	bx,[bp-4]	; data
	mov	cx,sp
	push	ss		; far *data
	push	bx
	push	ss		; far *parm
	push	cx
	call	__IOCtlOEMHLP
	or	ax,ax
	jnz	short loc_1
	cmp	byte ptr [bp-4],0
	jnz	short loc_1
	mov	ax,[bp-3]	; BusDevFunc
	leave
	retn
loc_1:
	or	ax,-1
	leave
	retn
_FindDevice	endp

; UCHAR _ReadPCI1(USHORT BusDevFunc, UCHAR register)
_ReadPCI1	proc	near
	enter	10,0
	mov	ax,[bp+4]
	mov	cl,[bp+6]
	mov	ch,1
	mov	byte ptr [bp-10],3
	mov	[bp-9],ax
	mov	[bp-7],cx
	mov	dx,sp
	lea	bx,[bp-5]
	push	ss
	push	bx
	push	ss
	push	dx
	call	__IOCtlOEMHLP
	or	ax,ax
	jnz	short loc_1
	cmp	byte ptr [bp-5],0
	jnz	short loc_1
	mov	al,[bp-4]
	leave
	retn
loc_1:
	or	ax,-1
	or	dx,-1
	leave
	retn
_ReadPCI1	endp

; UCHAR _ReadPCI4(USHORT BusDevFunc, UCHAR register)
_ReadPCI4	proc	near
	enter	10,0
	mov	ax,[bp+4]
	mov	cl,[bp+6]
	mov	ch,4
	mov	byte ptr [bp-10],3
	mov	[bp-9],ax
	mov	[bp-7],cx
	mov	dx,sp
	lea	bx,[bp-5]
	push	ss
	push	bx
	push	ss
	push	dx
	call	__IOCtlOEMHLP
	or	ax,ax
	jnz	short loc_1
	cmp	byte ptr [bp-5],0
	jnz	short loc_1
	mov	eax,[bp-4]
	mov	dx,[bp-2]
	leave
	retn
loc_1:
	or	ax,-1
	or	dx,-1
	leave
	retn
_ReadPCI4	endp

; rc _WritePCI1(USHORT BusDevFunc, UCHAR register, UCHAR data)
_WritePCI1	proc	near
	enter	10,0
	mov	ax,[bp+4]
	mov	cl,[bp+6]
	mov	ch,1
	mov	dl,[bp+8]

	mov	byte ptr [bp-10],4
	mov	[bp-9],ax
	mov	[bp-7],cx
	mov	[bp-5],dl
	mov	ax,sp
	lea	bx,[bp-1]
	push	ss
	push	bx
	push	ss
	push	ax
	call	__IOCtlOEMHLP
	or	ax,ax
	jnz	short loc_1
	cmp	byte ptr [bp-5],0
	jnz	short loc_1
	leave
	retn
loc_1:
	or	ax,-1
	leave
	retn
_WritePCI1	endp

_QueryBridge	proc	near
	push	bp
	mov	bp,sp
	push	0		; index
	push	8		; device
	push	1039h		; vendor
	call	_FindDevice
	add	sp,3*2
	cmp	ax,-1
	jnz	short loc_1
	push	1
	push	len_nobridge
	push	ds
	push	offset msg_nobridge
	call	Dos16PutMessage
	mov	ax,1
	jmp	short loc_ex
loc_1:
	push	word ptr [bp+6]
	push	word ptr [bp+4]		; offset MACaddr 
	push	ax			; BusDevFunc
	call	_s9c_bridge		; ISA bridge access
	xor	ax,ax
loc_ex:
	leave
	retn
_QueryBridge	endp

main	proc	near
;	int	3
	push	1
	push	len_title
	push	ds
	push	offset msg_title
	call	Dos16PutMessage

	call	_OpenOEMHLP
	or	ax,ax
	jnz	near ptr loc_er1
loc_0:
	mov	al,[pindex]

	push	ax		; index
	push	900h		; device
	push	1039h		; vendor
	call	_FindDevice
	add	sp,3*2
	cmp	ax,-1
	jz	near ptr loc_er2
	mov	[BusDevFunc],ax

	push	8
	push	ax
	call	_ReadPCI1
	add	sp,2*2
	mov	[ChipRev],al
	call	_PutChipRev

	push	10h
	push	[BusDevFunc]
	call	_ReadPCI4
	add	sp,2*2
	and	ax,-100h
	jz	near ptr loc_er2	; invalid IO address
	mov	[IOaddr],ax

	push	1
	push	len_d
	push	ds
	push	offset msg_d
	call	Dos16PutMessage
	push	ds
	push	offset MACaddr
	push	[IOaddr]
	call	_s9c_eeprom	; direct access
	call	_PutMACaddr

	push	1
	push	len_p
	push	ds
	push	offset msg_p
	call	Dos16PutMessage
	push	ds
	push	offset MACaddr
	push	[IOaddr]
	call	_s9c_peeprom	; pre-request access
	test	ax,ax		; timeout?
	jz	short loc_1
	push	1
	push	len_timeout
	push	ds
	push	offset msg_timeout
	call	Dos16PutMessage
	jmp	short loc_2
loc_1:
	call	_PutMACaddr
loc_2:
	push	1
	push	len_r
	push	ds
	push	offset msg_r
	call	Dos16PutMessage
	push	ds
	push	offset MACaddr
	push	[IOaddr]
	call	_s9c_reload	; reload pmatch filter
	call	_PutMACaddr


	push	1
	push	len_b
	push	ds
	push	offset msg_b
	call	Dos16PutMessage
	push	ds
	push	offset MACaddr
	call	_QueryBridge
	add	sp,2*2
	cmp	ax,0
	jnz	short loc_3
	call	_PutMACaddr

loc_3:
	inc	[pindex]
	cmp	[pindex],8
	jc	near ptr loc_0

loc_er2:
	call	_CloseOEMHLP
	cmp	[pindex],0
	jnz	short loc_er1
	push	1
	push	len_nf
	push	ds
	push	offset msg_nf
	call	Dos16PutMessage
loc_er1:
	push	0
	push	0
	call	Dos16Exit
main	endp


_PutChipRev	proc	near
	push	1
	push	len_ChipRev
	push	ds
	push	offset msg_ChipRev
	call	Dos16PutMessage

	mov	al,[ChipRev]
	push	ax
	call	_PutByte
	pop	cx

	push	1
	push	2
	push	ds
	push	offset msg_crlf
	call	Dos16PutMessage

	retn
_PutChipRev	endp

_PutMACaddr	proc	near
	enter	2,0
	xor	bx,bx
	mov	[bp-2],bx
loc_1:
	mov	bx,[bp-2]
	mov	al,MACaddr[bx]
	push	ax
	call	_PutByte
	pop	ax
	inc	word ptr [bp-2]
	cmp	word ptr [bp-2],6
	jc	short loc_1

	push	1
	push	2
	push	ds
	push	offset msg_crlf
	call	Dos16PutMessage
	leave
	retn
_PutMACaddr	endp

_PutByte	proc	near
	enter	2,0
	mov	cl,[bp+4]
	mov	bl,cl
	and	bx,0fh
	shr	cx,4
	mov	ah,TransTable[bx]
	and	cx,0fh
	mov	bx,cx
	mov	al,TransTable[bx]
	mov	[bp-2],ax
	mov	cx,sp

	push	1
	push	2
	push	ss
	push	cx
	call	Dos16PutMessage

	leave
	retn
_PutByte	endp

seg_c	ends

DGROUP	group	seg_d, seg_s

end	main
