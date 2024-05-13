@echo off
goto :main

:log
	>>"killServer.log" echo [%date%] [%time%] %~1
	exit /b 0

:main
	set serverName=%1
	call :log "Killing %serverName%"

	taskkill /f /fi "WINDOWTITLE eq %serverName%"
	rmdir /S /Q "%USERPROFILE%\Minecraft\Servers\%serverName%" > nul

	call :log "Killed %serverName%"
	echo Success
	exit
