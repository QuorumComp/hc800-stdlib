	INCLUDE	"heap.i"

		RSRESET
heap_IsFree	RB	1
heap_Prev	RW	1
heap_Size	RW	1
heap_SIZEOF	RB	0

; ---------------------------------------------------------------------------
; -- Initialize heap
; --
; -- Inputs:
; --   ft - pointer to heap
; --   bc - size of heap in bytes
; --
		SECTION	"HeapInit",CODE
HeapInit:
		pusha

		ld	de,heap
		ld	(de+),ft

		ld	d,1
		ld	(ft+),d		; IsFree		

		ld	d,0
		ld	(ft+),d		; Prev		
		ld	(ft+),d		; Prev		

		ld	(ft+),bc	; Size

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Allocate a block of memory from the heap
; --
; -- Inputs:
; --   ft - number of bytes to allocate
; --
; -- Outputs:
; --   ft - block or null if not enough memory available
; --
		SECTION	"HeapAlloc",CODE
HeapAlloc:
		push	bc-hl

		ld	hl,ft
		add	hl,heap_SIZEOF

		ld	ft,heap
		ld	bc,(ft+)

.loop		tst	bc
		j/eq	.fail

		ld	t,(bc)
		cmp	t,0
		j/eq	.next

		add	bc,heap_Size
		ld	ft,(bc+)
		sub	bc,heap_Size+1
		sub	ft,hl
		ld	de,ft
		tst	ft
		j/ltu	.next

		ld	ft,de
		ld	de,heap_SIZEOF
		cmp	ft,de
		j/leu	.whole_block

		; block is large enough and must be split

		; bc - old block, split this and return first section
		; hl - new size of first section

		ld	ft,hl
		jal	splitBlock

.whole_block	ld	t,0
		ld	(bc),t	; IsFree
		ld	ft,bc
		add	ft,heap_SIZEOF
		j	.exit

.next		add	bc,heap_Size
		ld	ft,(bc+)
		sub	bc,heap_Size+1
		add	ft,bc
		ld	bc,ft
		j	.loop
.exit
		pop	bc-hl
		j	(hl)


; ft - size of first section incl. header
; bc - block to split
splitBlock:
		pusha

		ld	hl,ft		; hl - size of first section

		add	ft,bc
		ld	de,ft		; de - second block

		; set up second block

		ld	t,1
		ld	(de+),t		; IsFree
		ld	ft,bc
		ld	(de+),ft	; Prev		

		add	bc,heap_Size
		ld	ft,(bc+)
		sub	ft,hl

		add	de,heap_Size-(heap_Prev+1)
		ld	(de+),ft	; Size

		; set up first block

		ld	t,0
		add	bc,heap_Free-(heap_Size+1)
		ld	(bc+),t		; IsFree
		add	bc,heap_Size-(heap_Free+1)
		ld	ft,hl
		ld	(bc+),hl

		popa
		j	(hl)



; ---------------------------------------------------------------------------
; -- Return a block of memory to the heap
; --
; -- Inputs:
; --   ft - block to free
; --
; --
		SECTION	"HeapFree",CODE
HeapFree:
		pusha

		ld	hl,ft
		ld	bc,ft

		add	hl,heap_Size
		ld	ft,(hl+)
		add	ft,bc
		ld	de,ft		; de - next
		ld	t,(de)		; IsFree
		cmp	t,0
		j/ne	.next_not_free

		jal	mergeBlocks

.next_not_free

; bc - first block
; de - second block
mergeBlocks:


		popa
		j	(hl)
	

		SECTION	"HeapVars",BSS
heap		DS	2
