main:

	@@@@@@@@@@ READ INT FROM FILE

	@@@ init index @@@
	mov r0, #0
	ldr r1, =CurrCmdIndex
	str r0, [r1]

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

	@@@ load commands into string
	
	ldr r1, =CommandsStorage
	mov r2, #99
	swi 0x6a

	@@ read first integer from file

	ldr r1, =InFileHandle
	ldr r0, [r1]				@ read integer from input file, and load into r0
	swi 0x6c

	@@ init root node

	mov r1, r0				@ store integer read into r1
	mov r0, #4				@ prepare to allocate for node
	swi 0x12
	ldr r12, =head				@ load pointer to head in r12
	str r0, [r12]				@ store pointer to head in pointer to head label
	str r1, [r0, #4]			@ store integer ( node value ) into head's 4-8 bytes
	@@ correct
	ldr r12, =tail
	str r0, [r12]				@ store pointer to node in tail
	str r1, [r0, #4]			@ storing integer in tails node value spot
	@@ INIT NULL POINTER to both tail and heads next
	mov r1, #0
	str r1, [r12, #0]			@ store null pointer in tails next
	ldr r12, =head
	str r1, [r12, #0]			@ store null pointer in heads next
	
	@@@ <<<<<<<<<<<<<<<< ROOT NODE INITIALIZED >>>>>>>>>>>>>>>>>>>>>> @@@

	@@@ <<<<<<<<<< NODE FORMAT >>>>>>>>>> @@@
	@@		NODE[0] = NEXT POINTER
	@@		NODE[4] = INT VALUE

	b readcmd

readint: @ reads int into r0 and then stores result in r1
	ldr r1, =InFileHandle		@@ set pointer to handler to r1
	ldr r0, [r1]			@@ dereference pointer to handler
	swi 0x6c			@@ read int
	mov r1, r0			@ move int read into r1
	mov pc, lr			@ mov to next line of line that called it

readstr: @ reads a string from txt file
	ldr r1, =CurrCmdIndex		@@ load pointer to current index of command into r1
	ldr r0, [r1]			@@ load current index into r0
	ldr r1, =CommandsStorage		@@ load current string
	ldrb r2, [r1, r0]		@@ load character at string[r0]
	ldr r1, =CurrCmdIndex
	add r0, r0, #2			@@ add two spaces to currIndex of commmand
	str r0, [r1]			@@ store incremented index into CurrCmdIndex pointer
	mov r0, r2			@@ store command in r0
	mov pc, lr

readcmd: @ reads command from text file
	bl readstr
	cmp r0, #112 			@@ 112 = p - push
	beq push
	cmp r0, #102			@@ 104 = f - find
	@@ TODO: beq find
	@@ potentially make one for delete

push:	@@ appends node onto list
	@@@@ ARGS
	@@@ r1 = number to push
	@@@ r0 = pointer that we will be cycling down with r2
	bl readint	 @@ store int to push into r1
	ldr r0, =head	 @@ store head pointer into r0
pushloop:	@@ test, see if weve reached the end of the list
	ldr r2, [r0,#8]		@@ check next pointer
	cmp r2, #0		@ if null, then we found the spot to create new node
	beq pushdone
	ldr r0, [r0, #8]	@ set next point to next node
	b pushloop
pushdone: @@ r0s #8 index is a NULL pointer, update it to be a node
	  @@ ARGS
	mov r3, r0		@@ copy pointer to current spot to r3
	mov r0, #4
	swi 0x12		@@ allocate 2 bytes for node to be placed at
	str r1, [r0, #4]	@@ store int at base addr of r0
	mov r1, #0		@@ init r3 to null pointer
	str r1, [r0]		@@ set next pointer to be null in last node
	str r0, [r3, #0]	@@ store next pointer
	


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
.align 4
CommandsStorage: .skip 999
.align 4
CurrCmdIndex: .word 0

