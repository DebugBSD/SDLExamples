;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_mouse.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_mouse.h

ifndef SDL_mouse_h_
SDL_mouse_h_	EQU	<>
include SDL_video.inc

SDL_SystemCursor typedef DWORD
SDL_SYSTEM_CURSOR_ARROW = 0
SDL_SYSTEM_CURSOR_IBEAM = 1
SDL_SYSTEM_CURSOR_WAIT = 2
SDL_SYSTEM_CURSOR_CROSSHAIR = 3
SDL_SYSTEM_CURSOR_WAITARROW = 4
SDL_SYSTEM_CURSOR_SIZENWSE = 5
SDL_SYSTEM_CURSOR_SIZENESW = 6
SDL_SYSTEM_CURSOR_SIZEWE = 7
SDL_SYSTEM_CURSOR_SIZENS = 8
SDL_SYSTEM_CURSOR_SIZEALL = 9
SDL_SYSTEM_CURSOR_NO = 10
SDL_SYSTEM_CURSOR_HAND = 11
SDL_NUM_SYSTEM_CURSORS = 12

SDL_MouseWheelDirection typedef DWORD
SDL_MOUSEWHEEL_NORMAL = 0
SDL_MOUSEWHEEL_FLIPPED = 1

externdef SDL_GetMouseFocus:proto  
externdef SDL_GetMouseState:proto
externdef SDL_GetGlobalMouseState:proto
externdef SDL_GetRelativeMouseState:proto
externdef SDL_WarpMouseInWindow:proto
externdef SDL_WarpMouseGlobal:proto
externdef SDL_SetRelativeMouseMode:proto
externdef SDL_CaptureMouse:proto
externdef SDL_GetRelativeMouseMode:proto  
externdef SDL_CreateCursor:proto
externdef SDL_CreateColorCursor:proto
externdef SDL_CreateSystemCursor:proto
externdef SDL_SetCursor:proto
externdef SDL_GetCursor:proto  
externdef SDL_GetDefaultCursor:proto  
externdef SDL_FreeCursor:proto
externdef SDL_ShowCursor:proto

SDL_BUTTON macro X
	exitm <( 1  shl  ( ( X ) - 1 ) ) >
	endm
	
SDL_BUTTON_LEFT		EQU	1
SDL_BUTTON_MIDDLE	EQU	2
SDL_BUTTON_RIGHT	EQU	3
SDL_BUTTON_X1		EQU	4
SDL_BUTTON_X2		EQU	5
SDL_BUTTON_LMASK	EQU	<SDL_BUTTON ( SDL_BUTTON_LEFT )>
SDL_BUTTON_MMASK	EQU	<SDL_BUTTON ( SDL_BUTTON_MIDDLE )>
SDL_BUTTON_RMASK	EQU	<SDL_BUTTON ( SDL_BUTTON_RIGHT )>
SDL_BUTTON_X1MASK	EQU	<SDL_BUTTON ( SDL_BUTTON_X1 )>
SDL_BUTTON_X2MASK	EQU	<SDL_BUTTON ( SDL_BUTTON_X2 )>
endif 

;--- errors: 0
;--- end of file ---
