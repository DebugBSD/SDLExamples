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

; Include files
include main.inc
include SDL.inc
include SDL_image.inc
include SDL_ttf.inc
include SDL_mixer.inc
; include Code files
include LTexture.asm
include LButton.asm
include LTimer.asm
include Dot.asm

Init 			proto 
Shutdown 		proto
LoadMedia		proto
LoadTexture 	proto	:QWORD
StringCopy 		proto 	:PTR BYTE, :PTR BYTE
StringConcat 	proto 	:PTR BYTE, :PTR BYTE
UpdateCamera 	proto 	:PTR SDL_Rect, :DWORD, :DWORD, :DWORD, :DWORD 
StringLength 	proto 	:PTR BYTE

.const

; The dimensions of the level
LEVEL_WIDTH = 1280
LEVEL_HEIGHT = 960

; Screen dimensions
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

; Values to rotate the sprite
WINDOW_TITLE 		BYTE "SDL Tutorial",0
FILE_ATTRS 			BYTE "rb"
LAZY_FONT			BYTE "Res/lazy.ttf",0
textColor			SDL_Color <0, 0, 0, 0FFh>
ENTER_TEXT			BYTE "Enter Text:", 0
SOME_TEXT			BYTE "Some Text", 0

.data
quit				BYTE 0
renderText			BYTE 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
gFont				QWORD ?
gPromptTextTexture	LTexture <>
gInputTextTexture	LTexture <>
gInputText			BYTE 1024 DUP(?)
.code

main proc 
	
	finit
		
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	
	invoke StringCopy, addr gInputText, addr SOME_TEXT
	
	invoke loadTextureFromRenderedText, gRenderer, addr gInputTextTexture, gFont, addr gInputText, textColor
	
	; Enable text input
	invoke SDL_StartTextInput
	
	; Gameloop
	.while quit!=1
		; The render text flag
		mov renderText, 0
		
		; Process input
		invoke SDL_PollEvent, addr eventHandler
		.while rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.elseif eventHandler.type_ == SDL_KEYDOWN ; Special key input
				invoke StringLength, addr gInputText
				.if eventHandler.key.keysym.sym == SDLK_BACKSPACE && rax > 0 ; Handle backspace
					mov rsi, offset gInputText
					add rsi, rax
					dec rsi
					mov BYTE PTR[rsi],0
					mov renderText, 1	
				.endif
				
				invoke SDL_GetModState
				and rax, KMOD_CTRL
				.if eventHandler.key.keysym.sym == SDLK_c && rax ; Handle copy
					invoke SDL_SetClipboardText, addr gInputText
				.endif
				
				invoke SDL_GetModState
				and rax, KMOD_CTRL
				.if eventHandler.key.keysym.sym == SDLK_v && rax ; Handle paste
					invoke SDL_GetClipboardText
					invoke StringCopy, addr gInputText, rax
					mov renderText, 1
				.endif
				
			.elseif eventHandler.type_ == SDL_TEXTINPUT
				invoke SDL_GetModState
				and rax, KMOD_CTRL
				mov bl, eventHandler.text.text[0]
				.if bl=='c' || bl=='C' || bl == 'v' || bl == 'V'
					mov rcx, KMOD_CTRL
				.endif
				
				.if rax != KMOD_CTRL && rcx != KMOD_CTRL
					mov renderText, 1
					invoke StringConcat,addr gInputText, addr eventHandler.text.text
	
				.endif
				
			.endif

			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		.if renderText
			invoke StringLength, addr gInputText
			.if rax>0
				; Render the text				
				invoke loadTextureFromRenderedText, gRenderer, addr gInputTextTexture, gFont, addr gInputText, textColor
			.endif
			
		.endif
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render Background
		mov eax, SCREEN_WIDTH
		sub eax, gPromptTextTexture.m_Width
		shr eax, 1
		invoke renderTexture, gRenderer, addr gPromptTextTexture, eax, 0, 0, 0, 0, 0
		mov eax, SCREEN_WIDTH
		sub eax, gInputTextTexture.m_Width
		shr eax, 1		
		invoke renderTexture, gRenderer, addr gInputTextTexture, eax, gPromptTextTexture.m_Height, 0, 0, 0, 0
				
		; Update the window
		invoke SDL_RenderPresent,gRenderer
	.endw
	
	; Disable Text input
	invoke SDL_StopTextInput
	
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
	invoke freeTexture, addr gInputTextTexture
	
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
	
	invoke loadTextureFromRenderedText, gRenderer, addr gPromptTextTexture, rax, addr ENTER_TEXT, textColor
	
	
EXIT:
	ret
LoadMedia endp

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

StringLength proc uses rsi, pSrc:PTR BYTE
	
	xor rax, rax
	mov rsi, pSrc
	.while BYTE PTR [rsi] != 0
		inc rsi
		inc rax
	.endw 
	
	ret
StringLength 	endp	


END

; vim options: ts=2 sw=2
