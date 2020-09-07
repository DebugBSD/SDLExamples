;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_video.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_video.h

ifndef SDL_video_h_
SDL_video_h_	EQU	<>
; include SDL_stdinc.inc
; include SDL_pixels.inc
include SDL_rect.inc
include SDL_surface.inc

SDL_DisplayMode	struct 
	format			DWORD	?
	w				DWORD	?
	h				DWORD	?
	refresh_rate	DWORD	?
	driverdata		DWORD	?
SDL_DisplayMode	ends

;SDL_Window typedef SDL_Window

SDL_WindowFlags typedef DWORD
SDL_WINDOW_FULLSCREEN = 00000001h 
SDL_WINDOW_OPENGL = 00000002h 
SDL_WINDOW_SHOWN = 00000004h 
SDL_WINDOW_HIDDEN = 00000008h 
SDL_WINDOW_BORDERLESS = 00000010h 
SDL_WINDOW_RESIZABLE = 00000020h 
SDL_WINDOW_MINIMIZED = 00000040h 
SDL_WINDOW_MAXIMIZED = 00000080h 
SDL_WINDOW_INPUT_GRABBED = 00000100h 
SDL_WINDOW_INPUT_FOCUS = 00000200h 
SDL_WINDOW_MOUSE_FOCUS = 00000400h 
SDL_WINDOW_FULLSCREEN_DESKTOP = ( SDL_WINDOW_FULLSCREEN  or  00001000h ) 
SDL_WINDOW_FOREIGN = 00000800h 
SDL_WINDOW_ALLOW_HIGHDPI = 00002000h 
SDL_WINDOW_MOUSE_CAPTURE = 00004000h 
SDL_WINDOW_ALWAYS_ON_TOP = 00008000h 
SDL_WINDOW_SKIP_TASKBAR = 00010000h 
SDL_WINDOW_UTILITY = 00020000h 
SDL_WINDOW_TOOLTIP = 00040000h 
SDL_WINDOW_POPUP_MENU = 00080000h 
SDL_WINDOW_VULKAN = 10000000h 

SDL_WINDOWPOS_UNDEFINED_MASK	EQU	1FFF0000h
SDL_WINDOWPOS_UNDEFINED_DISPLAY macro X
	exitm <( SDL_WINDOWPOS_UNDEFINED_MASK  or  ( X ) ) >
	endm
SDL_WINDOWPOS_UNDEFINED	EQU	SDL_WINDOWPOS_UNDEFINED_DISPLAY ( 0 )
SDL_WINDOWPOS_ISUNDEFINED macro X
	exitm <( ( ( X )  and  0FFFF0000h ) == SDL_WINDOWPOS_UNDEFINED_MASK ) >
	endm
SDL_WINDOWPOS_CENTERED_MASK	EQU	2FFF0000h
SDL_WINDOWPOS_CENTERED_DISPLAY macro X
	exitm <( SDL_WINDOWPOS_CENTERED_MASK  or  ( X ) ) >
	endm
SDL_WINDOWPOS_CENTERED	EQU	SDL_WINDOWPOS_CENTERED_DISPLAY ( 0 )
SDL_WINDOWPOS_ISCENTERED macro X
	exitm <( ( ( X )  and  0FFFF0000h ) == SDL_WINDOWPOS_CENTERED_MASK ) >
	endm
SDL_WindowEventID typedef DWORD
SDL_WINDOWEVENT_NONE = 0
SDL_WINDOWEVENT_SHOWN = 1
SDL_WINDOWEVENT_HIDDEN = 2
SDL_WINDOWEVENT_EXPOSED = 3
SDL_WINDOWEVENT_MOVED = 4
SDL_WINDOWEVENT_RESIZED = 5
SDL_WINDOWEVENT_SIZE_CHANGED = 6
SDL_WINDOWEVENT_MINIMIZED = 7
SDL_WINDOWEVENT_MAXIMIZED = 8
SDL_WINDOWEVENT_RESTORED = 9
SDL_WINDOWEVENT_ENTER = 10
SDL_WINDOWEVENT_LEAVE = 11
SDL_WINDOWEVENT_FOCUS_GAINED = 12
SDL_WINDOWEVENT_FOCUS_LOST = 13
SDL_WINDOWEVENT_CLOSE = 14
SDL_WINDOWEVENT_TAKE_FOCUS = 15
SDL_WINDOWEVENT_HIT_TEST = 16

