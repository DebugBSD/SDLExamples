include Dot.inc

Dot_shiftColliders proto :PTR Dot

.code

Dot_Init proc pDot:PTR Dot, x:DWORD, y:DWORD  				; Constructor
	mov r10d, x
	mov r11d, y
	mov rdi, pDot
	mov (Dot PTR [rdi]).m_PosX, r10d
	mov (Dot PTR [rdi]).m_PosY, r11d
	mov (Dot PTR [rdi]).m_VelX, 0
	mov (Dot PTR [rdi]).m_VelY, 0

	ret
Dot_Init endp


Dot_handleEvent proc uses rax rbx rcx rdx rsi, pDot:ptr Dot, e:ptr SDL_Event
	
	mov rsi, e
	mov rdi, pDot
	
	.if (SDL_Event PTR[rsi]).type_ == SDL_KEYDOWN && (SDL_Event PTR[rsi]).key.repeat_==0
		.if (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_UP
			sub (Dot PTR [rdi]).m_VelY, DOT_VEL
		.elseif (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_DOWN
			add (Dot PTR [rdi]).m_VelY, DOT_VEL
		.elseif (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_LEFT
			sub (Dot PTR [rdi]).m_VelX, DOT_VEL 
		.elseif (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_RIGHT
			add (Dot PTR [rdi]).m_VelX, DOT_VEL
		.endif
	.elseif (SDL_Event PTR[rsi]).type_ == SDL_KEYUP && (SDL_Event PTR[rsi]).key.repeat_==0
		.if (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_UP
			add (Dot PTR [rdi]).m_VelY, DOT_VEL
		.elseif (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_DOWN
			sub (Dot PTR [rdi]).m_VelY, DOT_VEL
		.elseif (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_LEFT
			add (Dot PTR [rdi]).m_VelX, DOT_VEL
		.elseif (SDL_Event PTR[rsi]).key.keysym.sym==SDLK_RIGHT
			sub (Dot PTR [rdi]).m_VelX, DOT_VEL
		.endif		
	.endif
	
	ret
Dot_handleEvent endp

Dot_move proc uses rsi r10 r11, pDot:PTR Dot
	LOCAL t1:DWORD
	LOCAL t2:QWORD
	mov rsi, pDot
	
	; Move the dot left or right
	mov r10d, (Dot PTR[rsi]).m_PosX
	add r10d, (Dot PTR[rsi]).m_VelX
	mov (Dot PTR[rsi]).m_PosX, r10d			; m_PosX += m_VelX	
	mov r11d, r10d
	add r11d, DOT_WIDTH

	; if ((m_PosX < 0) || (m_PosX + DOT_WIDTH) > LEVEL_WIDTH)
	.if r10d<0 || r11d > LEVEL_WIDTH
		sub r10d, (Dot PTR[rsi]).m_VelX
		mov (Dot PTR[rsi]).m_PosX, r10d		; m_PosX -= m_VelX
	.endif
	
	; Move the dot up or down
	mov r10d, (Dot PTR[rsi]).m_PosY
	add r10d, (Dot PTR[rsi]).m_VelY
	mov (Dot PTR[rsi]).m_PosY, r10d			; m_PosX += m_VelX	
	mov r11d, r10d
	add r11d, DOT_HEIGHT
	
	; if ((m_PosY < 0) || (m_PosY + DOT_HEIGHT) > LEVEL_HEIGHT)	
	.if r10d<0 || r11d > LEVEL_HEIGHT
		sub r10d, (Dot PTR[rsi]).m_VelY	
		mov (Dot PTR[rsi]).m_PosY, r10d		; m_PosY -= m_VelY
	.endif
	
	ret
Dot_move endp

Dot_render proc uses rsi r11 r12, pDot:ptr Dot, pTexture:ptr LTexture, camX:DWORD, camY:DWORD
	mov rsi, pDot
	
	mov r11d, (Dot PTR [rsi]).m_PosX
	sub r11d, camX
	
	mov r12d, (Dot PTR [rsi]).m_PosY
	sub r12d, camY
	
	invoke renderTexture, gRenderer, pTexture, r11d , r12d, 0, 0, 0, 0
	ret
Dot_render endp
