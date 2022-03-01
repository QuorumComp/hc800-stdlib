		INCLUDE "kernal/uart_commands.i"
		INCLUDE "kernal/uart_commands_disabled.i"

		INCLUDE	"lowlevel/rc800.i"

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
; -- Append characters to end of string
; --
; -- Inputs:
; --   ft - pointer to string
; --   bc - pointer to chars (BSS)
; --    d - number of chars
; --
		SECTION	"StringAppendChars",CODE
StringAppendChars:
		pusha

		; set new length
		ld	hl,ft
		ld	t,(hl)
		push	ft
		add	t,d
		ld	(hl),t
		add	hl,1

		; adjust dest pointer
		pop	ft
		ld	f,0
		add	ft,hl
		ld	hl,ft

		MDebugRegisters
		MDebugMemory bc,32

		add	d,1
		j	.start

.loop		ld	t,(bc)
		add	bc,1
		ld	(hl),t
		add	hl,1
.start		dj	d,.loop

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Append string in BSS segment to end of string
; --
; -- Inputs:
; --   ft - pointer to string
; --   bc - pointer to chars (BSS)
; --
		SECTION	"StringAppendString",CODE
StringAppendString:
		pusha

		exg	ft,bc
		ld	d,(ft)
		add	ft,1
		exg	ft,bc

		jal	StringAppendChars

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Append string in code segment to end of string
; --
; -- Inputs:
; --   bc - pointer to string
; --   de - pointer to string to append
; --
		SECTION	"StringAppendDataString",CODE
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
; -- Find character in memory
; --
; -- Inputs:
; --   ft - memory
; --    b - character
; --    c - maximum length
; --
; -- Outputs:
; --    f - "eq" if found
; --  ft' - pointer to character or non existant if f "ne"
; --
		SECTION	"MemoryCharN",CODE
MemoryCharN:
		push	bc-hl

		MDebugPrint <"MemoryCharN entry\n">
		MDebugRegisters

		ld	de,ft
.loop		ld	t,(de)
		cmp	t,b
		j/eq	.found
		add	de,1
		dj	c,.loop

		ld	f,FLAGS_NE
		j	.exit
		
.found		ld	ft,de
		push	ft
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Find character in string, search from the end
; --
; -- Inputs:
; --   ft - memory
; --    b - character
; --
; -- Outputs:
; --    f - "eq" if found
; --  ft' - pointer to character or non existant if f "ne"
; --
		SECTION	"StringReverseChar",CODE
StringReverseChar:
		push	bc-hl

		ld	c,(ft)
		add	ft,1
		jal	MemoryReverseCharN

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Find character in memory, searching from the end
; --
; -- Inputs:
; --   ft - memory
; --    b - character
; --    c - maximum length
; --
; -- Outputs:
; --    f - "eq" if found
; --  ft' - pointer to character or non existant if f "ne"
; --
		SECTION	"MemoryCharN",CODE
MemoryReverseCharN:
		push	bc-hl

		MDebugPrint <"MemoryReverseCharN entry\n">
		MDebugRegisters

		ld	de,ft

		cmp	c,0
		j/eq	.empty

		ld	f,0
		ld	t,c
		add	ft,de
		ld	de,ft

.loop		ld	t,(de)
		cmp	t,b
		j/eq	.found
		sub	de,1
		dj	c,.loop

.empty		ld	f,FLAGS_NE
		j	.exit
		
.found		ld	ft,de
		push	ft
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Compare memory content
; --
; -- Inputs:
; --   ft - memory
; --   bc - memory
; --    d - bytes to compare
; --
; -- Outputs:
; --    f - flags set according to result of comparing memory pointed to by
; --        ft and bc
; --
		SECTION	"MemoryCompareN",CODE
MemoryCompareN:
		push	bc-hl

		ld	hl,ft

.loop		ld	t,(bc)
		add	bc,1
		ld	f,t
		ld	t,(hl)
		add	hl,1

		cmp	t,f
		j/ne	.done

		dj	d,.loop

		ld	f,FLAGS_EQ

.done		pop	bc-hl
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
