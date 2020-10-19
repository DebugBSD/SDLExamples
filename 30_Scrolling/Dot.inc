
; Dimensions of the dot
DOT_HEIGHT = 20
DOT_WIDTH = 20

; Maximum axis velocity of the dot
DOT_VEL = 10

Circle struct
	x DWORD ?
	y DWORD ?
	r DWORD ?
Circle ends

; The Dot will move around on the screen
Dot struct
	; The X and Y offsets of the dot.
	m_PosX DWORD ?
	m_PosY DWORD ?
	
	; The velocity of the dot
	m_VelX DWORD ?
	m_VelY DWORD ?
	
Dot ends