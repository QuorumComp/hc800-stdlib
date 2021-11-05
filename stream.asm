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
; --   ft:ft' - value to print
		SECTION	"StreamHexLongOut",CODE
StreamHexLongOut:
		push	hl

		jal	StreamHexWordOut
		swap	ft
		jal	StreamHexWordOut
		swap	ft

		pop	hl
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

		jal	.recurse
		j	.exit

.print_zero	ld	t,0
		jal	StreamDigitOut

.exit		popa
		j	(hl)

.recurse
		; input: bc = value to print
		pusha

		tst	bc
		j/z	.recurse_done

		ld	ft,bc
		MZeroExtend ft
		ld	bc,10
		jal	MathDivideSigned_32by16_q16_r16

		swap	ft
		ld	bc,ft
		jal	.recurse

		pop	ft
		jal	StreamDigitOut

.recurse_done	popa
		j	(hl)


; -- Dump memory as hexadecimal and ASCII
; --
; -- Inputs:
; --   ft - number of bytes to dump (max 4096)
; --   bc - pointer to memory
; --
		SECTION	"StreamMemoryDump",CODE
StreamMemoryDump:
		pusha

		push	ft
		rs	ft,4
		ld	de,ft		; de = number of 16 byte lines to print
		tst	de
		j/eq	.lines_done

		; adjust loop counters

		sub	de,1
		add	d,1
		add	e,1

.full_lines	ld	f,16
		jal	.hex_dump
		ld	t,' '
		sys	KCharacterOut
		jal	.char_dump
		add	bc,16

		dj	e,.full_lines
		dj	d,.full_lines

.lines_done	pop	ft
		and	t,$F		; t = number of bytes to print at last line
		cmp	t,0
		j/eq	.partial_done

		ld	f,t
		jal	.hex_dump

		push	ft

		sub	t,16
		neg	t
		ld	f,t
		add	t,t
		add	t,f
		add	t,1		; t = spaces to print

		ld	f,t
		ld	t,' '
.space_loop	sys	KCharacterOut
		dj	f,.space_loop
		pop	ft

		jal	.char_dump

.partial_done	popa
		j	(hl)

.hex_dump	pusha
.hex_loop	ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		ld	t,' '
		sys	KCharacterOut
		dj	f,.hex_loop
		popa
		j	(hl)

.char_dump	pusha
		ld	t,f
		ld	e,t
.char_loop	ld	t,(bc)
		add	bc,1
		cmp	t,' '
		ld/ltu	t,'.'
		sys	KCharacterOut
		dj	e,.char_loop
		MNewLine
		popa
		j	(hl)
