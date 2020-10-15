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
IMAGE_PRESS		BYTE "Res/press.png",0
IMAGE_UP		BYTE "Res/up.png",0
IMAGE_DOWN		BYTE "Res/down.png",0
IMAGE_LEFT		BYTE "Res/left.png",0
IMAGE_RIGHT		BYTE "Res/right.png",0

.data
quit			BYTE 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
currentTexture 		QWORD ?	
gPressTexture		LTexture <>
gUpTexture			LTexture <>
gDownTexture		LTexture <>
gRightTexture		LTexture <>
gLeftTexture		LTexture <>

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

			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Set texture based on current keystate
        invoke SDL_GetKeyboardState,0
        .if BYTE PTR [rax + SDL_SCANCODE_UP] 
        	
            mov rax, offset gUpTexture
            mov currentTexture, rax
        
        .elseif BYTE PTR [rax+ SDL_SCANCODE_DOWN]
        
            mov rax, offset gDownTexture
            mov currentTexture, rax
        
        .elseif BYTE PTR [rax + SDL_SCANCODE_LEFT]
            
            mov rax, offset gLeftTexture
            mov currentTexture, rax
        
        .elseif BYTE PTR [rax + SDL_SCANCODE_RIGHT]
        
            mov rax, offset gRightTexture
            mov currentTexture, rax
        
        .else
            
            mov rax, offset gPressTexture
            mov currentTexture, rax
        
        .endif
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render texture
		invoke renderTexture, gRenderer, currentTexture, 0, 0, 0, 0, 0, 0
		
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
	
	invoke freeTexture, addr gLeftTexture
	invoke freeTexture, addr gRightTexture
	invoke freeTexture, addr gDownTexture
	invoke freeTexture, addr gUpTexture
	invoke freeTexture, addr gPressTexture
	
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
	
	invoke loadTextureFromFile, gRenderer, addr gPressTexture, addr IMAGE_PRESS
	.if eax==0
		jmp EXIT
	.endif
	
	invoke loadTextureFromFile, gRenderer, addr gUpTexture, addr IMAGE_UP
	.if eax==0
		jmp EXIT
	.endif
	
	invoke loadTextureFromFile, gRenderer, addr gDownTexture, addr IMAGE_DOWN
	.if eax==0
		jmp EXIT
	.endif
	
	invoke loadTextureFromFile, gRenderer, addr gLeftTexture, addr IMAGE_LEFT
	.if eax==0
		jmp EXIT
	.endif
	
	invoke loadTextureFromFile, gRenderer, addr gRightTexture, addr IMAGE_RIGHT
	.if eax==0
		jmp EXIT
	.endif
	
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
