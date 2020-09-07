; Windows
externdef ExitProcess:PROTO

; SDL
include inc/SDL.inc

; Prototypes of my Program
Init 		PROTO
LoadMedia 	PROTO
Close 		PROTO
LoadSurface	PROTO

.CONST 
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

WINDOW_TITLE BYTE "SDL Tutorial",0
FILE_ATTRS BYTE "rb"


IMAGE_PRESS 	BYTE "Res/stretch.bmp",0

.DATA 

quit		BYTE 0
stretchedRect SDL_Rect<> 


.DATA?

pWindow 			QWORD ?
pScreenSurface 		QWORD ?
eventHandler		SDL_Event <>
gStretchedSurface 	QWORD ?

.CODE

main PROC
	sub rsp, 40 ; Reserve memory for shadow space 
	
	; Init SDL and other stuff
	call Init
	cmp rax, 0
	je SDLERROR
	
	; Load data
	call LoadMedia
	cmp rax, 0
	je SDLERROR
	
L1:	
	cmp quit, 1
	je EXIT_LOOP
	
L2:
	mov rcx, offset eventHandler
	call SDL_PollEvent
	cmp rax, 0
	je L1
	cmp eventHandler.type_, SDL_QUIT
	jne L3
	mov quit, 1
	jmp L4
L3:
	mov stretchedRect.x,0
	mov stretchedRect.y, 0
	mov stretchedRect.w, SCREEN_WIDTH
	mov stretchedRect.h, SCREEN_HEIGHT	
	
	; Apply the image
	mov r9, OFFSET stretchedRect
	mov r8, pScreenSurface
	mov rdx, 0
	mov rcx, gStretchedSurface
	call SDL_BlitScaled
	
	; Update the surface
	mov rcx, pWindow
	call SDL_UpdateWindowSurface
	
L4:
	jmp L1
	
EXIT_LOOP:	
	; Destroy the window
	mov rcx, pWindow
	call SDL_DestroyWindow
	

SDLERROR:	
	; Quit the subsystem
	call Close
	
	
EXIT:	
	mov rax, 0
	add rsp, 40
	call ExitProcess
main endp

arg4 EQU<DWORD PTR[rsp+32]>
arg5 EQU<DWORD PTR[rsp+40]>
Init PROC
	sub rsp, 8
	sub rsp, 32
	sub rsp, 8 ; reserve space for argument 4
	sub rsp, 8 ; reserve space for argument 5 
	
	mov rcx, SDL_INIT_VIDEO
	call SDL_Init
	cmp rax, 0
	jb EXIT
	
	; We create the Window
	mov	arg5, SDL_WINDOW_SHOWN					; 6xt argument - (4)
	mov	arg4, SCREEN_HEIGHT						; 5th argument - (480) 000001e0H
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
	add rsp, 56 ; We clean all stack
	ret
Init endp

Close PROC
	sub rsp, 40
	
	mov rcx, gStretchedSurface
	call SDL_FreeSurface	
	
	mov rcx, pWindow
	call SDL_DestroyWindow
	
	call SDL_Quit
	
	add rsp, 40
	ret
Close endp

LoadMedia PROC
	sub rsp, 40
	
	mov rcx, OFFSET IMAGE_PRESS
	call LoadSurface
	cmp rax, 0
	je ERROR
	mov gStretchedSurface, rax
ERROR:
	add rsp, 40
	ret
LoadMedia endp

LoadSurface PROC
	sub rsp, 40
	mov rdx, OFFSET FILE_ATTRS
	call SDL_RWFromFile
	
	mov rcx, rax
	mov rdx, 1
	call SDL_LoadBMP_RW
	cmp rax, 0
	je ERROR
	
	mov r10, rax
	mov rbx, pScreenSurface
	mov r8, 0
	mov rdx, (SDL_Surface PTR [rbx]).format 
	mov rcx, rax
	call SDL_ConvertSurface
	cmp rax, 0
	je ERROR
	
	mov rcx, r10
	call SDL_FreeSurface
ERROR:	
	add rsp, 40
	ret
LoadSurface endp

END
