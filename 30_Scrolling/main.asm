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
include LTimer.asm
include Dot.asm

Init 			proto 
Shutdown 		proto
LoadMedia		proto
LoadTexture 	proto	:QWORD
StringCopy 		proto 	:PTR BYTE, :PTR BYTE
StringConcat 	proto 	:PTR BYTE, :PTR BYTE
UpdateCamera 	proto 	:PTR SDL_Rect, :DWORD, :DWORD, :DWORD, :DWORD 

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
DOT_IMAGE			BYTE "Res/dot.bmp",0
BKG_IMAGE			BYTE "Res/bg.png",0

.data
quit				BYTE 0
gDot				Dot <0,0,0,0>	
gCamera 			SDL_Rect <0,0,SCREEN_WIDTH, SCREEN_HEIGHT>	

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
gDotTexture			LTexture <>
gBkgTexture			LTexture <>

.code

main proc 
	local i:dword
	local poll:qword
	
	finit
		
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	
	invoke Dot_Init, addr gDot, 0, 0
	; Gameloop
	.while quit!=1
		
		; Process input
		invoke SDL_PollEvent, addr eventHandler
		.while rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.endif

			invoke Dot_handleEvent, addr gDot, addr eventHandler

			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Update game
		invoke Dot_move, addr gDot
		
		; Update Camera
		mov eax, gDot.m_PosX
		add eax, 10		; ( m_PosX + DOT_WIDTH / 2 )
		sub eax, 320 	; ( m_PosX + DOT_WIDTH / 2 ) - ( SCREEN_WIDTH / 2)

		mov ebx, gDot.m_PosY
		add ebx, 10		; ( m_PosX + DOT_HEIGHT / 2 )
		sub ebx, 240 	; ( m_PosX + DOT_HEIGHT / 2 ) - ( SCREEN_HEIGHT / 2)
		
		invoke UpdateCamera, addr gCamera, eax, ebx, LEVEL_WIDTH, LEVEL_HEIGHT
			
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render Background
		invoke renderTexture, gRenderer, addr gBkgTexture, 0, 0, addr gCamera, 0, 0, 0
		
		; Render dot
		invoke Dot_render, addr gDot, addr gDotTexture, gCamera.x, gCamera.y
				
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
	
	invoke freeTexture, addr gBkgTexture
	invoke freeTexture, addr gDotTexture
	
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
	
	invoke loadTextureFromFile, gRenderer, addr gDotTexture, addr DOT_IMAGE 
	
	invoke loadTextureFromFile, gRenderer, addr gBkgTexture, addr BKG_IMAGE 
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

UpdateCamera proc uses rax rbx r10 r11, pCamera:PTR SDL_Rect, x:DWORD, y:DWORD, w:DWORD, h:DWORD
	mov rsi, pCamera
	
	mov eax, x
	mov ebx, y
	
	mov gCamera.x, eax
	mov gCamera.y, ebx
	
	mov r10d, w
	sub r10d, gCamera.w
	
	mov r11d, h
	sub r11d, gCamera.h
	
	cmp (SDL_Rect PTR[rsi]).x, 0
	jge C1
		mov (SDL_Rect PTR[rsi]).x, 0
C1:
	cmp (SDL_Rect PTR[rsi]).y, 0
	jge C2
		mov (SDL_Rect PTR[rsi]).y, 0
C2:
	cmp (SDL_Rect PTR[rsi]).x, r10d
	jbe C3
		mov (SDL_Rect PTR[rsi]).x, r10d
C3:
	cmp (SDL_Rect PTR[rsi]).y, r11d
	jbe C4
		mov (SDL_Rect PTR[rsi]).y, r11d
C4:	


	ret
UpdateCamera endp 

END

; vim options: ts=2 sw=2
