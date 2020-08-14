@echo off
setlocal

set /a r=0
set /a f=0
set /a rf=0
set /a fr=0
set pathtofile=""

REM loops through all the arguments
for %%a in (%*) do (
    REM echo DEBUG : arg is %%a%
    if "%%a%" == "-r" ( 
        REM echo DEBUG : -r detected
        set /a r=1
    ) else if "%%a%" == "-rf" ( 
        REM echo DEBUG : -rf detected
        set /a rf=1
    ) else if "%%a%" == "-f" ( 
        REM echo DEBUG : -f detected
        set /a f=1
    ) else if "%%a%" == "-fr" (
        REM echo DEBUG : -fr detected
        set /a fr=1
    ) else ( 
        set pathtofile=%%a%
    )
)

if %r%==1 (
    if %f%==1 (
        set rf=1 
        set r=0 
        set f=0
    )
)

if %fr%==1 (
    set rf=1 
    set fr=0
)

if %rf%==1 goto force_delete_dir
if %r%==1 goto delete_dir
if %f%==1 goto force_delete_file
goto delete_file

:delete_dir
REM echo DEBUG : reached delete_dir
rmdir %pathtofile%
goto end

:force_delete_dir
REM echo DEBUG : reached force_delete_dir
rmdir /S /Q %pathtofile%
goto end

:delete_file
REM echo DEBUG : reached delete_file
call :check_if_dir %pathtofile% result
if "%result%" == "NOK" goto end
del /P %pathtofile%
goto end

:force_delete_file
REM echo DEBUG : reached force_delete_file
call :check_if_dir %pathtofile% result
if "%result%" == "NOK" goto end
del /F /Q %pathtofile%
goto end

:check_if_dir
if exist %1\* (
    echo Error : use -r when deleting a directory
    set %2=NOK
)

:end
endlocal
