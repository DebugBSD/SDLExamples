
include LTexture.inc
include SDL.inc
include SDL_pixels.INC

.const 

.data?

.data

.code

initTexture proc uses rdi, pTexture:QWORD
	
	mov rdi, pTexture
	mov (LTexture PTR[rdi]).m_Texture, 0
	mov (LTexture PTR[rdi]).m_Width, 0
	mov (LTexture PTR[rdi]).m_Height, 0
		
	ret
initTexture endp

freeTexture proc uses rdi, pTexture:QWORD
	mov rdi, pTexture
	.if (LTexture PTR[rdi]).m_Texture!=0
		invoke SDL_DestroyTexture, (LTexture PTR[rdi]).m_Texture
		mov (LTexture PTR[rdi]).m_Texture, 0
		mov (LTexture PTR[rdi]).m_Width, 0
		mov (LTexture PTR[rdi]).m_Height, 0
	.endif
	ret
freeTexture endp

; -----------------------------------------------------------------------------
;
; Brief:
;	- This function draw a texture or portion of it.
;
; Input:
;	- gRenderer: Pointer to the renderer
; 	- pTexture: Pointer to the LTexture data structure
;	- x: X position
;	- y: Y position
;	- clip: Pointer to the portion of the texture to show.
;
; Output:
;	- N/A
;
renderTexture proc uses rsi rax rbx rcx rdx, 
	gRenderer:QWORD, 
	pTexture:QWORD, 
	x:DWORD, 
	y:DWORD, 
	clip:QWORD,
	angle:REAL8,
	center:QWORD,
	flip:SDL_RendererFlip
	
	LOCAL renderQuad:SDL_Rect
	
	mov rsi, pTexture
	mov eax, x
	mov ebx, y
	mov ecx, (LTexture PTR[rsi]).m_Width
	mov edx, (LTexture PTR[rsi]).m_Height
	mov renderQuad.x, eax
	mov renderQuad.y, ebx
	mov renderQuad.w, ecx
	mov renderQuad.h, edx
	
	mov rbx, (LTexture PTR [rsi]).m_Texture
	
	.if clip!=0
		mov rsi, clip
		mov ecx, (SDL_Rect PTR[rsi]).w
		mov edx, (SDL_Rect PTR[rsi]).h
		mov renderQuad.w, ecx
		mov renderQuad.h, edx
	.endif
	
    invoke SDL_RenderCopyEx, gRenderer, rbx, clip, addr renderQuad, angle, center, flip
   	ret
renderTexture endp

loadTextureFromFile proc uses rsi rbx, gRenderer:QWORD, pTexture:QWORD, pathToTexture:QWORD
	LOCAL bSuccess:BYTE
	LOCAL loadedSurface:QWORD
	LOCAL newTexture:QWORD
	
	mov bSuccess, 1
	mov newTexture, 0
	
	mov rsi, pTexture
	
	; First we should clean existing texture from pTexture data structure
	invoke freeTexture, pTexture
	
	invoke IMG_Load, pathToTexture
	.if rax==0
		mov bSuccess, 0
		jmp ERROR
	.endif
	
	mov loadedSurface, rax
	invoke SDL_MapRGB, (SDL_Surface PTR [rax]).format,0,0FFh, 0FFh
	invoke SDL_SetColorKey, loadedSurface, 1, eax
	
	; Create texture from surface pixels
	invoke SDL_CreateTextureFromSurface, gRenderer, loadedSurface
	.if rax==0
		mov bSuccess, 0
		jmp ERROR
	.endif
	mov newTexture, rax
	
	; Get image dimensions
	mov rsi, loadedSurface
	mov eax, (SDL_Surface PTR [rsi]).w
	mov ebx, (SDL_Surface PTR [rsi]).h
	
	mov rsi, pTexture
	mov (LTexture PTR[rsi]).m_Width, eax
	mov (LTexture PTR[rsi]).m_Height, ebx
	
	; Set texture
	mov rax, newTexture
	mov (LTexture PTR[rsi]).m_Texture,rax
	 
	; Delete old loaded surface
	invoke SDL_FreeSurface, loadedSurface
	
ERROR:
	mov al, bSuccess
	ret
loadTextureFromFile endp

setTextureColor proc pTexture:QWORD, red:BYTE, green:BYTE, blue:BYTE
	mov rsi, pTexture
	mov rbx, (LTexture PTR [rsi]).m_Texture
	
	invoke SDL_SetTextureColorMod, rbx, red, green, blue
	
	ret
setTextureColor endp

setTextureBlendMode proc pTexture:QWORD, blendingMode:SDL_BlendMode
	
	mov rsi, pTexture
	mov rbx, (LTexture PTR [rsi]).m_Texture
	mov edx, blendingMode
	invoke SDL_SetTextureBlendMode, rbx, edx
	ret
setTextureBlendMode endp

setTextureAlphaBlend proc pTexture:QWORD, alpha:BYTE
	
	mov rsi, pTexture
	mov rbx, (LTexture PTR [rsi]).m_Texture
	mov dl, alpha
	
	invoke SDL_SetTextureAlphaMod, rbx, dl
	ret
setTextureAlphaBlend endp