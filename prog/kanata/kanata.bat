@echo off

:: BatchGotAdmin
:-------------------------------------
REM --> Set up logging with fixed path
set logfile=C:\Users\91949\kanata\kanata.log

REM --> Create VBS script to run kanata hidden
echo CreateObject("WScript.Shell").Run "C:\Users\91949\kanata\kanata.exe -c C:\Users\91949\kanata\kanata.kbd --port 9000", 0, false > "%temp%\runkanata.vbs"

REM --> Redirect all output to log file
(
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 0 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
wscript.exe "%temp%\runkanata.vbs" > "%logfile%" 2>&1
del "%temp%\runkanata.vbs"
) > "%logfile%" 2>&1
