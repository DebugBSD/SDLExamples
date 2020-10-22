
ifndef LWindow_INC_
LWindow_INC_ EQU <>

LWindow struct
	; Window data
	m_pWindow			QWORD ? ; Pointer to SDL_Window
	
	; Window dimensions
	m_Width				DWORD ?
	m_Height 			DWORD ?
	
	; Window focus
	m_MouseFocus 		BYTE ?
	m_KeyboardFocus 	BYTE ?
	m_FullScreen		BYTE ?
	m_Minimized			BYTE ?
LWindow ends

endif 
