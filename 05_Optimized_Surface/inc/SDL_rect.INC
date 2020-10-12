;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_rect.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_rect.h

ifndef SDL_rect_h_
SDL_rect_h_	EQU	<>
;	include SDL_stdinc.inc
	include SDL_error.inc
;	include SDL_pixels.inc
	include SDL_rwops.inc
	
SDL_Point	struct 
x	DWORD	?
y	DWORD	?
SDL_Point	ends

SDL_FPoint	struct 
x	REAL4	?
y	REAL4	?
SDL_FPoint	ends

SDL_Rect	struct 
x	DWORD	?
y	DWORD	?
w	DWORD	?
h	DWORD	?
SDL_Rect	ends

SDL_FRect	struct 
x	REAL4	?
y	REAL4	?
w	REAL4	?
h	REAL4	?
SDL_FRect	ends

;SDL_PointInRect proto
;;{
;return proto  :-> :ptr -> :ptr -> :ptr ->
;;}
;SDL_RectEmpty proto  :ptr SDL_Rect
;;{
;return proto  :! :<= :<=
;;}
;SDL_RectEquals proto  :ptr SDL_Rect, :ptr SDL_Rect
;;{
;return proto  :ptr ptr -> :ptr -> :ptr -> :ptr ->
;;}
SDL_HasIntersection proto  :ptr SDL_Rect, :ptr SDL_Rect
SDL_IntersectRect proto  :ptr SDL_Rect, :ptr SDL_Rect, :ptr SDL_Rect
SDL_UnionRect proto  :ptr SDL_Rect, :ptr SDL_Rect, :ptr SDL_Rect
SDL_EnclosePoints proto  :ptr SDL_Point, :DWORD, :ptr SDL_Rect, :ptr SDL_Rect
SDL_IntersectRectAndLine proto  :ptr SDL_Rect, :ptr DWORD, :ptr DWORD, :ptr DWORD, :ptr DWORD

endif 

;--- errors: 0
;--- end of file ---
