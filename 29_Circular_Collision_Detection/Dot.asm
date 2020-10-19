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
	
	; Set collision circle size
	mov (Dot PTR [rdi]).m_Collider.r, DOT_WIDTH/10
	
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

Dot_move proc uses rax rbx rcx rsi r10 r11 r12 r13, pDot:PTR Dot, pSquareCollider:ptr SDL_Rect, pCircleCollider:PTR Circle
	LOCAL t1:DWORD
	LOCAL t2:QWORD
	mov rsi, pDot
	
	; Move the dot left or right
	mov r10d, (Dot PTR[rsi]).m_PosX
	add r10d, (Dot PTR[rsi]).m_VelX
	mov (Dot PTR[rsi]).m_PosX, r10d			; m_PosX += m_VelX	
	invoke Dot_shiftColliders, pDot			; Update collision info

	mov rbx, r10
	add rbx, DOT_WIDTH
	; If the dot went too far to the left or right
	invoke CheckCollisionCircle, addr (Dot PTR[rsi]).m_Collider, pCircleCollider ; Check collision
	mov t1, eax
	invoke CheckCollisionRect, addr (Dot PTR[rsi]).m_Collider, pSquareCollider ; Check collision
	mov r13d, t1
	mov r12d, r10d
	sub r12d, (Dot PTR[rsi]).m_Collider.r ; (m_PosX - m_Collider.r)
	.if r12d<0 || rbx > SCREEN_WIDTH || rax || r13d
		sub r10d, (Dot PTR[rsi]).m_VelX
		mov (Dot PTR[rsi]).m_PosX, r10d		; m_PosX -= m_VelX
		invoke Dot_shiftColliders, pDot		; Update collision info
	.endif
	
	; Move the dot up or down
	mov r10d, (Dot PTR[rsi]).m_PosY
	add r10d, (Dot PTR[rsi]).m_VelY
	mov (Dot PTR[rsi]).m_PosY, r10d			; m_PosX += m_VelX	
	invoke Dot_shiftColliders, pDot			; Update collision info
	
	mov rbx, r10
	add rbx, DOT_HEIGHT
	; If the dot went too far up or down
	invoke CheckCollisionCircle, addr (Dot PTR[rsi]).m_Collider, pCircleCollider ; Check collision
	mov t1, eax
	invoke CheckCollisionRect, addr (Dot PTR[rsi]).m_Collider, pSquareCollider ; Check collision
	mov r13d, t1
	mov r12d, r10d
	sub r12d, (Dot PTR[rsi]).m_Collider.r ; (m_PosY - m_Collider.r)
	.if r12d<0 || rbx > SCREEN_HEIGHT || rax || r13d
		sub r10d, (Dot PTR[rsi]).m_VelY	
		mov (Dot PTR[rsi]).m_PosY, r10d		; m_PosY -= m_VelY
		invoke Dot_shiftColliders, pDot		; Update collision info
	.endif
	
	ret
Dot_move endp

Dot_render proc uses rax rcx rsi r11 r12, pDot:ptr Dot, pTexture:ptr LTexture
	mov rsi, pDot
	
	mov r11d, (Dot PTR [rsi]).m_PosX
	sub r11d, (Dot PTR [rsi]).m_Collider.r
	
	mov r12d, (Dot PTR [rsi]).m_PosY
	sub r12d, (Dot PTR [rsi]).m_Collider.r
	
	invoke renderTexture, gRenderer, pTexture, r11d , r12d, 0, 0, 0, 0
	ret
Dot_render endp

Dot_shiftColliders proc uses rax rsi, pDot:PTR Dot
	;Align collider to center of dot
	mov rsi, pDot
		
	mov eax, (Dot PTR[rsi]).m_PosX;
	mov (Dot PTR[rsi]).m_Collider.x, eax
	
	mov eax, (Dot PTR[rsi]).m_PosY;
	mov (Dot PTR[rsi]).m_Collider.y, eax
	
	ret
Dot_shiftColliders endp