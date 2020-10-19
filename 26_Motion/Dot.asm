include Dot.inc

.code

Dot_Init proc pDot:PTR Dot 				; Constructor
	mov rdi, pDot
	mov (Dot PTR [rdi]).m_PosX, 0
	mov (Dot PTR [rdi]).m_PosY, 0 
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

Dot_move proc uses rax rbx rsi, pDot:PTR Dot
	
	mov rsi, pDot
	
	; Move the dot left or right
	mov eax, (Dot PTR[rsi]).m_PosX
	add eax, (Dot PTR[rsi]).m_VelX
	mov (Dot PTR[rsi]).m_PosX, eax
	
	mov rbx, rax
	add rbx, DOT_WIDTH
	; If the dot went too far to the left or right
	.if rax<0 || rbx > SCREEN_WIDTH
		sub eax, (Dot PTR[rsi]).m_VelX
		mov (Dot PTR[rsi]).m_PosX, eax
	.endif
	
	; Move the dot up or down
	mov eax, (Dot PTR[rsi]).m_PosY
	add eax, (Dot PTR[rsi]).m_VelY
	mov (Dot PTR[rsi]).m_PosY, eax
	
	mov rbx, rax
	; If the dot went too far up or down
	add rbx, DOT_HEIGHT
	.if rax<0 || rbx > SCREEN_HEIGHT
		sub eax, (Dot PTR[rsi]).m_VelY
		mov (Dot PTR[rsi]).m_PosY, eax
	.endif
	
	ret
Dot_move endp

Dot_render proc uses rax rcx rsi, pDot:ptr Dot
	mov rsi, pDot
	
	invoke renderTexture, gRenderer, addr gDotTexture, (Dot PTR [rsi]).m_PosX, (Dot PTR [rsi]).m_PosY, 0, 0, 0, 0
	ret
Dot_render endp