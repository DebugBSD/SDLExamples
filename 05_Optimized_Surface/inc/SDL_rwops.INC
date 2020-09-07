;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_rwops.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_rwops.h

ifndef SDL_rwops_h_
SDL_rwops_h_	EQU	<>
;	include SDL_stdinc.inc
;	include SDL_error.inc
;	include begin_code.inc
SDL_RWOPS_UNKNOWN	EQU	0
SDL_RWOPS_WINFILE	EQU	1
SDL_RWOPS_STDFILE	EQU	2
SDL_RWOPS_JNIFILE	EQU	3
SDL_RWOPS_MEMORY	EQU	4
SDL_RWOPS_MEMORY_RO	EQU	5

;SDL_RWops	struct 
;	size				QWORD 	?
;	seek				QWORD 	?
;	read				QWORD 	?
;	write				QWORD 	?
;	close				QWORD	?
;	type_				DWORD	?
;union hidden
;ifndef defined
;defined macro x
;ifdef x
;  exitm <1>
;else
;  exitm <0>
;endif
;endm
;endif
;struct windowsio
;	append	SDL_bool	?
;	h		QWORD		?
;	struct buffer
;		data	DWORD	?
;		size_	size_t	?
;		left	size_t	?
;	ends
;ends
;struct mem
;base	DWORD	?
;here	DWORD	?
;stop	DWORD	?
;ends
;struct unknown
;data1	DWORD	?
;data2	DWORD	?
;ends
;ends
;SDL_RWops	ends

externdef SDL_RWFromFile :proto
externdef SDL_RWFromFP :proto
externdef SDL_RWFromMem :proto
externdef SDL_RWFromConstMem :proto
externdef SDL_AllocRW :proto  
externdef SDL_FreeRW :proto
RW_SEEK_SET	EQU	0
RW_SEEK_CUR	EQU	1
RW_SEEK_END	EQU	2
externdef SDL_RWsize :proto
externdef SDL_RWseek :proto
externdef SDL_RWtell :proto
externdef SDL_RWread :proto
externdef SDL_RWwrite :proto
externdef SDL_RWclose :proto
externdef SDL_LoadFile_RW :proto
externdef SDL_LoadFile :proto
externdef SDL_ReadU8 :proto
externdef SDL_ReadLE16 :proto
externdef SDL_ReadBE16 :proto
externdef SDL_ReadLE32 :proto
externdef SDL_ReadBE32 :proto
externdef SDL_ReadLE64 :proto
externdef SDL_ReadBE64 :proto
externdef SDL_WriteU8 :proto
externdef SDL_WriteLE16 :proto
externdef SDL_WriteBE16 :proto
externdef SDL_WriteLE32 :proto
externdef SDL_WriteBE32 :proto
externdef SDL_WriteLE64 :proto
externdef SDL_WriteBE64 :proto
endif 

;--- errors: 0
;--- end of file ---
