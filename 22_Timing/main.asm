; ML64 template file
; Compile: uasm64.exe -nologo -win64 -Zd -Zi -c testUasm.asm
; Link: link /nologo /debug /subsystem:console /entry:main testUasm.obj user32.lib kernel32.lib 
OPTION WIN64:8

; Include libraries
includelib SDL2.lib
includelib SDL2main.lib
includelib SDL2_image.lib
includelib SDL2_ttf.lib
includelib SDL2_mixer.lib

externdef _itoa:proc
itoa TEXTEQU <_itoa>

; Include files
include main.inc
include SDL.inc
include SDL_image.inc
include SDL_ttf.inc
include SDL_mixer.inc
; include Code files
include LTexture.asm
include LButton.asm

Init 			proto 
Shutdown 		proto
LoadMedia		proto
LoadTexture 	proto	:QWORD
StringCopy 		proto 	:PTR BYTE, :PTR BYTE
StringConcat 	proto 	:PTR BYTE, :PTR BYTE

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

; Values to rotate the sprite
WINDOW_TITLE 		BYTE "SDL Tutorial",0
FILE_ATTRS 			BYTE "rb"
LAZY_FONT			BYTE "Res/lazy.ttf",0
strRestartTimeMsg	BYTE "Press Enter to Reset Start Time.",0
gTimeText			BYTE "Milliseconds since start time ",0 

.data
quit				BYTE 0
textColor			SDL_Color <0,0,0,255>
startTime 			Uint32 0
.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
currentTexture 		QWORD ?	
gPromptTextTexture	LTexture <>
gTimeTextTexture	LTexture <>
gFont				QWORD ? 

gBuffer				BYTE 1024 DUP(?)
gCurrentTime		BYTE 1024 DUP(?)

.code

main proc 
	local i:dword
	local poll:qword
	
	; Convert from Integer to Character string
	;mov r8, 10
	;mov rdx, offset gCurrentTime
	;mov rcx, 500
	;call itoa 
		
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
			.elseif eventHandler.type_ == SDL_KEYDOWN && eventHandler.key.keysym.sym == SDLK_RETURN
				invoke SDL_GetTicks
				mov startTime, eax
				nop
			.endif

			invoke SDL_PollEvent, addr eventHandler
		.endw
				
		; Get current time
		invoke SDL_GetTicks
		sub eax, startTime
		mov r8, 10
		mov rdx, offset gCurrentTime
		mov rcx, rax
		call itoa 
		
		; Copy string to the buffer
		invoke StringCopy, addr gBuffer, addr gTimeText
		
		; Concatenate the time
		invoke StringConcat, addr gBuffer, addr gCurrentTime
			
		invoke loadTextureFromRenderedText, gRenderer, addr gTimeTextTexture, gFont, addr gBuffer, textColor
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render texture
		invoke renderTexture, gRenderer, addr gPromptTextTexture, 0, 0, 0, 0, 0, 0
		
		mov rax, SCREEN_WIDTH
		sub eax, gPromptTextTexture.m_Width
		shr rax, 1
		invoke renderTexture, gRenderer, addr gPromptTextTexture, eax, 0, 0, 0, 0, 0
		
		mov rax, SCREEN_WIDTH
		sub eax, gPromptTextTexture.m_Width
		shr rax, 1
		mov rbx, SCREEN_HEIGHT
		sub ebx, gPromptTextTexture.m_Height
		shr rbx, 1
		invoke renderTexture, gRenderer, addr gTimeTextTexture, eax, ebx, 0, 0, 0, 0
		
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
	
	invoke SDL_Init, SDL_INIT_VIDEO OR SDL_INIT_AUDIO 
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
	
	; Init PNG image format
	invoke IMG_Init, IMG_INIT_PNG
	and rax, IMG_INIT_PNG
	.if rax!=IMG_INIT_PNG
		xor rax, rax
		jmp EXIT
	.endif
	
	; Init Font module
    invoke TTF_Init
    .if rax==-1
    	xor rax, rax
    	jmp EXIT
    .endif
    
    ; Init Mixer module
    invoke Mix_OpenAudio, 44100, MIX_DEFAULT_FORMAT, 2, 2048
    .if rax<0
		xor rax, rax
		jmp EXIT
	.endif
    
	mov rax, 1
EXIT:	
	ret
Init endp

Shutdown proc
	
	invoke freeTexture, addr gPromptTextTexture
	
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
	
	invoke TTF_OpenFont, addr LAZY_FONT, 28
	.if rax==0
		jmp EXIT
	.endif
	mov gFont, rax
	
	invoke loadTextureFromRenderedText, gRenderer, addr gPromptTextTexture, gFont, addr strRestartTimeMsg, textColor
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
	
	
StringCopy 	proc uses rsi rdi, pDst:PTR BYTE, pSrc:PTR BYTE
	
	cld
	mov rsi, pSrc
	mov rdi, pDst
	.while BYTE PTR [rsi] != 0
		movsb
	.endw 
	
	mov BYTE PTR [rdi], 0 ; Mark end of string
	
	ret
StringCopy 	endp	
	
StringConcat proc uses rsi rdi, pDst:PTR BYTE, pSrc:PTR BYTE
	
	cld
	mov rsi, pSrc
	mov rdi, pDst
	.while BYTE PTR [rdi] != 0
		inc rdi
	.endw 
	
	.while BYTE PTR [rsi] != 0
		movsb
	.endw 
	
	mov BYTE PTR [rdi], 0 ; Mark end of string
	
	ret
StringConcat endp	
END

; vim options: ts=2 sw=2