SDL_DisplayEventID typedef DWORD
SDL_DISPLAYEVENT_NONE = 0
SDL_DISPLAYEVENT_ORIENTATION = 1

SDL_DisplayOrientation typedef DWORD
SDL_ORIENTATION_UNKNOWN = 0
SDL_ORIENTATION_LANDSCAPE = 1
SDL_ORIENTATION_LANDSCAPE_FLIPPED = 2
SDL_ORIENTATION_PORTRAIT = 3
SDL_ORIENTATION_PORTRAIT_FLIPPED = 4

SDL_GLContext typedef ptr 
SDL_GLattr typedef DWORD
SDL_GL_RED_SIZE = 0
SDL_GL_GREEN_SIZE = 1
SDL_GL_BLUE_SIZE = 2
SDL_GL_ALPHA_SIZE = 3
SDL_GL_BUFFER_SIZE = 4
SDL_GL_DOUBLEBUFFER = 5
SDL_GL_DEPTH_SIZE = 6
SDL_GL_STENCIL_SIZE = 7
SDL_GL_ACCUM_RED_SIZE = 8
SDL_GL_ACCUM_GREEN_SIZE = 9
SDL_GL_ACCUM_BLUE_SIZE = 10
SDL_GL_ACCUM_ALPHA_SIZE = 11
SDL_GL_STEREO = 12
SDL_GL_MULTISAMPLEBUFFERS = 13
SDL_GL_MULTISAMPLESAMPLES = 14
SDL_GL_ACCELERATED_VISUAL = 15
SDL_GL_RETAINED_BACKING = 16
SDL_GL_CONTEXT_MAJOR_VERSION = 17
SDL_GL_CONTEXT_MINOR_VERSION = 18
SDL_GL_CONTEXT_EGL = 19
SDL_GL_CONTEXT_FLAGS = 20
SDL_GL_CONTEXT_PROFILE_MASK = 21
SDL_GL_SHARE_WITH_CURRENT_CONTEXT = 22
SDL_GL_FRAMEBUFFER_SRGB_CAPABLE = 23
SDL_GL_CONTEXT_RELEASE_BEHAVIOR = 24
SDL_GL_CONTEXT_RESET_NOTIFICATION = 25
SDL_GL_CONTEXT_NO_ERROR = 26

SDL_GLprofile typedef DWORD
SDL_GL_CONTEXT_PROFILE_CORE = 0001h 
SDL_GL_CONTEXT_PROFILE_COMPATIBILITY = 0002h 
SDL_GL_CONTEXT_PROFILE_ES = 0004h 

SDL_GLcontextFlag typedef DWORD
SDL_GL_CONTEXT_DEBUG_FLAG = 0001h 
SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = 0002h 
SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG = 0004h 
SDL_GL_CONTEXT_RESET_ISOLATION_FLAG = 0008h 

SDL_GLcontextReleaseFlag typedef DWORD
SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE = 0000h 
SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = 0001h 

SDL_GLContextResetNotification typedef DWORD
SDL_GL_CONTEXT_RESET_NO_NOTIFICATION = 0000h 
SDL_GL_CONTEXT_RESET_LOSE_CONTEXT = 0001h 

