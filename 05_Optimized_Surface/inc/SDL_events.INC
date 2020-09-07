; SDL_events.h
ifndef SDL_events_h_
SDL_events_h_	EQU	<>

; include SDL_stdinc.inc
include SDL_error.inc
include SDL_video.inc
include SDL_keyboard.inc
include SDL_mouse.inc
; include SDL_joystick.inc
; include SDL_gamecontroller.inc
; include SDL_quit.inc
; include SDL_gesture.inc
; include SDL_touch.inc
; include begin_code.inc
	
SDL_RELEASED					EQU	0
SDL_PRESSED						EQU	1
SDL_EventType 					typedef DWORD
SDL_FIRSTEVENT 					= 0 
SDL_QUIT 						= 100h 
SDL_APP_TERMINATING 			= 101
SDL_APP_LOWMEMORY 				= 102
SDL_APP_WILLENTERBACKGROUND 	= 103
SDL_APP_DIDENTERBACKGROUND 		= 104
SDL_APP_WILLENTERFOREGROUND 	= 105
SDL_APP_DIDENTERFOREGROUND 		= 106
SDL_DISPLAYEVENT 				= 150h 
SDL_WINDOWEVENT 				= 200h 
SDL_SYSWMEVENT 					= 201
SDL_KEYDOWN 					= 300h 
SDL_KEYUP 						= 301
SDL_TEXTEDITING 				= 302
SDL_TEXTINPUT 					= 303
SDL_KEYMAPCHANGED 				= 304
SDL_MOUSEMOTION 				= 400h 
SDL_MOUSEBUTTONDOWN 			= 401
SDL_MOUSEBUTTONUP 				= 402
SDL_MOUSEWHEEL 					= 403
SDL_JOYAXISMOTION 				= 600h 
SDL_JOYBALLMOTION 				= 601
SDL_JOYHATMOTION 				= 602
SDL_JOYBUTTONDOWN 				= 603
SDL_JOYBUTTONUP 				= 604
SDL_JOYDEVICEADDED 				= 605
SDL_JOYDEVICEREMOVED 			= 606
SDL_CONTROLLERAXISMOTION 		= 650h 
SDL_CONTROLLERBUTTONDOWN 		= 651
SDL_CONTROLLERBUTTONUP 			= 652
SDL_CONTROLLERDEVICEADDED 		= 653
SDL_CONTROLLERDEVICEREMOVED 	= 654
SDL_CONTROLLERDEVICEREMAPPED 	= 655
SDL_FINGERDOWN 					= 700h 
SDL_FINGERUP 					= 701
SDL_FINGERMOTION 				= 702
SDL_DOLLARGESTURE 				= 800h 
SDL_DOLLARRECORD 				= 801
SDL_MULTIGESTURE 				= 802
SDL_CLIPBOARDUPDATE 			= 900h 
SDL_DROPFILE 					= 1000h 
SDL_DROPTEXT 					= 1001
SDL_DROPBEGIN 					= 1002
SDL_DROPCOMPLETE 				= 1003
SDL_AUDIODEVICEADDED 			= 1100h 
SDL_AUDIODEVICEREMOVED 			= 1101
SDL_SENSORUPDATE 				= 1200h 
SDL_RENDER_TARGETS_RESET 		= 2000h 
SDL_RENDER_DEVICE_RESET 		= 2001
SDL_USEREVENT 					= 8000h 
SDL_LASTEVENT 					= 0FFFFh 

SDL_CommonEvent	struct 
	type_		DWORD	?
	timestamp	DWORD	?
SDL_CommonEvent	ends

SDL_DisplayEvent	struct 
	type_		DWORD	?
	timestamp	DWORD	?
	display		DWORD	?
	event		BYTE	?
	padding1	BYTE	?
	padding2	BYTE	?
	padding3	BYTE	?
	data1		SDWORD	?
SDL_DisplayEvent	ends

SDL_WindowEvent	struct 
	type_		DWORD	?
	timestamp	DWORD	?
	windowID	DWORD	?
	event		BYTE	?
	padding1	BYTE	?
	padding2	BYTE	?
	padding3	BYTE	?
	data1		SDWORD	?
	data2		SDWORD	?
