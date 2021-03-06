		INCLUDE	"string.i"

; ---------------------------------------------------------------------------
; -- Clear a string (set it to the empty string)
; --
; -- Inputs:
; --   bc - pointer to string
; --
		SECTION	"StringClear",CODE
StringClear:
		push	ft

		ld	t,0
		ld	(bc),t

		pop	ft
		j	(hl)


; ---------------------------------------------------------------------------
; -- Trim white space off string end
; --
; -- Inputs:
; --   bc - pointer to string
; --
		SECTION	"StringTrimRight",CODE
StringTrimRight:
		push	ft
		push	bc

		ld	t,(bc)
		ld	f,0
		add	ft,bc
		ld	bc,ft

.find		ld	t,(bc)
		sub	bc,1
		cmp	t,' '
		j/leu	.find

		ld	ft,bc
		pop	bc
		sub	ft,bc
		add	t,1
		ld	(bc),t

		pop	ft
		j	(hl)


; ---------------------------------------------------------------------------
; -- Append character to end of string
; --
; -- Inputs:
; --    t - character to append
; --   bc - pointer to string
; --
; -- Outputs:
; --    t - new string length
; --
		SECTION	"StringAppendChar",CODE
StringAppendChar:
		push	bc/de

		ld	d,t
		ld	t,(bc)
		add	t,1
		ld	(bc),t
		ld	f,0
		add	ft,bc
		ld	(ft),d

		pop	bc/de
		j	(hl)


; ---------------------------------------------------------------------------
; -- Append string in code segment to end of string
; --
; -- Inputs:
; --   bc - pointer to string
; --   de - pointer to string to append
; --
; -- Outputs:
; --    t - new string length
; --
		SECTION	"StringAppendChar",CODE
StringAppendDataString:
		pusha

		lco	t,(de)
		add	de,1

		; update destination length

		ld	h,t
		ld	t,(bc)
		push	ft
		add	t,h
		ld	(bc),t
		pop	ft

		; adjust destination pointer

		ld	f,0
		add	ft,1
		add	ft,bc
		ld	bc,ft

		cmp	h,0
		j/eq	.exit

.loop		lco	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	h,.loop

.exit		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Copy string
; --
; -- Inputs:
; --   bc - destination
; --   de - source
; --
		SECTION	"StringCopy",CODE
StringCopy:
		pusha

		ld	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1

		cmp	t,0
		j/eq	.exit

		ld	f,t
.loop		ld	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.loop

.exit		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Split string at separator. Destination must be at least source string
; -- length + 2. Destination will be filled with a array of strings, the
; -- last one having a length of 0. Initial, trailing and consecutive
; -- separators will be ignored, no empty strings are stored.
; --
; -- Inputs:
; --    t - separator
; --   bc - destination (BSS)
; --   de - source (BSS)
; --
		SECTION	"StringSplit",CODE
StringSplit:
		pusha

		ld	l,t	; l = separator
		ld	t,(de)
		ld	h,t	; h = string length remaining
		add	de,1

.next_string	push	bc
		add	bc,1	; skip length byte

.next_char	cmp	h,0
		j/eq	.string_end

		ld	t,(de)
		add	de,1
		sub	h,1
		cmp	t,l
		j/eq	.string_end

		ld	(bc),t
		add	bc,1
		j	.next_char

.string_end	ld	ft,bc
		swap	bc	; restore start of string
		sub	ft,bc
		sub	ft,1	; adjust for length byte
		ld	(bc),t
		cmp	t,0
		swap/eq	bc	; don't store empty string
		pop	bc

		cmp	h,0
		j/ne	.next_string

		ld	t,0
		ld	(bc),t	; length byte

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Convert digit (any base) to ASCII
; --
; -- Inputs:
; --    t - digit
; --
; -- Outputs:
; --    t - character
; --
		SECTION	"DigitToAscii",CODE
DigitToAscii:
		cmp	t,10
		j/ltu	.decimal
		add	t,'A'-10
		j	(hl)
.decimal	add	t,'0'
		j	(hl)