externdef SDL_GetNumVideoDrivers :proto  
externdef SDL_GetVideoDriver :proto
externdef SDL_VideoInit :proto
externdef SDL_VideoQuit :proto  
externdef SDL_GetCurrentVideoDriver :proto  
externdef SDL_GetNumVideoDisplays :proto  
externdef SDL_GetDisplayName :proto
externdef SDL_GetDisplayBounds :proto
externdef SDL_GetDisplayUsableBounds :proto
externdef SDL_GetDisplayDPI :proto
externdef SDL_GetDisplayOrientation :proto
externdef SDL_GetNumDisplayModes :proto
externdef SDL_GetDisplayMode :proto
externdef SDL_GetDesktopDisplayMode :proto
externdef SDL_GetCurrentDisplayMode :proto
externdef SDL_GetClosestDisplayMode :proto
externdef SDL_GetWindowDisplayIndex :proto
externdef SDL_SetWindowDisplayMode :proto
externdef SDL_GetWindowDisplayMode :proto
externdef SDL_GetWindowPixelFormat :proto
externdef SDL_CreateWindow :proto
externdef SDL_CreateWindowFrom :proto
externdef SDL_GetWindowID :proto
externdef SDL_GetWindowFromID :proto
externdef SDL_GetWindowFlags :proto
externdef SDL_SetWindowTitle :proto
externdef SDL_GetWindowTitle :proto
externdef SDL_SetWindowIcon :proto
externdef SDL_SetWindowData :proto
externdef SDL_GetWindowData :proto
externdef SDL_SetWindowPosition :proto
externdef SDL_GetWindowPosition :proto
externdef SDL_SetWindowSize :proto
externdef SDL_GetWindowSize :proto
externdef SDL_GetWindowBordersSize :proto
externdef SDL_SetWindowMinimumSize :proto
externdef SDL_GetWindowMinimumSize :proto
externdef SDL_SetWindowMaximumSize :proto
externdef SDL_GetWindowMaximumSize :proto
externdef SDL_SetWindowBordered :proto
externdef SDL_SetWindowResizable :proto
externdef SDL_ShowWindow :proto
externdef SDL_HideWindow :proto
externdef SDL_RaiseWindow :proto
externdef SDL_MaximizeWindow :proto
externdef SDL_MinimizeWindow :proto
externdef SDL_RestoreWindow :proto
externdef SDL_SetWindowFullscreen :proto
externdef SDL_GetWindowSurface :proto
externdef SDL_UpdateWindowSurface :proto
externdef SDL_UpdateWindowSurfaceRects :proto
externdef SDL_SetWindowGrab :proto
externdef SDL_GetWindowGrab :proto
externdef SDL_GetGrabbedWindow :proto  
externdef SDL_SetWindowBrightness :proto
externdef SDL_GetWindowBrightness :proto
externdef SDL_SetWindowOpacity :proto
externdef SDL_GetWindowOpacity :proto
externdef SDL_SetWindowModalFor :proto
externdef SDL_SetWindowInputFocus :proto
externdef SDL_SetWindowGammaRamp :proto
externdef SDL_GetWindowGammaRamp :proto
SDL_HitTestResult typedef DWORD
SDL_HITTEST_NORMAL = 0
SDL_HITTEST_DRAGGABLE = 1
SDL_HITTEST_RESIZE_TOPLEFT = 2
SDL_HITTEST_RESIZE_TOP = 3
SDL_HITTEST_RESIZE_TOPRIGHT = 4
SDL_HITTEST_RESIZE_RIGHT = 5
SDL_HITTEST_RESIZE_BOTTOMRIGHT = 6
SDL_HITTEST_RESIZE_BOTTOM = 7
SDL_HITTEST_RESIZE_BOTTOMLEFT = 8
SDL_HITTEST_RESIZE_LEFT = 9

externdef SDL_SetWindowHitTest :proto
externdef SDL_DestroyWindow :proto
externdef SDL_IsScreenSaverEnabled :proto  
externdef SDL_EnableScreenSaver :proto  
externdef SDL_DisableScreenSaver :proto  
externdef SDL_GL_LoadLibrary :proto
externdef SDL_GL_GetProcAddress :proto
externdef SDL_GL_UnloadLibrary :proto  
externdef SDL_GL_ExtensionSupported :proto
externdef SDL_GL_ResetAttributes :proto  
externdef SDL_GL_SetAttribute :proto
externdef SDL_GL_GetAttribute :proto
externdef SDL_GL_CreateContext :proto
externdef SDL_GL_MakeCurrent :proto
externdef SDL_GL_GetCurrentWindow :proto  
externdef SDL_GL_GetCurrentContext :proto  
externdef SDL_GL_GetDrawableSize :proto
externdef SDL_GL_SetSwapInterval :proto
externdef SDL_GL_GetSwapInterval :proto  
externdef SDL_GL_SwapWindow :proto
externdef SDL_GL_DeleteContext :proto

endif 

;--- errors: 0
;--- end of file ---
