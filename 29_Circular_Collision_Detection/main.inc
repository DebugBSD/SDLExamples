EXIT_SUCCESS = 0
EXIT_FAILURE = -1

GENERIC_READ	= 080000000h
GENERIC_WRITE	= 040000000h

STD_INPUT_HANDLE = -10
STD_OUTPUT_HANDLE = -11
STD_ERROR_HANDLE = -12

WriteConsole TEXTEQU <WriteConsoleA>

GetStdHandle PROTO nStdHandle:DWORD

ExitProcess PROTO exitValue:DWORD

WriteConsoleA PROTO hConsoleOutput:DWORD, lpBuffer:DWORD, nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:DWORD, lpReserver:DWORD

TestFunction PROTO dwArg1:DWORD,dwArg2:DWORD,dwArg3:DWORD,dwArg4:DWORD

TestFunction2 PROTO
