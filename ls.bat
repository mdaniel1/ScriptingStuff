@echo off

set arg=%1
set arg2=%2

if [%arg%] == [] (
	dir /b
) else if "%arg%" == "-l" (
	if [%arg2%] == [] (
		dir
	) else (
		dir %arg2%
	)
) else (
	dir /b %arg%
)