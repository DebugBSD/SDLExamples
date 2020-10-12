; ML64 template file
; Compile: uasm64.exe -nologo -win64 -Zd -Zi -c testUasm.asm
; Link: link /nologo /debug /subsystem:console /entry:main testUasm.obj user32.lib kernel32.lib 
OPTION WIN64:8

; Include files
include main.inc
include SDL.inc
include SDL_image.inc

; Include libraries
includelib SDL2.lib
includelib SDL2main.lib
includelib SDL2_image.lib

Init 		proto 
Shutdown 	proto
LoadMedia	proto
LoadSurface proto	:QWORD

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

WINDOW_TITLE BYTE "SDL Tutorial",0
FILE_ATTRS BYTE "rb"

IMAGE_PRESS 	BYTE "Res/stretch.bmp",0

.data
quit		BYTE 0
stretchedRect SDL_Rect<> 

.data?
pWindow 			QWORD ?
pScreenSurface 		QWORD ?
eventHandler		SDL_Event <>
gStretchedSurface 	QWORD ?

.code

main proc 
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	; Gameloop
	.while quit!=1
		invoke SDL_PollEvent, addr eventHandler
		.if rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.else
				mov stretchedRect.x,0
				mov stretchedRect.y, 0
				mov stretchedRect.w, SCREEN_WIDTH
				mov stretchedRect.h, SCREEN_HEIGHT
				
				; Apply image
				invoke SDL_BlitScaled, gStretchedSurface, 0, pScreenSurface, addr stretchedRect
				
				; Update
				invoke SDL_UpdateWindowSurface, pWindow
			.endif	
		.endif
		
	.endw
	
	invoke SDL_DestroyWindow, pWindow
	
	; Clean our allocated memory, shutdown SDL, ...
	invoke Shutdown
	invoke ExitProcess, EXIT_SUCCESS
	ret
main endp

Init proc
	invoke SDL_Init, SDL_INIT_VIDEO
	.if rax<0
		xor rax, rax
		jmp EXIT
	.endif

	invoke SDL_CreateWindow, 
		addr WINDOW_TITLE, 
		SDL_WINDOWPOS_UNDEFINED, 
		SDL_WINDOWPOS_UNDEFINED, 
		SCREEN_WIDTH, 
		SCREEN_HEIGHT, 
		SDL_WINDOW_SHOWN
		
	.if rax==0
		jmp EXIT
	.endif
	mov pWindow, rax
	
	invoke SDL_GetWindowSurface, rax
	mov pScreenSurface, rax
	
	mov rax, 1
EXIT:	
	ret
Init endp

Shutdown proc
	
	invoke SDL_FreeSurface, gStretchedSurface
	
	invoke SDL_DestroyWindow, pWindow
	
	invoke SDL_Quit
	ret
Shutdown endp


LoadMedia PROC
	
	invoke LoadSurface, addr IMAGE_PRESS
	.if rax==0
		jmp ERROR
	.endif
	mov gStretchedSurface, rax
ERROR:
	ret
LoadMedia endp

LoadSurface PROC pFile:QWORD
	
	;SDL_LoadBMP pFile ; This should be possible

	invoke SDL_RWFromFile, pFile, addr FILE_ATTRS	
	
	invoke SDL_LoadBMP_RW, rax, 1
	.if rax==0
		jmp ERROR
	.endif

	mov r10, rax
	mov rbx, pScreenSurface
	invoke SDL_ConvertSurface, rax, (SDL_Surface PTR [rbx]).format, 0
	.if rax==0
		jmp ERROR
	.endif
	
	invoke SDL_FreeSurface, r10	
ERROR:	
	ret
LoadSurface endp

END

; vim options: ts=2 sw=2
