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
	mov r1, #2				@ initialize handler for input
	swi 0x66				@ set r0 = file handler
	ldr r1, =CmdFileHandle			@ set r1 = pointer to file handler
	str r0, [r1]

	@@ allocating commands file handle

	ldr r0, =CommandsFileName		@@ init r0 to file name
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
	mov r0, #8				@ prepare to allocate for node
	swi 0x12
	ldr r12, =head				@ load pointer to head in r12
	str r0, [r12]				@ store pointer to head in pointer to head label
	str r1, [r0, #4]			@ store integer ( node value ) into head's 4-8 bytes
	@@ correct
	ldr r12, =tail
	str r0, [r12]				@ store pointer to node in tail
	@@ INIT NULL POINTER to both tail and heads next
	mov r1, #0
	ldr r12, [r12]
	str r1, [r12, #0]			@ store null pointer in tails next
	ldr r12, =head
	ldr r12, [r12]
	str r1, [r12, #0]			@ store null pointer in heads next
	
	ldr r1, =head				@@ DEBUG
	ldr r1, [r1]				@@ DEBUG
	ldr r4, [r1, #4]			@@ DEBUG

	@@@ <<<<<<<<<<<<<<<< ROOT NODE INITIALIZED >>>>>>>>>>>>>>>>>>>>>> @@@

	@@@ <<<<<<<<<< NODE FORMAT >>>>>>>>>> @@@
	@@		NODE[0] = NEXT POINTER
	@@		NODE[4] = INT VALUE

	b readcmd

readint: @ reads int into r0 and then stores result in r1
	ldr r1, =InFileHandle		@@ set pointer to handler to r1
	ldr r0, [r1]			@@ dereference pointer to handler
	swi 0x6c			@@ read int
	bcs printlist
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
	bleq push
	cmp r0, #102			@@ 104 = f - find
	beq find
	cmp r0, #0			@@ done reading, printList
	b printlist
	@@ TODO: beq find
	@@ potentially make one for delete

find: @@ searches through the loop
	bl readint		@@ store int read into r1
	ldr r0, =head		@ load head node into r0
	ldr r0, [r0]
findloop: @@ loops through nodes
	ldr r2, [r0, #4]		@@ value of currnode
	cmp r2, r1			@@ see if we found the value
	beq found
	ldr r2, [r0]
	cmp r2, #0			@@ check if pointer to next is null
	beq notfound			@@ branch to notfound if we reached the last node and still have not found the value
	ldr r0, [r0,#0]			@@ move r0 to next node
	b findloop				@@ repeat loop with next node

notfound:	@ we have reached end of list and have not found node
	ldr r0, =OutputFileHandler	@ load outputfilehandler into r0
	ldr r0, [r0]			@ dereference outputfilehandler
	ldr r1, =notFoundNumber		@ load string to r1
	swi 0x69
	b readcmd			@ end find loop, load next command

found:
	ldr r0, =OutputFileHandler
	ldr r0, [r0]		@ dereference file handler
	ldr r1, =foundNumber	@ load string addr into r1
	swi 0x69		@ write to file
	b readcmd		@ end loop


push:	@@ appends node onto list
	@@@@ ARGS
	@@@ r1 = number to push
	@@@ r0 = pointer that we will be cycling down with r2
	bl readint	 @@ store int to push into r1
	ldr r0, =head	 @@ store head pointer into r0
	ldr r0, [r0]
	ldr r4, [r0, #4]	@@ DEBUG
pushloop:	@@ test, see if weve reached the end of the list
	ldr r2, [r0,#0]		@@ check next pointer
	cmp r2, #0		@ if null, then we found the spot to create new node
	beq pushdone
	ldr r0, [r0, #4]	@ set next point to next node
	b pushloop
pushdone: @@ r0s #8 index is a NULL pointer, update it to be a node
	  @@ ARGS
	mov r3, r0		@@ copy pointer to current spot to r3
	mov r0, #8
	ldr r4, [r3, #4]	@@ DEBUG
	swi 0x12		@@ allocate 2 bytes for node to be placed at
	ldr r4, [r3, #4]	@@ DEBUG
	str r1, [r0, #4]	@@ store int at base addr of r0
	mov r1, #0		@@ init r3 to null pointer
	str r1, [r0]		@@ set next pointer to be null in last node
	ldr r4, =tail		@@ make tail point to last node
	str r0, [r4]		@@ set tails base address to store the address of the node
	ldr r4, [r3, #4]	@@ DEBUG	<--- this is where bug happens
	str r0, [r3, #0]	@@ store next pointer
	bl printlist
	b readcmd
printlist:	@ prints linked list
	ldr r0, =head
	ldr r0, [r0]		@@ dereference node
printlistloop:
	cmp r0, #0
	mov r3, r0		@@ set r3 to currNode
	beq printlistendloop
	ldr r1, [r0, #4]	@@ copy int of node into r1
	ldr r0, =CmdFileHandle
	ldr r0, [r0]
	swi 0x6b		@@ display integer read in
	mov r0, r1
	ldr r0, =CmdFileHandle
	ldr r0, [r0]
	ldr r1, =commaSeparator
	swi 0x69		@@ display comma onto console
	ldr r0, [r3, #0]
	b printlistloop
printlistendloop:
	mov pc, lr

halt:
	swi 0x11

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
.align 4
commaSeparator: .asciz ", "
.align 4
OutputFileName: .asciz "output.txt"
.align 4
OutputFileHandler: .word 0
.align 4
findingAnnouncer: .asciz "Searching for "
.align 4
foundNumber: .asciz "Found it! "
.align 4
notFoundNumber: .asciz "Did not find "
