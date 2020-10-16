
ifndef LButton_INC_
LButton_INC_ EQU <>

BUTTON_WIDTH = 300
BUTTON_HEIGHT = 200
TOTAL_BUTTONS = 4

LButtonSprite TYPEDEF DWORD
BUTTON_SPRITE_MOUSE_OUT = 0
BUTTON_SPRITE_MOUSE_OVER_MOTION = 1
BUTTON_SPRITE_MOUSE_DOWN = 2
BUTTON_SPRITE_MOUSE_UP = 3
BUTTON_SPRITE_TOTAL = 4

LButton struct
	m_Position 		SDL_Point 		<>		; 8 Bytes
	m_Spare			DWORD 			?		; 4 bytes
	m_CurrentSprite LButtonSprite 	?		; 4 Bytes
LButton ends

endif 
