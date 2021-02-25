		INCLUDE	"lowlevel/math.i"

		INCLUDE	"stream.i"
		INCLUDE	"string.i"
		INCLUDE	"syscall.i"


; -- Write data to stream out
; --
; -- Inputs:
; --   bc - pointer to code/data
; --   de - number of bytes to write
		SECTION	"StreamDataOut",CODE
StreamDataOut:
		pusha
		tst	de
		j/z	.exit
		sub	de,1
		add	d,1
		add	e,1
.next		lco	t,(bc)
		add	bc,1
		sys	KCharacterOut
		dj	e,.next
		dj	d,.next
.exit		popa
		j	(hl)


; -- Write data string to stream out
; --
; -- Inputs:
; --   bc - pointer to std string
		SECTION	"StreamDataStringOut",CODE
StreamDataStringOut:
		pusha
		lco	t,(bc)
		cmp	t,0
		j/z	.exit
		ld	d,t
.next		add	bc,1
		lco	t,(bc)
		sys	KCharacterOut
		dj	d,.next
.exit		popa
		j	(hl)


; -- Write bss string to stream out
; --
; -- Inputs:
; --   bc - pointer to std string
		SECTION	"StreamBssStringOut",CODE
StreamBssStringOut:
		pusha
		ld	t,(bc)
		cmp	t,0
		j/z	.exit
		ld	d,t
.next		add	bc,1
		ld	t,(bc)
		sys	KCharacterOut
		dj	d,.next
.exit		popa
		j	(hl)


; -- Print value as hexadecimal
; --
; -- Inputs:
; --   ft - value to print
		SECTION	"StreamHexWordOut",CODE
StreamHexWordOut:
		pusha

		exg	f,t
		jal	StreamHexByteOut
		exg	f,t
		jal	StreamHexByteOut

		popa
		j	(hl)


; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
		SECTION	"StreamHexByteOut",CODE
StreamHexByteOut:
		pusha

		ld	d,t

		ld	f,0
		rs	ft,4
		jal	StreamDigitOut

		ld	t,$F
		and	t,d
		jal	StreamDigitOut

		popa
		j	(hl)

; -- Print single digit
; --
; --    t - digit ($0-$F)
		SECTION	"StreamDigitOut",CODE
StreamDigitOut:
		pusha

		jal	DigitToAscii
		sys	KCharacterOut

		popa
		j	(hl)



; -- Print value as decimal
; --
; -- Inputs:
; --   ft - value to print
		SECTION	"StreamDecimalWordOut",CODE
StreamDecimalWordOut:
		pusha

		ld	bc,ft
		tst	bc
		j/z	.print_zero

		ld	ft,bc
		jal	.recurse
		j	.exit

.print_zero	ld	t,0
		jal	StreamDigitOut

.exit		popa
		j	(hl)

.recurse
		pusha

		ld	bc,ft
		tst	bc
		j/z	.recurse_done

		ld	ft,10
		push	bc
		ld	bc,0
		jal	MathDivideUnsigned_32_16

		jal	.recurse

		ld	ft,bc
		jal	StreamDigitOut

.recurse_done	popa
		j	(hl)


