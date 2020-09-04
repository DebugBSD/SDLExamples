; Windows
externdef ExitProcess:PROTO

; SDL
include SDL.inc

.CONST 
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

WINDOW_TITLE BYTE "SDL Tutorial",0

.DATA 

.DATA?

pWindow QWORD ?
pScreenSurface QWORD ?

.CODE

main PROC
	sub rsp, 8 ; Align stack
	sub rsp, 20h ; Create shadow space
	
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
	je SDLERROR
	mov pWindow, rax ; Save the handle
	
	
	; Get Window surface
	mov rcx, rax
	call SDL_GetWindowSurface
	mov pScreenSurface, rax
	
	; Call to SDL_MapRGB
	mov r9, 0ffh
	mov r8, 0ffh
	mov rdx, 0ffh
	mov rcx, (SDL_Surface PTR[rax]).format		; Cast to SDL structure
	call SDL_MapRGB
	
	; Fill the surface with white color
	mov r8, rax ; Result of SDL_MapRGB
	mov rdx, 0
	mov rcx, pScreenSurface
	call SDL_FillRect
	
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
	call SDL_Quit
	
	
EXIT:	
	mov rax, 0
	call ExitProcess
main endp

END