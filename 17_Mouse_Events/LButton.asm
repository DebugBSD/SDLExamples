include LButton.inc

.const 

.data?

externdef gRenderer:QWORD
externdef gButtonSpriteSheetTexture:LTexture
externdef gSpriteClips:SDL_Rect 
.data

.code

LButton_init proc uses rax rcx rdi, pLButton:ptr
	
	mov rdi, pLButton
	mov rcx, SIZEOF LButton
	mov rax, 0
	rep stosb
	
	ret
LButton_init endp


LButton_setPosition proc uses rax rbx rcx rdi, pLButton:ptr LButton, x:DWORD, y:DWORD
	
	mov rdi, pLButton
	mov eax, x
	mov ebx, y
	
	mov (LButton PTR [rdi]).m_Position.x, eax
	mov (LButton PTR [rdi]).m_Position.y, ebx
	
	ret
LButton_setPosition endp

LButton_handleEvent proc uses rax rbx rcx rdx rsi, pLButton:ptr LButton, e:ptr SDL_Event
	LOCAL xCoord:DWORD
	LOCAL yCoord:DWORD
	LOCAL inside:BYTE
	
	mov rsi, e
	
	.if (SDL_Event PTR[rsi]).type_ == SDL_MOUSEMOTION || (SDL_Event PTR[rsi]).type_ == SDL_MOUSEBUTTONDOWN || (SDL_Event PTR[rsi]).type_ == SDL_MOUSEBUTTONUP
				
		invoke SDL_GetMouseState, addr xCoord, addr yCoord	
		
		mov inside, 1
		mov rsi, pLButton
		mov ebx, xCoord
		mov ecx, yCoord
		
		mov r10d, (LButton PTR [rsi]).m_Position.x
		mov r11d, (LButton PTR [rsi]).m_Position.y
		mov r12d, r10d
		mov r13d, r11d
		add r12d, BUTTON_WIDTH
		add r13d, BUTTON_HEIGHT
		
		.if ebx < r10d 		; x < mPosition.x
			mov inside, 0
		.elseif	ebx > r12d 	; x > mPosition.x + BUTTON_WIDTH
			mov inside, 0
		.elseif ecx < r11d 	; y < mPosition.y
			mov inside, 0		
		.elseif ecx > r13d 	; y > mPosition.y + BUTTON_HEIGHT
			mov inside, 0
		.endif
			
		.if !inside
			mov (LButton PTR [rsi]).m_CurrentSprite, BUTTON_SPRITE_MOUSE_OUT
		.else
			mov rsi, e
			mov rdi, pLButton
			.if (SDL_Event PTR[rsi]).type_ == SDL_MOUSEMOTION
				mov (LButton PTR [rdi]).m_CurrentSprite, BUTTON_SPRITE_MOUSE_OVER_MOTION
			.elseif (SDL_Event PTR[rsi]).type_ == SDL_MOUSEBUTTONDOWN	
				mov (LButton PTR [rdi]).m_CurrentSprite, BUTTON_SPRITE_MOUSE_DOWN
			.elseif (SDL_Event PTR[rsi]).type_ == SDL_MOUSEBUTTONUP	
				mov (LButton PTR [rdi]).m_CurrentSprite, BUTTON_SPRITE_MOUSE_UP
			.endif 
		.endif
	.endif
	
	ret
LButton_handleEvent endp

LButton_render proc uses rax rcx rsi rdi, pLButton:ptr LButton
	mov rsi, pLButton
	mov rdi, offset gSpriteClips
	
	mov eax, (LButton PTR[rsi]).m_CurrentSprite
	mov ecx, SIZEOF SDL_Rect
	mul ecx
	add rdi, rax
		
	invoke renderTexture, gRenderer, addr gButtonSpriteSheetTexture, (LButton PTR [rsi]).m_Position.x, (LButton PTR [rsi]).m_Position.y, rdi, 0, 0, 0
	ret
LButton_render endp