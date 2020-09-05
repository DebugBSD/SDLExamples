
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
;extern DECLSPEC void SDLCALL SDL_FreeSurface(SDL_Surface * surface);
externdef SDL_FreeSurface:PROTO
externdef SDL_FillRect:PROTO
externdef SDL_UpdateWindowSurface:PROTO
externdef SDL_Delay:PROTO
externdef SDL_MapRGB:PROTO
externdef SDL_LoadBMP_RW:PROTO

; extern DECLSPEC SDL_RWops *SDLCALL SDL_RWFromFile(const char *file,const char *mode);
externdef SDL_RWFromFile:PROTO

; extern DECLSPEC int SDLCALL SDL_UpperBlit(SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect);
externdef SDL_UpperBlit:PROTO
SDL_BlitSurface TEXTEQU<SDL_UpperBlit>
