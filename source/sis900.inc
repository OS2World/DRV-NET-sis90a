; *** silicon integrated systems sis900 ***

; +++ registers definition +++
SIS900_Register	struc
CR		dd	?	; 00 command
CFG		dd	?	; 04 configuration
MEAR		dd	?	; 08 EEPROM access
PTSCR		dd	?	; 0c PCI test control
ISR		dd	?	; 10 interrupt status
IMR		dd	?	; 14 interrupt mask
IER		dd	?	; 18 interrupt enable
ENPHY		dd	?	; 1c enhanced PHY access
TXDP		dd	?	; 20 transmit descriptor pointer
TXCFG		dd	?	; 24 transmit configuration
		dd	?	; 28
		dd	?	; 2c
RXDP		dd	?	; 30 receive descriptor pointer
RXCFG		dd	?	; 34 receive configuration
FLOWCTL		dd	?	; 38 flow control
		dd	?	; 3c 
		dd	?	; 40 
		dd	?	; 44 
RFCR		dd	?	; 48 receive filter/match control
RFDR		dd	?	; 4c receive filter/match data
		dd	24 dup(?) ; 50-ac
PMCTL		dd	?	; b0 power management control
PMEVT		dd	?	; b4 power management wake-up event
		dd	?	; b8
WAKECRC		dd	?	; bc wake-up sample frame CRC
WAKEMASK	dd	12 dup(?) ; c0-ec wake-up sample frame mask
		dd	4 dup(?) ; f0-fc
SIS900_Register	ends

; +++ command register +++
RELOAD		equ	400h	; reload mac address?
ACCESSMODE	equ	200h	; mii access mode? SIS630ET
RST		equ	100h	; reset
SWIR		equ	 80h	; software interrupt
RXR		equ	 20h	; receiver reset
TXR		equ	 10h	; transmit reset
RXD		equ	  8	; receiver disable
RXE		equ	  4	; receiver enable
TXD		equ	  2	; transmit disable
TXE		equ	  1	; transmit enable

; +++ configuration and media status register +++
;LNKSTS		equ	80000000h	; link status
;SPEED100	equ	40000000h	; speed 100Mb/s
;FDUP		equ	20000000h	; full duplex
;POL		equ	10000000h	; 10Mb/s polarity indication
;ANEG_DN		equ	 8000000h	; auto-negotiation done
;PINT_ACEN	equ	   20000h	; phy interrupt auto clear enable
;PAUSE_ADV	equ	   10000h	; pause advertise
;ANEG_SEL	equ	   0e000h	; auto negotiation select
;EXT_PHY		equ	    1000h	; external phy support
;PHY_RST		equ	     400h	; reset internal phy
RND_CNT		equ	     400h	; ? 635, 900B, 96x
;PHY_DIS		equ	     200h	; disable interrupt phy
;EUPHCOMP	equ	     100h	; dp83810 descriptor compatibillity
REQALG		equ	      80h	; PCI bus request algorithm
SB		equ	      40h	; single back-off
POW		equ	      20h	; program out of window timer
EXD		equ	      10h	; excessive deferral timer disable
PESEL		equ	       8	; parity error detection action
;BROM_DIS	equ	       4	; disable boot ROM interface
BEM		equ	       1	; big endian mode

; +++ EEPROM access register +++
EEREQ		equ	400h	; ?? sis963
EEDONE		equ	200h	; ?? sis963
EEGNT		equ	100h	; ?? sis963
;MDC		equ	40h	; MII management clock
;MDDIR		equ	20h	; MII managemant direction
;MDIO		equ	10h	; MII management data
EESEL		equ	 8	; EEPROM chip select
EECLK		equ	 4	; EEPROM serial clock
EEDO		equ	 2	; EEPROM data out
EEDI		equ	 1	; EEPROM data in

