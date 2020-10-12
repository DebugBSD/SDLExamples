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
LoadTexture proto	:QWORD

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480


WINDOW_TITLE BYTE "SDL Tutorial",0
FILE_ATTRS BYTE "rb"

IMAGE_PRESS 	BYTE "Res/viewport.png",0

.data
quit			BYTE 0
fillRect 		SDL_Rect<160,120,320,240> 
outlineRect 	SDL_Rect<106,80,426,320> 

topLeftViewport 	SDL_Rect <0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT  / 2>
topRightViewport 	SDL_Rect <SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT  / 2>
bottomViewport 		SDL_Rect <0, SCREEN_HEIGHT  / 2, SCREEN_WIDTH, SCREEN_HEIGHT  / 2>

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gTexture			QWORD ?
gRenderer			QWORD ?	

.code

main proc 
	local i:dword
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	; Gameloop
	.while quit!=1
		
		invoke SDL_PollEvent, addr eventHandler
		.while rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.endif	
			
			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Top left corner viewport
		invoke SDL_RenderSetViewport, gRenderer, addr topLeftViewport;
		
		; Render texture to screen
		invoke SDL_RenderCopy,gRenderer, gTexture, 0, 0
		
		; Top right corner viewport
		invoke SDL_RenderSetViewport, gRenderer, addr topRightViewport;
		
		; Render texture to screen
		invoke SDL_RenderCopy,gRenderer, gTexture, 0, 0
		
		; Bottom corner viewport
		invoke SDL_RenderSetViewport, gRenderer, addr bottomViewport;
		
		; Render texture to screen
		invoke SDL_RenderCopy,gRenderer, gTexture, 0, 0
		
		; Update the window
		invoke SDL_RenderPresent,gRenderer
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
	
	; Create the renderer
	invoke SDL_CreateRenderer, rax, -1, SDL_RENDERER_ACCELERATED
	.if rax==0
		jmp EXIT
	.endif
	mov gRenderer, rax
	
	; Initialize renderer color
	invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFH, 0FFH, 0FFH
	
	invoke IMG_Init, IMG_INIT_PNG
	and rax, IMG_INIT_PNG
	.if rax!=IMG_INIT_PNG
		xor rax, rax
		jmp EXIT
	.endif
	
	mov rax, 1
EXIT:	
	ret
Init endp

Shutdown proc
	
	invoke SDL_DestroyTexture, gTexture
	
	invoke SDL_DestroyRenderer, gRenderer 
	invoke SDL_DestroyWindow, pWindow
	
	invoke IMG_Quit
	invoke SDL_Quit
	ret
Shutdown endp


LoadMedia PROC
	LOCAL success:BYTE
	mov success, 1
		
	invoke LoadTexture, addr IMAGE_PRESS
	.if rax==0
		mov success, 0
		jmp EXIT
	.endif	
	mov gTexture, rax
EXIT:
	ret
LoadMedia endp

LoadTexture PROC pFile:QWORD
	LOCAL loadedSurface:QWORD
	LOCAL newTexture:QWORD
	
	invoke IMG_Load, pFile
	.if rax==0
		jmp ERROR
	.endif
	mov loadedSurface, rax
	invoke SDL_CreateTextureFromSurface, gRenderer, rax
	.if rax==0
		jmp ERROR
	.endif
	mov newTexture, rax
	invoke SDL_FreeSurface, loadedSurface
	mov rax, newTexture
ERROR:	
	ret
LoadTexture endp
	
END

; vim options: ts=2 sw=2
