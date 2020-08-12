@echo off
set arg=%1

findstr /R /I /N /C:"%arg%"
