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
CheckCollisionCircle 	proto 	:PTR Circle, :PTR Circle
CheckCollisionRect 		proto 	:PTR Circle, :PTR SDL_Rect
include Dot.asm

Init 			proto 
Shutdown 		proto
LoadMedia		proto
LoadTexture 	proto	:QWORD
StringCopy 		proto 	:PTR BYTE, :PTR BYTE
StringConcat 	proto 	:PTR BYTE, :PTR BYTE
DistanceSquared proto 	:DWORD, :DWORD, :DWORD, :DWORD

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
SCREEN_TICKS_PER_FRAME = 16
frames					REAL4 1000.0

; Values to rotate the sprite
WINDOW_TITLE 		BYTE "SDL Tutorial",0
FILE_ATTRS 			BYTE "rb"
DOT_IMAGE			BYTE "Res/dot.bmp",0

.data
quit				BYTE 0
gDot				Dot <0,0,0,0>		
gOtherDot			Dot <0,0,0,0>	
gWall 				SDL_Rect<300, 40, 40, 400>

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
gDotTexture			LTexture <>
gOtherDotTexture	LTexture <>

gBuffer				BYTE 1024 DUP(?)
gCurrentTime		BYTE 1024 DUP(?)



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
	
	invoke Dot_Init, addr gDot, 10, 10
	invoke Dot_Init, addr gOtherDot, 200, 200
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
		invoke Dot_move, addr gDot, addr gWall, addr gOtherDot.m_Collider
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render wall
		invoke SDL_SetRenderDrawColor, gRenderer, 0h, 0h, 0h, 0FFh
		invoke SDL_RenderDrawRect, gRenderer, addr gWall
		
		; Render dots
		invoke Dot_render, addr gDot, addr gDotTexture
		invoke Dot_render, addr gOtherDot, addr gOtherDotTexture
		
		
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
	
	invoke freeTexture, addr gDotTexture
	invoke freeTexture, addr gOtherDotTexture
	
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
	
	invoke loadTextureFromFile, gRenderer, addr gOtherDotTexture, addr DOT_IMAGE 
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

; Circle / Circle collision detector
CheckCollisionCircle proc uses rbx rsi rdi, a:ptr Circle, b:ptr Circle
	LOCAL totalRadiusSquared:DWORD
	; Calculate total radius squared
	
	mov rsi, a
	mov rdi, b
	mov ebx, (Circle PTR[rsi]).r
	add ebx, (Circle PTR[rdi]).r
	xor rdx, rdx
	mov rax, rbx
	mul rbx
	mov totalRadiusSquared, ebx  ; totalRadiusSquared = totalRadiusSquared (rax) * totalRadiusSquared (rbx)
	
	invoke DistanceSquared, (Circle PTR[rsi]).x, (Circle PTR[rsi]).y, (Circle PTR[rdi]).x, (Circle PTR[rdi]).y
	.if eax < totalRadiusSquared
		mov rax, 1
	.else
		xor rax, rax
	.endif
	
	ret
CheckCollisionCircle endp 

; Circle / Circle collision detector
CheckCollisionRect proc uses r11 r12 r13 rsi rdi, a:ptr Circle, b:ptr SDL_Rect
	LOCAL colX:DWORD
	LOCAL colY:DWORD
	
	mov rsi, a
	mov rdi, b
	mov r11d, (SDL_Rect PTR[rdi]).x
	add r11d, (SDL_Rect PTR[rdi]).w
	
	mov r12d, (Circle PTR[rsi]).x
	mov r13d, (SDL_Rect PTR[rdi]).x
	; Find closest x offset
	.if(r12d < r13d)
		mov colX, r13d
	.elseif (r12d > r11d) 
		mov colX, r11d 
	.else
		mov colX, r12d
	.endif
	
	; Find closes y offset
	mov r11d, (SDL_Rect PTR[rdi]).y
	add r11d, (SDL_Rect PTR[rdi]).h
	
	mov r12d, (Circle PTR[rsi]).y
	mov r13d, (SDL_Rect PTR[rdi]).y
	.if(r12d <r13d )
		mov colY, r13d
	.elseif (r12d > r11d) 
		mov colY, r11d 
	.else
		mov colY, r12d
	.endif
	
	mov rdx, 0
	mov eax, (Circle PTR[rsi]).r
	mul (Circle PTR[rsi]).r
	mov r11, rax
	invoke DistanceSquared, (Circle PTR[rsi]).x, (Circle PTR[rsi]).y, colX, colY
	.if rax < r11
		mov rax, 1
	.else
		xor rax, rax
	.endif
	ret
CheckCollisionRect endp 

DistanceSquared proc uses rdx r10 r11, x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
	LOCAL deltaX:DWORD
	LOCAL deltaY:DWORD
	
	mov r10d, x2
	sub r10d, x1
	mov deltaX, r10d
	
	mov r11d, y2
	sub r11d, y1
	mov deltaY, r11d
	
	xor edx, edx
	mov eax, deltaX
	mul deltaX
	mov deltaX, eax
	
	xor edx, edx
	mov eax, deltaY
	mul deltaY
	mov deltaY, eax
	
	mov eax, deltaX
	add eax, deltaY
	ret
DistanceSquared endp

; Collision against vector of colliders
;CheckCollision 	proc uses rbx rcx rdx rsi rdi, a:PTR SDL_Rect, b:PTR SDL_Rect
;	LOCAL t1:DWORD
;	LOCAL ABox:DWORD
;	LOCAL BBox:DWORD
;	mov r11, 0
;	mov ABox, 0
;	mov BBox, 0
;	
;	mov rsi, a
;	mov rdi, b
;	
;	; By default, return false
;	mov rax, 0
;	mov rbx, 0
;	.while ABox < 11
;		
;		; Calculate the sides of rect A
;		mov r8d, (SDL_Rect PTR [rsi]).x		; leftA = a[ABox].x
;		mov r9, r8							; rightA = leftA
;		add r9d, (SDL_Rect PTR [rsi]).w		; rightA += a[ABox].w
;		
;		mov r10d, (SDL_Rect PTR [rsi]).y	; topA = a[ABox].y
;		mov r11, r10						; bottomA = topA
;		add r11d, (SDL_Rect PTR [rsi]).h	; bottomA += a[ABox].h
;		
;		mov rdi, b
;		; Go through the B Boxes
;		.while BBox < 11 
;			; Calculate the sides of rect B
;			mov r12d, (SDL_Rect PTR [rdi]).x		; leftB = b[BBox].x
;			mov r13, r12							; rightB = leftB
;			add r13d, (SDL_Rect PTR [rdi]).w		; rightB += b[BBox].w
;			
;			mov r14d, (SDL_Rect PTR [rdi]).y		; topB = B[BBox].y
;			mov r15, r14							; bottomB = topB
;			add r15d, (SDL_Rect PTR [rdi]).h		; bottomB += B[BBox].h
;			xor rbx, rbx
;			.if (r11<=r14)
;				or rbx, 1
;			.endif
;			
;			.if (r10>=r15)
;				or rbx, 2
;			.endif		
;			
;			.if (r9<=r12)
;				or rbx, 4
;			.endif
;			
;			.if (r8>=r13)
;				or rbx, 8
;			.endif		
;			
;			.if rbx==0
;				mov rax, 1
;				jmp EXIT
;			.endif
;			
;			inc BBox
;			add rdi, SIZEOF SDL_Rect	
;		.endw
;		inc ABox
;		add rsi, SIZEOF SDL_Rect	
;	.endw
;EXIT:
;
;	ret
;CheckCollision endp

END

; vim options: ts=2 sw=2
