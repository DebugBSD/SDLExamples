include LTimer.inc

.code

LTimer_Init proc pTimer:PTR LTimer 				; Constructor
	mov rdi, pTimer
	mov (LTimer PTR [rdi]).m_StartTicks, 0
	mov (LTimer PTR [rdi]).m_PausedTicks, 0 
	mov (LTimer PTR [rdi]).m_Paused, 0
	mov (LTimer PTR [rdi]).m_Started, 0
	ret
LTimer_Init endp


LTimer_Start proc pTimer:PTR LTimer
	mov rdi, pTimer
	
	invoke SDL_GetTicks		; Get current timestamp
	mov (LTimer PTR [rdi]).m_StartTicks, eax
	mov (LTimer PTR [rdi]).m_PausedTicks, 0 
	mov (LTimer PTR [rdi]).m_Paused, 0
	mov (LTimer PTR [rdi]).m_Started, 1
	
	ret
LTimer_Start endp


LTimer_Stop proc pTimer:PTR LTimer
	
	mov rdi, pTimer
	mov (LTimer PTR [rdi]).m_StartTicks, 0
	mov (LTimer PTR [rdi]).m_PausedTicks, 0 
	mov (LTimer PTR [rdi]).m_Paused, 0
	mov (LTimer PTR [rdi]).m_Started, 0
	ret
	
LTimer_Stop endp


LTimer_Pause proc pTimer:PTR LTimer
	
	mov rdi, pTimer
	.if (LTimer PTR [rdi]).m_Started == 1 && (LTimer PTR [rdi]).m_Paused == 0
	 
		mov (LTimer PTR [rdi]).m_Paused, 1 			; Pause the timer
		invoke SDL_GetTicks							; Get current timestamp
		sub eax, (LTimer PTR [rdi]).m_StartTicks	; Calculate the paused ticks
		mov (LTimer PTR [rdi]).m_PausedTicks, eax
		
		mov (LTimer PTR [rdi]).m_StartTicks, 0		; Reset the paused ticks
	.endif
	ret
	
LTimer_Pause endp

LTimer_Unpause proc uses rax rdi, pTimer:PTR LTimer
	
	mov rdi, pTimer
	.if (LTimer PTR [rdi]).m_Started == 1 && (LTimer PTR [rdi]).m_Paused == 1
	 
		mov (LTimer PTR [rdi]).m_Paused, 0 			; Unpause the timer
		invoke SDL_GetTicks							; Get current timestamp
		sub eax, (LTimer PTR [rdi]).m_PausedTicks	; Reset the starting ticks
		mov (LTimer PTR [rdi]).m_StartTicks, eax
		
		mov (LTimer PTR [rdi]).m_PausedTicks, 0		; Reset the paused ticks
	.endif
	ret
	
LTimer_Unpause endp

LTimer_GetTicks proc uses rdi, pTimer:PTR LTimer
	
	mov rdi, pTimer
	.if (LTimer PTR [rdi]).m_Started == 1
	 
	 	.if  (LTimer PTR [rdi]).m_Paused == 1
	 		mov eax, (LTimer PTR [rdi]).m_PausedTicks
	 	.else
	 		invoke SDL_GetTicks							; Get current timestamp
			sub eax, (LTimer PTR [rdi]).m_StartTicks	; Reset the starting ticks
	 	.endif 
		
	.endif
	
	ret
	
LTimer_GetTicks endp


LTimer_IsStarted proc uses rdi, pTimer:PTR LTimer
	
	mov rdi, pTimer
	mov al, (LTimer PTR [rdi]).m_Started
	ret
	
LTimer_IsStarted endp

LTimer_IsPaused proc uses rdi, pTimer:PTR LTimer
	
	xor rax, rax
	mov rdi, pTimer
	.if (LTimer PTR [rdi]).m_Paused == 1 && (LTimer PTR [rdi]).m_Started == 1
		mov rax, 1
	.endif
	
	ret
	
LTimer_IsPaused endp