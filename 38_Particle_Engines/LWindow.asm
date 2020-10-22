include LWindow.inc

.code

; Constructor
LWindow_ctor proc uses rsi, pWindow:PTR LWindow
	
	mov rsi, pWindow
	; Window data
	
	mov (LWindow PTR[rsi]).m_pWindow, 0
	
	; Window dimensions
	mov (LWindow PTR[rsi]).m_Width, 0
	mov (LWindow PTR[rsi]).m_Height, 0
	
	; Window focus
	mov (LWindow PTR[rsi]).m_MouseFocus, 0
	mov (LWindow PTR[rsi]).m_KeyboardFocus, 0
	mov (LWindow PTR[rsi]).m_FullScreen, 0
	mov (LWindow PTR[rsi]).m_Minimized, 0
	
	ret
LWindow_ctor endp

; Destructor
LWindow_dtor proc uses rsi, pWindow:PTR LWindow
	
	mov (LWindow PTR[rsi]).m_pWindow, 0
	
	; Window dimensions
	mov (LWindow PTR[rsi]).m_Width, 0
	mov (LWindow PTR[rsi]).m_Height, 0
	
	; Window focus
	mov (LWindow PTR[rsi]).m_MouseFocus, 0
	mov (LWindow PTR[rsi]).m_KeyboardFocus, 0
	mov (LWindow PTR[rsi]).m_FullScreen, 0
	mov (LWindow PTR[rsi]).m_Minimized, 0
	ret
LWindow_dtor endp

; Init window
LWindow_init proc uses rsi, pWindow:PTR LWindow
	
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
	
	mov rsi, pWindow
	mov (LWindow PTR[rsi]).m_pWindow, rax
	mov (LWindow PTR[rsi]).m_MouseFocus, 1
    mov (LWindow PTR[rsi]).m_KeyboardFocus, 1
    mov (LWindow PTR[rsi]).m_Width, SCREEN_WIDTH
    mov (LWindow PTR[rsi]).m_Height, SCREEN_HEIGHT
	
EXIT:
	ret
LWindow_init endp

; Create Renderer
LWindow_createRenderer proc uses rsi, pWindow:PTR LWindow
	; Create the renderer
	mov rsi, pWindow
	invoke SDL_CreateRenderer, (LWindow PTR [rsi]).m_pWindow, -1, SDL_RENDERER_ACCELERATED OR SDL_RENDERER_PRESENTVSYNC
	ret
LWindow_createRenderer endp

;Handle Input events
LWindow_handleEvent proc uses rax rbx rsi rdi r10, pWindow:PTR LWindow, evt:PTR SDL_Event
	
	mov rsi, pWindow
	mov rdi, evt
	
	.if (SDL_Event PTR [rdi]).type_ == SDL_WINDOWEVENT
		; Caption update flag
		xor r10, r10
		.if	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_SIZE_CHANGED
			mov eax, (SDL_Event PTR [rdi]).window.data1
			mov ebx, (SDL_Event PTR [rdi]).window.data2
			mov (LWindow PTR [rsi]).m_Width, eax
			mov (LWindow PTR [rsi]).m_Height, ebx
			invoke SDL_RenderPresent, gRenderer
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_EXPOSED
			invoke SDL_RenderPresent, gRenderer
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_ENTER
			mov (LWindow PTR [rsi]).m_MouseFocus, 1
			mov r10, 1
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_LEAVE
			mov (LWindow PTR [rsi]).m_MouseFocus, 0
			mov r10, 1
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_FOCUS_GAINED
			mov (LWindow PTR [rsi]).m_KeyboardFocus, 1
			mov r10, 1
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_FOCUS_LOST
			mov (LWindow PTR [rsi]).m_KeyboardFocus, 0
			mov r10, 1		
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_MINIMIZED
			mov (LWindow PTR [rsi]).m_Minimized, 1
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_MAXIMIZED
			mov (LWindow PTR [rsi]).m_Minimized, 0		
		.elseif	(SDL_Event PTR [rdi]).window.event == SDL_WINDOWEVENT_RESTORED
			mov (LWindow PTR [rsi]).m_Minimized, 0
		.endif
		.if r10==1
			; Update window caption with new data
		.endif
	.elseif (SDL_Event PTR [rdi]).type_ == SDL_KEYDOWN && (SDL_Event PTR [rdi]).key.keysym.sym == SDLK_RETURN
		.if (LWindow PTR [rsi]).m_Fullscreen == 1
			invoke SDL_SetWindowFullscreen, (LWindow PTR [rsi]).m_pWindow, SDL_FALSE
			mov (LWindow PTR [rsi]).m_Fullscreen, 0
		.else
			invoke SDL_SetWindowFullscreen, (LWindow PTR [rsi]).m_pWindow, SDL_TRUE
			mov (LWindow PTR [rsi]).m_Fullscreen, 1
			mov (LWindow PTR [rsi]).m_Minimized, 0
		.endif
	.endif
	ret
LWindow_handleEvent endp

