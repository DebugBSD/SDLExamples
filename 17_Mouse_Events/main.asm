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
include LButton.asm

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
IMAGE_BUTTON	BYTE "Res/button.png",0

.data
quit			BYTE 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?	
gFont				QWORD ?
gSpriteClips 		SDL_Rect BUTTON_SPRITE_TOTAL DUP(<>)
gButtonSpriteSheetTexture LTexture <>
gButtons			LButton TOTAL_BUTTONS DUP(<>)

.code

main proc 
	local i:dword
	local poll:qword
	
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
			
			.if eventHandler.type_ == SDL_MOUSEBUTTONDOWN
				nop
			.endif
			
			mov i, 0
			mov rsi, offset gButtons
			mov rax, SIZEOF LButton
			.while i < TOTAL_BUTTONS
	
				invoke LButton_handleEvent, rsi, addr eventHandler
				add rsi, rax				; Increment the pointer to the next element
				inc i
				
			.endw
			
			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render Buttons
		mov i, 0
		mov rsi, offset gButtons
		mov rax, SIZEOF LButton
		.while i < TOTAL_BUTTONS

			invoke LButton_render, rsi
			add rsi, rax				; Increment the pointer to the next element
			inc i
			
		.endw
		
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
	
	invoke freeTexture, addr gButtonSpriteSheetTexture
	
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
	
	invoke loadTextureFromFile, gRenderer, addr gButtonSpriteSheetTexture, addr IMAGE_BUTTON
	.if eax==0
		jmp EXIT
	.endif
	
	xor rcx, rcx
	mov rbx, SIZEOF SDL_Rect	; 16 bytes
	mov rsi, offset gSpriteClips
	.while rcx < BUTTON_SPRITE_TOTAL
		
		mov rax, 200
		mul rcx
		
		mov (SDL_Rect PTR[rsi]).x,0
		mov (SDL_Rect PTR[rsi]).y,eax
		mov (SDL_Rect PTR[rsi]).w,BUTTON_WIDTH
		mov (SDL_Rect PTR[rsi]).h,BUTTON_HEIGHT
		
		add rsi, rbx ; Increment the pointer to the next element
		inc rcx
		
	.endw
			
	mov rsi, offset gButtons
	invoke LButton_setPosition, rsi, 0, 0
	
	add rsi, SIZEOF LButton
	invoke LButton_setPosition, rsi, SCREEN_WIDTH - BUTTON_WIDTH, 0
	
	add rsi, SIZEOF LButton
	invoke LButton_setPosition, rsi, 0, SCREEN_HEIGHT - BUTTON_HEIGHT
	
	add rsi, SIZEOF LButton
	invoke LButton_setPosition, rsi, SCREEN_WIDTH - BUTTON_WIDTH, SCREEN_HEIGHT - BUTTON_HEIGHT
	
	
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
