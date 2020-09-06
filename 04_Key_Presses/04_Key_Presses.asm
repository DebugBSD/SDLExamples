; Windows
externdef ExitProcess:PROTO

; SDL
include inc/SDL.inc

; Prototypes of my Program
Init 		PROTO
LoadMedia 	PROTO
Close 		PROTO
LoadImage	PROTO

.CONST 
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

WINDOW_TITLE BYTE "SDL Tutorial",0
FILE_ATTRS BYTE "rb"

KEY_PRESS_SURFACE_DEFAULT 	= 0
KEY_PRESS_SURFACE_UP 		= 1
KEY_PRESS_SURFACE_DOWN 		= 2
KEY_PRESS_SURFACE_LEFT 		= 3
KEY_PRESS_SURFACE_RIGHT 	= 4
KEY_PRESS_SURFACE_TOTAL 	= 5

IMAGE_PRESS 	BYTE "Res/press.bmp",0
IMAGE_UP 		BYTE "Res/up.bmp",0
IMAGE_DOWN 		BYTE "Res/down.bmp",0
IMAGE_LEFT 		BYTE "Res/left.bmp",0
IMAGE_RIGHT 	BYTE "Res/right.bmp",0

.DATA 

quit		BYTE 0

gKeyPresses QWORD KEY_PRESS_SURFACE_TOTAL DUP(0)

.DATA?

pWindow 			QWORD ?
pScreenSurface 		QWORD ?
eventHandler		SDL_Event <>
pCurrentSurface 	QWORD ?

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
	jmp L2
L3:
	cmp eventHandler.type_, SDL_KEYDOWN
	jne DEFAULT
	
	cmp eventHandler.key.keysym.sym, SDLK_UP
	jne L4
	mov r9,gKeyPresses[KEY_PRESS_SURFACE_UP*8]
	mov pCurrentSurface, r9
	jmp SHOW_IMAGE
L4:
	cmp eventHandler.key.keysym.sym, SDLK_DOWN
	jne L5
	mov r9,gKeyPresses[KEY_PRESS_SURFACE_DOWN*8]
	mov pCurrentSurface, r9
	jmp SHOW_IMAGE
L5:
	cmp eventHandler.key.keysym.sym, SDLK_LEFT
	jne L6
	mov r9,gKeyPresses[KEY_PRESS_SURFACE_LEFT*8]
	mov pCurrentSurface, r9
	jmp SHOW_IMAGE
L6:
	cmp eventHandler.key.keysym.sym, SDLK_RIGHT
	jne DEFAULT
	mov r9,gKeyPresses[KEY_PRESS_SURFACE_RIGHT*8]
	mov pCurrentSurface, r9
	jmp SHOW_IMAGE
DEFAULT:
	mov r9,gKeyPresses[KEY_PRESS_SURFACE_DEFAULT*8]
	mov pCurrentSurface, r9
SHOW_IMAGE:
	; Apply the image
	mov r9, 0
	mov r8, pScreenSurface
	mov rdx, 0
	mov rcx, pCurrentSurface
	call SDL_BlitSurface
	
	; Update the surface
	mov rcx, pWindow
	call SDL_UpdateWindowSurface
	
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
	
	mov rcx, gKeyPresses[KEY_PRESS_SURFACE_DEFAULT]
	call SDL_FreeSurface
	
	mov rcx, gKeyPresses[KEY_PRESS_SURFACE_UP]
	call SDL_FreeSurface
	
	mov rcx, gKeyPresses[KEY_PRESS_SURFACE_DOWN]
	call SDL_FreeSurface
	
	mov rcx, gKeyPresses[KEY_PRESS_SURFACE_LEFT]
	call SDL_FreeSurface
	
	mov rcx, gKeyPresses[KEY_PRESS_SURFACE_RIGHT]
	call SDL_FreeSurface
	
	
	mov rcx, pWindow
	call SDL_DestroyWindow
	
	call SDL_Quit
	
	add rsp, 56
	ret
Close endp

LoadMedia PROC
	sub rsp, 56
	xor rbx, rbx
	
	mov rcx, OFFSET IMAGE_PRESS
	call LoadImage
	cmp rax, 0
	je ERROR
	mov gKeyPresses[KEY_PRESS_SURFACE_DEFAULT*8], rax

	mov rcx, OFFSET IMAGE_UP
	call LoadImage
	cmp rax, 0
	je ERROR
	mov gKeyPresses[KEY_PRESS_SURFACE_UP*8], rax
	
	mov rcx, OFFSET IMAGE_DOWN
	call LoadImage
	cmp rax, 0
	je ERROR
	mov gKeyPresses[KEY_PRESS_SURFACE_DOWN*8], rax
	
	mov rcx, OFFSET IMAGE_LEFT
	call LoadImage
	cmp rax, 0
	je ERROR
	mov gKeyPresses[KEY_PRESS_SURFACE_LEFT*8], rax
	
	mov rcx, OFFSET IMAGE_RIGHT
	call LoadImage
	cmp rax, 0
	je ERROR
	mov gKeyPresses[KEY_PRESS_SURFACE_RIGHT*8], rax

ERROR:
	add rsp, 56
	ret
LoadMedia endp

LoadImage PROC
	sub rsp, 56
	mov rdx, OFFSET FILE_ATTRS
	call SDL_RWFromFile
	
	mov rcx, rax
	mov rdx, 1
	call SDL_LoadBMP_RW
	add rsp, 56
	ret
LoadImage endp

END
