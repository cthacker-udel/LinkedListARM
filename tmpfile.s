main:

	@@@@@@@@@@ READ INT FROM FILE

	ldr r0, =InFileName		@ set r0 = name of file
	mov r1, #0			@ set r1 = type of mode (0 = input)
	swi 0x66 			@ swi command for opening a file, assigns r0 to the file handle
	ldr r1, =InFileHandle
	str r0, [r1]

	@@ stored file handle in input file

	ldr r0, =CmdFileName			@ initialize r1 to file name
	swi 0x02
	mov r1, #0				@ initialize handler for input
	swi 0x66				@ set r0 = file handler
	ldr r1, =CmdFileHandle			@ set r1 = pointer to file handler
	str r0, [r1]				@ store file handler in pointer to cmdfilehandler

	


.data
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
