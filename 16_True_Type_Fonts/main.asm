; ML64 template file
; Compile: uasm64.exe -nologo -win64 -Zd -Zi -c testUasm.asm
; Link: link /nologo /debug /subsystem:console /entry:main testUasm.obj user32.lib kernel32.lib 
OPTION WIN64:8


; Include libraries
includelib SDL2.lib
includelib SDL2main.lib
includelib SDL2_image.lib
includelib SDL2_ttf.lib

; Include files
include main.inc
include SDL.inc
include SDL_image.inc
include SDL_ttf.inc
; include Code files
include LTexture.asm

Init 		proto 
Shutdown 	proto
LoadMedia	proto
LoadTexture proto	:QWORD

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

; Values to rotate the sprite
WINDOW_TITLE 	BYTE "SDL Tutorial",0
FILE_ATTRS 		BYTE "rb"
FONT_FILE 		BYTE "Res/lazy.ttf",0
LAZY_TEXT		BYTE "The quick brown fox jumps over the lazy dog",0

.data
quit			BYTE 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?	
gFont				QWORD ?
gTextTexture		LTexture <>

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
			.elseif eventHandler.type_==SDL_KEYDOWN
				nop
			.endif	
			
			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		mov rsi, offset gTextTexture
		mov eax, SCREEN_WIDTH
		mov ebx, SCREEN_HEIGHT
		sub eax, (LTexture PTR[rsi]).m_Width
		sub ebx, (LTexture PTR[rsi]).m_Height
		shr eax, 1
		shr ebx, 1
		invoke renderTexture, gRenderer, addr gTextTexture, eax, ebx, 0, 0, 0, SDL_FLIP_NONE
		
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
	finit ; Starts the FPU
	
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
	invoke SDL_CreateRenderer, rax, -1, SDL_RENDERER_ACCELERATED OR SDL_RENDERER_PRESENTVSYNC
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
	
    invoke TTF_Init
    .if rax==-1
    	xor rax, rax
    	jmp EXIT
    .endif
    
	mov rax, 1
EXIT:	
	ret
Init endp

Shutdown proc
	
	invoke freeTexture, addr gTextTexture
	
	invoke TTF_CloseFont, gFont
	mov gFont, 0
	
	invoke SDL_DestroyRenderer, gRenderer 
	invoke SDL_DestroyWindow, pWindow
	
	invoke TTF_Quit
	invoke IMG_Quit
	invoke SDL_Quit
	ret
Shutdown endp


LoadMedia PROC
	LOCAL success:BYTE
	mov success, 1
	
	invoke TTF_OpenFont, addr FONT_FILE, 28
	.if rax==0
		jmp EXIT
	.endif 
	mov gFont, rax
	
	invoke loadTextureFromRenderedText, gRenderer, addr gTextTexture, gFont, addr LAZY_TEXT, 0
	
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
