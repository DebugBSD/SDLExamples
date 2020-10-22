include Particle.inc

.code
; Constructor
Particle_ctor proc uses rax rbx rsi, pParticle:PTR Particle, x:DWORD, y:DWORD
	
	mov rsi, pParticle
	mGetRandom 25
	add rdx, 5
	mov ebx, x
	sub rbx, rdx
	mov (Particle PTR [rsi]).m_PosX, ebx
	
	mGetRandom 25
	add rdx, 5
	mov ebx, y
	sub rbx, rdx
	mov (Particle PTR [rsi]).m_PosY, ebx
	
	mGetRandom 5
	mov (Particle PTR [rsi]).m_Frame, edx
	
	mGetRandom 3
	.if rdx==0
		mov rax, offset gRedTexture
		mov (Particle PTR [rsi]).m_pTexture, rax
	.elseif rdx==1
		mov rax, offset gGreenTexture
		mov (Particle PTR [rsi]).m_pTexture, rax
	.elseif rdx==2
		mov rax, offset gBlueTexture
		mov (Particle PTR [rsi]).m_pTexture, rax
	.endif
	
	ret
Particle_ctor endp

; Destructor
Particle_dtor proc uses rsi, pParticle:PTR Particle
	
	ret
Particle_dtor endp

Particle_render proc uses rax rsi, pParticle:PTR Particle
	
	mov rsi, pParticle
	invoke renderTexture, gRenderer, (Particle PTR [rsi]).m_pTexture, (Particle PTR [rsi]).m_PosX, (Particle PTR [rsi]).m_PosY, 0, 0, 0, 0
	
	mov eax, (Particle PTR [rsi]).m_Frame
	and rax, 1
	.if rax==0
		invoke renderTexture, gRenderer, addr gShimmerTexture, (Particle PTR [rsi]).m_PosX, (Particle PTR [rsi]).m_PosY, 0, 0, 0, 0
	.endif
	
	inc (Particle PTR [rsi]).m_Frame
	
	ret
Particle_render endp

Particle_isDead proc uses rsi, pParticle:PTR Particle
	
	xor rax, rax
	mov rsi, pParticle
	
	.if (Particle PTR [rsi]).m_Frame > 10
		mov rax, 1
	.endif
	ret
Particle_isDead endp