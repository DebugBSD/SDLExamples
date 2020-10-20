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

TOTAL_DATA = 10

; Values to rotate the sprite
WINDOW_TITLE 		BYTE "SDL Tutorial",0
READ_FILE_ATTRS		BYTE "r+b",0
WRITE_FILE_ATTRS	BYTE "w+b",0
ENTER_DATA_MESSAGE	BYTE "Enter Data:",0
LAZY_FONT			BYTE "Res/lazy.ttf",0
textColor			SDL_Color <0, 0, 0, 0FFh>
highlightColor 		SDL_Color <0FFh, 0, 0, 0FFh>
BINARY_FILE			BYTE "Res/nums.bin",0

.data
quit				BYTE 0
renderText			BYTE 0
gPromptTextTexture	LTexture<>
gDataTextures		LTexture TOTAL_DATA DUP(<0,0,0>)
; Current input point
dwCurrentData		DWORD 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
gFont				QWORD ?
gFile				QWORD ?
gData				Sint32 TOTAL_DATA DUP(?)
number				BYTE ?

.code

main proc 
	LOCAL temp:DWORD
	LOCAL coordX:DWORD
	LOCAL coordY:DWORD
	
	mov coordY,0
	
	finit
		
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	
	mov dwCurrentData, 0
	
	; Gameloop
	.while quit!=1
		
		; Process input
		invoke SDL_PollEvent, addr eventHandler
		.while rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.elseif eventHandler.type_ == SDL_KEYDOWN
				.if eventHandler.key.keysym.sym==SDLK_UP
					mov rsi, offset gDataTextures
					mov eax, dwCurrentData
					mov ebx, SIZEOF LTexture
					mul ebx
					add rsi, rax
					
					mov rdi, offset gData
					mov eax, dwCurrentData
					shl rax, 3
					add rdi, rax
					mov rax, [rdi]
					mov number, al
					add number, 30h				; Convert from decimal to ascii
					invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,textColor
					dec dwCurrentData
					cmp dwCurrentData,0
					jge @f
						mov dwCurrentData, TOTAL_DATA-1
					@@:
					
					; Render current entry input point
					mov rsi, offset gDataTextures
					mov eax, dwCurrentData
					mov ebx, SIZEOF LTexture
					mul ebx
					add rsi, rax
					
					mov rdi, offset gData
					mov eax, dwCurrentData
					shl rax, 3
					add rdi, rax
					mov rax, [rdi]
					mov number, al
					add number, 30h				; Convert from decimal to ascii
					invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,highlightColor
				.elseif eventHandler.key.keysym.sym==SDLK_DOWN
					mov rsi, offset gDataTextures
					mov eax, dwCurrentData
					mov ebx, SIZEOF LTexture
					mul ebx
					add rsi, rax
					
					mov rdi, offset gData
					mov eax, dwCurrentData
					shl rax, 3
					add rdi, rax
					mov rax, [rdi]
					mov number, al
					add number, 30h				; Convert from decimal to ascii
					invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,textColor
					inc dwCurrentData
					.if dwCurrentData == TOTAL_DATA
						mov dwCurrentData, 0
					.endif
					
					; Render current entry input point
					mov rsi, offset gDataTextures
					mov eax, dwCurrentData
					mov ebx, SIZEOF LTexture
					mul ebx
					add rsi, rax
					
					mov rdi, offset gData
					mov eax, dwCurrentData
					shl rax, 3
					add rdi, rax
					mov rax, [rdi]
					mov number, al
					add number, 30h				; Convert from decimal to ascii
					invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,highlightColor
				.elseif eventHandler.key.keysym.sym==SDLK_LEFT
					
					; Render current entry input point
					mov rsi, offset gDataTextures
					mov eax, dwCurrentData
					mov ebx, SIZEOF LTexture
					mul ebx
					add rsi, rax
					
					mov rdi, offset gData
					mov eax, dwCurrentData
					shl rax, 3
					add rdi, rax
					dec DWORD PTR [rdi]
					mov rax, [rdi]
					mov number, al
					add number, 30h				; Convert from decimal to ascii
					invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,highlightColor
				.elseif eventHandler.key.keysym.sym==SDLK_RIGHT
					; Render current entry input point
					mov rsi, offset gDataTextures
					mov eax, dwCurrentData
					mov ebx, SIZEOF LTexture
					mul ebx
					add rsi, rax
					
					mov rdi, offset gData
					mov eax, dwCurrentData
					shl rax, 3
					add rdi, rax
					inc DWORD PTR [rdi]
					mov rax, [rdi]
					mov number, al
					add number, 30h				; Convert from decimal to ascii
					invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,highlightColor
				.endif
			.endif

			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Update the game
		
		; Process output
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render text textures
		mov rax, SCREEN_WIDTH
		sub eax, gPromptTextTexture.m_Width
		shr rax, 1
		invoke renderTexture,gRenderer, addr gPromptTextTexture, eax, 0, 0, 0, 0, 0 
		
		xor rcx, rcx
		mov rsi, offset gDataTextures
		mov rdi, offset gDataTextures
		
		.while rcx < TOTAL_DATA
			mov rax, SCREEN_WIDTH
			sub eax, (LTexture PTR [rsi]).m_Width
			shr rax, 1
			mov coordX, eax
			
			mov ebx, gPromptTextTexture.m_Height
			mov eax, (LTexture PTR [rdi]).m_Height
			mul rcx
			add rbx, rax
			mov coordY, eax
			add coordY, 30
			
			mov temp, ecx
			invoke renderTexture,gRenderer, rsi, coordX, coordY, 0, 0, 0, 0
			mov ecx, temp
			add rsi, SIZEOF LTexture
			inc rcx
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
	; Save game data 
	invoke SDL_RWFromFile, addr BINARY_FILE, addr WRITE_FILE_ATTRS
	.if rax == 0
		; Error: Unable to create the file!: See error calling SDL_GetError"
		jmp EXIT
	.else
		mov gFile, rax
		xor rbx, rbx
		mov rsi, offset gData
		
		; Initialize data
		.while rbx < TOTAL_DATA
			mov SDWORD PTR[rsi], 0
			invoke SDL_RWwrite, gFile, rsi, 4, 1 
			add rsi, 4
			inc rbx
		.endw
		
		; Close file handler
		invoke SDL_RWclose, gFile
	.endif
