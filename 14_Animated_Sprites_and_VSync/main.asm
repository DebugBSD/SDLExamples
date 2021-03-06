; ML64 template file
; Compile: uasm64.exe -nologo -win64 -Zd -Zi -c testUasm.asm
; Link: link /nologo /debug /subsystem:console /entry:main testUasm.obj user32.lib kernel32.lib 
OPTION WIN64:8


; Include libraries
includelib SDL2.lib
includelib SDL2main.lib
includelib SDL2_image.lib

; Include files
include main.inc
include SDL.inc
include SDL_image.inc
; include Code files
include LTexture.asm

Init 		proto 
Shutdown 	proto
LoadMedia	proto
LoadTexture proto	:QWORD

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480


WINDOW_TITLE BYTE "SDL Tutorial",0
FILE_ATTRS BYTE "rb"

WALKING_ANIMATION_FRAMES = 4
IMAGE_SPRITE_SHEET 	BYTE "Res/foo.png",0

.data
quit			BYTE 0
dwCurrentFrame 	DWORD 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?	

gSpriteClips		SDL_Rect WALKING_ANIMATION_FRAMES DUP(<>)
gSpriteSheetTexture	LTexture <>

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
				.if eventHandler.key.keysym.sym==SDLK_w
					;mov al, dwAlphaValue
					;add dwAlphaValue,32
					;.if dwAlphaValue>255
					;	mov dwAlphaValue,255
					;.endif
				.elseif eventHandler.key.keysym.sym==SDLK_s
					;mov al,dwAlphaValue	
					;sub dwAlphaValue,32
					;.if dwAlphaValue<0
					;	mov dwAlphaValue,0
					;.endif
				.endif
			.endif	
			
			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render current frame
		mov rsi, offset gSpriteClips
		mov eax, SIZEOF SDL_Rect
		mov rdx, 0
		mul dwCurrentFrame
		add rsi, rax
		
		mov eax, SCREEN_WIDTH
		mov ebx, SCREEN_HEIGHT
		sub eax, (SDL_Rect PTR[rsi]).w
		sub ebx, (SDL_Rect PTR[rsi]).h
		shr eax, 1
		shr ebx, 1
		invoke renderTexture, gRenderer, addr gSpriteSheetTexture, eax, ebx, rsi 
		
		; Go to next frame
		inc dwCurrentFrame
		
		; Cycle animation
		.if dwCurrentFrame==WALKING_ANIMATION_FRAMES
			mov dwCurrentFrame, 0
		.endif 
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
	
	mov rax, 1
EXIT:	
	ret
Init endp

Shutdown proc
	
	invoke freeTexture, addr gSpriteSheetTexture
	
	invoke SDL_DestroyRenderer, gRenderer 
	invoke SDL_DestroyWindow, pWindow
	
	invoke IMG_Quit
	invoke SDL_Quit
	ret
Shutdown endp


LoadMedia PROC
	LOCAL success:BYTE
	mov success, 1
	
	invoke loadTextureFromFile, gRenderer, addr gSpriteSheetTexture, addr IMAGE_SPRITE_SHEET
	.if rax==0
		mov success, 0
		jmp EXIT
	.endif	
	
	; Set top left sprite
	mov gSpriteClips[0].x, 0
	mov gSpriteClips[0].y, 0
	mov gSpriteClips[0].w, 64
	mov gSpriteClips[0].h, 205
	; Set top right sprite
	mov gSpriteClips[1*sizeof SDL_Rect].x, 64
	mov gSpriteClips[1*sizeof SDL_Rect].y, 0
	mov gSpriteClips[1*sizeof SDL_Rect].w, 64
	mov gSpriteClips[1*sizeof SDL_Rect].h, 205
	; Set bottom left sprite
	mov gSpriteClips[2*sizeof SDL_Rect].x, 128
	mov gSpriteClips[2*sizeof SDL_Rect].y, 0
	mov gSpriteClips[2*sizeof SDL_Rect].w, 64
	mov gSpriteClips[2*sizeof SDL_Rect].h, 205
	; Set bottom right sprite
	mov gSpriteClips[3*sizeof SDL_Rect].x, 196
	mov gSpriteClips[3*sizeof SDL_Rect].y, 0
	mov gSpriteClips[3*sizeof SDL_Rect].w, 64
	mov gSpriteClips[3*sizeof SDL_Rect].h, 205
	
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
