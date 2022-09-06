@Various macros to perform file I/O 

@ The fd parameter needs to be a register. 
@ Uses R0, R1, R7. 
@ Return code is in R0. 

.equ O_RDONLY, 0 
.equ O_WRONLY, 1 
.equ O_CREAT, 0100 
.equ S_RDWR, 0666 
.equ sys_open, 5
.equ sys_close, 6
.equ sys_read, 3
.equ sys_write, 4
.equ sys_fsync, 118

.macro openFile fileName, flags
	ldr r0, =\fileName 
	mov r1, #\flags 
	mov r2, #S_RDWR 
	@ RW access rights 
	mov r7, #sys_open 
	svc 0 
.endm 

.macro readFile fd, buffer, length 
	mov r0, \fd @ file descriptor 
	ldr r1, =\buffer 
	mov r2, #\length 
	mov r7, #sys_read 
	svc 0 
.endm 

.macro writeFile fd, buffer, length 
	mov r0, \fd @ file descriptor 
	ldr r1, =\buffer 
	mov r2, \length 
	mov r7, #sys_write 
	svc 0 
.endm 

.macro flushClose fd 
@fsync syscall 
	mov r0, \fd 
	mov r7, #sys_fsync 
	svc 0
	@close syscall 
	mov r0, \fd 
	mov r7, #sys_close 
	svc 0 
.endm