;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: C:\Users\debugg\My Projects\Librerias\SDL2-devel-2.0.12-VC\include\SDL_error.h, last modified: 3/11/2020 3:39
;--- cmdline used for creation:  SDL_error.h

ifndef SDL_error_h_
SDL_error_h_	EQU	<>

externdef SDL_SetError:proto
externdef SDL_GetError:proto  
externdef SDL_ClearError:proto  

SDL_OutOfMemory macro 
	exitm <SDL_Error ( SDL_ENOMEM ) >
	endm
	
SDL_Unsupported macro 
	exitm <SDL_Error ( SDL_UNSUPPORTED ) >
	endm
	
SDL_InvalidParamError macro param
	exitm <SDL_SetError ( "Parameter '%s' is invalid" , ( param ) ) >
	endm
	
SDL_errorcode typedef DWORD
SDL_ENOMEM = 0
SDL_EFREAD = 1
SDL_EFWRITE = 2
SDL_EFSEEK = 3
SDL_UNSUPPORTED = 4
SDL_LASTERROR = 5

externdef SDL_Error:proto
endif 

;--- errors: 0
;--- end of file ---
