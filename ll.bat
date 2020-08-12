@echo off

set arg=%1

if [%arg%] == [] (
	dir
) else (
	dir %arg%
)