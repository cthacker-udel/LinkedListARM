main:

	@@@@@@@@@@ READ INT FROM FILE

	ldr r0, =InFileName		@ set r0 = name of file
	mov r1, #0			@ set r1 = type of mode (0 = input)
	swi 0x66 			@ swi command for opening a file, assigns r0 to the file handle
	ldr r1, =InFileHandle
	str r0, [r1]

	@@ stored file handle in input file

	ldr r0, =CmdFileName			@ initialize r0 to file name
	swi 0x02
	mov r1, #1				@ initialize handler for input
	swi 0x66				@ set r0 = file handler
	ldr r1, =CmdFileHandle			@ set r1 = pointer to file handler
	str r0, [r1]				@ store file handler in pointer to cmdfilehandler
	
	@@ allocating commands file handle

	ldr r0, =CommandsFileName		@@ init r0 to file name
	swi 0x02
	mov r1, #0
	swi 0x66
	ldr r1, =CommandsFileHandle
	str r0, [r1]

	@@ read first integer from file

	ldr r1, =InFileHandle
	ldr r0, [r1]				@ read integer from input file, and load into r0
	swi 0x6c

	@@ init root node

	mov r1, r0				@ store integer read into r1
	mov r0, #8				@ prepare to allocate for node
	swi 0x12
	ldr r12, =head				@ load pointer to head in r12
	str r0, [r12]				@ store pointer to head in pointer to head label
	str r1, [r0, #4]			@ store integer ( node value ) into head's 4-8 bytes
	ldr r12, =tail
	str r0, [r12]				@ store pointer to node in tail
	str r1, [r0, #4]			@ storing integer in tails node value spot
	mov r1, #0
	str r1, [r12, #8]			@ store null pointer in tails next
	ldr r12, =head
	str r1, [r12, #8]			@ store null pointer in heads next



.data

.align 4
head: .word 0
.align 4
tail: .word 0
.align 4
InFileName: .asciz "list.txt"
.align 4
InFileHandle: .word 0
.align 4
CmdFileName: .asciz "cmd.txt"
.align 4
CmdFileHandle: .word 0
.align 4
CommandsFileName: .asciz "commands.txt"
.align 4
CommandsFileHandle: .word 0
