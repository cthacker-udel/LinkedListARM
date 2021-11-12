main:

	@@@@@@@@@@ READ INT FROM FILE

	ldr r0, =InFileName		@ set r0 = name of file
	mov r1, #0			@ set r1 = type of mode (0 = input)
	swi 0x66 			@ swi command for opening a file, assigns r0 to the file handle
	ldr r1, =InFileHandle		@ get pointer to file handle
	str r0, [r1, #0]		@ store file handle in dereferenced filehandle

	@read first integer from file

	ldr r1, =InFileHandle 		@ load pointer to file handle into r1
	ldr r0, [r1]			@ load file handle from dereferenced r1 pointer r1->filehandle
	swi 0x6c			@ read integer into r0

	@@@@ --- initialize root node

	mov r1, r0 			@ move integer read into r1

	mov r0, #8			@ pre-assign amount of bytes to allocate into r8

	swi 0x12			@ allocate 8 bytes of space and place addr into r0

	ldr r12, =head 			@ load pointer to head into r12

	str r0, [r12, #0]		@ store new node address into head

	ldr r12, =tail			@ load pointer to tail into r12

	str r0, [r12, #0]		@ store root node into tail pointer

	str r1, [r0, #0]		@ saving integer into root node's integer addr

	mov r3, #0			@ set r3 to null

	str r3, [r0, #4]		@ set next pointer to null

	@@@@ PUSH

	push: @ pushes a node to the end of the list

		bl read 		@ make r1 = next int in file
		mov r0, #8 		@ set r0 to be 8 bytes for allocation at next step
		swi 0x12 		@ allocate 8 bytes because r0 is 8
		str r1 [ r0, #0 ] 		@ set new node value to be r1
		mov r1, #0 		@ set r1 to be null
		str r1, [ r0, #4 ] 		@ set new node next to be null
		ldr r2, =tail 		@ load tail data header into r2
		ldr r2, [r2] 		@ dereference tail
		str r0, [ r2, #4 ] 		@ store address of new node in tails next
		ldr r2, =tail 		@ load tail into r2 again to change the tail's pointer addr
		str r0, [r2] 		@ store node to where tails pointer is pointing to, so new node = tail

	readint: @ reads int into r0 and then stores the result into r1
		
		ldr r1, =InFileHandle
		ldr r0, [ r1, #0 ] 		@ load file handle into r0
		swi 0x6c 		@ r0 = int read
		mov r1, r0 		@ move int read into r1
		mov pc, lr		@ move to next line where read was called from

	readstr: @ reads a string from the txt file
		
		mov r1, #6		@ allocate 6 bytes for r1
		ldr r0, =InFileHandle	@ load file handler into r0
		mov r2, #6		@ load max # of bytes to store in r2
		swi 0x6a		@ read string from file
		mov pc, lr		@ move to next line after the readstr call
		

	@@@@ TODO --- delete with index

	@@@@ TODO --- clear method

	@@@@ TODO --- contains

	@@@@ TODO --- pop

	@@@@ TODO --- removeHead

	@@@@ TODO --- removeTail


.data
head: .word 0
tail: .word 0
InFileName: .ascii "values.txt"
InFileHandle: .word 0
Space: .ascii " "