; +++ interrupt status/mask register +++
WAKEEVT		equ	10000000h	; wake up event
PAUSE_END	equ	08000000h	; end of transmission pause
PAUSE_ST	equ	04000000h	; start of transmission pause
TXRCMP		equ	02000000h	; transmit reset complete
RXRCMP		equ	01000000h	; receive reset complete
DPERR		equ	00800000h	; detectd parity error
SSERR		equ	00400000h	; signaled system error
RMABT		equ	00200000h	; receive master abort
RTABT		equ	00100000h	; receive target abort
RXSOVR		equ	00010000h	; rx status FIFO overrun
HIBERR		equ	00008000h	; high bit error set
;PHY		equ	00004000h	; phy interrupt
;PME		equ	00002000h	; power management event
SWI		equ	00001000h	; software interrupt
;MIB		equ	00000800h	; MIB service
TXURN		equ	00000400h	; tx underrun
TXIDLE		equ	00000200h	; tx idle
TXERR		equ	00000100h	; tx packet error
TXDESC		equ	00000080h	; tx descriptor
TXOK		equ	00000040h	; tx packet ok
RXORN		equ	00000020h	; rx overrun
RXIDLE		equ	00000010h	; rx idle
RXEARLY		equ	00000008	; rx early threshold
RXERR		equ	00000004	; rx packet error
RXDESC		equ	00000002	; rx descriptor
RXOK		equ	00000001	; rx ok

; +++ interrupt enable register +++
IE		equ	1	; interrupt enable

; +++ enhanced PHY access register +++
PHYDATA		equ	0ffff0000h	; PHY data (mask)
REGADDR		equ	      7c0h	; PHY register address (mask)
RWCMD		equ	       20h	; access command 1:read 0:write
ACCESS		equ	       10h	; 1:request/0:done

; +++ transmit configuration register +++
CSI		equ	80000000h	; carrier sense ignore
HBI		equ	40000000h	; heartbeat ignore
MLB		equ	20000000h	; MAC loopback
ATP		equ	10000000h	; automatic transmit padding
;IFG		equ	0c000000h	; interframe gap time (mask)
;ECRETRY		equ	  800000h	; excessive collision retry enable
TxMXDMA		equ	  700000h	; max DMA burst size per tx DMA burst (mask)
TxFLTH		equ	    3f00h	; tx fill threshold (mask)
TxDRTH		equ	      3fh	; tx drain threshold (mask)

; +++ receive configuration register +++
AEP		equ	80000000h	; accept errored packets
ARP		equ	40000000h	; accept runt packets
ATX		equ	10000000h	; accept transmit packets
ALP		equ	 8000000h	; accept long packets
RxMXDMA		equ	  700000h	; max DMA burst size per rx DMA burst (mask)
RxDRTH		equ	      3eh	; rx drain threshold (mask)

; +++ flow control register +++
PAUSE		equ	2		; pause flag
FLOWEN		equ	1		; flow control enable

; +++ receive filter/match control register +++
RFEN		equ	80000000h	; rx filter enable
rfAAB		equ	40000000h	; accept all broadcast
rfAAM		equ	20000000h	; accept all multicast
rfAAU		equ	10000000h	; accept all unicast
;rfAPM		equ	 8000000h	; accept on perfect match
;rfAPAT		equ	 7800000h	; accept on pattern match
;rfAARP		equ	  400000h	; accept ARP packets
;rfMHEN		equ	  200000h	; multicast hash enable
;rfUHEN		equ	  100000h	; unicast hash enable
;rfULM		equ	   80000h	; U/L bit mask
RFADDR		equ	  0f0000h	; receive filter address
;RFADDR		equ	     3ffh	; receive filter extended register address

; +++ receive filter/match data register +++
;BMASK		equ	   30000h	; byte mask
RFDATA		equ	   0ffffh	; receive filter data (mask)

; +++ power management control register +++
GATECLK		equ	80000000h	; gate dual target clock enable
WAKEALL		equ	40000000h	; wake-up while receive OK packet
FRM3ACS		equ	 4000000h	; 3rd wake-up frame access
FRM2ACS		equ	 2000000h	; 2nd wake-up frame access
FRM1ACS		equ	 1000000h	; 1st wake-up frame access
FRM3EN		equ	  400000h	; 3rd wake-up frame match enable
FRM2EN		equ	  200000h	; 2nd wake-up frame match enable
FRM1EN		equ	  100000h	; 1st wake-up frame match enable
ALGORITHM	equ	     800h	; magic packet match algorithm
MAGICPKT	equ	     400h	; magic packet match enable
LINKON		equ	       2	; link on monitor enable
LINKLOSS	equ	       1	; link loss monitor enable

