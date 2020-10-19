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
	
	mov (Dot PTR [rdi]).m_Colliders[0 * SIZEOF SDL_Rect].w, 6
	mov (Dot PTR [rdi]).m_Colliders[0 * SIZEOF SDL_Rect].h, 1
	
	mov (Dot PTR [rdi]).m_Colliders[1 * SIZEOF SDL_Rect].w, 10
	mov (Dot PTR [rdi]).m_Colliders[1 * SIZEOF SDL_Rect].h, 1
	
	mov (Dot PTR [rdi]).m_Colliders[2 * SIZEOF SDL_Rect].w, 14
	mov (Dot PTR [rdi]).m_Colliders[2 * SIZEOF SDL_Rect].h, 1
	
	mov (Dot PTR [rdi]).m_Colliders[3 * SIZEOF SDL_Rect].w, 16
	mov (Dot PTR [rdi]).m_Colliders[3 * SIZEOF SDL_Rect].h, 2
	
	mov (Dot PTR [rdi]).m_Colliders[4 * SIZEOF SDL_Rect].w, 18
	mov (Dot PTR [rdi]).m_Colliders[4 * SIZEOF SDL_Rect].h, 2
	
	mov (Dot PTR [rdi]).m_Colliders[5 * SIZEOF SDL_Rect].w, 20
	mov (Dot PTR [rdi]).m_Colliders[5 * SIZEOF SDL_Rect].h, 6
	
	mov (Dot PTR [rdi]).m_Colliders[6 * SIZEOF SDL_Rect].w, 18
	mov (Dot PTR [rdi]).m_Colliders[6 * SIZEOF SDL_Rect].h, 2
	
	mov (Dot PTR [rdi]).m_Colliders[7 * SIZEOF SDL_Rect].w, 16
	mov (Dot PTR [rdi]).m_Colliders[7 * SIZEOF SDL_Rect].h, 2
	
	mov (Dot PTR [rdi]).m_Colliders[8 * SIZEOF SDL_Rect].w, 14
	mov (Dot PTR [rdi]).m_Colliders[8 * SIZEOF SDL_Rect].h, 1
	
	mov (Dot PTR [rdi]).m_Colliders[9 * SIZEOF SDL_Rect].w, 10
	mov (Dot PTR [rdi]).m_Colliders[9 * SIZEOF SDL_Rect].h, 1
	
	mov (Dot PTR [rdi]).m_Colliders[10 * SIZEOF SDL_Rect].w, 6
	mov (Dot PTR [rdi]).m_Colliders[10 * SIZEOF SDL_Rect].h, 1
	
	; Initialize colliders relative to position
	invoke Dot_shiftColliders, pDot
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

Dot_move proc uses rax rbx rcx rsi, pDot:PTR Dot, pOtherColliders:PTR SDL_Rect
	LOCAL t1:DWORD
	LOCAL t2:QWORD
	mov rsi, pDot
	
	; Move the dot left or right
	mov r10d, (Dot PTR[rsi]).m_PosX
	add r10d, (Dot PTR[rsi]).m_VelX
	mov (Dot PTR[rsi]).m_PosX, r10d
	invoke Dot_shiftColliders, pDot									; Update collision info

	mov rbx, r10
	add rbx, DOT_WIDTH
	; If the dot went too far to the left or right
	mov t1, r10d
	mov t2, rsi
	invoke CheckCollision, addr (Dot PTR[rsi]).m_Colliders, pOtherColliders ; Check collision
	mov rsi, t2
	mov r10d, t1
	.if r10<0 || rbx > SCREEN_WIDTH || rax
		sub r10d, (Dot PTR[rsi]).m_VelX
		mov (Dot PTR[rsi]).m_PosX, r10d
		invoke Dot_shiftColliders, pDot								; Update collision info
	.endif
	
	; Move the dot up or down
	mov r10d, (Dot PTR[rsi]).m_PosY
	add r10d, (Dot PTR[rsi]).m_VelY
	mov (Dot PTR[rsi]).m_PosY, r10d
	invoke Dot_shiftColliders, pDot									; Update collision info
	
	mov rbx, r10
	; If the dot went too far up or down
	add rbx, DOT_HEIGHT
	mov t1, r10d
	mov t2, rsi
	invoke CheckCollision, addr (Dot PTR[rsi]).m_Colliders, pOtherColliders	; Check collision
	mov rsi, t2
	mov r10d, t1
	.if r10d<0 || rbx > SCREEN_HEIGHT || rax
		sub r10d, (Dot PTR[rsi]).m_VelY
		mov (Dot PTR[rsi]).m_PosY, r10d
		invoke Dot_shiftColliders, pDot								; Update collision info
	.endif
	
	ret
Dot_move endp

Dot_render proc uses rax rcx rsi, pDot:ptr Dot, pTexture:ptr LTexture
	mov rsi, pDot
	
	invoke renderTexture, gRenderer, pTexture, (Dot PTR [rsi]).m_PosX, (Dot PTR [rsi]).m_PosY, 0, 0, 0, 0
	ret
Dot_render endp

Dot_shiftColliders proc uses rsi rdi r8 r9, pDot:PTR Dot
	LOCAL r:DWORD
	
	mov rsi, pDot
	lea rdi, (Dot PTR[rsi]).m_Colliders
	
	xor r11, r11
	xor r12, r12
	mov r, 0
	.while r12 < 11
		; Center the collision box
		mov r8d, DOT_WIDTH
		sub r8d, (SDL_Rect PTR[rdi]).w 	; (DOT_WIDTH - m_Colliders[set].w)
		shr r8d, 1						; ((DOT_WIDTH - m_Colliders[set].w) / 2)
		add r8d, (Dot PTR[rsi]).m_PosX	; (m_PosX + ((DOT_WIDTH - m_Colliders[set].w) / 2))
		mov (SDL_Rect PTR[rdi]).x, r8d	; mColliders[ set ].x = (m_PosX + ((DOT_WIDTH - m_Colliders[set].w) / 2))
		
		; Set the collision box at its row offset
		mov r9d, (Dot PTR[rsi]).m_PosY
		add r9d, r
		mov (SDL_Rect PTR[rdi]).y, r9d
		
		; Move the row offset down the height of the collision box
		mov r8d, r
		add r8d, (SDL_Rect PTR[rdi]).h
		mov r, r8d
		
		; Increment the pointer
		add rdi, SIZEOF SDL_Rect
		inc r12
	.endw
	
	ret
Dot_shiftColliders endp