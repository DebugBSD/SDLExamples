include Dot.inc

Dot_shiftColliders proto :PTR Dot
Dot_renderParticles proto :PTR Dot

.code

Dot_ctor proc uses rsi rdi r10 r11, pDot:PTR Dot  				; Constructor
	LOCAL r10q_:QWORD
	mov rdi, pDot
	mov (Dot PTR [rdi]).m_PosX, 0
	mov (Dot PTR [rdi]).m_PosY, 0
	mov (Dot PTR [rdi]).m_VelX, 0
	mov (Dot PTR [rdi]).m_VelY, 0

	lea rsi, (Dot PTR [rdi]).m_Particles
	xor r10, r10
	.while r10<TOTAL_PARTICLES
		mov r10q_, r10
		invoke Particle_ctor, rsi, (Dot PTR [rdi]).m_PosX, (Dot PTR [rdi]).m_PosY
		mov r10, r10q_
		add rsi, SIZEOF Particle
		inc r10
	.endw
	

	ret
Dot_ctor endp

Dot_dtor proc uses rdi r10 r11, pDot:PTR Dot ; Destructor

	mov rdi, pDot
	lea rsi, (Dot PTR [rdi]).m_Particles
	xor r10, r10
	; Call destructor
	.while r10<TOTAL_PARTICLES
		
		invoke Particle_dtor, rsi
		
		add rsi, SIZEOF Particle
		inc r10
	.endw
	
	ret
Dot_dtor endp


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

Dot_render proc uses rsi r11 r12, pDot:ptr Dot, pTexture:ptr LTexture
	mov rsi, pDot
	
	invoke renderTexture, gRenderer, pTexture, (Dot PTR [rsi]).m_PosX , (Dot PTR [rsi]).m_PosY, 0, 0, 0, 0
	
	invoke Dot_renderParticles, pDot
	
	ret
Dot_render endp

Dot_renderParticles proc uses rsi rdi r10, pDot:PTR Dot
	LOCAL r10q_:QWORD
	mov rdi, pDot
	lea rsi, (Dot PTR [rdi]).m_Particles
	xor r10, r10
	.while r10<TOTAL_PARTICLES
		
		invoke Particle_isDead, rsi
		.if rax==1
			invoke Particle_ctor, rsi, (Dot PTR [rdi]).m_PosX, (Dot PTR [rdi]).m_PosY
		.endif
		
		add rsi, SIZEOF Particle
		inc r10
	.endw
	
	; Show particle
	lea rsi, (Dot PTR [rdi]).m_Particles
	xor r10, r10
	.while r10<TOTAL_PARTICLES
		
		mov r10q_, r10
		invoke Particle_render, rsi
		mov r10, r10q_
		add rsi, SIZEOF Particle
		inc r10
	.endw
	
	ret
Dot_renderParticles endp