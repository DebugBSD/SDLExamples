; Windows
externdef ExitProcess:PROTO

; SDL
include SDL.inc

; Prototypes of my Program
Init PROTO
LoadMedia PROTO
Close PROTO

.CONST 
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

WINDOW_TITLE BYTE "SDL Tutorial",0
FILE_ATTRS BYTE "rb"

.DATA 

fileName BYTE "Res/hello_world.bmp"

.DATA?

pWindow 			QWORD ?
pScreenSurface 		QWORD ?
pHelloWorld 		QWORD ?
.CODE

main PROC
	sub rsp, 56 ; Reserve memory for shadow space 
	
	; Init SDL and other stuff
	call Init
	cmp rax, 0
	je SDLERROR
	
	; Load data
	call LoadMedia
	cmp rax, 0
	je SDLERROR
	
	; Apply the image
	mov r9, 0
	mov r8, pScreenSurface
	mov rdx, 0
	mov rcx, pHelloWorld
	call SDL_BlitSurface
	
	; Update the surface
	mov rcx, pWindow
	call SDL_UpdateWindowSurface
	
	; Wait to seconds
	mov rcx, 2000			; 2 seconds
	call SDL_Delay
	
	; Destroy the window
	mov rcx, pWindow
	call SDL_DestroyWindow
	
SDLERROR:	
	; Quit the subsystem
	call Close
	
	
EXIT:	
	mov rax, 0
	call ExitProcess
main endp

Init PROC	
	sub rsp, 56
	
	mov rcx, SDL_INIT_VIDEO
	call SDL_Init
	cmp rax, 0
	jb EXIT
	
	; We create the Window
	mov	DWORD PTR [rsp+40], SDL_WINDOW_SHOWN	; 6xt argument - (4)
	mov	DWORD PTR [rsp+32], SCREEN_HEIGHT		; 5th argument - (480) 000001e0H
	mov	r9, SCREEN_WIDTH						; 4th argument - (640) 00000280H
	mov	r8, SDL_WINDOWPOS_UNDEFINED				; 3rd argument - 1fff0000H
	mov	rdx, r8									; 2nd argument - 1fff0000H
	lea	rcx, OFFSET WINDOW_TITLE				; 1st argument - Window title
	call SDL_CreateWindow
	cmp rax, 0
	je ERROR
	mov pWindow, rax ; Save the handle
	
	; Get Window surface
	mov rcx, rax
	call SDL_GetWindowSurface
	mov pScreenSurface, rax
	jmp EXIT
	
ERROR:
	mov rax, 0

EXIT:
	add rsp, 56
	ret
Init endp

Close PROC
	sub rsp, 56
	
	mov rcx, pHelloWorld
	call SDL_FreeSurface
	
	mov rcx, pWindow
	call SDL_DestroyWindow
	
	call SDL_Quit
	
	add rsp, 56
	ret
Close endp

LoadMedia PROC
	sub rsp, 56
	
	mov rcx, OFFSET fileName
	mov rdx, OFFSET FILE_ATTRS
	call SDL_RWFromFile
	
	mov rcx, rax
	mov rdx, 1
	call SDL_LoadBMP_RW
	cmp rax, 0
	je ERROR
	mov pHelloWorld, rax
	
ERROR:
	add rsp, 56
	ret
LoadMedia endp

END