; +++ power management wake-up event register +++
ALLFRMMAT	equ	40000000h	; receive ok packet
FRM3MAT		equ	  400000h	; match 3rd wake-up sample frame
FRM2MAT		equ	  200000h	; match 2nd wake-up sample frame
FRM1MAT		equ	  100000h	; match 1st wake-up sample frame
MAGICMAT	equ	     400h	; magic packet
ONEVT		equ	       2	; link on event
LOSSEVT		equ	       1	; link loss event


; +++ buffer +++
bufdesc		struc
link		dd	?	; next descriptor link
cmdsts		dd	?	; command/status field
bufptr		dd	?	; buffer pointer
; above for device, below for driver.
phyaddr		dd	?	; physical address of this descriptor
virtaddr	dd	?	; virtual address of bufptr (rx)
deschandle	dw	?	; descriptor handle (rx)
desctail	dw	?	; frame tail descriptor (rx)
vlink		dw	?	; virtual link
		dw	?	; reserve for dword alignment
bufdesc		ends

; +++ cmdsts bit +++
OWN		equ	80000000h	; descriptor ownership
MORE		equ	40000000h	; more descriptor
INTR		equ	20000000h	; interrupt
SUPCRC		equ	10000000h	; tx suppress CRC
INCCRC		equ	10000000h	; rx inclued CRC
OK		equ	 8000000h	; packet OK
BUFSIZE		equ	    0fffh	; descriptor byte count

; +++ transmit status bit +++
TXA		equ	 4000000h	; transmit abort
TFU		equ	 2000000h	; transmit FIFO underrun
CRS		equ	 1000000h	; carrier sense lost
TD		equ	  800000h	; transmit deferred
ED		equ	  400000h	; excessive defferred
OWC		equ	  200000h	; out of window collision
EC		equ	  100000h	; excessive collisions
CCNT		equ	  0f0000h	; collision count

; +++ receive status bit +++
RXA		equ	 4000000h	; receive aborted
RXO		equ	 2000000h	; receive overrun
DEST		equ	 1800000h	; destination class
LONG		equ	  400000h	; too long packet received
RUNT		equ	  200000h	; runt packet received
ISE		equ	  100000h	; invalid symbol error
CRCE		equ	   80000h	; CRC error
FAE		equ	   40000h	; frame alignment error
LBP		equ	   20000h	; loopback packet
COL		equ	   10000h	; collision activity

; +++ virtual tx frame descriptor (for driver) +++
txdesc		struc
deschead	dw	?	; head descriptor
desctail	dw	?	; tail descriptor
reqhandle	dw	?	; requset handle
protid		dw	?	; protocol id
vlink		dw	?	; vlink
		dw	?	; reserve
immedphy	dd	?	; physical address of immediate data
immed		db	64 dup (?) ; reserve for immediate data
txdesc		ends


; *** from solaris driver.  mainly chip revision specific definition ***
; +++ chip revision +++
SIS630A		equ	80h
SIS630E		equ	81h
SIS630S		equ	82h
SIS630EA1	equ	83h
SIS630ET	equ	84h
SIS635A		equ	90h
SIS962		equ	91h
SIS900B		equ	03h

; +++ SiS630 bridge revision +++
SIS630A0	equ	 0
SIS630A1	equ	 1
SIS630B0	equ	10h
SIS630B1	equ	11h

; +++ SIS900 integrated PHY registers +++
miiCONFIG1	equ	10h
miiCONFIG2	equ	11h
miiMASK		equ	13h
miiRESV		equ	14h

; +++ PHY id +++
PHY_SIS900	equ	001d8000h
PHY_ICS1893	equ	0015f440h

