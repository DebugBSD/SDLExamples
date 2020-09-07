; SDL.h

ifndef SDL_h_
SDL_h_	EQU	<>
;include SDL_main.inc
;include SDL_stdinc.inc
;include SDL_assert.inc
;include SDL_atomic.inc
;include SDL_audio.inc
;include SDL_clipboard.inc
;include SDL_cpuinfo.inc
;include SDL_endian.inc
;include SDL_error.inc
include SDL_events.inc
;include SDL_filesystem.inc
;include SDL_gamecontroller.inc
;include SDL_haptic.inc
;include SDL_hints.inc
;include SDL_joystick.inc
;include SDL_loadso.inc
;include SDL_log.inc
;include SDL_messagebox.inc
;include SDL_metal.inc
;include SDL_mutex.inc
;include SDL_power.inc
;include SDL_render.inc
;include SDL_rwops.inc
;include SDL_sensor.inc
;include SDL_shape.inc
;include SDL_system.inc
;include SDL_thread.inc
include SDL_timer.inc
;include SDL_version.inc
include SDL_video.inc

SDL_INIT_TIMER				EQU	00000001h
SDL_INIT_AUDIO				EQU	00000010h
SDL_INIT_VIDEO				EQU	00000020h
SDL_INIT_JOYSTICK			EQU	00000200h
SDL_INIT_HAPTIC				EQU	00001000h
SDL_INIT_GAMECONTROLLER		EQU	00002000h
SDL_INIT_EVENTS				EQU	00004000h
SDL_INIT_SENSOR				EQU	00008000h
SDL_INIT_NOPARACHUTE		EQU	00100000h
SDL_INIT_EVERYTHING			EQU	( SDL_INIT_TIMER  or  SDL_INIT_AUDIO  or  SDL_INIT_VIDEO  or  SDL_INIT_EVENTS  or  SDL_INIT_JOYSTICK  or  SDL_INIT_HAPTIC  or  SDL_INIT_GAMECONTROLLER  or  SDL_INIT_SENSOR )
externdef SDL_Init:proto
externdef SDL_InitSubSystem:proto
externdef SDL_QuitSubSystem:proto
externdef SDL_WasInit:proto
externdef SDL_Quit:proto  

endif 

;--- errors: 0
;--- end of file ---
