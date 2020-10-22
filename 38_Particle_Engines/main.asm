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


; External definitions
externdef	__imp_srand:PROC
srand equ <__imp_srand>
externdef	__imp_rand:PROC
rand equ <__imp_rand>
externdef __imp_malloc:proc
malloc equ <__imp_malloc>
externdef __imp_free:proc
free equ <__imp_free>

; This macro doesn't save RAX nor RDX, ...
mGetRandom MACRO num:REQ
	LOCAL val
	.data 
	val QWORD num
	.code
	mov rdx, 0
	call QWORD PTR rand		; Sets RAX to the current random
	div val					; Apply the module based on 'num' argument, so RAX has the result.
endm

mCreateTextureFromFile MACRO pTexture:REQ, pString:REQ
	LOCAL constString
	.const
	constString BYTE pString,0
	.code
	lea r8, constString
	mov rdx, pTexture
	mov rcx, gRenderer
	call loadTextureFromFile
;	invoke loadTextureFromFile, gRenderer, pTexture, addr constString
endm

; Include files
include main.inc
include SDL.inc
include SDL_image.inc
include SDL_ttf.inc
include SDL_mixer.inc
; include Code files
include LWindow.asm
include LTexture.asm
include LButton.asm
include LTimer.asm
include Particle.asm
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

.data
quit				BYTE 0
gWindow 			LWindow <0,0,0,0,0,0,0>
gDot				Dot<>

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
gDotTexture			LTexture <>
gRedTexture			LTexture <>  
gGreenTexture		LTexture <>
gBlueTexture 		LTexture <>
gShimmerTexture		LTexture <>

.code

main proc 
	
	finit
		
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	
	invoke Dot_ctor, addr gDot
	
	; Gameloop
	.while quit!=1
		
		; Process input
		invoke SDL_PollEvent, addr eventHandler
		.while rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.endif

			invoke LWindow_handleEvent, addr gWindow, addr eventHandler

			invoke Dot_handleEvent, addr gDot, addr eventHandler
			
			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		; Update the game
		invoke Dot_move,addr gDot		
		
		; Process output
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		invoke Dot_render, addr gDot, addr gDotTexture
		
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

	invoke LWindow_init, addr gWindow
	.if rax==0
		jmp EXIT
	.endif
	
	; Create the renderer
	invoke LWindow_createRenderer, addr gWindow
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
	
	; Clean all data textures
	invoke LTexture_dtor, addr gDotTexture 
	invoke LTexture_dtor, addr gRedTexture
	invoke LTexture_dtor, addr gGreenTexture
	invoke LTexture_dtor, addr gBlueTexture
	invoke LTexture_dtor, addr gShimmerTexture
	
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
	
	
	mCreateTextureFromFile offset gDotTexture, "Res/dot.bmp"
	.if rax==0
		; Handle error
		jmp EXIT
	.endif
	
	mCreateTextureFromFile offset gRedTexture, "Res/red.bmp"
	.if rax==0
		; Handle error
		jmp EXIT
	.endif
	
	mCreateTextureFromFile offset gGreenTexture, "Res/green.bmp"
	.if rax==0
		; Handle error
		jmp EXIT
	.endif
	
	mCreateTextureFromFile offset gBlueTexture, "Res/blue.bmp"
	.if rax==0
		; Handle error
		jmp EXIT
	.endif
	
	mCreateTextureFromFile offset gShimmerTexture, "Res/shimmer.bmp"
	.if rax==0
		; Handle error
		jmp EXIT
	.endif
	
	; Set texture transparency
	invoke LTexture_setAlpha, addr gRedTexture, 192
	invoke LTexture_setAlpha, addr gGreenTexture, 192
	invoke LTexture_setAlpha, addr gBlueTexture, 192
	invoke LTexture_setAlpha, addr gShimmerTexture, 192
	
	
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
