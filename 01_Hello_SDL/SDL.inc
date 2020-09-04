
SDL_INIT_VIDEO = 000000020h

SDL_WINDOWPOS_UNDEFINED = 01FFF0000h
SDL_WINDOW_SHOWN = 4

SDL_Rect STRUC
	x DWORD ?
	y DWORD ?
	w DWORD ?
	h DWORD ?
SDL_Rect ends

SDL_Surface STRUC
	flags 		DWORD ?
	format 		QWORD ?
	x 			DWORD ?
	y 			DWORD ?
	pitch 		DWORD ?
	pixels 		QWORD ?
	userdata 	QWORD ?
	locked 		DWORD ?
	lock_data 	QWORD ?
	clip_rect 	SDL_Rect<>
	map 		QWORD ?
	refcount 	DWORD ?
SDL_Surface ends

externdef SDL_Init:PROTO
externdef SDL_Quit:PROTO

externdef SDL_CreateWindow:PROTO
externdef SDL_DestroyWindow:PROTO
externdef SDL_GetWindowSurface:PROTO
externdef SDL_FillRect:PROTO
externdef SDL_UpdateWindowSurface:PROTO
externdef SDL_Delay:PROTO
externdef SDL_MapRGB:PROTO