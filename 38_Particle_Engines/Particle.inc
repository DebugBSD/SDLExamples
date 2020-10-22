
ifndef Particle_INC_
Particle_INC_ EQU <>

TOTAL_PARTICLES = 20

Particle struct
	m_PosX		DWORD ? ; Offset Y
	m_PosY		DWORD ? ; Offset Y
	m_Frame 	DWORD ? ; Current frame of animation
	m_pTexture	QWORD ? ; Type of particle. This member is a pointer to LTexture. 
Particle ends

endif 
