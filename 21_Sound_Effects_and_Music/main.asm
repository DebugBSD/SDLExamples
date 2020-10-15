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

; Include files
include main.inc
include SDL.inc
include SDL_image.inc
include SDL_ttf.inc
include SDL_mixer.inc
; include Code files
include LTexture.asm
include LButton.asm

Init 		proto 
Shutdown 	proto
LoadMedia	proto
LoadTexture proto	:QWORD

.const
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

; Values to rotate the sprite
WINDOW_TITLE 	BYTE "SDL Tutorial",0
FILE_ATTRS 		BYTE "rb"
IMAGE_PROMPT	BYTE "Res/prompt.png",0

; Audios 
MUSIC_BEAT 		BYTE "Res/beat.wav",0
MUSIC_SCRATCH	BYTE "Res/scratch.wav",0
MUSIC_HIGH 		BYTE "Res/high.wav",0
MUSIC_MEDIUM	BYTE "Res/medium.wav",0
MUSIC_LOW 		BYTE "Res/low.wav",0


.data
quit			BYTE 0

.data?
pWindow 			QWORD ?
eventHandler		SDL_Event <>
gRenderer			QWORD ?
currentTexture 		QWORD ?	
gPromptTexture		LTexture <>

; Audios
gMusic				QWORD ?
gScratch			QWORD ?
gHigh				QWORD ?
gMedium				QWORD ?
gLow				QWORD ?

.code

main proc 
	local i:dword
	local poll:qword
	
	; Alloc our memory for our objects, starts SDL, ...
	invoke Init
	.if rax==0
		invoke ExitProcess, EXIT_FAILURE
	.endif
	
	invoke LoadMedia
	; Gameloop
	.while quit!=1
		
		invoke SDL_PollEvent, addr eventHandler
		.while rax!=0
			.if eventHandler.type_ == SDL_EVENTQUIT
				mov quit, 1
			.elseif eventHandler.type_ == SDL_KEYDOWN
				.if eventHandler.key.keysym.sym == SDLK_1
					invoke Mix_PlayChannelTimed, -1, gHigh, 0, -1
				.elseif eventHandler.key.keysym.sym == SDLK_2
					invoke Mix_PlayChannelTimed, -1, gMedium, 0, -1
				.elseif eventHandler.key.keysym.sym == SDLK_3
					invoke Mix_PlayChannelTimed, -1, gLow, 0, -1
				.elseif eventHandler.key.keysym.sym == SDLK_4
					invoke Mix_PlayChannelTimed, -1, gScratch, 0, -1
				.elseif eventHandler.key.keysym.sym == SDLK_9
					invoke Mix_PlayingMusic
					.if rax==0
						invoke Mix_PlayMusic, gMusic, -1
					.else
						invoke Mix_PauseMusic
						.if rax==1
							invoke Mix_ResumeMusic
						.else
							invoke Mix_PauseMusic
						.endif
					.endif
				.elseif eventHandler.key.keysym.sym == SDLK_0
					invoke Mix_HaltMusic
				.endif
			.endif

			invoke SDL_PollEvent, addr eventHandler
		.endw
		
		
		; Clear screen
		invoke SDL_SetRenderDrawColor, gRenderer, 0FFh, 0FFh, 0FFh, 0FFh
		invoke SDL_RenderClear, gRenderer
		
		; Render texture
		invoke renderTexture, gRenderer, addr gPromptTexture, 0, 0, 0, 0, 0, 0
		
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
	
	invoke freeTexture, addr gPromptTexture
	
	invoke Mix_FreeChunk, gScratch
	invoke Mix_FreeChunk, gHigh
	invoke Mix_FreeChunk, gMedium
	invoke Mix_FreeChunk, gLow
	
	invoke Mix_FreeMusic, gMusic
	
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
	
	invoke loadTextureFromFile, gRenderer, addr gPromptTexture, addr IMAGE_PROMPT
	.if eax==0
		jmp EXIT
	.endif

	invoke Mix_LoadMUS, addr MUSIC_BEAT
	.if rax==0
		jmp EXIT
	.endif
	mov gMusic, rax
	
	invoke SDL_RWFromFile, addr MUSIC_SCRATCH, addr FILE_ATTRS
	invoke Mix_LoadWAV_RW, rax, 1
	.if rax==0
		jmp EXIT
	.endif
	mov gScratch, rax
	
	invoke SDL_RWFromFile, addr MUSIC_HIGH, addr FILE_ATTRS
	invoke Mix_LoadWAV_RW, rax, 1
	.if rax==0
		jmp EXIT
	.endif
	mov gHigh, rax
	
	invoke SDL_RWFromFile, addr MUSIC_MEDIUM, addr FILE_ATTRS
	invoke Mix_LoadWAV_RW, rax, 1
	.if rax==0
		jmp EXIT
	.endif
	mov gMedium, rax
	
	invoke SDL_RWFromFile, addr MUSIC_LOW, addr FILE_ATTRS
	invoke Mix_LoadWAV_RW, rax, 1
	.if rax==0
		jmp EXIT
	.endif
	mov gLow, rax
	
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
	
END

; vim options: ts=2 sw=2