SDL_WindowEvent	ends

SDL_KeyboardEvent	struct 
	type_		DWORD	?
	timestamp	DWORD	?
	windowID	DWORD	?
	state		BYTE	?
	rpt			BYTE	?
	padding2	BYTE	?
	padding3	BYTE	?
	keysym		SDL_Keysym	<>
SDL_KeyboardEvent	ends

SDL_TEXTEDITINGEVENT_TEXT_SIZE	EQU	32
SDL_TextEditingEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
windowID	DWORD	?
text		SBYTE SDL_TEXTEDITINGEVENT_TEXT_SIZE dup (?)
start		SDWORD	?
length_		SDWORD	?
SDL_TextEditingEvent	ends

SDL_TEXTINPUTEVENT_TEXT_SIZE	EQU	32
SDL_TextInputEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
windowID	DWORD	?
text		SBYTE SDL_TEXTINPUTEVENT_TEXT_SIZE dup (?)
SDL_TextInputEvent	ends

SDL_MouseMotionEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
windowID	DWORD	?
which		DWORD	?
state		DWORD	?
x			SDWORD	?
y			SDWORD	?
xrel		SDWORD	?
yrel		SDWORD	?
SDL_MouseMotionEvent	ends

SDL_MouseButtonEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
windowID	DWORD	?
which		DWORD	?
button		BYTE	?
state		BYTE	?
clicks		BYTE	?
padding1	BYTE	?
x			SDWORD	?
y			SDWORD	?
SDL_MouseButtonEvent	ends

SDL_MouseWheelEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
windowID	DWORD	?
which		DWORD	?
x			SDWORD	?
y			SDWORD	?
direction	DWORD	?
SDL_MouseWheelEvent	ends

; SDL_JoyAxisEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; which		SDL_JoystickID	?
; axis		BYTE	?
; padding1	BYTE	?
; padding2	BYTE	?
; padding3	BYTE	?
; value		SWORD	?
; padding4	WORD	?
; SDL_JoyAxisEvent	ends

; SDL_JoyBallEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; which		SDL_JoystickID	?
; ball		BYTE	?
; padding1	BYTE	?
; padding2	BYTE	?
; padding3	BYTE	?
; xrel		SWORD	?
; yrel		SWORD	?
; SDL_JoyBallEvent	ends

; SDL_JoyHatEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; which		SDL_JoystickID	?
; hat			BYTE	?
; value		BYTE	?
; padding1	BYTE	?
; padding2	BYTE	?
; SDL_JoyHatEvent	ends

; SDL_JoyButtonEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; which		SDL_JoystickID	?
; button		BYTE	?
; state		BYTE	?
; padding1	BYTE	?
; padding2	BYTE	?
; SDL_JoyButtonEvent	ends

SDL_JoyDeviceEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
which		SDWORD	?
SDL_JoyDeviceEvent	ends

; SDL_ControllerAxisEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; which		SDL_JoystickID	?
; axis		BYTE	?
; padding1	BYTE	?
; padding2	BYTE	?
; padding3	BYTE	?
; value		SWORD	?
; padding4	WORD	?
; SDL_ControllerAxisEvent	ends

; SDL_ControllerButtonEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; which		SDL_JoystickID	?
; button		BYTE	?
; state		BYTE	?
; padding1	BYTE	?
; padding2	BYTE	?
; SDL_ControllerButtonEvent	ends

SDL_ControllerDeviceEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
which		SDWORD	?
SDL_ControllerDeviceEvent	ends

SDL_AudioDeviceEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
which		DWORD	?
iscapture	BYTE	?
padding1	BYTE	?
padding2	BYTE	?
padding3	BYTE	?
SDL_AudioDeviceEvent	ends

; SDL_TouchFingerEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; touchId		SDL_TouchID	?
; fingerId	SDL_FingerID	?
; x			REAL4	?
; y			REAL4	?
; dx_			REAL4	?
; dy			REAL4	?
; pressure	REAL4	?
; windowID	DWORD	?
; SDL_TouchFingerEvent	ends

