
ifndef LTimer_INC_
LTimer_INC_ EQU <>

LTimer struct
	m_StartTicks	Uint32 ?
	m_PausedTicks 	Uint32 ?
	m_Paused		BYTE ?
	m_Started		BYTE ?
LTimer ends

endif 