EXIT:
	; Clean all data textures
	invoke freeTexture, addr gPromptTextTexture
	
	xor rcx, rcx
	mov rsi, offset gDataTextures
	.while rcx < TOTAL_DATA
		invoke freeTexture, rsi
		add rsi, SIZEOF LTexture
		inc rcx
	.endw
	
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
	
	invoke loadTextureFromRenderedText, gRenderer, addr gPromptTextTexture, rax, addr ENTER_DATA_MESSAGE, textColor
	
	invoke SDL_RWFromFile, addr BINARY_FILE, addr READ_FILE_ATTRS
	.if rax == 0
		invoke SDL_RWFromFile, addr BINARY_FILE, addr WRITE_FILE_ATTRS
		.if rax == 0
			; Error: Unable to create the file!: See error calling SDL_GetError"
			jmp EXIT
		.else
			mov gFile, rax
			xor rbx, rbx
			mov rsi, offset gData
			
			; Initialize data
			.while rbx < TOTAL_DATA
				mov SDWORD PTR[rsi], 0
				invoke SDL_RWwrite, gFile, rsi, 4, 1 
				add rsi, 4
				inc rbx
			.endw
			
			; Close file handler
			invoke SDL_RWclose, gFile
		.endif
		
	.else
		; File exists
		mov gFile, rax
		xor rbx, rbx
		mov rsi, offset gData
		
		; Read data
		.while rbx < TOTAL_DATA
			mov SDWORD PTR[rsi], 0
			invoke SDL_RWread, gFile, rsi, 4, 1 
			add rsi, 4
			inc rbx
		.endw
	
		; Close file handler
		invoke SDL_RWclose, gFile
	.endif
	
	; Initialize data textures
	mov rsi, offset gDataTextures
	mov rdi, offset gData
	mov rax, [rdi]
	mov number, al
	add number, 30h				; Convert from decimal to ascii
	invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,highlightColor
	add rsi, SIZEOF LTexture
	add rdi, 4
	xor rbx, rbx
	.while rbx<TOTAL_DATA
		mov rax, [rdi]
		mov number, al
		add number, 30h				; Convert from decimal to ascii
		invoke loadTextureFromRenderedText, gRenderer, rsi,gFont,addr number,textColor 
		add rsi, SIZEOF LTexture
		add rdi, 4
		inc rbx
	.endw 
	
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
