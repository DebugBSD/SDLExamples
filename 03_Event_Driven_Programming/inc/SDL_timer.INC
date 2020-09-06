;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_timer.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_timer.h

ifndef SDL_timer_h_
SDL_timer_h_	EQU	<>
;	include SDL_stdinc.inc
include SDL_error.inc
;	include begin_code.inc
SDL_GetTicks proto  
SDL_TICKS_PASSED macro A,B
	exitm <( ( Sint32 ) ( ( B ) - ( A ) ) <= 0 ) >
	endm
externdef SDL_GetPerformanceCounter:proto  
externdef SDL_GetPerformanceFrequency:proto  
externdef SDL_Delay:proto
SDL_TimerID typedef DWORD
externdef SDL_AddTimer:proto
externdef SDL_RemoveTimer:proto
endif 

;--- errors: 0
;--- end of file ---