; SDL_MultiGestureEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; touchId		SDL_TouchID	?
; dTheta		REAL4	?
; dDist		REAL4	?
; x			REAL4	?
; y			REAL4	?
; numFingers	WORD	?
; padding		WORD	?
; SDL_MultiGestureEvent	ends

; SDL_DollarGestureEvent	struct 
; type_		DWORD	?
; timestamp	DWORD	?
; touchId		SDL_TouchID	?
; gestureId	SDL_GestureID	?
; numFingers	DWORD	?
; error		REAL4	?
; x			REAL4	?
; y			REAL4	?
; SDL_DollarGestureEvent	ends

SDL_DropEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
file		DWORD	?
windowID	DWORD	?
SDL_DropEvent	ends

SDL_SensorEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
which		SDWORD	?
data		REAL4 6 dup (?)
SDL_SensorEvent	ends

SDL_QuitEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
SDL_QuitEvent	ends

SDL_OSEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
SDL_OSEvent	ends

SDL_UserEvent	struct 
type_		DWORD	?
timestamp	DWORD	?
windowID	DWORD	?
ucode		SDWORD	?
data1		DWORD	?
data2		DWORD	?
SDL_UserEvent	ends

;SDL_SysWMmsg typedef SDL_SysWMmsg

SDL_SysWMEvent	struct 
	type_		DWORD	?
	timestamp	DWORD	?
	msg			DWORD	?
SDL_SysWMEvent	ends

SDL_Event	union 
	type_		DWORD	?
	common		SDL_CommonEvent	<>
	display		SDL_DisplayEvent	<>
	window		SDL_WindowEvent	<>
	key			SDL_KeyboardEvent	<>
	edit		SDL_TextEditingEvent	<>
	text		SDL_TextInputEvent	<>
	motion		SDL_MouseMotionEvent	<>
	button		SDL_MouseButtonEvent	<>
	wheel		SDL_MouseWheelEvent	<>
	;jaxis		SDL_JoyAxisEvent	<>
	;jball		SDL_JoyBallEvent	<>
	;jhat		SDL_JoyHatEvent	<>
	;jbutton	SDL_JoyButtonEvent	<>
	jdevice		SDL_JoyDeviceEvent	<>
	;caxis		SDL_ControllerAxisEvent	<>
	;cbutton	SDL_ControllerButtonEvent	<>
	cdevice		SDL_ControllerDeviceEvent	<>
	adevice		SDL_AudioDeviceEvent	<>
	sensor		SDL_SensorEvent	<>
	quit		SDL_QuitEvent	<>
	user		SDL_UserEvent	<>
	syswm		SDL_SysWMEvent	<>
	;tfinger	SDL_TouchFingerEvent	<>
	;mgesture	SDL_MultiGestureEvent	<>
	;dgesture	SDL_DollarGestureEvent	<>
	drop		SDL_DropEvent	<>
	padding		BYTE 56 dup (?)
SDL_Event	ends

externdef SDL_PumpEvents :proto  
SDL_ADDEVENT = 0
SDL_PEEKEVENT = 1
SDL_GETEVENT = 2

externdef SDL_PeepEvents:proto
externdef SDL_HasEvent:proto
externdef SDL_HasEvents:proto
externdef SDL_FlushEvent:proto
externdef SDL_FlushEvents:proto
externdef SDL_PollEvent:proto
externdef SDL_WaitEvent:proto
externdef SDL_WaitEventTimeout:proto
externdef SDL_PushEvent:proto
externdef SDL_SetEventFilter:proto
externdef SDL_GetEventFilter:proto
externdef SDL_AddEventWatch:proto
externdef SDL_DelEventWatch:proto
externdef SDL_FilterEvents:proto

SDL_QUERY	EQU	-1
SDL_IGNORE	EQU	0
SDL_DISABLE	EQU	0
SDL_ENABLE	EQU	1
externdef SDL_EventState:proto
SDL_GetEventState macro type
	exitm <SDL_EventState ( type , SDL_QUERY ) >
	endm
externdef SDL_RegisterEvents:proto
 
; include close_code.inc
endif 

;--- errors: 0
;--- end of file ---
