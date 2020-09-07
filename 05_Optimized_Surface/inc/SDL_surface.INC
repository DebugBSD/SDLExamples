;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_surface.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_surface.h

ifndef SDL_surface_h_
SDL_surface_h_	EQU	<>
;include SDL_pixels.inc
include SDL_rect.inc
include SDL_blendmode.inc
include SDL_rwops.inc


SDL_SWSURFACE		EQU	0
SDL_PREALLOC		EQU	00000001h
SDL_RLEACCEL		EQU	00000002h
SDL_DONTFREE		EQU	00000004h
SDL_SIMD_ALIGNED	EQU	00000008h

SDL_MUSTLOCK macro S
;	exitm <( ( ( S ) -> flags  and  SDL_RLEACCEL ) != 0 ) >
	endm
	
SDL_Surface STRUC
	spare0		DWORD ?
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

SDL_YUV_CONVERSION_MODE typedef DWORD
SDL_YUV_CONVERSION_JPEG = 0
SDL_YUV_CONVERSION_BT601 = 1
SDL_YUV_CONVERSION_BT709 = 2
SDL_YUV_CONVERSION_AUTOMATIC = 3

externdef SDL_CreateRGBSurface :proto
externdef SDL_CreateRGBSurfaceWithFormat :proto
externdef SDL_CreateRGBSurfaceFrom :proto
externdef SDL_CreateRGBSurfaceWithFormatFrom :proto
externdef SDL_FreeSurface :proto
externdef SDL_SetSurfacePalette :proto
externdef SDL_LockSurface :proto
externdef SDL_UnlockSurface :proto
externdef SDL_LoadBMP_RW :proto

SDL_LoadBMP macro file
	exitm <SDL_LoadBMP_RW ( SDL_RWFromFile ( file , "rb" ) , 1 ) >
	endm
externdef SDL_SaveBMP_RW :proto
SDL_SaveBMP macro surface,file
	exitm <SDL_SaveBMP_RW ( surface , SDL_RWFromFile ( file , "wb" ) , 1 ) >
	endm
	
externdef SDL_SetSurfaceRLE :proto
externdef SDL_SetColorKey :proto
externdef SDL_HasColorKey :proto
externdef SDL_GetColorKey :proto
externdef SDL_SetSurfaceColorMod :proto
externdef SDL_GetSurfaceColorMod :proto
externdef SDL_SetSurfaceAlphaMod :proto
externdef SDL_GetSurfaceAlphaMod :proto
externdef SDL_SetSurfaceBlendMode :proto
externdef SDL_GetSurfaceBlendMode :proto
externdef SDL_SetClipRect :proto
externdef SDL_GetClipRect :proto
externdef SDL_DuplicateSurface :proto
externdef SDL_ConvertSurface :proto
externdef SDL_ConvertSurfaceFormat :proto
externdef SDL_ConvertPixels :proto
externdef SDL_FillRect :proto
externdef SDL_FillRects :proto
SDL_BlitSurface EQU	<SDL_UpperBlit>
externdef SDL_UpperBlit :proto
externdef SDL_LowerBlit :proto
externdef SDL_SoftStretch :proto
SDL_BlitScaled	EQU	<SDL_UpperBlitScaled>
externdef SDL_UpperBlitScaled :proto
externdef SDL_LowerBlitScaled :proto
externdef SDL_SetYUVConversionMode :proto
externdef SDL_GetYUVConversionMode :proto  
externdef SDL_GetYUVConversionModeForResolution :proto

endif 

;--- errors: 0
;--- end of file ---
