; SDL_keyboard.h

ifndef SDL_keyboard_h_
SDL_keyboard_h_	EQU	<>
; include SDL_stdinc.inc
include SDL_error.inc
include SDL_keycode.inc
include SDL_video.inc
; include begin_code.inc

SDL_Keysym	struct 
	scancode	SDL_Scancode	?
	sym			SDL_Keycode	?
	mode		WORD	?
	unused		DWORD	?
SDL_Keysym	ends

SDL_GetKeyboardFocus proto  
SDL_GetKeyboardState proto
SDL_GetModState proto  
SDL_SetModState proto
SDL_GetKeyFromScancode proto
SDL_GetScancodeFromKey proto
SDL_GetScancodeName proto
SDL_GetScancodeFromName proto
SDL_GetKeyName proto
SDL_GetKeyFromName proto
SDL_StartTextInput proto  
SDL_IsTextInputActive proto  
SDL_StopTextInput proto  
SDL_SetTextInputRect proto
SDL_HasScreenKeyboardSupport proto  
SDL_IsScreenKeyboardShown proto

endif 

;--- errors: 0
;--- end of file ---
